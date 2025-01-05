---
--- @author zsh in 2023/2/16 9:08
---

local assets =
{
    Asset("ANIM", "anim/candybag.zip"),
    Asset("ANIM", "anim/ui_krampusbag_2x8.zip"),
    Asset("ANIM", "anim/ui_tacklecontainer_3x2.zip"),
}

local prefabs =
{
    "ash",
}

local function onequip(inst, owner)
    owner.AnimState:OverrideSymbol("backpack", "candybag", "backpack")
    owner.AnimState:OverrideSymbol("swap_body", "candybag", "swap_body")
    inst.components.container:Open(owner)
end

local function onunequip(inst, owner)
    owner.AnimState:ClearOverrideSymbol("backpack")
    owner.AnimState:ClearOverrideSymbol("swap_body")
    inst.components.container:Close(owner)
end

local function onequiptomodel(inst, owner)
    inst.components.container:Close(owner)
end

local function onburnt(inst)
    if inst.components.container ~= nil then
        inst.components.container:DropEverything()
        inst.components.container:Close()
    end

    SpawnPrefab("ash").Transform:SetPosition(inst.Transform:GetWorldPosition())

    inst:Remove()
end

local function onignite(inst)
    if inst.components.container ~= nil then
        inst.components.container.canbeopened = false
    end
end

local function onextinguish(inst)
    if inst.components.container ~= nil then
        inst.components.container.canbeopened = true
    end
end

local function ondropped(inst)
    if inst.components.container then
        inst.components.container:Close()
    end
end

-- 重载游戏时，会执行该函数
local function onpickupfn(inst, pickupguy, src_pos)
    if inst and inst.components.container and pickupguy then
        inst.components.container:Open(pickupguy);
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("candybag")
    inst.AnimState:SetBuild("candybag")
    inst.AnimState:PlayAnimation("anim")

    inst.foleysound = "dontstarve/movement/foley/backpack"

    inst:AddTag("backpack")

    MakeInventoryFloatable(inst, "med", 0.125, 0.65)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        local old_OnEntityReplicated = inst.OnEntityReplicated
        inst.OnEntityReplicated = function(inst)
            if old_OnEntityReplicated then
                old_OnEntityReplicated(inst)
            end
            if inst and inst.replica and inst.replica.container then
                inst.replica.container:WidgetSetup("mone_candybag");
            end
        end
        return inst
    end

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
    --inst.components.inventoryitem.cangoincontainer = false
    inst.components.inventoryitem:ChangeImageName("candybag");
    inst.components.inventoryitem:SetOnDroppedFn(ondropped);
    inst.components.inventoryitem:SetOnPickupFn(onpickupfn);

    --inst:AddComponent("equippable")
    --inst.components.equippable.equipslot = EQUIPSLOTS.BODY
    --
    --inst.components.equippable:SetOnEquip(onequip)
    --inst.components.equippable:SetOnUnequip(onunequip)
    --inst.components.equippable:SetOnEquipToModel(onequiptomodel)

    inst:AddComponent("container")
    inst.components.container:WidgetSetup("mone_candybag")
    inst.components.container.skipclosesnd = true
    inst.components.container.skipopensnd = true
    inst.components.container.onopenfn = function(inst)
        inst.SoundEmitter:PlaySound("dontstarve/wilson/chest_open")
    end
    inst.components.container.onclosefn = function(inst)
        inst.SoundEmitter:PlaySound("dontstarve/wilson/chest_close")
    end

    --MakeSmallBurnable(inst)
    --MakeSmallPropagator(inst)
    --inst.components.burnable:SetOnBurntFn(onburnt)
    --inst.components.burnable:SetOnIgniteFn(onignite)
    --inst.components.burnable:SetOnExtinguishFn(onextinguish)

    MakeHauntableLaunchAndDropFirstItem(inst)

    return inst
end

return Prefab("mone_candybag", fn, assets, prefabs)
