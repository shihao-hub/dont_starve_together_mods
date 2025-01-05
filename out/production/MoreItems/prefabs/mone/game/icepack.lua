---
--- @author zsh in 2023/3/6 22:21
---

local assets = {
    Asset("ANIM", "anim/swap_icepack.zip"),
    Asset("ANIM", "anim/ui_backpack_2x4.zip"),
}

local prefabs = {
    "ash",
}

local function onequip(inst, owner)
    owner.AnimState:OverrideSymbol("swap_body", "swap_icepack", "backpack")
    owner.AnimState:OverrideSymbol("swap_body", "swap_icepack", "swap_body")
    inst.components.container:Open(owner)
end

local function onunequip(inst, owner)
    owner.AnimState:ClearOverrideSymbol("swap_body")
    owner.AnimState:ClearOverrideSymbol("backpack")
    inst.components.container:Close(owner)
end

local function onequiptomodel(inst, owner)
    inst.components.container:Close(owner)
end

local function ondropped(inst)
    if inst.components.container then
        inst.components.container:Close()
    end
end

local function onpickupfn(inst, pickupguy, src_pos)
    if inst.components.container and pickupguy then
        inst.components.container:Open(pickupguy);
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

    inst.MiniMapEntity:SetIcon("icepack.png")

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("icepack")
    inst.AnimState:SetBuild("swap_icepack")
    inst.AnimState:PlayAnimation("anim")

    inst:AddTag("backpack")

    inst.foleysound = "dontstarve/movement/foley/backpack"

    MakeInventoryFloatable(inst, "small", 0.15)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        local old_OnEntityReplicated = inst.OnEntityReplicated
        inst.OnEntityReplicated = function(inst)
            if old_OnEntityReplicated then
                old_OnEntityReplicated(inst)
            end
            if inst and inst.replica and inst.replica.container then
                inst.replica.container:WidgetSetup("mone_icepack");
            end
        end
        return inst
    end

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.cangoincontainer = true
    inst.components.inventoryitem:ChangeImageName("icepack");
    inst.components.inventoryitem:SetOnDroppedFn(ondropped);
    --inst.components.inventoryitem:SetOnPickupFn(onpickupfn); -- 不需要

    --inst:AddComponent("equippable")
    --inst.components.equippable.equipslot = EQUIPSLOTS.BODY
    --inst.components.equippable:SetOnEquip(onequip)
    --inst.components.equippable:SetOnUnequip(onunequip)
    --inst.components.equippable:SetOnEquipToModel(onequiptomodel)

    inst:AddComponent("container")
    inst.components.container:WidgetSetup("mone_icepack")
    inst.components.container.skipclosesnd = true
    inst.components.container.skipopensnd = true
    inst.components.container.onopenfn = function(inst)
        inst.SoundEmitter:PlaySound("dontstarve/wilson/chest_open")
    end
    inst.components.container.onclosefn = function(inst)
        inst.SoundEmitter:PlaySound("dontstarve/wilson/chest_close")
    end

    inst:AddComponent("preserver")
    inst.components.preserver:SetPerishRateMultiplier(0.5);

    local preserver_value = TUNING.MONE_TUNING.GET_MOD_CONFIG_DATA.preserver_value;
    if preserver_value == 1 then
        inst.components.preserver:SetPerishRateMultiplier(0);
    elseif preserver_value == 2 then
        inst.components.preserver:SetPerishRateMultiplier(-0.33);
    end

    MakeHauntableLaunchAndDropFirstItem(inst)

    return inst
end

return Prefab("mone_icepack", fn, assets, prefabs)
