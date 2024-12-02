---
--- @author zsh in 2023/2/21 9:42
---

local name = "mie_wooden_drawer";

local assets = {
    Asset("ANIM", "anim/quagmire_drawer.zip"),

    Asset("IMAGE", "images/inventoryimages/tap_buildingimages.tex"),
    Asset("ATLAS", "images/inventoryimages/tap_buildingimages.xml"),
    Asset("IMAGE", "images/minimapimages/tap_minimapicons.tex"),
    Asset("ATLAS", "images/minimapimages/tap_minimapicons.xml"),
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
    inst.SoundEmitter:PlaySound("dontstarve/common/destroy_wood")
    inst:Remove()
end

local function onhit(inst, worker)
    inst.AnimState:PlayAnimation("hit")
    inst.AnimState:PushAnimation("closed", true)
end

local function onbuilt(inst)
    inst.AnimState:PushAnimation("closed", true)
    inst.SoundEmitter:PlaySound("dontstarve/common/craftable/chest")
    --inst.SoundEmitter:PlaySound("dontstarve/common/chest_craft")
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

    inst.MiniMapEntity:SetIcon("kyno_drawerchest.tex")

    --inst:SetPhysicsRadiusOverride(.3)
    --MakeObstaclePhysics(inst, inst.physicsradiusoverride)

    inst:AddTag("structure")
    inst:AddTag("chest")
    inst:AddTag("mie_wooden_drawer")

    inst.AnimState:SetBank("quagmire_drawer")
    inst.AnimState:SetBuild("quagmire_drawer")
    inst.AnimState:PlayAnimation("closed", true)

    MakeSnowCoveredPristine(inst)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        local old_OnEntityReplicated = inst.OnEntityReplicated
        inst.OnEntityReplicated = function(inst)
            if old_OnEntityReplicated then
                old_OnEntityReplicated(inst)
            end
            if inst and inst.replica and inst.replica.container then
                inst.replica.container:WidgetSetup("treasurechest");
            end
        end
        return inst
    end

    inst:AddComponent("inspectable")
    inst:AddComponent("container")
    inst.components.container:WidgetSetup("treasurechest")
    inst.components.container.onopenfn = onopen
    inst.components.container.onclosefn = onclose
    inst.components.container.skipclosesnd = true
    inst.components.container.skipopensnd = true

    -- 我去，这永久保鲜。。。
    --inst:AddComponent("preserver")
    --inst.components.preserver:SetPerishRateMultiplier(0);

    inst:AddComponent("lootdropper")
    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(3)
    inst.components.workable:SetOnFinishCallback(onhammered)
    inst.components.workable:SetOnWorkCallback(onhit)

    if inst.components.workable then
        local old_Destroy = inst.components.workable.Destroy
        function inst.components.workable:Destroy(destroyer)
            if destroyer.components.playercontroller == nil then
                -- DoNothing
                return ;
            end
            return old_Destroy(self, destroyer)
        end
    end

    inst:ListenForEvent("onbuilt", onbuilt)
    MakeSnowCovered(inst)

    return inst
end

return Prefab(name, fn, assets), MakePlacer(name .. "_placer", "quagmire_drawer", "quagmire_drawer", "closed");