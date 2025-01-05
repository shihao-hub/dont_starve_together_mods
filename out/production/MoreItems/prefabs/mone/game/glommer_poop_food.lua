---
--- @author zsh in 2023/7/4 12:00
---


local assets={
    Asset("ANIM", "anim/cook_pot_food.zip"),
    Asset("INV_IMAGE", "bananajuice"),
}

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("cook_pot_food")
    inst.AnimState:SetBuild("cook_pot_food")
    inst.AnimState:PlayAnimation("idle")

    inst.AnimState:OverrideSymbol("swap_food", "cook_pot_food10", "bananajuice")

    MakeInventoryFloatable(inst);

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst;
    end

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "bananajuice";
    inst.components.inventoryitem.atlasname = "images/inventoryimages1.xml"

    inst:AddComponent("stackable")
    inst.components.stackable.maxsize = TUNING.STACK_SIZE_MEDITEM;

    return inst;
end

return Prefab("mone_glommer_poop_food",fn,assets);