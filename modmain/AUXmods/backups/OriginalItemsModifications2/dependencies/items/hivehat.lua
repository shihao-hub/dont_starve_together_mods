---
--- @author zsh in 2023/4/25 0:01
---

local API = require("chang_mone.dsts.API");

local function hivehat()
    local Debug = API.Debug;
    local inner_fns = {};

    -- 收获蜂箱里的蜂蜜不出杀人蜂
    local function beeboxs()
        return function(inst)
            if not TheWorld.ismastersim then
                return inst;
            end
            if inst.components.harvestable == nil or inst.components.childspawner == nil then
                return inst;
            end

            --local old_onharvestfn = inst.components.harvestable.onharvestfn;
            --local old_ongrowfn = inst.components.harvestable.ongrowfn;
            --local updatelevel = Debug.GetUpvalueFn(old_onharvestfn, "updatelevel");
            --if old_ongrowfn == updatelevel then
            --    print("old_ongrowfn == updatelevel"); -- yes!
            --else
            --    print("old_ongrowfn ~= updatelevel");
            --end

            -- 这种 :ReleaseAllChildren 应该直接改组件！
            local old_ReleaseAllChildren = inst.components.childspawner.ReleaseAllChildren;
            function inst.components.childspawner:ReleaseAllChildren(target, prefab, radius, ...)
                if target and target:IsValid() and target:HasTag("mone_hivehat") then
                    return ;
                end
                if old_ReleaseAllChildren then
                    return old_ReleaseAllChildren(self, target, prefab, radius, ...);
                end
            end
        end
    end

    -- 靠近杀人蜂巢不出杀人蜂：为什么不执行啊？...因为 playerprox 写成 playerpro 了 ...
    local function wasphive()
        return function(inst)
            if not TheWorld.ismastersim then
                return inst;
            end
            if inst.components.playerprox == nil then
                return inst;
            end
            local old_onnear = inst.components.playerprox.onnear;
            inst.components.playerprox.onnear = function(inst, target, ...)
                if target and target:IsValid() and target:HasTag("mone_hivehat") then
                    return ;
                end
                if old_onnear then
                    return old_onnear(inst, target, ...);
                end
            end
        end
    end

    -- 普通蜂巢佩戴蜂王冠后可以采集蜂蜜：由于我的模组优先级最低，因此一般应该都能够提前判断出来然后让他不生效
    local function beehive()
        local levels = {
            { amount = 6, idle = "honey3", hit = "hit_honey3" },
            { amount = 3, idle = "honey2", hit = "hit_honey2" },
            { amount = 1, idle = "honey1", hit = "hit_honey1" },
            { amount = 0, idle = "bees_loop", hit = "hit_idle" },
        }

        local function setlevel(inst, level)
            if not inst:HasTag("burnt") then
                if inst.anims == nil then
                    inst.anims = { idle = level.idle, hit = level.hit }
                else
                    inst.anims.idle = level.idle
                    inst.anims.hit = level.hit
                end
                inst.AnimState:PlayAnimation(inst.anims.idle)
            end
        end

        local function updatelevel(inst)
            if not inst:HasTag("burnt") then
                for k, v in pairs(levels) do
                    if inst.components.harvestable.produce >= v.amount then
                        setlevel(inst, v)
                        break
                    end
                end
            end
        end

        local function onharvest(inst, picker, produce)
            --print(inst, "onharvest")
            if not inst:HasTag("burnt") then
                if inst.components.harvestable then
                    inst.components.harvestable:SetGrowTime(nil)
                    inst.components.harvestable.pausetime = nil
                    inst.components.harvestable:StopGrowing()
                end
                if produce == levels[1].amount then
                    AwardPlayerAchievement("honey_harvester", picker)
                end
                updatelevel(inst)
                if inst.components.childspawner ~= nil and not TheWorld.state.iswinter then
                    inst.components.childspawner:ReleaseAllChildren(picker)
                end
            end
        end

        local function onchildgoinghome(inst, data)
            if not inst:HasTag("burnt") and
                    data.child ~= nil and
                    data.child.components.pollinator ~= nil and
                    data.child.components.pollinator:HasCollectedEnough() and
                    inst.components.harvestable ~= nil then
                inst.components.harvestable:Grow()
            end
        end
        return function(inst)
            if not TheWorld.ismastersim then
                return inst;
            end
            if inst.components.harvestable then
                return inst;
            end
            inst:AddComponent("harvestable")
            inst.components.harvestable:SetUp("honey", 4, nil, onharvest, updatelevel)
            inst:ListenForEvent("childgoinghome", onchildgoinghome)

            local harvestable = inst.components.harvestable;
            -- 补充一下：其他人不能采集
            local old_Harvest = harvestable.Harvest;
            function harvestable:Harvest(picker, ...)
                self.enabled = false;
                if picker:HasTag("mone_hivehat") then
                    self.enabled = true;
                end
                if old_Harvest then
                    return old_Harvest(self, picker, ...);
                end
            end
        end
    end

    -- 换一种方式实现：靠近杀人蜂巢不生成杀人蜂？不对，这样导致压根不出现杀人蜂了。
    --local childspawner = require("components/childspawner");
    --if childspawner then
    --    local old_ReleaseAllChildren = childspawner.ReleaseAllChildren;
    --    if old_ReleaseAllChildren then
    --        function childspawner:ReleaseAllChildren(target, prefab, radius, ...)
    --            if target and target:IsValid() and target:HasTag("mone_hivehat")
    --                    and prefab == "killerbeen" then
    --                return ;
    --            end
    --            if old_ReleaseAllChildren then
    --                return old_ReleaseAllChildren(self, target, prefab, radius, ...);
    --            end
    --        end
    --    end
    --end

    env.AddPrefabPostInitAny(function(inst)
        if inst.prefab == "beebox" or inst.prefab == "beebox_hermit" then
            beeboxs()(inst);
        elseif inst.prefab == "wasphive" then
            wasphive()(inst);
        elseif inst.prefab == "beehive" then
            --beehive()(inst); -- 未完成品：而且目前看来该功能应该要舍弃了。
        else
            -- ? 能力勋章的蜂箱？
        end
    end)

    -- 蜜蜂/杀人蜂永远都不会对你有仇恨：其实这种写法并没有从根本上解决问题
    for _, name in ipairs({ "bee", "killerbee" }) do
        env.AddPrefabPostInit(name, function(inst)
            if not TheWorld.ismastersim then
                return inst;
            end
            if inst.components.combat == nil then
                return inst;
            end

            if inst.components.combat.targetfn then
                local old_TryRetarget = inst.components.combat.TryRetarget;
                inst.components.combat.TryRetarget = function(self)
                    if old_TryRetarget then
                        old_TryRetarget(self);
                    end
                    if self.targetfn ~= nil
                            and not (self.inst.components.health ~= nil and
                            self.inst.components.health:IsDead())
                            and not (self.inst.components.sleeper ~= nil and
                            self.inst.components.sleeper:IsInDeepSleep()) then
                        if self.target and self.target:HasTag("mone_hivehat") then
                            self:SetTarget(nil);
                        end
                    end
                end
            end

            if inst.components.combat.keeptargetfn then
                local old_keeptargetfn = inst.components.combat.keeptargetfn;
                inst.components.combat.keeptargetfn = function(inst, target)
                    if target:HasTag("mone_hivehat") then
                        return false;
                    end
                    return old_keeptargetfn(inst, target);
                end
            end
        end)
    end
