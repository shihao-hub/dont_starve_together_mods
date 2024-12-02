---
--- @author zsh in 2023/2/9 17:02
---

require "prefabutil"

local easing = require("easing")

local assets = {
    Asset("ANIM", "anim/winona_battery_placement.zip"),
    Asset("ANIM", "anim/boat_waterpump.zip"),
    Asset("INV_IMAGE", "waterpump_item"),
}

local prefabs = {
    "waterstreak_projectile",
    "collapse_small",
}

local DIST = 15;

local function onhammered(inst, worker)
    local x, y, z = inst.Transform:GetWorldPosition()

    if inst.components.burnable ~= nil and inst.components.burnable:IsBurning() then
        inst.components.burnable:Extinguish()
    end

    inst.components.lootdropper:DropLoot()
    local fx = SpawnPrefab("collapse_small")
    fx.Transform:SetPosition(x, y, z)
    fx:SetMaterial("wood")
    inst:Remove()
end

local function cancel_channeling(inst)
    if inst.channeler ~= nil and inst.channeler:IsValid() then
        inst.channeler:PushEvent("cancel_channel_longaction")
    end
end

local function onhit(inst, worker)
    if not inst:HasTag("burnt") and not inst.channeler then
        inst.AnimState:PlayAnimation("use_pst")
    end
end

local function CancelReadyTask(inst)
    if inst._ready_task ~= nil then
        inst._ready_task:Cancel()
        inst._ready_task = nil
    end
end

local function CancelLaunchProjectileTask(inst)
    if inst._launch_projectile_task ~= nil then
        inst._launch_projectile_task:Cancel()
        inst._launch_projectile_task = nil
    end
end

local function onburnt(inst)
    cancel_channeling(inst)

    CancelReadyTask(inst)
    CancelLaunchProjectileTask(inst)
    if inst.channeler then
        inst:OnStopChanneling()
    end

    inst:RemoveComponent("channelable")
end

local function LaunchWaterstreakProjectile(inst, x, y, z, targetpos)
    local projectile = SpawnPrefab("waterstreak_projectile")

    if projectile.components.wateryprotection then
        projectile.components.wateryprotection.addwetness = TUNING.WATERBALLOON_ADD_WETNESS * 2.5; -- value = 20
    end
    projectile.Transform:SetPosition(x, 5, z)

    local dx = targetpos.x - x
    local dz = targetpos.z - z
    local rangesq = dx * dx + dz * dz
    local maxrange = TUNING.WATERPUMP.MAXRANGE;
    local speed = easing.linear(rangesq, 8, 3, maxrange * maxrange)
    projectile.components.complexprojectile:SetHorizontalSpeed(speed)
    projectile.components.complexprojectile:SetGravity(-25)
    projectile.components.complexprojectile:Launch(targetpos, inst, inst)
end

local NOTAGS = { "FX", "INLIMBO", "burnt", "player", "monster" } --{ "FX", "NOCLICK", "DECOR", "INLIMBO", "burnt", "player", "monster" }
local ONEOFTAGS = { "fire", "smolder", "wateringcan", "needwater", "mie_nutrients_overlay" }

