---
--- @author zsh in 2023/3/17 10:50
---

require "prefabutil"

local assets = {
    Asset("ANIM", "anim/fish_box.zip"),
    Asset("ANIM", "anim/ui_zx_5x10.zip"),
    Asset("ANIM", "anim/ui_fish_box_3x4.zip"),
    Asset("ANIM", "anim/ui_fish_box_5x4.zip"),
}

local prefabs = {
    "collapse_small",
    "boat_leak",
}

local CONFIG_DATA = TUNING.MIE_TUNING.MOD_CONFIG_DATA;

if CONFIG_DATA.mie_fish_box_animstate then
    assets = {
        Asset("ANIM", "anim/saltbox.zip"),
        Asset("ANIM", "anim/ui_chest_3x3.zip"),
    }
end

local AnimStateMap = {
    bank = "fish_box";
    build = "fish_box";
    animation = "closed";
}
local MiniMapMap = {
    icon = "fish_box.png";
}
if CONFIG_DATA.mie_fish_box_animstate then
    AnimStateMap = {
        bank = "saltbox";
        build = "saltbox";
        animation = "closed";
    }
    MiniMapMap = {
        icon = "saltbox.png";
    }
end

local FISH_BOX_SCALE = 1.3

if CONFIG_DATA.mie_fish_box_animstate then
    FISH_BOX_SCALE = 1.1;
end

local function onopen(inst)
    inst.AnimState:PlayAnimation("open")
    inst.AnimState:PushAnimation("opened", false)
    inst.SoundEmitter:PlaySound("hookline/common/fishbox/open")
end

local function onclose(inst)
    inst.AnimState:PlayAnimation("close")
    inst.AnimState:PushAnimation("closed", false)
    inst.SoundEmitter:PlaySound("hookline/common/fishbox/close")
end

local function onhammered(inst, worker)
    if inst.components.lootdropper then
        inst.components.lootdropper:DropLoot();
    end
    if inst.components.container then
        inst.components.container:DropEverything();
    end
    local fx = SpawnPrefab("collapse_small");
    fx.Transform:SetPosition(inst.Transform:GetWorldPosition());
    fx:SetMaterial("wood");
    inst:Remove();
end

local function onhit(inst, worker)
    if inst.components.container ~= nil then
        if not inst.components.container:IsOpen() then
            inst.AnimState:PlayAnimation("hit_closed")
            inst.AnimState:PushAnimation("closed")
        end

        inst.components.container:Close()
    end
end

local function onbuilt(inst)
    inst.AnimState:PlayAnimation("place", false)
    inst.AnimState:PushAnimation("closed", false)
    inst.SoundEmitter:PlaySound("hookline/common/fishbox/place")
end

if CONFIG_DATA.mie_fish_box_animstate then
    onopen = function(inst)
        inst.AnimState:PlayAnimation("open")
        inst.SoundEmitter:PlaySound("saltydog/common/saltbox/open")
    end
    onclose = function(inst)
        inst.AnimState:PlayAnimation("close")
        inst.SoundEmitter:PlaySound("saltydog/common/saltbox/close")
    end
    onhammered = function(inst, worker)
        inst.components.lootdropper:DropLoot()
        inst.components.container:DropEverything()
        local fx = SpawnPrefab("collapse_small")
        fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
        fx:SetMaterial("metal")
        inst:Remove()
    end
    onhit = function(inst, worker)
        inst.AnimState:PlayAnimation("hit")
        inst.components.container:DropEverything()
        inst.AnimState:PushAnimation("closed", false)
        inst.components.container:Close()
    end
    onbuilt = function(inst)
        inst.AnimState:PlayAnimation("place")
        inst.AnimState:PushAnimation("closed", false)
        inst.SoundEmitter:PlaySound("saltydog/common/saltbox/place")
    end
end

local function OnSink(inst)
    if inst:GetCurrentPlatform() == nil and not TheWorld.Map:IsDockAtPoint(inst.Transform:GetWorldPosition()) then
        inst.components.workable:Destroy(inst)
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

    inst.Transform:SetScale(FISH_BOX_SCALE, FISH_BOX_SCALE, FISH_BOX_SCALE)

    inst.MiniMapEntity:SetPriority(4)
    inst.MiniMapEntity:SetIcon(MiniMapMap.icon)

    inst:AddTag("structure")
    inst:AddTag("mie_fish_box")
    inst:AddTag("more_items_fridge");

    inst.AnimState:SetBank(AnimStateMap.bank)
    inst.AnimState:SetBuild(AnimStateMap.build)
    inst.AnimState:PlayAnimation(AnimStateMap.animation)

    MakeSnowCoveredPristine(inst)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        local old_OnEntityReplicated = inst.OnEntityReplicated
        inst.OnEntityReplicated = function(inst)
            if old_OnEntityReplicated then
                old_OnEntityReplicated(inst)
            end
            if inst and inst.replica and inst.replica.container then
                inst.replica.container:WidgetSetup("mie_fish_box");
            end
        end
        return inst
    end

    inst:AddComponent("inspectable")
    inst:AddComponent("lootdropper")

    inst:AddComponent("container")
    inst.components.container:WidgetSetup("mie_fish_box")
    inst.components.container.onopenfn = onopen
    inst.components.container.onclosefn = onclose
    inst.components.container.skipclosesnd = true
    inst.components.container.skipopensnd = true

    inst:AddComponent("preserver")
    inst.components.preserver:SetPerishRateMultiplier(0.1);

    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(4)
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

    MakeSnowCovered(inst)

    AddHauntableDropItemOrWork(inst)

    inst:ListenForEvent("onbuilt", onbuilt)

    return inst
end

return Prefab("mie_fish_box", fn, assets, prefabs),
MakePlacer("mie_fish_box_placer", AnimStateMap.bank, AnimStateMap.build, AnimStateMap.animation, nil, nil, nil, FISH_BOX_SCALE)
