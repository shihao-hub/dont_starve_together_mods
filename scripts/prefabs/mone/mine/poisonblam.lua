---
--- @author zsh in 2023/1/25 3:47
---

local assets = {
    Asset("ANIM", "anim/poison_salve.zip"),
}

local function fn()
    local inst = CreateEntity();

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("poison_salve")
    inst.AnimState:SetBuild("poison_salve")
    inst.AnimState:PlayAnimation("idle")

    MakeInventoryFloatable(inst)

    if not TheWorld.ismastersim then
        return inst;
    end

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "poisonbalm"
    inst.components.inventoryitem.atlasname = "images/DLC0003/inventoryimages.xml"

    inst:AddComponent("stackable")
    inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

    inst:AddComponent("mone_poisonblam")

    return inst;
end

return Prefab("mone_poisonblam", fn, assets);