---
--- @author zsh in 2023/7/4 13:19
---


local COMMON_FNS = {
    ReplaceEat = function(old_fn)
        return function(self, food, feeder, ...)
            local res = {};
            if old_fn then
                res = { old_fn(self, food, feeder, ...) };
            end
            if res[1] then
                local inst = self.inst;
                if food and food:IsValid() and inst.components.armor then
                    local armor = inst.components.armor;
                    local health = math.abs(food.components.edible:GetHealth(inst)) * inst.components.eater.healthabsorption
                    local hunger = math.abs(food.components.edible:GetHunger(inst)) * inst.components.eater.hungerabsorption
                    local delta = armor.maxcondition - armor.condition;
                    if delta > 0 then
                        local num = math.floor(delta / (health + hunger)) or 0;
                        local food_num = food.components.stackable and food.components.stackable:StackSize() or 1;
                        local eat_num = num < food_num and num or food_num;
                        inst.components.armor:Repair(eat_num * (health + hunger));
                        if not self.eatwholestack and food.components.stackable ~= nil then
                            if food.components.stackable:StackSize() > eat_num then
                                food.components.stackable:Get(eat_num):Remove();
                            else
                                food:Remove();
                            end
                        else
                            food:Remove();
                        end
                    end
                end
            end
            return unpack(res, 1, table.maxn(res));
        end
    end,
    ReplaceSetCondition = function(old_fn)
        return function(self, amount, ...)
            local old_Remove = self.inst.Remove;
            self.inst.Remove = function()
                -- DoNothing
            end;
            if old_fn then
                old_fn(self, amount, ...);
            end
            self.inst.Remove = old_Remove;

            self.condition = math.max(0, math.min(amount, self.maxcondition));
            self.inst:PushEvent("percentusedchange", { percent = self:GetPercent() });

            return ;
        end
    end
}

