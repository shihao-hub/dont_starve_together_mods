---
--- @author zsh in 2023/2/20 0:50
---

local name = "mie_bear_skin_cabinet";

local assets = {
    Asset("ANIM", "anim/quagmire_safe.zip"),

    Asset("IMAGE", "images/inventoryimages/tap_buildingimages.tex"),
    Asset("ATLAS", "images/inventoryimages/tap_buildingimages.xml"),
};

local function onopen(inst)
    inst.AnimState:PlayAnimation("open")
    inst.SoundEmitter:PlaySound("dontstarve/quagmire/common/safe/key")
end

local function onclose(inst)
    inst.AnimState:PlayAnimation("closed")
    inst.SoundEmitter:PlaySound("dontstarve/quagmire/common/safe/key")
end

local function onhammered(inst, worker)
    inst.components.lootdropper:DropLoot()
    if inst.components.container then
        inst.components.container:DropEverything()
    end
    SpawnPrefab("collapse_small").Transform:SetPosition(inst.Transform:GetWorldPosition())
    inst.SoundEmitter:PlaySound("dontstarve/common/destroy_metal")
    inst:Remove()
end

local function onhit(inst, worker)
    inst.AnimState:PlayAnimation("hit")
    inst.AnimState:PushAnimation("closed", true)
    --if inst.components.container then
    --    inst.components.container:DropEverything()
    --    inst.components.container:Close()
    --end
end

local function onbuilt(inst)
    inst.AnimState:PushAnimation("closed", true)
    inst.SoundEmitter:PlaySound("dontstarve/common/craftable/chest")
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

    inst.MiniMapEntity:SetIcon("quagmire_safe.tex")

    inst:AddTag("structure")
    inst:AddTag("mie_bear_skin_cabinet")

    inst.AnimState:SetBank("quagmire_safe")
    inst.AnimState:SetBuild("quagmire_safe")
    inst.AnimState:PlayAnimation("closed",true)

    MakeSnowCoveredPristine(inst)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        local old_OnEntityReplicated = inst.OnEntityReplicated
        inst.OnEntityReplicated = function(inst)
            if old_OnEntityReplicated then
                old_OnEntityReplicated(inst)
            end
            if inst and inst.replica and inst.replica.container then
                inst.replica.container:WidgetSetup("mie_bear_skin_cabinet");
            end
        end
        return inst
    end

    inst:AddComponent("inspectable")
    inst:AddComponent("container")
    inst.components.container:WidgetSetup("mie_bear_skin_cabinet")
    inst.components.container.onopenfn = onopen
    inst.components.container.onclosefn = onclose
    inst.components.container.skipclosesnd = true
    inst.components.container.skipopensnd = true

    inst:AddComponent("preserver")
    inst.components.preserver:SetPerishRateMultiplier(0);

    inst:AddComponent("lootdropper")
    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(3)
    inst.components.workable:SetOnFinishCallback(onhammered)
    inst.components.workable:SetOnWorkCallback(onhit)

    inst:ListenForEvent("onbuilt", onbuilt)
    MakeSnowCovered(inst)

    return inst
end

return Prefab(name, fn, assets), MakePlacer(name .. "_placer", "quagmire_safe", "quagmire_safe", "closed");