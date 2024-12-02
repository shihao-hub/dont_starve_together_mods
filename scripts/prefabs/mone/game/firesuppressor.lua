---
--- @author zsh in 2023/1/9 20:26
---

local API = require("chang_mone.dsts.API");
local TEXT = require("languages.mone.loc");

require "prefabutil"

local easing = require("easing")

local assets = {
    Asset("ANIM", "anim/firefighter.zip"),
    Asset("ANIM", "anim/firefighter_placement.zip"),
    Asset("ANIM", "anim/firefighter_meter.zip"),
}

local glow_assets = {
    Asset("ANIM", "anim/firefighter_glow.zip"),
}

local prefabs = {
    "snowball",
    "collapse_small",
    "firesuppressor_glow",
}

local FIRE_DETECTOR_RANGE = TUNING.__FIRE_DETECTOR_RANGE__;

local DIST = FIRE_DETECTOR_RANGE;

local function surroundHasPerson(inst)
    if inst:IsAsleep() then
        return false;
    end
    return true;
    --local x, y, z = inst.Transform:GetWorldPosition();
    --if #TheSim:FindEntities(x, y, z, DIST, { "player" }) > 0 then
    --    return true;
    --end
    --return false;
end

local function autofn(inst)
    -- 1 秒？ 3 秒？ 5 秒？ 10 秒？
    inst:DoPeriodicTask(TUNING.MONE_TUNING.AUTO_SORTER.nFullInterval, function(inst)
        if surroundHasPerson(inst) then
            if not inst.components.container:IsFull() then
                API.AutoSorter.pickObjectOnFloor(inst);
            end
            API.AutoSorter.beginTransfer(inst);
        end
    end)
end

--Called from stategraph
local function LaunchProjectile(inst, targetpos)
    local x, y, z = inst.Transform:GetWorldPosition()

    local projectile = SpawnPrefab("snowball")

    -- 先用这种方式吧！但这功能实现了就行。
    if TUNING.MONE_TUNING.AUTO_SORTER.auto_sorter_notags_extra then
        local old_ignoretags;
        if projectile.components.wateryprotection then
            old_ignoretags = deepcopy(projectile.components.wateryprotection.ignoretags); -- 表是引用，所以我必须如此吧？
            table.insert(projectile.components.wateryprotection.ignoretags, "campfire");
        end

        projectile:DoTaskInTime(10, function(projectile, data)
            if projectile and projectile:IsValid() and type(old_ignoretags) == "table" then
                projectile.components.wateryprotection.ignoretags = old_ignoretags;
            end
        end)
    end

    projectile.Transform:SetPosition(x, y, z)

    --V2C: scale the launch speed based on distance
    --     because 15 does not reach our max range.
    local dx = targetpos.x - x
    local dz = targetpos.z - z
    local rangesq = dx * dx + dz * dz
    local maxrange = FIRE_DETECTOR_RANGE
    local speed = easing.linear(rangesq, FIRE_DETECTOR_RANGE, 3, maxrange * maxrange)
    projectile.components.complexprojectile:SetHorizontalSpeed(speed)
    projectile.components.complexprojectile:SetGravity(-25)
    projectile.components.complexprojectile:Launch(targetpos, inst, inst)
end

local function SpreadProtectionAtPoint(inst, firePos)
    inst.components.wateryprotection:SpreadProtectionAtPoint(firePos:Get())
end

local function OnFindFire(inst, firePos)
    if inst:IsAsleep() then
        inst:DoTaskInTime(1 + math.random(), SpreadProtectionAtPoint, firePos)
    else
        -- Question: 待解决问题：灌溉的时候也会探测到营火，所以灌溉在哪里的？

        inst:PushEvent("putoutfire", { firePos = firePos })
    end
end

local WarningColours = {
    green = { 163 / 255, 255 / 255, 186 / 255 },
    yellow = { 255 / 255, 228 / 255, 81 / 255 },
    red = { 255 / 255, 146 / 255, 146 / 255 },
}

local function GetWarningLevelLight(level)
    return (level == nil and "off")
            or (level <= 0 and "green")
            or (level <= TUNING.EMERGENCY_BURNT_NUMBER and "yellow")
            or "red"