local function MakeHat(name)
    -- NEW!
    name = name or "eyemask";

    local fns = {}
    local fname = "hat_" .. name
    local symname = name .. "hat"
    local prefabname = symname

    -- NEW!
    prefabname = "mone_eyemaskhat";

    --If you want to use generic_perish to do more, it's still
    --commented in all the relevant places below in this file.
    --[[local function generic_perish(inst)
        inst:Remove()
    end]]

    local swap_data = { bank = symname, anim = "anim" }

    -- do not pass this function to equippable:SetOnEquip as it has different a parameter listing
    local function _base_onequip(inst, owner, symbol_override, swap_hat_override)
        local skin_build = inst:GetSkinBuild()
        if skin_build ~= nil then
            owner:PushEvent("equipskinneditem", inst:GetSkinName())
            owner.AnimState:OverrideItemSkinSymbol(swap_hat_override or "swap_hat", skin_build, symbol_override or "swap_hat", inst.GUID, fname)
        else
            owner.AnimState:OverrideSymbol(swap_hat_override or "swap_hat", fname, symbol_override or "swap_hat")
        end

        if inst.components.fueled ~= nil then
            inst.components.fueled:StartConsuming()
        end

        if inst.skin_equip_sound and owner.SoundEmitter then
            owner.SoundEmitter:PlaySound(inst.skin_equip_sound)
        end
    end

    -- do not pass this function to equippable:SetOnEquip as it has different a parameter listing
    local function _onequip(inst, owner, symbol_override, headbase_hat_override)
        _base_onequip(inst, owner, symbol_override)

        owner.AnimState:ClearOverrideSymbol("headbase_hat") --clear out previous overrides
        if headbase_hat_override ~= nil then
            local skin_build = owner.AnimState:GetSkinBuild()
            if skin_build ~= "" then
                owner.AnimState:OverrideSkinSymbol("headbase_hat", skin_build, headbase_hat_override)
            else
                local build = owner.AnimState:GetBuild()
                owner.AnimState:OverrideSymbol("headbase_hat", build, headbase_hat_override)
            end
        end

        owner.AnimState:Show("HAT")
        owner.AnimState:Show("HAIR_HAT")
        owner.AnimState:Hide("HAIR_NOHAT")
        owner.AnimState:Hide("HAIR")

        if owner:HasTag("player") then
            owner.AnimState:Hide("HEAD")
            owner.AnimState:Show("HEAD_HAT")
            owner.AnimState:Show("HEAD_HAT_NOHELM")
            owner.AnimState:Hide("HEAD_HAT_HELM")
        end
    end

    local function _onunequip(inst, owner)
        local skin_build = inst:GetSkinBuild()
        if skin_build ~= nil then
            owner:PushEvent("unequipskinneditem", inst:GetSkinName())
        end

        owner.AnimState:ClearOverrideSymbol("headbase_hat") --it might have been overriden by _onequip
        if owner.components.skinner ~= nil then
            owner.components.skinner.base_change_cb = owner.old_base_change_cb
        end

        owner.AnimState:ClearOverrideSymbol("swap_hat")
        owner.AnimState:Hide("HAT")
        owner.AnimState:Hide("HAIR_HAT")
        owner.AnimState:Show("HAIR_NOHAT")
        owner.AnimState:Show("HAIR")

        if owner:HasTag("player") then
            owner.AnimState:Show("HEAD")
            owner.AnimState:Hide("HEAD_HAT")
            owner.AnimState:Hide("HEAD_HAT_NOHELM")
            owner.AnimState:Hide("HEAD_HAT_HELM")
        end

        if inst.components.fueled ~= nil then
            inst.components.fueled:StopConsuming()
        end
    end

    fns.simple_onequip = function(inst, owner, from_ground)
        _onequip(inst, owner)
    end

    fns.simple_onunequip = function(inst, owner, from_ground)
        _onunequip(inst, owner)
    end

    fns.opentop_onequip = function(inst, owner)
        _base_onequip(inst, owner)

        owner.AnimState:Show("HAT")
        owner.AnimState:Hide("HAIR_HAT")
        owner.AnimState:Show("HAIR_NOHAT")
        owner.AnimState:Show("HAIR")

        owner.AnimState:Show("HEAD")
        owner.AnimState:Hide("HEAD_HAT")
        owner.AnimState:Hide("HEAD_HAT_NOHELM")
        owner.AnimState:Hide("HEAD_HAT_HELM")
    end

    fns.fullhelm_onequip = function(inst, owner)
        if owner:HasTag("player") then
            _base_onequip(inst, owner, nil, "headbase_hat")

            owner.AnimState:Hide("HAT")
            owner.AnimState:Hide("HAIR_HAT")
            owner.AnimState:Hide("HAIR_NOHAT")
            owner.AnimState:Hide("HAIR")

            owner.AnimState:Hide("HEAD")
            owner.AnimState:Show("HEAD_HAT")
            owner.AnimState:Hide("HEAD_HAT_NOHELM")
            owner.AnimState:Show("HEAD_HAT_HELM")

            owner.AnimState:HideSymbol("face")
            owner.AnimState:HideSymbol("swap_face")
            owner.AnimState:HideSymbol("beard")
            owner.AnimState:HideSymbol("cheeks")

            owner.AnimState:UseHeadHatExchange(true)
        else
            _base_onequip(inst, owner)

            owner.AnimState:Show("HAT")
            owner.AnimState:Hide("HAIR_HAT")
            owner.AnimState:Hide("HAIR_NOHAT")
            owner.AnimState:Hide("HAIR")
        end
    end

    fns.fullhelm_onunequip = function(inst, owner)
        _onunequip(inst, owner)

        if owner:HasTag("player") then
            owner.AnimState:ShowSymbol("face")
            owner.AnimState:ShowSymbol("swap_face")
            owner.AnimState:ShowSymbol("beard")
            owner.AnimState:ShowSymbol("cheeks")

            owner.AnimState:UseHeadHatExchange(false)
        end
    end

    fns.simple_onequiptomodel = function(inst, owner, from_ground)
        if inst.components.fueled ~= nil then
            inst.components.fueled:StopConsuming()
        end
    end

    local _skinfns = { -- NOTES(JBK): These are useful for skins to have access to them instead of sometimes storing a reference to a hat.
        simple_onequip = fns.simple_onequip,
        simple_onunequip = fns.simple_onunequip,
        opentop_onequip = fns.opentop_onequip,
        fullhelm_onequip = fns.fullhelm_onequip,
        fullhelm_onunequip = fns.fullhelm_onunequip,
        simple_onequiptomodel = fns.simple_onequiptomodel,
    }

    local function simple(custom_init)
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddNetwork()

        MakeInventoryPhysics(inst)

        inst.AnimState:SetBank(symname)
        inst.AnimState:SetBuild(fname)
        inst.AnimState:PlayAnimation("anim")

        inst:AddTag("hat")

        if custom_init ~= nil then
            custom_init(inst)
        end

        MakeInventoryFloatable(inst)
        inst.components.floater:SetBankSwapOnFloat(false, nil, swap_data) --Hats default animation is not "idle", so even though we don't swap banks, we need to specify the swap_data for re-skinning to reset properly when floating

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end

        inst._skinfns = _skinfns

        inst:AddComponent("inventoryitem")

        inst:AddComponent("inspectable")

        inst:AddComponent("tradable")

        inst:AddComponent("equippable")
        inst.components.equippable.equipslot = EQUIPSLOTS.HEAD
        inst.components.equippable:SetOnEquip(fns.simple_onequip)
        inst.components.equippable:SetOnUnequip(fns.simple_onunequip)
        inst.components.equippable:SetOnEquipToModel(fns.simple_onequiptomodel)

        MakeHauntableLaunch(inst)

        return inst
    end

    local function eyemask_custom_init(inst)
        -- To play an eat sound when it's on the ground and fed.
        inst.entity:AddSoundEmitter()

        inst:AddTag(prefabname)

        --waterproofer (from waterproofer component) added to pristine state for optimization
        inst:AddTag("waterproofer")

        inst:AddTag("handfed")
        inst:AddTag("fedbyall")

        -- for eater
        inst:AddTag("eatsrawmeat")
        inst:AddTag("strongstomach")
    end

    local function eyemask_oneatfn(inst, food)
        local health = math.abs(food.components.edible:GetHealth(inst)) * inst.components.eater.healthabsorption
        local hunger = math.abs(food.components.edible:GetHunger(inst)) * inst.components.eater.hungerabsorption
        inst.components.armor:Repair(health + hunger)

        if not inst.inlimbo then
            inst.AnimState:PlayAnimation("eat")
            inst.AnimState:PushAnimation("anim", true)

            inst.SoundEmitter:PlaySound("terraria1/eyemask/eat")
        end
    end

    -- NEW!
    local ABSORB_PERCENT = TUNING.ARMOR_WATHGRITHRHAT_ABSORPTION;

    local function onpercentusedchange(inst, data)
        local percent = data and data.percent;
        if type(percent) ~= "number" then
            return ;
        end
        if inst.components.armor == nil or inst.components.inventoryitem == nil or inst.components.equippable == nil then
            return ;
        end
        local armor = inst.components.armor;
        if percent <= 0 then
            armor.absorb_percent = 0;
        else
            armor.absorb_percent = ABSORB_PERCENT;
        end
    end

    fns.eyemask = function()
        local inst = simple(eyemask_custom_init)

        inst.components.floater:SetSize("med")
        inst.components.floater:SetScale(0.72)

        if not TheWorld.ismastersim then
            return inst
        end

        inst.components.inventoryitem.imagename = "eyemaskhat";
        inst.components.inventoryitem.atlasname = "images/DLC/inventoryimages1.xml";

        inst:AddComponent("eater")
        --inst.components.eater:SetDiet({ FOODGROUP.OMNI }, { FOODGROUP.OMNI }) -- FOODGROUP.OMNI  is default
        inst.components.eater:SetOnEatFn(eyemask_oneatfn)
        inst.components.eater:SetAbsorptionModifiers(4.0, 1.75, 0)
        inst.components.eater:SetCanEatRawMeat(true)
        inst.components.eater:SetStrongStomach(true)
        inst.components.eater:SetCanEatHorrible(true)

        -- 成组喂食
        inst.components.eater.Eat = COMMON_FNS.ReplaceEat(inst.components.eater.Eat)

        inst:AddComponent("armor")
        inst.components.armor:InitCondition(TUNING.ARMOR_WATHGRITHRHAT, ABSORB_PERCENT)

        inst:AddComponent("waterproofer")
        inst.components.waterproofer:SetEffectiveness(TUNING.WATERPROOFNESS_SMALL)

        -- 耐久为 0 不消失
        inst.components.armor.SetCondition = COMMON_FNS.ReplaceSetCondition(inst.components.armor.SetCondition);

        if inst.components.armor.DisablePercentChangedArmorBrokeEvent2 then
            inst.components.armor:DisablePercentChangedArmorBrokeEvent2();
        end

        inst:ListenForEvent("percentusedchange", onpercentusedchange);
        inst:DoTaskInTime(0, function(inst)
            if inst.components.armor then
                onpercentusedchange(inst, { percent = inst.components.armor:GetPercent() });
            end
        end)

        return inst
    end

    local function default()
        return simple()
    end

    local fn = nil
    local assets = { Asset("ANIM", "anim/" .. fname .. ".zip") }
    local prefabs = nil

    fn = fns.eyemask;

    return Prefab(prefabname, fn or default, assets, prefabs)
