---
--- @author zsh in 2023/2/11 22:29
---

local API = require("chang_mone.dsts.API");

local function MakeHat(prefabname, assets, animstate, overridesymbol)
    local swap_data = { bank = animstate[1], anim = animstate[3] }

    local function _onequip(inst, owner)
        -- 此函数内有和皮肤有关的东西，不知道在干嘛，先删除。
        -- 2023-02-11-23:26：知道是干嘛的了，就是 xxx_clear_fn 相关
        -- NOTE: 目前主模组似乎没出为什么问题？好像是因为压根只换了建筑皮肤？
        -- 但是目前有个 妈妈放心种子袋，好像没出问题。那就先不改了！

        local fname = overridesymbol[1];

        local skin_build = inst:GetSkinBuild()
        if skin_build ~= nil then
            owner:PushEvent("equipskinneditem", inst:GetSkinName())
            owner.AnimState:OverrideItemSkinSymbol("swap_hat", skin_build, overridesymbol[2], inst.GUID, fname)
        else
            owner.AnimState:OverrideSymbol("swap_hat", fname, overridesymbol[2]);
        end

        owner.AnimState:ClearOverrideSymbol("headbase_hat") --clear out previous overrides

        owner.AnimState:Show("HAT")
        owner.AnimState:Show("HAIR_HAT")
        owner.AnimState:Hide("HAIR_NOHAT")
        owner.AnimState:Hide("HAIR")

        if owner:HasTag("player") then
            owner.AnimState:Hide("HEAD")
            owner.AnimState:Show("HEAD_HAT")
        end

        if inst.components.fueled ~= nil then
            inst.components.fueled:StartConsuming()
        end
    end

    local function _onunequip(inst, owner)

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

    local function simple_onequip(inst, owner)
        _onequip(inst, owner);
    end

    local function simple_onunequip(inst, owner)
        _onunequip(inst, owner);
    end

    local function simple_onequiptomodel(inst, owner)
        if inst.components.fueled ~= nil then
            inst.components.fueled:StopConsuming()
        end
    end

    local function simple(custom_init)
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddNetwork()

        MakeInventoryPhysics(inst)

        inst.AnimState:SetBank(animstate[1])
        inst.AnimState:SetBuild(animstate[2])
        inst.AnimState:PlayAnimation(animstate[3])

        inst:AddTag("hat")

        if custom_init ~= nil then
            custom_init(inst)
        end

        MakeInventoryFloatable(inst)
        inst.components.floater:SetBankSwapOnFloat(false, nil, swap_data)
        --Hats default animation is not "idle", so even though we don't swap banks, we need to specify the swap_data for re-skinning to reset properly when floating

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end

        inst:AddComponent("inventoryitem")

        inst:AddComponent("inspectable")

        inst:AddComponent("tradable")

        inst:AddComponent("equippable")
        inst.components.equippable.equipslot = EQUIPSLOTS.HEAD
        inst.components.equippable:SetOnEquip(simple_onequip)
        inst.components.equippable:SetOnUnequip(simple_onunequip)
        inst.components.equippable:SetOnEquipToModel(simple_onequiptomodel)

        MakeHauntableLaunch(inst)

        return inst
    end
    local function bushhat_stopusingbush(owner, data)
        local hat = owner.components.inventory and owner.components.inventory:GetEquippedItem(EQUIPSLOTS.HEAD) or nil
        local bushhat = owner._mie_bushhat;

        if hat and data.statename ~= "hide" then
            hat.components.useableitem:StopUsingItem()

            if bushhat and bushhat.components.fueled then
                bushhat.components.fueled:StopConsuming();
            end

            API.RemoveTag(owner, "mie_notarget");
            return ;
        end

        if hat and data.statename == "hide" then
            API.AddTag(owner, "mie_notarget");

            if bushhat and bushhat.components.fueled then
                if bushhat.components.fueled:GetPercent() <= 0 then
                    API.RemoveTag(owner, "mie_notarget");
                else
                    bushhat.components.fueled:StartConsuming();
                end
            end

            return ;
        end
    end

    local function bushhat()
        local inst = simple();

        inst.entity:AddMiniMapEntity()
        inst.MiniMapEntity:SetIcon("bushhat.tex")

        inst:AddTag("hide")

        inst.foleysound = "dontstarve/movement/foley/bushhat"

        inst.components.floater:SetSize("med")
        inst.components.floater:SetScale(0.65)

        inst.mone_repair_materials = { redgem = 1 };
        inst:AddTag("mone_can_be_repaired");

        if not TheWorld.ismastersim then
            return inst
        end

        inst.components.inventoryitem:ChangeImageName("bushhat");

        inst:AddComponent("useableitem")
        inst.components.useableitem:SetOnUseFn(function(inst)
            local owner = inst.components.inventoryitem.owner;
            if owner then
                owner.sg:GoToState("hide");
            end
        end)

        inst:AddComponent("fueled")
        inst.components.fueled.maxfuel = TUNING.CAMPFIRE_FUEL_MAX * 0.75
        inst.components.fueled.accepting = true
        inst.components.fueled:InitializeFuelLevel(TUNING.CAMPFIRE_FUEL_MAX * 0.75)

        -- TEMPLATE!!!
        local old_onequipfn = inst.components.equippable.onequipfn;
        inst.components.equippable.onequipfn = function(inst, owner, from_ground)
            if old_onequipfn then
                old_onequipfn(inst, owner, from_ground);
            end
            owner._mie_bushhat = inst;
            inst:ListenForEvent("newstate", bushhat_stopusingbush, owner);
        end

        local old_onunequipfn = inst.components.equippable.onunequipfn;
        inst.components.equippable.onunequipfn = function(inst, owner)
            if old_onunequipfn then
                old_onunequipfn(inst, owner);
            end

            API.RemoveTag(owner, "mie_notarget"); -- 修复不是站起来，而是点击的方式导致的bug
            owner._mie_bushhat = nil;
            inst:RemoveEventCallback("newstate", bushhat_stopusingbush, owner);
        end

        inst:DoTaskInTime(0, function(inst)
            local owner = inst.components.inventoryitem and inst.components.inventoryitem.owner;
            --print("bushhat's owner: " .. tostring(owner));
            if inst.components.fueled:GetPercent() <= 0 then
                if owner and owner:HasTag("player") then
                    API.RemoveTag(owner, "mie_notarget");
                end
            end
        end);

        inst:ListenForEvent("percentusedchange", function(inst, data)
            local owner = inst.components.inventoryitem and inst.components.inventoryitem.owner;
            --print("bushhat's owner: " .. tostring(owner));
            if data and data.percent <= 0 then
                if owner and owner:HasTag("player") then
                    API.RemoveTag(owner, "mie_notarget");
                end
            end
        end)

        return inst;
    end



    local function tophat()
        local inst = simple();

        inst.entity:AddMiniMapEntity()
        inst.MiniMapEntity:SetIcon("tophat.tex")

        inst:AddTag("waterproofer")

        inst.components.floater:SetSize("med")
        inst.components.floater:SetVerticalOffset(0.1)
        inst.components.floater:SetScale(0.65)

        if not TheWorld.ismastersim then
            return inst
        end

        inst.components.inventoryitem:ChangeImageName("tophat");

        inst.components.equippable.dapperness = TUNING.DAPPERNESS_LARGE

        local old_onequipfn = inst.components.equippable.onequipfn;
        inst.components.equippable.onequipfn = function(inst, owner, from_ground)
            if old_onequipfn then
                old_onequipfn(inst, owner, from_ground);
            end
            owner:AddTag("mie_tophat_wolfgang");
        end

        local old_onunequipfn = inst.components.equippable.onunequipfn;
        inst.components.equippable.onunequipfn = function(inst, owner)
            if old_onunequipfn then
                old_onunequipfn(inst, owner);
            end
            owner:RemoveTag("mie_tophat_wolfgang");
        end

        inst:AddComponent("waterproofer")
        inst.components.waterproofer:SetEffectiveness(TUNING.WATERPROOFNESS_SMALL)

        inst:AddComponent("fueled")
        inst.components.fueled.fueltype = FUELTYPE.USAGE
        inst.components.fueled:InitializeFuelLevel(TUNING.WALRUSHAT_PERISHTIME)
        inst.components.fueled:SetDepletedFn(inst.Remove)

        inst:AddComponent("insulator")
        inst.components.insulator:SetInsulation(TUNING.INSULATION_MED)

        return inst;
    end

    local function walterhat()
        local inst = simple();

        inst.entity:AddMiniMapEntity()
        inst.MiniMapEntity:SetIcon("walterhat.tex")

        inst:AddTag("waterproofer")

        if not TheWorld.ismastersim then
            return inst
        end

        inst.components.inventoryitem:ChangeImageName("walterhat");

        inst.components.equippable.dapperness = TUNING.DAPPERNESS_LARGE

        local old_onequipfn = inst.components.equippable.onequipfn;
        inst.components.equippable.onequipfn = function(inst, owner, from_ground)
            if old_onequipfn then
                old_onequipfn(inst, owner, from_ground);
            end
            owner:AddTag("mie_walterhat_wolfgang");
        end

        local old_onunequipfn = inst.components.equippable.onunequipfn;
        inst.components.equippable.onunequipfn = function(inst, owner)
            if old_onunequipfn then
                old_onunequipfn(inst, owner);
            end
            owner:RemoveTag("mie_walterhat_wolfgang");
        end

        inst:AddComponent("waterproofer")
        inst.components.waterproofer:SetEffectiveness(TUNING.WATERPROOFNESS_SMALL)

        inst:AddComponent("fueled")
        inst.components.fueled.fueltype = FUELTYPE.USAGE
        inst.components.fueled:InitializeFuelLevel(TUNING.WALRUSHAT_PERISHTIME)
        inst.components.fueled:SetDepletedFn(inst.Remove)

        inst:AddComponent("insulator")
        inst.components.insulator:SetInsulation(TUNING.INSULATION_MED)

        return inst;
    end

    local fn;
    if string.find(prefabname, "_bushhat") then
        fn = bushhat;
    elseif string.find(prefabname, "_tophat") then
        fn = tophat;
    elseif string.find(prefabname, "_walterhat") then
        fn = walterhat;
    else
        fn = simple;
    end

    return Prefab(prefabname, fn, assets);
end

local config_data = TUNING.MIE_TUNING.MOD_CONFIG_DATA;

local hats = {};

if config_data.bushhat then
    table.insert(hats, MakeHat("mie_bushhat", {
        Asset("ANIM", "anim/hat_bush.zip"),
    }, { "bushhat", "hat_bush", "anim" }, { "hat_bush", "swap_hat" }));
end

if config_data.tophat then
    table.insert(hats, MakeHat("mie_tophat", {
        Asset("ANIM", "anim/hat_top.zip"),
    }, { "tophat", "hat_top", "anim" }, { "hat_top", "swap_hat" }));
end

if config_data.walterhat then
    table.insert(hats, MakeHat("mie_walterhat", {
        Asset("ANIM", "anim/hat_walter.zip"),
    }, { "walterhat", "hat_walter", "anim" }, { "hat_walter", "swap_hat" }));
end

return unpack(hats);