end

local function SetWarningLevelLight(inst, level)
    local anim = GetWarningLevelLight(level)
    if inst._warninglevel ~= anim then
        inst._warninglevel = anim
        if WarningColours[anim] ~= nil then
            inst.Light:SetColour(unpack(WarningColours[anim]))
            inst.Light:Enable(true)
            inst._glow.AnimState:PlayAnimation(anim, true)
            inst._glow._ison:set(true)
        else
            inst.Light:Enable(false)
            inst._glow._ison:set(false)
        end
    end
end

local function TurnOff(inst, instant)
    inst.on = false
    inst.components.firedetector:Deactivate()

    if not inst:HasTag("fueldepleted") then
        local randomizedStartTime = POPULATING
        inst:DoTaskInTime(0, inst.components.firedetector:ActivateEmergencyMode(randomizedStartTime)) -- this can be called from onload, so make sure everything is set up first
    end

    inst.components.fueled:StopConsuming()

    SetWarningLevelLight(inst, nil)
    inst.sg:GoToState(instant and "idle_off" or "turn_off")

    if TUNING.MONE_TUNING.AUTO_SORTER.whetherIsFull == 0 or TUNING.MONE_TUNING.AUTO_SORTER.whetherIsFull == 1 then
        if inst.mone_task then
            inst.mone_task:Cancel();
            inst.mone_task = nil;
        end
    end
end

local function TurnOn(inst, instant)
    inst.on = true
    local isemergency = inst.components.firedetector:IsEmergency()
    if not isemergency then
        local randomizedStartTime = POPULATING
        inst.components.firedetector:Activate(randomizedStartTime)
        SetWarningLevelLight(inst, 0)
    end
    inst.components.fueled:StartConsuming()
    inst.sg:GoToState(instant and "idle_on" or (inst.sg:HasStateTag("light") and "turn_on_light" or "turn_on"), isemergency == true--[[must not be nil]])

    if TUNING.MONE_TUNING.AUTO_SORTER.whetherIsFull == 0 or TUNING.MONE_TUNING.AUTO_SORTER.whetherIsFull == 1 then
        if inst.mone_task then
            inst.mone_task:Cancel();
            inst.mone_task = nil;
        end

        inst.mone_task = inst:DoPeriodicTask(TUNING.MONE_TUNING.AUTO_SORTER.nFullInterval, function(inst)
            if surroundHasPerson(inst) then
                if not inst.components.container:IsFull() then
                    API.AutoSorter.pickObjectOnFloor(inst);
                end
                API.AutoSorter.beginTransfer(inst);
            end
        end)
    end

end

local function OnBeginEmergency(inst, level)
    SetWarningLevelLight(inst, math.huge)
    if not inst.on then
        inst.components.machine:TurnOn()
    end
end

local function OnEndEmergency(inst, level)
    if inst.on then
        inst.components.machine:TurnOff()
    end
end

local function OnBeginWarning(inst, level)
    SetWarningLevelLight(inst, level)
    if not inst.on then
        inst.sg:GoToState("light_on")
    end
end

local function OnUpdateWarning(inst, level)
    SetWarningLevelLight(inst, level)
    --inst:PushEvent("warninglevelchanged", { level = level })
end

local function OnEndWarning(inst, level)
    SetWarningLevelLight(inst, nil)
    if not inst.on then
        inst.sg:GoToState("light_off")
    end
end

local function OnFuelEmpty(inst)
    inst.components.machine:TurnOff()
end

local function OnAddFuel(inst)
    inst.SoundEmitter:PlaySound("dontstarve_DLC001/common/machine_fuel")
    if inst.on == false then
        inst.components.machine:TurnOn()
    end
end

local function OnFuelSectionChange(new, old, inst)
    if inst._fuellevel ~= new then
        inst._fuellevel = new

        local skin_build = inst:GetSkinBuild()
        if skin_build ~= nil then
            inst.AnimState:OverrideItemSkinSymbol("swap_meter", skin_build, tostring(new), inst.GUID, "firefighter_meter")
        else
            inst.AnimState:OverrideSymbol("swap_meter", "firefighter_meter", tostring(new))
        end
    end
