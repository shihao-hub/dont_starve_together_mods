---
--- @author zsh in 2023/1/12 23:33
---


local assets = {
    Asset("ANIM", "anim/ballpein_hammer.zip"),
    Asset("ANIM", "anim/swap_ballpein_hammer.zip"),
}

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)
    MakeInventoryFloatable(inst)

    inst.AnimState:SetBank("ballpein_hammer")
    inst.AnimState:SetBuild("ballpein_hammer")
    inst.AnimState:PlayAnimation("idle")

    inst:AddTag("hammer")
    inst:AddTag("tool")
    inst:AddTag("weapon")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")

    inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(17)

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "ballpein_hammer"
    inst.components.inventoryitem.atlasname = "images/DLC0003/inventoryimages.xml"


    inst:AddComponent("equippable")
    inst.components.equippable:SetOnEquip(function(inst, owner)
        owner.AnimState:OverrideSymbol("swap_object", "swap_ballpein_hammer", "swap_ballpein_hammer")
        owner.AnimState:Show("ARM_carry")
        owner.AnimState:Hide("ARM_normal")
    end)
    inst.components.equippable:SetOnUnequip(function(inst, owner)
        owner.AnimState:Hide("ARM_carry")
        owner.AnimState:Show("ARM_normal")
    end)

    inst:AddComponent("tool")
    inst.components.tool:SetAction(ACTIONS.HAMMER)

    inst:AddInherentAction(ACTIONS.TERRAFORM)
    inst:AddComponent("terraformer")

    inst:AddComponent("finiteuses")
    inst.components.finiteuses:SetMaxUses(TUNING.HAMMER_USES)
    inst.components.finiteuses:SetUses(TUNING.HAMMER_USES)
    inst.components.finiteuses:SetOnFinished(inst.Remove)

    inst.components.finiteuses:SetConsumption(ACTIONS.HAMMER, 0.3)
    inst.components.finiteuses:SetConsumption(ACTIONS.TERRAFORM, 0.3)

    MakeHauntableLaunch(inst)
    return inst;
end

return Prefab("mone_ballpein_hammer",fn,assets);