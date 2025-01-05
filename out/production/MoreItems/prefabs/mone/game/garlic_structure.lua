---
--- @author zsh in 2023/1/16 5:38
---


local assets = {
    Asset("IMAGE", "images/inventoryimages/garlic_bat.tex"),
    Asset("ATLAS", "images/inventoryimages/garlic_bat.xml")
}


local function onhammered(inst, worker)
    inst.components.lootdropper:DropLoot()
    if inst.components.container ~= nil then
        inst.components.container:DropEverything()
    end
    local fx = SpawnPrefab("collapse_small")
    fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
    fx:SetMaterial("wood")
    inst:Remove()
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst.entity:AddMiniMapEntity()
    inst.MiniMapEntity:SetIcon("garlic_bat.tex")

    inst:SetPhysicsRadiusOverride(.8)
    MakeObstaclePhysics(inst, inst.physicsradiusoverride)

    inst:AddTag("structure")
    inst:AddTag("mone_garlic_structure")

    inst.AnimState:SetBank("farm_plant_garlic")
    inst.AnimState:SetBuild("farm_plant_garlic")
    inst.AnimState:PlayAnimation("idle_oversized")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst;
    end

    inst:AddComponent("inspectable")

    inst:AddComponent("lootdropper")
    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(3)
    inst.components.workable:SetOnFinishCallback(onhammered)

    return inst;
end

return Prefab("mone_garlic_structure",fn,assets),MakePlacer("mone_garlic_structure_placer", "farm_plant_garlic", "farm_plant_garlic", "idle_oversized");