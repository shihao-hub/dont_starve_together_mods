---
--- @author zsh in 2023/1/12 16:03
---

local assets={
    Asset("ANIM", "anim/pheromone_stone.zip"),
}

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("pheromone_stone")
    inst.AnimState:SetBuild("pheromone_stone")
    inst.AnimState:PlayAnimation("pherostone")

    MakeInventoryFloatable(inst);

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst;
    end

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "pheromonestone";
    inst.components.inventoryitem.atlasname = "images/DLC0003/inventoryimages.xml"

    inst:AddComponent("mone_pheromonestone")

    return inst;
end

return Prefab("mone_pheromonestone",fn,assets);