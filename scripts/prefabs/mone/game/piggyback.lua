---
--- @author zsh in 2023/1/10 7:06
---

local assets = {
    Asset("ANIM", "anim/piggyback.zip"),
    Asset("ANIM", "anim/swap_piggyback.zip"),
    Asset("ANIM", "anim/ui_piggyback_2x6.zip"),
}

local function onequip(inst, owner)

    local skin_build = inst:GetSkinBuild()
    if skin_build ~= nil then
        owner:PushEvent("equipskinneditem", inst:GetSkinName())
        owner.AnimState:OverrideItemSkinSymbol("swap_body", skin_build, "swap_body", inst.GUID, "swap_piggyback")
    else
        owner.AnimState:OverrideSymbol("swap_body", "swap_piggyback", "swap_body")
    end

    inst.components.container:Open(owner)
end

local function onunequip(inst, owner)
    local skin_build = inst:GetSkinBuild()
    if skin_build ~= nil then
        owner:PushEvent("unequipskinneditem", inst:GetSkinName())
    end
    owner.AnimState:ClearOverrideSymbol("swap_body")
    inst.components.container:Close(owner)
end

local function onequiptomodel(inst, owner)
    inst.components.container:Close(owner)
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("piggyback")
    inst.AnimState:SetBuild("swap_piggyback")
    inst.AnimState:PlayAnimation("anim")

    inst.MiniMapEntity:SetIcon("piggyback.png")

    inst.foleysound = "dontstarve/movement/foley/backpack"


    --waterproofer (from waterproofer component) added to pristine state for optimization
    inst:AddTag("waterproofer")


    MakeInventoryFloatable(inst, "small", 0.1, 0.85)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        local old_OnEntityReplicated = inst.OnEntityReplicated

        inst.OnEntityReplicated = function(inst)

            if old_OnEntityReplicated then
                old_OnEntityReplicated(inst)
            end
            if inst and inst.replica and inst.replica.container then
                inst.replica.container:WidgetSetup("mone_piggyback");
            end
        end

        return inst
    end

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem:ChangeImageName("piggyback");
    inst.components.inventoryitem.canonlygoinpocket = true;
    inst.components.inventoryitem:SetOnDroppedFn(function(inst)
        if inst.components.container then
            inst.components.container:Close()
        end
    end);
    --[[    inst.components.inventoryitem:SetOnPickupFn(function(inst, pickupguy, src_pos)
            if not (inst and inst.prefab and inst.components.container and pickupguy) then
                return
            end
            inst.components.container:Open(pickupguy)
        end);]]

    --inst:AddComponent("equippable")
    --inst.components.equippable.equipslot = EQUIPSLOTS.BODY

    --inst.components.equippable:SetOnEquip(onequip)
    --inst.components.equippable:SetOnUnequip(onunequip)
    --inst.components.equippable:SetOnEquipToModel(onequiptomodel)
    --inst.components.equippable.walkspeedmult = TUNING.PIGGYBACK_SPEED_MULT

    inst:AddComponent("waterproofer")
    inst.components.waterproofer:SetEffectiveness(0)

    inst:AddComponent("container")
    inst.components.container:WidgetSetup("mone_piggyback")
    inst.components.container.skipclosesnd = true
    inst.components.container.skipopensnd = true

    MakeHauntableLaunchAndDropFirstItem(inst)

    return inst
end

return Prefab("mone_piggyback", fn, assets)