end

local function MakeArmor()
    local assets = {
        Asset("ANIM", "anim/eye_shield.zip"),
        Asset("ANIM", "anim/swap_eye_shield.zip"),
    }

    local function onequip(inst, owner)
        local skin_build = inst:GetSkinBuild()
        if skin_build ~= nil then
            owner:PushEvent("equipskinneditem", inst:GetSkinName())
            owner.AnimState:OverrideItemSkinSymbol("lantern_overlay", skin_build, "swap_shield", inst.GUID, "swap_eye_shield")
        else
            owner.AnimState:OverrideSymbol("lantern_overlay", "swap_eye_shield", "swap_shield")
        end
        owner.AnimState:HideSymbol("swap_object")

        owner.AnimState:Show("ARM_carry")
        owner.AnimState:Hide("ARM_normal")
        owner.AnimState:Show("LANTERN_OVERLAY")

        owner:ListenForEvent("onattackother", inst._weaponused_callback)
    end

    local function onunequip(inst, owner)
        owner.AnimState:Hide("ARM_carry")
        owner.AnimState:Show("ARM_normal")
        local skin_build = inst:GetSkinBuild()
        if skin_build ~= nil then
            owner:PushEvent("unequipskinneditem", inst:GetSkinName())
        end

        owner:RemoveEventCallback("onattackother", inst._weaponused_callback)

        owner.AnimState:ClearOverrideSymbol("lantern_overlay")
        owner.AnimState:Hide("LANTERN_OVERLAY")
        owner.AnimState:ShowSymbol("swap_object")
    end

    local function oneatfn(inst, food)
        local health = math.abs(food.components.edible:GetHealth(inst)) * inst.components.eater.healthabsorption
        local hunger = math.abs(food.components.edible:GetHunger(inst)) * inst.components.eater.hungerabsorption
        inst.components.armor:Repair(health + hunger)

        if not inst.inlimbo then
            inst.AnimState:PlayAnimation("eat")
            inst.AnimState:PushAnimation("idle", true)

            inst.SoundEmitter:PlaySound("terraria1/eye_shield/eat")
        end
    end

    -- NEW!
    local prefabname = "mone_shieldofterror";
    local ABSORB_PERCENT = TUNING.ARMOR_WATHGRITHRHAT_ABSORPTION;
    local DAMAGE = TUNING.SHIELDOFTERROR_DAMAGE;

    local function onpercentusedchange(inst, data)
        local percent = data and data.percent;
        if type(percent) ~= "number" then
            return ;
        end
        if inst.components.armor == nil or inst.components.weapon == nil then
            return ;
        end
        local armor = inst.components.armor;
        local weapon = inst.components.weapon;
        if percent <= 0 then
            armor.absorb_percent = 0;
            weapon:SetDamage(17);
        else
            armor.absorb_percent = ABSORB_PERCENT;
            weapon:SetDamage(DAMAGE);
        end
    end

    local function fn()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddNetwork()
        inst.entity:AddSoundEmitter()

        MakeInventoryPhysics(inst)

        inst.AnimState:SetBank("eye_shield")
        inst.AnimState:SetBuild("eye_shield")
        inst.AnimState:PlayAnimation("idle")

        inst:AddTag(prefabname)

        inst:AddTag("handfed")
        inst:AddTag("fedbyall")
        inst:AddTag("toolpunch")

        -- for eater
        inst:AddTag("eatsrawmeat")
        inst:AddTag("strongstomach")

        --weapon (from weapon component) added to pristine state for optimization
        inst:AddTag("weapon")

        --shadowlevel (from shadowlevel component) added to pristine state for optimization
        inst:AddTag("shadowlevel")

        MakeInventoryFloatable(inst, nil, 0.2, { 1.1, 0.6, 1.1 })

        inst.entity:SetPristine()
        if not TheWorld.ismastersim then
            return inst
        end

        inst._weaponused_callback = function(_, data)
            if data.weapon ~= nil and data.weapon == inst then
                inst.components.armor:TakeDamage(TUNING.SHIELDOFTERROR_USEDAMAGE)
            end
        end

        inst:AddComponent("eater")
        inst.components.eater:SetOnEatFn(oneatfn)
        inst.components.eater:SetAbsorptionModifiers(4.0, 1.75, 0)
        inst.components.eater:SetCanEatRawMeat(true)
        inst.components.eater:SetStrongStomach(true)
        inst.components.eater:SetCanEatHorrible(true)

        -- 成组喂食
        inst.components.eater.Eat = COMMON_FNS.ReplaceEat(inst.components.eater.Eat)

        inst:AddComponent("weapon")
        inst.components.weapon:SetDamage(DAMAGE)

        -------

        inst:AddComponent("armor")
        --inst.components.armor:InitCondition(TUNING.ARMOR_WATHGRITHRHAT, ABSORB_PERCENT);
        inst.components.armor:InitCondition(TUNING.ARMOR_RUINSHAT, ABSORB_PERCENT);

        -- 耐久为 0 不消失
        inst.components.armor.SetCondition = COMMON_FNS.ReplaceSetCondition(inst.components.armor.SetCondition);

        if inst.components.armor.DisablePercentChangedArmorBrokeEvent2 then
            inst.components.armor:DisablePercentChangedArmorBrokeEvent2();
        end

        inst:ListenForEvent("percentusedchange", onpercentusedchange);
        inst:DoTaskInTime(0, function(inst)
            if inst.components.armor then
                onpercentusedchange(inst, { percent = inst.components.armor:GetPercent() });
            end
        end)

        inst:AddComponent("inspectable")

        inst:AddComponent("inventoryitem")
        inst.components.inventoryitem.imagename = "shieldofterror";
        inst.components.inventoryitem.atlasname = "images/DLC/inventoryimages2.xml";

        inst:AddComponent("equippable")
        inst.components.equippable:SetOnEquip(onequip)
        inst.components.equippable:SetOnUnequip(onunequip)

        inst:AddComponent("shadowlevel")
        inst.components.shadowlevel:SetDefaultLevel(TUNING.SHIELDOFTERROR_SHADOW_LEVEL)

        MakeHauntableLaunch(inst)

        return inst
    end

    return Prefab(prefabname, fn, assets)
end

return MakeHat(), MakeArmor();