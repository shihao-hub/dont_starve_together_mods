---
--- @author zsh in 2023/3/29 10:02
---

local assets={
    Asset("ANIM", "anim/relics.zip"),
}

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("relic")
    inst.AnimState:SetBuild("relics")
    inst.AnimState:PlayAnimation("5")

    MakeInventoryFloatable(inst);

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst;
    end

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "relic_5";
    inst.components.inventoryitem.atlasname = "images/DLC0003/inventoryimages.xml"

    inst:AddComponent("mone_pheromonestone2")

    return inst;
end

return Prefab("mone_pheromonestone2",fn,assets);