---
--- @author zsh in 2023/1/15 14:44
---

local function MakeGoggle(prefabname, assets, animstate, overridesymbol)
    local swap_data = { bank = animstate[1], anim = animstate[3] }

    local function onequip(inst, owner)

        owner.AnimState:OverrideSymbol("swap_hat", overridesymbol[1], overridesymbol[2])

        owner.AnimState:ClearOverrideSymbol("headbase_hat") --clear out previous overrides

        owner.AnimState:Show("HAT")
        owner.AnimState:Show("HAIR_HAT")
        owner.AnimState:Hide("HAIR_NOHAT")
        owner.AnimState:Hide("HAIR")

        if owner:HasTag("player") then
            owner.AnimState:Hide("HEAD")
            owner.AnimState:Show("HEAD_HAT")
        end

        if inst.components.fueled then
            inst.components.fueled:StartConsuming()
        end
    end

    local function onunequip(inst, owner)
        owner.AnimState:ClearOverrideSymbol("headbase_hat") --it might have been overriden by _onequip

        owner.AnimState:ClearOverrideSymbol("swap_hat")
        owner.AnimState:Hide("HAT")
        owner.AnimState:Hide("HAIR_HAT")
        owner.AnimState:Show("HAIR_NOHAT")
        owner.AnimState:Show("HAIR")

        if owner:HasTag("player") then
            owner.AnimState:Show("HEAD")
            owner.AnimState:Hide("HEAD_HAT")
        end

        if inst.components.fueled ~= nil then
            inst.components.fueled:StopConsuming()
        end
    end

    local function simple()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddNetwork()

        MakeInventoryPhysics(inst)

        inst.AnimState:SetBank(animstate[1])
        inst.AnimState:SetBuild(animstate[2])
        inst.AnimState:PlayAnimation(animstate[3])

        inst:AddTag("mone_goggles")

        MakeInventoryFloatable(inst);

        inst:AddTag("hat")

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst;
        end

        inst:AddComponent("inspectable")

        inst:AddComponent("inventoryitem")

        inst:AddComponent("tradable")

        inst:AddComponent("equippable")
        inst.components.equippable.equipslot = EQUIPSLOTS.HEAD

        inst.components.equippable:SetOnEquip(onequip)
        inst.components.equippable:SetOnUnequip(onunequip)
        inst.components.equippable:SetOnEquipToModel(function(inst, owner)
            if inst.components.fueled ~= nil then
                inst.components.fueled:StopConsuming()
            end
        end);

        MakeHauntableLaunch(inst)

        return inst
    end

    local function mole_turnon(owner)
        owner.SoundEmitter:PlaySound("dontstarve_DLC001/common/moggles_on")
    end

    local function mole_turnoff(owner)
        owner.SoundEmitter:PlaySound("dontstarve_DLC001/common/moggles_off")
    end

    local function mole_onequip(inst, owner)
        onequip(inst, owner)
        mole_turnon(owner)
    end

    local function mole_onunequip(inst, owner)
        onunequip(inst, owner)
        mole_turnoff(owner)
    end

    local function mole_perish(inst)
        if inst.components.equippable ~= nil and inst.components.equippable:IsEquipped() then
            local owner = inst.components.inventoryitem ~= nil and inst.components.inventoryitem.owner or nil
            if owner ~= nil then
                mole_turnoff(owner)
            end
        end
        inst:Remove()--generic_perish(inst)
    end

    local function normal()
        local inst = simple();

        -- 注意！
        inst:AddTag("nightvision")
        inst:AddTag("mone_gogglesnormal_tag");

        if not TheWorld.ismastersim then
            return inst;
        end

        inst.components.inventoryitem.imagename = "gogglesnormalhat"
        inst.components.inventoryitem.atlasname = "images/DLC0000/inventoryimages.xml"

        inst.components.equippable:SetOnEquip(mole_onequip)
        inst.components.equippable:SetOnUnequip(mole_onunequip)

        inst:AddComponent("armor");
        inst.components.armor:InitCondition(1, 0.4); -- (self.condition,self.absorb_percent)
        local old_SetCondition = inst.components.armor.SetCondition;
        function inst.components.armor:SetCondition(amount)
            amount = 0;
            if old_SetCondition then
                old_SetCondition(self, amount);
            end
        end

        inst:AddComponent("fueled")
        inst.components.fueled.fueltype = FUELTYPE.WORMLIGHT
        inst.components.fueled:InitializeFuelLevel(TUNING.MOLEHAT_PERISHTIME)
        inst.components.fueled:SetDepletedFn(mole_perish)
        inst.components.fueled:SetFirstPeriod(TUNING.TURNON_FUELED_CONSUMPTION, TUNING.TURNON_FULL_FUELED_CONSUMPTION)
        inst.components.fueled.accepting = true

        return inst
    end

    local function heat()
        local inst = simple()

        if not TheWorld.ismastersim then
            return inst;
        end

        return inst
    end

    local function armor()
        local inst = simple()

        if not TheWorld.ismastersim then
            return inst;
        end

        return inst
    end

    local function shoot()
        local inst = simple()

        if not TheWorld.ismastersim then
            return inst;
        end

        return inst
    end

    local fn = nil

    if prefabname == "gogglesnormal" then
        fn = normal
    elseif prefabname == "gogglesheat" then
        fn = heat
    elseif prefabname == "gogglesarmor" then
        fn = armor
    elseif prefabname == "gogglesshoot" then
        fn = shoot
    end

    return Prefab(prefabname, fn or simple, assets);
end

return MakeGoggle("mone_gogglesnormal",{
    Asset("ANIM", "anim/hat_gogglesnormal.zip"),
},{"gogglesnormalhat","hat_gogglesnormal",""},{"hat_gogglesnormal","swap_hat"})
--MakeGoggle("gogglesheat"),
--MakeGoggle("gogglesarmor"),
--MakeGoggle("gogglesshoot")