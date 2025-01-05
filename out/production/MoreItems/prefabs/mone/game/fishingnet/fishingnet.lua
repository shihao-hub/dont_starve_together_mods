---
--- @author zsh in 2023/6/2 11:58
---

local assets =
{
    --fishingnet unused, so switching to PKGREF
    --Asset("PKGREF", "anim/boat_net.zip"),
    --Asset("PKGREF", "anim/swap_boat_net.zip"),
    Asset("ANIM", "anim/boat_net.zip"),
    Asset("ANIM", "anim/swap_boat_net.zip"),

    Asset("IMAGE", "images/modules/uc/inventoryimages/uncompromising_fishingnet.tex"),
    Asset("ATLAS", "images/modules/uc/inventoryimages/uncompromising_fishingnet.xml"),
}

local prefabs =
{
    "fishingnetvisualizer"
}

local function onequip(inst, owner)
    owner.AnimState:OverrideSymbol("swap_object", "swap_boat_net", "swap_boat_net")
    owner.AnimState:Show("ARM_carry")
    owner.AnimState:Hide("ARM_normal")
end

local function onunequip(inst, owner)
    owner.AnimState:Hide("ARM_carry")
    owner.AnimState:Show("ARM_normal")
end

local function onpocket(inst, owner)

end

local function onattack(weapon, attacker, target)

end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

    inst:AddTag("allow_action_on_impassable")

    inst:AddTag("mone_fishingnetvisualizer")

    inst:AddTag("mone_fishingnet")

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("boat_net")
    inst.AnimState:SetBuild("boat_net")
    inst.AnimState:PlayAnimation("idle")

    inst.MiniMapEntity:SetIcon("boat_net.png")

    MakeInventoryFloatable(inst, "large", nil, {0.68, 0.5, 0.68})

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.netweight = 1 -- uc:new

    inst:AddComponent("finiteuses")
    inst.components.finiteuses:SetMaxUses(40) -- TUNING.FISHING_NET_USES
    inst.components.finiteuses:SetUses(40) -- TUNING.FISHING_NET_USES
    inst.components.finiteuses:SetOnFinished(inst.Remove)
    --inst.components.finiteuses:SetConsumption(ACTIONS.CAST_NET, 1) -- uc:new

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "uncompromising_fishingnet";
    inst.components.inventoryitem.atlasname = "images/modules/uc/inventoryimages/uncompromising_fishingnet.xml";

    inst:AddComponent("fishingnet")
    inst:AddComponent("inspectable")

    inst:AddComponent("equippable")
    inst.components.equippable:SetOnPocket(onpocket)
    inst.components.equippable:SetOnEquip(onequip)
    inst.components.equippable:SetOnUnequip(onunequip)

    --inst:AddComponent("burnable")
    --inst.components.burnable.canlight = false
    --inst.components.burnable.fxprefab = nil

    MakeHauntableLaunch(inst)

    return inst
end

return Prefab("mone_fishingnet", fn, assets, prefabs)
