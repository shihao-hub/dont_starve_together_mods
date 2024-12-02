---
--- @author zsh in 2023/2/21 1:15
---

local name = "mie_watersource";

local assets = {
    Asset("ANIM", "anim/water_bucket.zip"),
    Asset("IMAGE", "images/inventoryimages/water_bucket.tex"),
    Asset("ATLAS", "images/inventoryimages/water_bucket.xml"),

    -- NEW
    Asset("ANIM", "anim/jamesbucket.zip"),

    Asset("IMAGE", "images/inventoryimages/tap_buildingimages.tex"),
    Asset("ATLAS", "images/inventoryimages/tap_buildingimages.xml"),
}

local fns = {};

function fns.onopenfn(inst)
    inst.SoundEmitter:PlaySound("dontstarve/wilson/chest_open");
end

function fns.onclosefn(inst)
    inst.SoundEmitter:PlaySound("dontstarve/wilson/chest_close");
end

function fns.onhammered(inst, worker)
    if inst.components.lootdropper then
        inst.components.lootdropper:DropLoot()
    end

    if inst.components.container then
        inst.components.container:DropEverything()
    end
    local fx = SpawnPrefab("collapse_small")
    fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
    fx:SetMaterial("wood")
    inst:Remove()
end

function fns.onbuild(inst)
    -- NEW
    inst.AnimState:PushAnimation("idle")

    --inst.AnimState:PlayAnimation("place")
    --inst.AnimState:PushAnimation("closed", false)
    inst.SoundEmitter:PlaySound("dontstarve/common/dragonfly_chest_craft")
end

-- NEW
local scale = 1.1;

scale = 1.65; -- 2 1.6 1.8

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()
    inst.entity:AddSoundEmitter()

    inst.entity:AddMiniMapEntity()
    --inst.MiniMapEntity:SetIcon("water_bucket.tex")

    -- NEW
    inst.MiniMapEntity:SetIcon("kyno_bucket.tex")


    inst:AddTag("structure")
    inst:AddTag("watersource")

    --inst.AnimState:SetBank("water_bucket")
    --inst.AnimState:SetBuild("water_bucket")
    --inst.AnimState:PlayAnimation("idle")

    -- NEW
    MakeObstaclePhysics(inst, .3)

    inst.AnimState:SetScale(scale, scale, scale)

    inst.AnimState:SetBank("jamesbucket")
    inst.AnimState:SetBuild("jamesbucket")
    inst.AnimState:PlayAnimation("idle")

    MakeSnowCoveredPristine(inst)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        local old_OnEntityReplicated = inst.OnEntityReplicated
        inst.OnEntityReplicated = function(inst)
            if old_OnEntityReplicated then
                old_OnEntityReplicated(inst)
            end
            if inst and inst.replica and inst.replica.container then
                inst.replica.container:WidgetSetup("mie_watersource");
            end
        end
        return inst
    end

    inst:AddComponent("inspectable")
    inst:AddComponent("container")
    inst.components.container:WidgetSetup("mie_watersource")
    inst.components.container.onopenfn = fns.onopenfn;
    inst.components.container.onclosefn = fns.onclosefn;
    inst.components.container.skipclosesnd = true
    inst.components.container.skipopensnd = true

    inst:AddComponent("lootdropper")
    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(3)
    inst.components.workable:SetOnFinishCallback(fns.onhammered)

    inst:AddComponent("watersource");

    inst:ListenForEvent("onbuilt", fns.onbuilt);

    MakeSnowCovered(inst)

    return inst
end

return Prefab(name, fn, assets),
--MakePlacer(name .. "_placer", "water_bucket", "water_bucket", "idle");
-- NEW
MakePlacer(name .. "_placer", "jamesbucket", "jamesbucket", "idle", nil, nil, nil, scale);