end

local function CanInteract(inst)
    return not inst.components.fueled:IsEmpty()
end

local function onhammered(inst, worker)
    if inst.components.burnable ~= nil and inst.components.burnable:IsBurning() then
        inst.components.burnable:Extinguish()
    end

    -- 扩充
    if inst.components.container ~= nil then
        inst.components.container:DropEverything();
    end

    inst.SoundEmitter:KillSound("firesuppressor_idle")
    inst.components.lootdropper:DropLoot()
    local fx = SpawnPrefab("collapse_small")
    fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
    fx:SetMaterial("metal")
    inst:Remove()
end

local function onhit(inst, worker)
    if not (inst:HasTag("burnt") or inst.sg:HasStateTag("busy")) then
        inst.sg:GoToState("hit", inst.sg:HasStateTag("light"))
    end
end

local function getstatus(inst, viewer)
    --if inst.on then
    return inst.components.fueled ~= nil
            and inst.components.fueled.currentfuel / inst.components.fueled.maxfuel <= .25
            and "LOWFUEL"
            or "ON"
    --else
    --return "OFF"
    --end
end

local function OnEntitySleep(inst)
    inst.SoundEmitter:KillSound("firesuppressor_idle")
end

local function OnRemoveEntity(inst)
    inst._glow:Remove()
end

local function onsave(inst, data)
    if inst:HasTag("burnt") or (inst.components.burnable ~= nil and inst.components.burnable:IsBurning()) then
        data.burnt = true
    end
end

local function onload(inst, data)
    if data ~= nil and data.burnt and inst.components.burnable ~= nil and inst.components.burnable.onburnt ~= nil then
        inst.components.burnable.onburnt(inst)
    end
end

--V2C: Don't do this?
--     I believe all the affected components save their protected state already
--[[
local function OnLoadPostPass(inst)
    if not inst.components.fueled:IsEmpty() then
        inst.components.wateryprotection:SpreadProtection(inst, TUNING.FIRE_DETECTOR_RANGE, true)
    end
end]]

local function oninit(inst)
    inst._glow.Follower:FollowSymbol(inst.GUID, "swap_glow", 0, 0, 0)
end

local function onbuilt(inst)
    inst.SoundEmitter:PlaySound("dontstarve_DLC001/common/firesupressor_craft")
end

--------------------------------------------------------------------------
local PLACER_SCALE = 1.55

if FIRE_DETECTOR_RANGE == 20 then
    PLACER_SCALE = 1.77
end

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
            inst.helper.AnimState:SetAddColour(0, .2, .5, 0)

            inst.helper.entity:SetParent(inst.entity)
        end
    elseif inst.helper ~= nil then
        inst.helper:Remove()
        inst.helper = nil
    end
end