end

hivehat();
return function(inst)
    if not inst.mi_ori_item_modify_tag then
        return inst;
    end

    if not TheWorld.ismastersim then
        return inst;
    end

    if inst.components.named then
        inst.components.named:SetName("修改版·" .. tostring(STRINGS.NAMES[inst.prefab:upper()]));
    end

    if inst.components.armor == nil or inst.components.equippable == nil then
        return ;
    end

    -- 70% -> 90%
    inst.components.armor:InitCondition(TUNING.ARMOR_HIVEHAT, TUNING.ARMORRUINS_ABSORPTION);

    -- 添加一些标签
    local old_onequipfn = inst.components.equippable.onequipfn
    inst.components.equippable.onequipfn = function(inst, owner, ...)
        if old_onequipfn then
            old_onequipfn(inst, owner, ...)
        end

        -- 昆虫标签，不会被蜜蜂主动攻击
        API.AddTag(owner, "insect");

        owner:AddTag("mone_hivehat");
    end
    local old_onunequipfn = inst.components.equippable.onunequipfn
    inst.components.equippable.onunequipfn = function(inst, owner, ...)
        if old_onunequipfn then
            old_onunequipfn(inst, owner, ...);
        end

        API.RemoveTag(owner, "insect");

        owner:RemoveTag("mone_hivehat");
    end
end