-- 只有这个函数是最最最重要的函数！
local function LaunchProjectile(inst)
    CancelLaunchProjectileTask(inst)

    local x, y, z = inst.Transform:GetWorldPosition()

    local DIST = DIST; -- 差不多也算是个九宫格范围吧！
    local ents = TheSim:FindEntities(x, y, z, DIST, nil, NOTAGS, ONEOFTAGS)
    local targetpos;
    local upvaluedebug = require("mie.upvaluedebug");
    local _moisturegrid;
    if TheWorld and TheWorld.components and TheWorld.components.farming_manager then
        local old_IsSoilMoistAtPoint = TheWorld.components.farming_manager.IsSoilMoistAtPoint;
        if old_IsSoilMoistAtPoint then
            _moisturegrid = upvaluedebug.GetLocalValue(old_IsSoilMoistAtPoint, "_moisturegrid", nil, true);
        end
    end
    --print("_moisturegrid: " .. tostring(_moisturegrid));
    --print("#ents: " .. tostring(#ents));

    --for _, v in ipairs(ents) do
    --    print("    " .. tostring(v));
    --end

    local cnt = 0;
    local max_number = 4;
    for _, v in ipairs(ents) do
        local vpos = v:GetPosition();
        local vx, vy, vz = vpos.x, vpos.y, vpos.z;
        if vx and vy and vz then
            if v:HasTag("fire") or v:HasTag("smolder") then
                targetpos = vpos;
                cnt = cnt + 1;
            elseif v:HasTag("wateringcan") then
                if v.components.finiteuses and v.components.finiteuses:GetPercent() < 1 then
                    v.components.finiteuses:SetPercent(1);
                    targetpos = vpos;
                    cnt = cnt + 1;
                end
            elseif v:HasTag("needwater") or v:HasTag("mie_nutrients_overlay") then
                --if v:HasTag("needwater") then
                --    print("    needwater");
                --end
                --if v:HasTag("mie_nutrients_overlay") then
                --    print("    mie_nutrients_overlay");
                --end
                print();
                local soilmoisture = _moisturegrid and _moisturegrid:GetDataAtPoint(TheWorld.Map:GetTileCoordsAtPoint(vx, vy, vz));
                --print("soilmoisture: " .. tostring(soilmoisture))
                if soilmoisture and soilmoisture < 0.5 * TUNING.SOIL_MAX_MOISTURE_VALUE then
                    targetpos = vpos;
                    cnt = cnt + 1;
                end
            end
        end

        if targetpos then
            LaunchWaterstreakProjectile(inst, x, y, z, targetpos);
        end

        if cnt >= max_number then
            break ;
        end
    end

    -- 随机发射
    if targetpos == nil then
        local theta = math.random() * 2 * PI
        local offset = math.random() * DIST
        targetpos = Point(x + math.cos(theta) * offset, 0, z + math.sin(theta) * offset)

        LaunchWaterstreakProjectile(inst, x, y, z, targetpos);
    end
end

local function onbuilt(inst)
    inst.AnimState:PlayAnimation("place")
    inst.SoundEmitter:PlaySound("dangerous_sea/common/water_pump/place")
    inst.AnimState:Show("fx");
end

local PLACER_SCALE = 1.82

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

            inst.helper.AnimState:SetBank("winona_battery_placement")
            inst.helper.AnimState:SetBuild("winona_battery_placement")
            inst.helper.AnimState:PlayAnimation("idle")
            inst.helper.AnimState:SetLightOverride(1)
            inst.helper.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
            inst.helper.AnimState:SetLayer(LAYER_BACKGROUND)
            inst.helper.AnimState:SetSortOrder(1)
            --inst.helper.AnimState:SetAddColour(0, .2, .5, 0)
            inst.helper.AnimState:SetAddColour(255 / 255, 66 / 255, 51 / 255, 0)
            inst.helper.AnimState:Hide("inner")

            inst.helper.entity:SetParent(inst.entity)
        end
    elseif inst.helper ~= nil then
        inst.helper:Remove()
        inst.helper = nil
    end
end

local function startprojectilelaunch(inst)
    inst.AnimState:PlayAnimation("use_loop")
    if not inst.SoundEmitter:PlayingSound("pump") then
        inst.SoundEmitter:PlaySound("dangerous_sea/common/water_pump/LP", "pump")
    end

    inst._launch_projectile_task = inst:DoTaskInTime(7 * FRAMES, LaunchProjectile);
end

local function OnStartChanneling(inst, channeler)
    inst.channeler = channeler
    inst.AnimState:PlayAnimation("use_pre")
    inst:ListenForEvent("animover", startprojectilelaunch);

    ---- TEMP
    inst.farmplanttendable_task = inst:DoTaskInTime(7 * FRAMES, function(inst)
        local x, y, z = inst.Transform:GetWorldPosition()
        if x and y and z then
            local DIST = DIST;
            local MUST_TAGS = { "tendable_farmplant" }
            local CANT_TAGS = { "FX", "DECOR", "INLIMBO" }
            local ents = TheSim:FindEntities(x, y, z, DIST, MUST_TAGS, CANT_TAGS);
            for _, v in ipairs(ents) do
                if v.components.farmplanttendable then
                    v.components.farmplanttendable:TendTo(channeler);
                end
            end
        end
    end)

    inst.AnimState:Show("fx");
end

local function OnStopChanneling(inst)
    inst:RemoveEventCallback("animover", startprojectilelaunch)
    inst.channeler = nil
    if inst._launch_projectile_task then
        inst._launch_projectile_task:Cancel()
        inst._launch_projectile_task = nil
    end
    inst.SoundEmitter:KillSound("pump")
    if not inst:HasTag("burnt") then
        inst.AnimState:PlayAnimation("use_pst", false)
        inst.AnimState:PushAnimation("idle")
    end

    -- TEMP
    if inst.farmplanttendable_task then
        inst.farmplanttendable_task:Cancel();
        inst.farmplanttendable_task = nil;
    end
end

--[[local function farmplanttendable_task(inst, doer_save_record)
    local doer = SpawnSaveRecord(doer_save_record);
    doer.persists = false; -- 2023-02-10-00:12 我不需要这样啊。。。inst 添加一些组件当 doer 不就行了吗！
    inst.farmplanttendable_task = inst:DoPeriodicTask(7 * FRAMES, function(inst)
        local x, y, z = inst.Transform:GetWorldPosition()
        if x and y and z then
            local DIST = DIST;
            local MUST_TAGS = { "tendable_farmplant" }
            local CANT_TAGS = { "FX", "DECOR", "INLIMBO" }
            local ents = TheSim:FindEntities(x, y, z, DIST, MUST_TAGS, CANT_TAGS);
            for _, v in ipairs(ents) do
                if v.components.farmplanttendable then
                    v.components.farmplanttendable:TendTo(doer);
                end
            end
        end
    end)
end]]

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst.entity:AddMiniMapEntity();
    inst.MiniMapEntity:SetIcon("waterpump_item.tex")

    --MakeObstaclePhysics(inst, .25)
    inst:SetPhysicsRadiusOverride(0.25)

    inst.AnimState:SetBank("boat_waterpump")
    inst.AnimState:SetBuild("boat_waterpump")
    inst.AnimState:PlayAnimation("idle")

    inst:AddTag("structure")
    inst:AddTag("pump")

    --Dedicated server does not need deployhelper
    if not TheNet:IsDedicated() then
        inst:AddComponent("deployhelper")
        inst.components.deployhelper.onenablehelper = OnEnableHelper
    end

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")

    --[[    inst:AddComponent("trader")
        inst.components.trader:SetAbleToAcceptTest(function(inst, item, giver)
            if inst.has_fruitflyfruit then
                inst.components.talker:Say("不要再给我了，我已经吃饱了！");
            end
            if inst.has_fruitflyfruit == nil and item.prefab == "fruitflyfruit" then
                inst.SoundEmitter:PlaySound("terraria1/eyemask/eat");
                inst.has_fruitflyfruit = true;
                inst.doer_save_record = item:GetSaveRecord();
                farmplanttendable_task(inst, inst.doer_save_record);
                if item.components.leader then
                    local followers = item.components.leader.followers or {};
                    for k, v in pairs(followers) do
                        if k and k.prefab == "friendlyfruitfly" then
                            if k.components.health then
                                k.components.health:DoDelta(-k.components.health.maxhealth);
                            end
                        end
                    end
                end
                item:Remove();
                return true;
            end
            --return true; -- 如果永远都是 true 会发生什么事情？回答：消失了。
        end)]]

    inst:AddComponent("talker")

    inst:AddComponent("channelable")
    inst.components.channelable:SetChannelingFn(OnStartChanneling, OnStopChanneling)
    inst.components.channelable.use_channel_longaction = true
    inst.components.channelable.skip_state_channeling = true
    inst.components.channelable.skip_state_stopchanneling = true
    inst.components.channelable.ignore_prechannel = true

    inst:ListenForEvent("channel_finished", OnStopChanneling)

    inst.OnStopChanneling = OnStopChanneling

    inst:AddComponent("lootdropper")
    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(3)
    inst.components.workable:SetOnFinishCallback(onhammered)
    inst.components.workable:SetOnWorkCallback(onhit)

    MakeHauntableWork(inst)

    inst:ListenForEvent("onbuilt", onbuilt)
    inst:ListenForEvent("onremove", cancel_channeling)

    --[[    inst.OnSave = function(inst, data)
            data.has_fruitflyfruit = inst.has_fruitflyfruit;
            data.doer_save_record = inst.doer_save_record;
        end

        inst.OnLoad = function(inst, data)
            if data then
                if data.has_fruitflyfruit then
                    inst.has_fruitflyfruit = data.has_fruitflyfruit;
                    inst.doer_save_record = data.doer_save_record;

                    -- DoSomething
                    farmplanttendable_task(inst, inst.doer_save_record);
                end
            end
        end]]

    return inst
end

local function placer_postinit_fn(inst)
    --Show the waterpump placer on top of the range ground placer

    inst.AnimState:Hide("inner")

    local placer2 = CreateEntity()

    --[[Non-networked entity]]
    placer2.entity:SetCanSleep(false)
    placer2.persists = false

    placer2.entity:AddTransform()
    placer2.entity:AddAnimState()

    placer2:AddTag("CLASSIFIED")
    placer2:AddTag("NOCLICK")
    placer2:AddTag("placer")

    local s = 1 / PLACER_SCALE
    placer2.Transform:SetScale(s, s, s)

    placer2.AnimState:SetBank("boat_waterpump")
    placer2.AnimState:SetBuild("boat_waterpump")
    placer2.AnimState:PlayAnimation("idle")
    placer2.AnimState:SetLightOverride(1)

    placer2.entity:SetParent(inst.entity)

    inst.components.placer:LinkEntity(placer2)
end

return Prefab("mie_waterpump", fn, assets, prefabs),
MakePlacer("mie_waterpump_placer", "winona_battery_placement", "winona_battery_placement", "idle", true, nil, nil, PLACER_SCALE, nil, nil, placer_postinit_fn)