--------------------------------------------------------------------------

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddLight()
    inst.entity:AddNetwork()

    inst.MiniMapEntity:SetPriority(5)
    inst.MiniMapEntity:SetIcon("firesuppressor.png")

    MakeObstaclePhysics(inst, 1)

    inst.AnimState:SetBank("firefighter")
    inst.AnimState:SetBuild("firefighter")
    inst.AnimState:PlayAnimation("idle_off")
    inst.AnimState:OverrideSymbol("swap_meter", "firefighter_meter", "10")

    inst:AddTag("hasemergencymode")
    inst:AddTag("structure")
    inst:AddTag("mone_firesuppressor");

    inst.Light:SetIntensity(.4)
    inst.Light:SetRadius(.8)
    inst.Light:SetFalloff(1)
    inst.Light:SetColour(unpack(WarningColours.green))
    inst.Light:Enable(false)

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
                inst.replica.container:WidgetSetup("mone_firesuppressor");
            end
        end
        return inst
    end

    inst._warninglevel = "off"
    inst._fuellevel = 10

    inst._glow = SpawnPrefab("firesuppressor_glow")
    inst:DoTaskInTime(0, oninit)
    inst:ListenForEvent("onbuilt", onbuilt)

    inst:AddComponent("inspectable")
    inst.components.inspectable.getstatus = getstatus

    inst:AddComponent("machine")
    inst.components.machine.turnonfn = TurnOn
    inst.components.machine.turnofffn = TurnOff
    inst.components.machine.caninteractfn = CanInteract
    inst.components.machine.cooldowntime = 0.5

    -- 扩充
    inst:AddComponent("container");
    inst.components.container:WidgetSetup("mone_firesuppressor");
    inst.components.container.onopenfn = function(inst)
        inst.SoundEmitter:PlaySound("dontstarve/wilson/chest_open");
    end
    inst.components.container.onclosefn = function(inst)
        inst.SoundEmitter:PlaySound("dontstarve/wilson/chest_close");

        API.AutoSorter.beginTransfer(inst);
    end


    -- 全自动
    if TUNING.MONE_TUNING.AUTO_SORTER.whetherIsFull == 2 then
        autofn(inst);
    end

    -- 夜间发光（绑定一个发光实体）
    if TUNING.MONE_TUNING.AUTO_SORTER.auto_sorter_light then
        inst:DoTaskInTime(0.1, function(inst)
            inst._mone_light_fx = inst._mone_light_fx or SpawnPrefab("mone_light_fx");
            -- 修改特效的照明范围以及添加标签
            do
                inst._mone_light_fx.Light:SetRadius(DIST - 3);
                inst._mone_light_fx:AddTag("daylight"); -- 让作物在夜间也能生长
            end
            inst._mone_light_fx._mone_firesuppressor = inst;
            inst._mone_light_fx.entity:SetParent(inst.entity);
        end);
    end

    inst:AddComponent("fueled")
    inst.components.fueled:SetDepletedFn(OnFuelEmpty)
    inst.components.fueled:SetTakeFuelFn(OnAddFuel)
    inst.components.fueled.accepting = true
    inst.components.fueled:SetSections(10)
    inst.components.fueled:SetSectionCallback(OnFuelSectionChange)
    inst.components.fueled:InitializeFuelLevel(TUNING.FIRESUPPRESSOR_MAX_FUEL_TIME)
    inst.components.fueled.bonusmult = 5
    inst.components.fueled.secondaryfueltype = FUELTYPE.CHEMICAL

    -- 不消耗燃料
    if TUNING.MONE_TUNING.AUTO_SORTER.auto_sorter_no_fuel then
        inst.components.fueled.StartConsuming = function(self)
            self:StopConsuming();
        end
        inst.components.fueled:StopConsuming();
        inst.components.fueled.rate = 0;
        inst.components.fueled:SetPercent(1);
    end

    inst:AddComponent("firedetector")
    inst.components.firedetector:SetOnFindFireFn(OnFindFire)
    inst.components.firedetector:SetOnBeginEmergencyFn(OnBeginEmergency)
    inst.components.firedetector:SetOnEndEmergencyFn(OnEndEmergency)
    inst.components.firedetector:SetOnBeginWarningFn(OnBeginWarning)
    inst.components.firedetector:SetOnUpdateWarningFn(OnUpdateWarning)
    inst.components.firedetector:SetOnEndWarningFn(OnEndWarning)
    inst.components.firedetector.range=FIRE_DETECTOR_RANGE;

    if TUNING.MONE_TUNING.AUTO_SORTER.auto_sorter_notags_extra then
        -- Question: 修改上值，确确实实修改了 NOTAGS 的值，但是这居然是永久修改。
        do
            -- upvaluehelper
            local upvaluehelper = require("chang_mone.dsts.upvaluehelper");
            local success = false;
            local old_Activate = inst.components.firedetector.Activate;
            local function SetNOTAGS()
                if not success then
                    if old_Activate then
                        local LookForFiresAndFirestarters = upvaluehelper.Get(old_Activate, "LookForFiresAndFirestarters");
                        --print("--1: "..tostring(LookForFiresAndFirestarters));
                        if type(LookForFiresAndFirestarters) == "function" then
                            local NOTAGS = upvaluehelper.Get(LookForFiresAndFirestarters, "NOTAGS");
                            --print("--2: "..tostring(NOTAGS));
                            if type(NOTAGS) == "table" then
                                table.insert(NOTAGS, "campfire");
                                success = true;

                                local msg = {};
                                for _, v in ipairs(NOTAGS) do
                                    table.insert(msg, v);
                                end
                                print(table.concat(msg, ","));
                            end
                        end
                    end
                end
            end
        end

        function inst.components.firedetector:Activate(randomizedStartTime)
            local build_in_vars_fns = {
                Cancel = function(inst, self)
                    if self.detectTask ~= nil then
                        self.detectTask:Cancel()
                        self.detectTask = nil
                    end
                    if self.emergencyShutdownTask ~= nil then
                        self.emergencyShutdownTask:Cancel()
                        self.emergencyShutdownTask = nil
                        self.emergencyShutdownTime = nil
                    end
                    if self.emergencyWatched ~= nil then
                        for k, v in pairs(self.emergencyWatched) do
                            inst:RemoveEventCallback("onburnt", v.onburnt, k)
                            inst:RemoveEventCallback("onremove", v.onremove, k)
                        end
                        self.emergencyWatched = nil
                    end
                    self.emergencyBurnt = nil
                    self.emergencyLevel = 0
                    self.emergency = false
                    self.warningStartTime = nil
                end,
                LookForFiresAndFirestarters = function(inst, self, force)
                    local build_in_vars_fns = {
                        NOTAGS = { "FX", "NOCLICK", "DECOR", "INLIMBO", "burnt", "player", "monster" },
                        NONEMERGENCYTAGS = { "witherable", "fire", "smolder" },
                        NONEMERGENCY_FIREONLY_TAGS = { "fire", "smolder" },
                        CheckTargetScore = function(target)
                            if not target:IsValid() then
                                return 0
                            elseif target.components.burnable ~= nil then
                                if target.components.burnable:IsBurning() then
                                    return 10, true --Burning, highest priority so no need to keep testing others
                                elseif target.components.burnable:IsSmoldering() then
                                    return 9 --Smoldering
                                end
                            end
                            if target.components.witherable == nil or target.components.witherable:IsProtected() then
                                return 0
                            elseif target.components.witherable:CanWither() then
                                return 8 --Withering
                            elseif target.components.witherable:CanRejuvenate() then
                                return 7 --Withered but can be rejuvenated
                            end
                            return 0
                        end,
                        RegisterDetectedItem = function(inst, self, target)
                            self.detectedItems[target] = inst:DoTaskInTime(2, function(inst, self, target)
                                self.detectedItems[target] = nil
                            end, self, target)
                        end
                    }

                    table.insert(build_in_vars_fns.NOTAGS, "campfire");

                    if not force and inst.sg ~= nil and inst.sg:HasStateTag("busy") then
                        return
                    end
                    local x, y, z = inst.Transform:GetWorldPosition()
                    local ents = TheSim:FindEntities(x, y, z, self.range, nil, build_in_vars_fns.NOTAGS, (self.fireOnly and build_in_vars_fns.NONEMERGENCY_FIREONLY_TAGS) or build_in_vars_fns.NONEMERGENCYTAGS)
                    local target = nil
                    local targetscore = 0
                    for i, v in ipairs(ents) do
                        if not self.detectedItems[v] then
                            local score, force = build_in_vars_fns.CheckTargetScore(v)
                            if force then
                                target = v
                                break
                            elseif score > targetscore then
                                targetscore = score
                                target = v
                            end
                        end
                    end
                    if target ~= nil then
                        build_in_vars_fns.RegisterDetectedItem(inst, self, target)
                        if self.onfindfire ~= nil then
                            self.onfindfire(inst, target:GetPosition())
                        end
                    end
                end,
                TURN_ON_DELAY = 13 * FRAMES
            };

            -- 直接从 firedetector.lua 文件中复制+重写。我服了，这么多局部函数和变量。
            build_in_vars_fns.Cancel(self.inst, self);
            self.detectTask = self.inst:DoPeriodicTask(self.detectPeriod, build_in_vars_fns.LookForFiresAndFirestarters, randomizedStartTime and build_in_vars_fns.TURN_ON_DELAY + math.random() * self.detectPeriod or build_in_vars_fns.TURN_ON_DELAY, self);
        end
    end

    inst:AddComponent("wateryprotection")
    inst.components.wateryprotection.extinguishheatpercent = TUNING.FIRESUPPRESSOR_EXTINGUISH_HEAT_PERCENT
    inst.components.wateryprotection.temperaturereduction = TUNING.FIRESUPPRESSOR_TEMP_REDUCTION
    inst.components.wateryprotection.witherprotectiontime = TUNING.FIRESUPPRESSOR_PROTECTION_TIME
    inst.components.wateryprotection.addcoldness = TUNING.FIRESUPPRESSOR_ADD_COLDNESS
    inst.components.wateryprotection:AddIgnoreTag("player")

    inst:AddComponent("lootdropper")
    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(4)
    inst.components.workable:SetOnFinishCallback(onhammered)
    inst.components.workable:SetOnWorkCallback(onhit)

    inst.LaunchProjectile = LaunchProjectile
    inst:SetStateGraph("SGfiresuppressor")

    inst.OnSave = onsave
    inst.OnLoad = onload
    --inst.OnLoadPostPass = OnLoadPostPass
    inst.OnEntitySleep = OnEntitySleep
    inst.OnRemoveEntity = OnRemoveEntity

    inst.components.machine:TurnOn()

    MakeHauntableWork(inst)

    return inst
