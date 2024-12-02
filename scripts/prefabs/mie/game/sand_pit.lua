---
--- @author zsh in 2023/2/10 9:09
---

local API = require("chang_mone.dsts.API");

require "prefabutil"

local assets = {
    Asset("ANIM", "anim/sand_spike.zip"), -- 官方的沙坑
    Asset("ATLAS", "images/inventoryimages/tall_pre.xml"),
    Asset("IMAGE", "images/inventoryimages/tall_pre.tex"),
    --Asset("MINIMAP_IMAGE", "tall_pre")
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

local function onbuilt(inst)
    inst.AnimState:PlayAnimation("tall_pre")
end

local PLACER_SCALE = 1.82 -- 1.55 虽然和灭火器一样，但是显示为什么这么小。。。

local function OnEnableHelper(inst, enabled)
    if enabled then
        if inst.helper == nil then
            inst.helper = CreateEntity()

            --[[Non-networked entity]]
            inst.helper.entity:SetCanSleep(false)
            inst.helper.persists = false

            inst.helper.entity:AddTransform()
            inst.helper.entity:AddAnimState()

            inst.helper:AddTag("CLASSIFIED")
            inst.helper:AddTag("NOCLICK")
            inst.helper:AddTag("placer")

            inst.helper.Transform:SetScale(PLACER_SCALE, PLACER_SCALE, PLACER_SCALE)

            inst.helper.AnimState:SetBank("firefighter_placement")
            inst.helper.AnimState:SetBuild("firefighter_placement")
            inst.helper.AnimState:PlayAnimation("idle")
            inst.helper.AnimState:SetLightOverride(1)
            inst.helper.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
            inst.helper.AnimState:SetLayer(LAYER_BACKGROUND)
            inst.helper.AnimState:SetSortOrder(1)
            inst.helper.AnimState:SetAddColour(237 / 255, 162 / 255, 0 / 255, 0)

            inst.helper.entity:SetParent(inst.entity)
        end
    elseif inst.helper ~= nil then
        inst.helper:Remove()
        inst.helper = nil
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst.entity:AddMiniMapEntity()
    --inst.MiniMapEntity:SetIcon("tall_pre.png")
    inst.MiniMapEntity:SetIcon("tall_pre.tex")

    inst.Transform:SetScale(0.8, 0.8, 0.8);

    inst:AddTag("structure")
    inst:AddTag("mie_sand_pit")

    -- 微光
    --[[    inst.entity:AddLight()
        inst.Light:SetIntensity(0.1)
        inst.Light:SetRadius(1)
        inst.Light:SetFalloff(1)
        inst.Light:SetColour(1, 1, 1);
        inst.Light:Enable(true)]]

    inst.AnimState:SetBank("sand_spike")
    inst.AnimState:SetBuild("sand_spike")
    inst.AnimState:PlayAnimation("tall_pre")

    --Dedicated server does not need deployhelper
    if not TheNet:IsDedicated() then
        inst:AddComponent("deployhelper")
        inst.components.deployhelper.onenablehelper = OnEnableHelper
    end

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        local old_OnEntityReplicated = inst.OnEntityReplicated
        inst.OnEntityReplicated = function(inst)
            if old_OnEntityReplicated then
                old_OnEntityReplicated(inst)
            end
            if inst.replica and inst.replica.container then
                inst.replica.container:WidgetSetup("mie_sand_pit");
            end
        end
        return inst
    end

    inst:AddComponent("inspectable")
    inst:AddComponent("container");
    inst.components.container:WidgetSetup("mie_sand_pit");
    inst.components.container.onopenfn = function(inst)
        inst.SoundEmitter:PlaySound("dontstarve/wilson/chest_open");
    end
    inst.components.container.onclosefn = function(inst)
        inst.SoundEmitter:PlaySound("dontstarve/wilson/chest_close");
        API.AutoSorter.beginTransfer(inst);
        inst.AnimState:PlayAnimation("tall_pre");
    end

    inst:AddComponent("lootdropper")
    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.DIG)
    inst.components.workable:SetWorkLeft(3)
    inst.components.workable:SetOnFinishCallback(onhammered)

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

    inst:ListenForEvent("onbuilt", onbuilt);

    MakeSnowCovered(inst);

    return inst;
end

return Prefab("mie_sand_pit", fn, assets),
MakePlacer("mie_sand_pit_placer", "sand_spike", "sand_spike", "tall_pre");