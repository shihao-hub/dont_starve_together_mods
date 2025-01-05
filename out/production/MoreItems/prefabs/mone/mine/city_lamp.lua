---
--- @author zsh in 2023/1/15 1:19
---

local assets = {
    Asset("ANIM", "anim/lamp_post2.zip"),
    Asset("ANIM", "anim/lamp_post2_city_build.zip"),
    Asset("ANIM", "anim/lamp_post2_yotp_build.zip"),
    --Asset("INV_IMAGE", "city_lamp"),
}

local INTENSITY = 0.6

local LAMP_DIST = 16
local LAMP_DIST_SQ = LAMP_DIST * LAMP_DIST

local function UpdateAudio(inst)
    local player = ThePlayer

    -- 开启洞穴后 ThePlayer 不存在
    if not ThePlayer then
        --print("UpdateAudio ThePlayer a nil value");
        return;
    end

    local instPosition = Vector3(inst.Transform:GetWorldPosition())
    local playerPosition = Vector3(player.Transform:GetWorldPosition())
    local lampIsNearby = (distsq(playerPosition, instPosition) < LAMP_DIST_SQ)
    --local clock = TheWorld and TheWorld.components and TheWorld.components["clock"];

    -- TEMP
    -- 播放音乐呢？
    --if TheWorld.state.isdusk and lampIsNearby and not inst.SoundEmitter:PlayingSound("onsound") then
    --    inst.SoundEmitter:PlaySound("dontstarve_DLC003/common/objects/city_lamp/on_LP", "onsound")
    --elseif not lampIsNearby and inst.SoundEmitter:PlayingSound("onsound") then
    --    inst.SoundEmitter:KillSound("onsound")
    --end
end

local function GetStatus(inst)
    return not inst.lighton and "ON" or nil
end

local function fadein(inst)
    inst.components.fader:StopAll()
    inst.AnimState:PlayAnimation("on")
    -- TEMP
    --inst.SoundEmitter:PlaySound("dontstarve_DLC003/common/objects/city_lamp/fire_on")
    inst.AnimState:PushAnimation("idle", true)
    inst.Light:Enable(true)

    if inst:IsAsleep() then
        inst.Light:SetIntensity(INTENSITY)
    else
        inst.Light:SetIntensity(0)
        inst.components.fader:Fade(0, INTENSITY, 3 + math.random() * 2, function(v)
            inst.Light:SetIntensity(v)
        end)
    end
end

local function fadeout(inst)
    inst.components.fader:StopAll()
    inst.AnimState:PlayAnimation("off")
    inst.AnimState:PushAnimation("idle", true)

    if inst:IsAsleep() then
        inst.Light:SetIntensity(0)
    else
        inst.components.fader:Fade(INTENSITY, 0, .75 + math.random() * 1, function(v)
            inst.Light:SetIntensity(v)
        end)
    end
end

local function updatelight(inst)
    if TheWorld.state.isdusk or TheWorld.state.isnight then
        if not inst.lighton then
            inst:DoTaskInTime(math.random() * 2, function()
                fadein(inst)
            end)

        else
            inst.Light:Enable(true)
            inst.Light:SetIntensity(INTENSITY)
        end
        inst.AnimState:Show("FIRE")
        inst.AnimState:Show("GLOW")
        inst.lighton = true
    else
        if inst.lighton then
            inst:DoTaskInTime(math.random() * 2, function()
                fadeout(inst)
            end)
        else
            inst.Light:Enable(false)
            inst.Light:SetIntensity(0)
        end

        inst.AnimState:Hide("FIRE")
        inst.AnimState:Hide("GLOW")

        inst.lighton = false
    end
end

local function setobstical(inst)
    local ground = TheWorld;
    if ground then
        local pt = Vector3(inst.Transform:GetWorldPosition())
        ground.Pathfinder:AddWall(pt.x, pt.y, pt.z)
    end
end

local function clearobstacle(inst)
    local ground = TheWorld;
    if ground then
        local pt = Vector3(inst.Transform:GetWorldPosition())
        ground.Pathfinder:RemoveWall(pt.x, pt.y, pt.z)
    end
end

local function onhammered(inst, worker)

    -- TEMP
    --inst.SoundEmitter:KillSound("onsound")
    --
    --if not inst.components.fixable then
    --    inst.components.lootdropper:DropLoot()
    --end
    --
    --SpawnPrefab("collapse_small").Transform:SetPosition(inst.Transform:GetWorldPosition())
    --inst.SoundEmitter:PlaySound("dontstarve/common/destroy_metal")
    --
    --inst:Remove()

    inst.components.lootdropper:DropLoot()
    local fx = SpawnPrefab("collapse_small")
    fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
    fx:SetMaterial("wood")
    if inst.components.container ~= nil then
        inst.components.container:DropEverything()
    end
    inst:Remove()