end

local function onfade(inst)
    if inst._ison:value() then
        local df = math.max(.1, (1 - inst._fade) * .5)
        inst._fade = inst._fade + df
        if inst._fade >= 1 then
            inst._fade = 1
            inst._task:Cancel()
            inst._task = nil
        end
        inst.AnimState:OverrideMultColour(1, 1, 1, inst._fade)
    else
        local df = math.max(.1, inst._fade * .5)
        inst._fade = inst._fade - df
        if inst._fade <= 0 then
            inst._fade = 0
            inst._task:Cancel()
            inst._task = nil
        end
        inst.AnimState:OverrideMultColour(1, 1, 1, inst._fade)
    end
end

local function onisondirty(inst)
    if inst._task == nil and (inst._ison:value() and 1 or 0) ~= inst._fade then
        inst._task = inst:DoPeriodicTask(FRAMES, onfade, 0)
    end
end

local function oninitglow(inst)
    if inst._ison:value() then
        inst.AnimState:OverrideMultColour(1, 1, 1, 1)
        inst._fade = 1
    end
    inst:ListenForEvent("onisondirty", onisondirty)
end

local function glow_fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddFollower()
    inst.entity:AddNetwork()

    inst:AddTag("FX")
    inst:AddTag("NOCLICK")

    inst.AnimState:SetBank("firefighter_glow")
    inst.AnimState:SetBuild("firefighter_glow")
    inst.AnimState:PlayAnimation("green", true)
    inst.AnimState:SetLightOverride(1)
    inst.AnimState:SetFinalOffset(3)
    inst.AnimState:OverrideMultColour(1, 1, 1, 0)

    -- ??????
    inst._ison = net_bool(inst.GUID, "firesuppressor_glow._ison", "onisondirty")
    inst._fade = 0
    inst._task = nil
    inst:DoTaskInTime(0, oninitglow)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false

    return inst
end

local function placer_postinit_fn(inst)
    --Show the flingo placer on top of the flingo range ground placer

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

    placer2.AnimState:SetBank("firefighter")
    placer2.AnimState:SetBuild("firefighter")
    placer2.AnimState:PlayAnimation("idle_off")
    placer2.AnimState:SetLightOverride(1)

    placer2.entity:SetParent(inst.entity)

    inst.components.placer:LinkEntity(placer2)
end

return Prefab("mone_firesuppressor", fn, assets, prefabs),
Prefab("mone_firesuppressor_glow", glow_fn, glow_assets),
MakePlacer("mone_firesuppressor_placer", "firefighter_placement", "firefighter_placement", "idle", true, nil, nil, PLACER_SCALE, nil, nil, placer_postinit_fn)
