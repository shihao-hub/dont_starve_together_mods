---
--- @author zsh in 2023/4/21 9:33
---

local config_data = TUNING.MONE_TUNING.GET_MOD_CONFIG_DATA;

-- PS: 此处我将尝试换一种、几种改动预制物的方法，主要目的是让每类预制物都指向同一个函数。
---- 1. 可能会被其他模组通过 package.loaded["xxx"] = nil; 然后再 require("xxx"); 的方式导致失效。
---- 2. 我去这样不太对，还得是用 AddComponent 这种方式吧？不然很容易覆盖其他模组内容啊？
------ emm，这感觉太麻烦了，没必要吧？何必呢，为了稍微优化一下麻烦我自己呢？

-- 虽然指向了同一个函数，但是为什么我觉得有可能会覆盖掉其他模组的内容呢？
if config_data.willow_firestaff then
    local function CalcDamage(attacker, damage, target, weapon)
        local old_damage = damage < 0 and 0 or damage;

        local self = attacker.components.combat;
        local targ = target or self.target;
        local weapon = weapon or self:GetWeapon();

        if targ.components.combat == nil then
            return old_damage;
        end

        local stimuli;
        if stimuli == nil then
            if weapon ~= nil and weapon.components.weapon ~= nil and weapon.components.weapon.overridestimulifn ~= nil then
                stimuli = weapon.components.weapon.overridestimulifn(weapon, self.inst, targ)
            end
            if stimuli == nil and self.inst.components.electricattacks ~= nil then
                stimuli = "electric"
            end
        end

        local multiplier = (stimuli == "electric" or (weapon ~= nil and weapon.components.weapon ~= nil and weapon.components.weapon.stimuli == "electric"))
                and not (targ:HasTag("electricdamageimmune")
                or (targ.components.inventory ~= nil and targ.components.inventory:IsInsulated()))
                and TUNING.ELECTRIC_DAMAGE_MULT + TUNING.ELECTRIC_WET_DAMAGE_MULT * (targ.components.moisture ~= nil and targ.components.moisture:GetMoisturePercent()
                or (targ:GetIsWet() and 1 or 0))
                or 1;

        local old_GetDamage = weapon.components.weapon.GetDamage;
        function weapon.components.weapon:GetDamage(...)
            return old_damage;
        end
        damage = self:CalcDamage(targ, weapon, multiplier);
        weapon.components.weapon.GetDamage = old_GetDamage;

        return damage < 0 and old_damage or damage;
    end
    -- 薇洛使用火魔杖有伤害：目前看来其实没什么大用
    local weapon = require("components/weapon");
    if weapon then
        local old_OnAttack = weapon.OnAttack;
        if old_OnAttack then
            function weapon:OnAttack(attacker, target, projectile, ...)
                if attacker and attacker.prefab == "willow" and self.inst.prefab == "firestaff" then
                    if target.components.combat then
                        -- 我无法确定此处函数的稳定性，故此处的伤害暂时固定起来吧，不要动态计算了。
                        ---- 毕竟，此处对于人物的修改只是我的模组的附带功能，因此能稳定尽量稳定！
                        ------ 提示：我为什么不从修改武器的伤害下手呢？
                        -------- 被装备的时候设置伤害，卸载的时候取消伤害。再补充点相关判定和优化相应内容差不多就行了吧。
                        --local damage = CalcDamage(attacker, 25, target, self.inst);
                        local damage = 25;
                        target.components.combat:GetAttacked(attacker, damage, self.inst, "fire");
                    end
                end
                if old_OnAttack then
                    return old_OnAttack(self, attacker, target, projectile, ...);
                end
            end
        end
    end

    -- 薇洛使用火魔杖消耗的耐久更少
    local finiteuses = require("components/finiteuses");
    if finiteuses then
        local old_Use = finiteuses.Use;
        if old_Use then
            function finiteuses:Use(num, ...)
                if self.inst and self.inst.prefab == "firestaff" then
                    local inventoryitem = self.inst.components.inventoryitem;
                    -- 这里怎么说呢，按道理没啥问题，因为正常情况火魔杖是攻击的时候才消耗耐久。
                    local owner = inventoryitem and inventoryitem:GetGrandOwner();
                    if owner and owner.prefab == "willow" then
                        num = num / 5;
                    end
                end
                if old_Use then
                    return old_Use(self, num, ...);
                end
            end
        end
    end
end

if config_data.willow_sewing_kit then
    env.AddPrefabPostInit("sewing_kit", function(inst)
        if not TheWorld.ismastersim then
            return inst;
        end
        if null(inst.components.finiteuses) then
            return inst;
        end
        HookComponentSimulated("finiteuses", inst, function(self, inst)
            local old_Use = self.Use;
            function self:Use(num, ...)
                if self.inst and self.inst.prefab == "sewing_kit" then
                    local inventoryitem = self.inst.components.inventoryitem;
                    local owner = inventoryitem and inventoryitem:GetGrandOwner();
                    if owner and owner.prefab == "willow" then
                        num = 0;
                    end
                end
                if old_Use then
                    return old_Use(self, num, ...);
                end
            end
        end)
    end)
end

if config_data.willow_lighter then
    env.AddPrefabPostInit("lighter", function(inst)
        if not TheWorld.ismastersim then
            return inst;
        end

        -- 烹饪食物的时候不消耗耐久
        if inst.components.cooker then
            local old_oncookfn = inst.components.cooker.oncookfn;
            inst.components.cooker.oncookfn = function(inst, product, chef, ...)
                if chef.prefab == "willow" then
                    -- DoNothing
                else
                    if old_oncookfn ~= nil then
                        old_oncookfn(inst, product, chef, ...)
                    end
                end
            end
        end

        -- 不消耗耐久：是否需要通过 onputininventory 事件实现 隐藏标签+回复耐久呢？
        if inst.components.equippable then
            local old_onequipfn = inst.components.equippable.onequipfn;
            inst.components.equippable.onequipfn = function(inst, owner, ...)
                if old_onequipfn ~= nil then
                    old_onequipfn(inst, owner, ...);
                end
                if inst.components.fueled and owner.prefab == "willow" then
                    inst.components.fueled:StopConsuming();
                end
            end
        end

        --inst:ListenForEvent("onputininventory", function(inst, data)
        --    local owner = data;
        --    if not isTab(owner) then
        --        return;
        --    end
        --    if owner:HasTag("player") then
        --
        --    end
        --end)
    end)

    -- 薇洛使用打火机时发光范围增大：2023-04-21：没必要...真的，首先是没感觉了，其次是边缘模糊导致范围感觉很不舒服。
    --for _, name in ipairs({ "lighterfire", "lighterfire_haunteddoll" }) do
    --    env.AddPrefabPostInit(name, function(inst)
    --        inst:DoTaskInTime(0, function(inst)
    --            local parent = inst.entity:GetParent();
    --            if parent and parent.prefab == "willow" then
    --                if inst._light and inst._light.Light then
    --                    inst._light.Light:SetRadius(4);
    --                end
    --            end
    --        end)
    --    end)
    --end
end