end

local function onhit(inst, worker)
    inst.AnimState:PlayAnimation("hit")
    inst.AnimState:PushAnimation("idle", true)
    inst:DoTaskInTime(0.3, function()
        updatelight(inst)
    end)
end

local function onbuilt(inst)
    inst.AnimState:PlayAnimation("place")
    inst.AnimState:PushAnimation("idle", true)
    inst:DoTaskInTime(0, function()
        updatelight(inst)
    end)
end

local function OnEntitySleep(inst)
    if inst.audiotask then
        inst.audiotask:Cancel()
        inst.audiotask = nil
    end
end

local function OnEntityWake(inst)
    if inst.audiotask then
        inst.audiotask:Cancel()
    end
    inst.audiotask = inst:DoPeriodicTask(1.0, function()
        UpdateAudio(inst)
    end, math.random())

    -- TEMP
    --if GetAporkalypse() and GetAporkalypse():GetFiestaActive() then
    --    if inst.build == "lamp_post2_city_build" then
    --        inst.build = "lamp_post2_yotp_build"
    --        inst.AnimState:SetBuild(inst.build)
    --    end
    --elseif inst.build == "lamp_post2_yotp_build" then
    --    inst.build = "lamp_post2_city_build"
    --    inst.AnimState:SetBuild(inst.build)
    --end
end

local function fn(Sim)
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    --MakeObstaclePhysics(inst, 0.25)

    inst.entity:AddLight()
    inst.Light:SetIntensity(INTENSITY)
    inst.Light:SetColour(197 / 255, 197 / 255, 10 / 255)
    inst.Light:SetFalloff(0.9)
    inst.Light:SetRadius(6) -- old:5, 1.25*4
    inst.Light:Enable(false)

    inst.entity:AddMiniMapEntity()
    inst.MiniMapEntity:SetIcon("city_lamp.tex")

    inst.build = "lamp_post2_city_build";
    inst.AnimState:SetBank("lamp_post")
    inst.AnimState:SetBuild(inst.build)
    inst.AnimState:PlayAnimation("idle", true)

    inst.AnimState:Hide("FIRE")
    inst.AnimState:Hide("GLOW")

    inst.AnimState:SetRayTestOnBB(true);

    inst:AddTag("lightsource")
    inst:AddTag("MONE_CITY_LAMP")
    inst:AddTag("structure")
    inst:AddTag("city_hammerable")

    if not TheWorld.ismastersim then
        return inst;
    end

    inst:AddComponent("inspectable")
    inst.components.inspectable.getstatus = GetStatus

    inst:AddComponent("lootdropper")

    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(4)
    inst.components.workable:SetOnFinishCallback(onhammered)
    inst.components.workable:SetOnWorkCallback(onhit)

    inst:AddComponent("fader")

    --inst:ListenForEvent("daytime", function()
    --    inst:DoTaskInTime(1 / 30, function()
    --        updatelight(inst)
    --    end)
    --end, GetWorld())
    --
    --inst:ListenForEvent("dusktime", function()
    --    inst:DoTaskInTime(1 / 30, function()
    --        updatelight(inst)
    --    end)
    --end, GetWorld())

    inst:WatchWorldState("phase", function(inst, phase)
        if phase == "day" then
            inst:DoTaskInTime(1 / 30, function()
                updatelight(inst)
            end)
        end

        if phase == "dusk" then
            inst:DoTaskInTime(1 / 30, function()
                updatelight(inst)
            end)
        end
    end)

    inst:ListenForEvent("onbuilt", onbuilt)

    inst.OnSave = function(inst, data)
        if inst.lighton then
            data.lighton = inst.lighton
        end
    end

    inst.OnLoad = function(inst, data)
        if data then
            if data.lighton then
                fadein(inst)
                inst.Light:Enable(true)
                inst.Light:SetIntensity(INTENSITY)
                inst.AnimState:Show("FIRE")
                inst.AnimState:Show("GLOW")
                inst.lighton = true
            end
        end
    end

    inst.audiotask = inst:DoPeriodicTask(1.0, function()
        UpdateAudio(inst)
    end, math.random())

    -- TEMP
    --inst:AddComponent("fixable")
    --inst.components.fixable:AddRecinstructionStageData("rubble", "lamp_post", "lamp_post2_city_build")

    inst.setobstical = setobstical
    --inst:AddComponent("gridnudger")

    inst.OnEntitySleep = OnEntitySleep
    inst.OnEntityWake = OnEntityWake
    return inst
end

return Prefab("mone_city_lamp", fn, assets),
MakePlacer("mone_city_lamp_placer", "lamp_post", "lamp_post2_city_build", "idle")

