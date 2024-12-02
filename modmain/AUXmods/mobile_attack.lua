---
--- @author zsh in 2023/4/16 14:11
---

local ENV = TUNING.MONE_TUNING.MY_MODULES.MOBILE_ATTACK.ENV;
setfenv(1, ENV);

local function GetModConfigData(optionname, get_local_config, ...)
    do
        local condition = optionname;
        local switch = {
            ["Attack_key"] = function()
                return "KEY_G"; -- 攻击键
            end,
            ["Addattackdelay_key"] = function()
                return "KEY_UP"; -- 增加攻击速度
            end,
            ["Reduceattackdelay_key"] = function()
                return "KEY_DOWN"; -- 减少攻击速度
            end,
            ["Addmovedelay_key"] = function()
                return "KEY_RIGHT"; -- 增加移动延迟
            end,
            ["Reducemovedelay_key"] = function()
                return "KEY_LEFT"; -- 减少移动延迟
            end,
            ["Default_attackdelay"] = function()
                return 355; -- 攻击速度
            end,
            ["Default_movedelay"] = function()
                return 10; -- 移动延迟
            end,
        }
        if switch[condition] then
            return switch[condition]();
        else
            -- DoNothing
            print("按道理来说不会进入此处！");
        end
    end
    return env.GetModConfigData(optionname, get_local_config, ...);
end

local attackDelay = GetModConfigData("Default_attackdelay")
local moveDelay = GetModConfigData("Default_movedelay")

--local ping=0
local function IsDefaultScreen()
    local screen = TheFrontEnd:GetActiveScreen()
    local screenName = screen and screen.name or ""
    print("screenName: " .. tostring(screenName));
    return screenName:find("HUD") ~= nil
end

local function GetTarget(targettype)
    local player = ThePlayer
    local playercontroller = player.components.playercontroller
    local x, y, z = playercontroller.inst.Transform:GetWorldPosition()
    local combat = playercontroller.inst.replica.combat
    local attackRange = combat:GetAttackRangeWithWeapon()
    local CANT_TAGS = { "INLIMBO", "companion", "wall", "abigail", "shadowminion", "playerghost" };
    local entities = TheSim:FindEntities(x, y, z, attackRange + 10, { targettype }, CANT_TAGS)

    -- 优先最近的目标
    table.sort(entities, function(a, b)
        local qeueu = {}
        local A = qeueu[a.GUID]
        local B = qeueu[b.GUID]
        return (A and not B) or ((A or not B) and player:GetDistanceSqToInst(a) < player:GetDistanceSqToInst(b))
    end)

    for _, entity in ipairs(entities) do
        if entity and entity:IsValid() and entity.replica.health ~= nil
                and not entity.replica.health:IsDead()
                and ThePlayer.replica.combat:CanTarget(entity) then
            return entity
        end
    end
    return nil
end

local function Attack(target)
    local playeractionpicker = ThePlayer.components.playeractionpicker
    local playercontroller = ThePlayer.components.playercontroller
    if target == nil or not target:IsValid()
            or target.replica.health == nil or target.replica.health:IsDead()
            or not ThePlayer.replica.combat:CanTarget(target) then
        return false
    end
    local tx, ty, tz = target:GetPosition():Get()
    local px, py, pz = ThePlayer:GetPosition():Get()
    if tx == px and tz == pz then
        tx = tx + 0.1
        tz = tz + 0.1
    end
    local distance = math.sqrt((px - tx) * (px - tx) + (pz - tz) * (pz - tz))
    local range = ThePlayer.components.playercontroller.inst.replica.combat:GetAttackRangeWithWeapon() + target:GetPhysicsRadius(0)
    if ThePlayer.components.playercontroller:CanLocomote() then
        if distance > range - 0.2 or target:HasTag("butterfly") and distance > 0.5 then
            local playercontroller = ThePlayer.components.playercontroller
            local action = BufferedAction(playercontroller.inst, nil, ACTIONS.WALKTO, nil, Vector3(tx, 0, tz))
            playercontroller:DoAction(action)
            Sleep((20) * 0.001)
            return false
        end
    else
        if distance > range or target:HasTag("butterfly") and distance > 1.5 then
            SendRPCToServer(RPC.LeftClick, ACTIONS.WALKTO.code, tx, tz, nil, true, nil, nil, nil)
            Sleep((20) * 0.001)
            return false
        end
    end
    if ThePlayer.components.playercontroller:CanLocomote() then
        local act = playeractionpicker:GetLeftClickActions(target:GetPosition(), target)[1]
        if act == nil then
            return false
        end
        act.preview_cb = function()
            SendRPCToServer(RPC.PredictWalking, px, pz, true)
            SendRPCToServer(RPC.LeftClick, ACTIONS.ATTACK.code, px, pz, target, true, 10, nil, nil)
        end
        playercontroller:DoAction(act)
    else
        SendRPCToServer(RPC.PredictWalking, px, pz, true)
        SendRPCToServer(RPC.LeftClick, ACTIONS.ATTACK.code, px, pz, target, true, 10, nil, nil)
    end
    Sleep((attackDelay) * 0.001)
    return true
end

local function Move(target)
    local tx, ty, tz = target:GetPosition():Get()
    local px, py, pz = ThePlayer:GetPosition():Get()
    if tx == px and tz == pz then
        tx = tx + 0.1
        tz = tz + 0.1
    end
    local distance = math.sqrt((px - tx) * (px - tx) + (pz - tz) * (pz - tz))
    if distance == 0 then
        distance = 0.1
        tx = tx + 0.1
    end
    if ThePlayer.components.playercontroller:CanLocomote() then
        local playercontroller = ThePlayer.components.playercontroller
        local action = BufferedAction(playercontroller.inst, nil, ACTIONS.WALKTO, nil, Vector3(px + (px - tx) / distance, 0, pz + (pz - tz) / distance))
        playercontroller:DoAction(action)
    else
        SendRPCToServer(RPC.PredictWalking, px + (px - tx) / distance, pz + (pz - tz) / distance, true)
        SendRPCToServer(RPC.LeftClick, ACTIONS.WALKTO.code, px + (px - tx) / distance, pz + (pz - tz) / distance, nil, true, nil, nil, nil)
    end
    Sleep(0.001 * moveDelay)
end

local function Start()
    if IsDefaultScreen() and ThePlayer ~= nil and ThePlayer.Cheatthread == nil then
        -- 没有武器则不生效
        if ThePlayer.components.playercontroller.inst.replica.combat:GetWeapon() == nil then
            ThePlayer.components.playercontroller:DoAttackButton()
            return
        end
        ThePlayer.Cheatthread = ThePlayer:StartThread(function()
            --ping = TheNet:GetAveragePing()
            while true do
                Sleep(0.01)
                local target = GetTarget("epic");
                --if target == nil then
                --    target = GetTarget("monster"); -- 不能加，因为这样优先打怪物了
                --end
                if target == nil then
                    target = GetTarget("_combat")
                end
                if target == nil then
                    target = ThePlayer.components.playercontroller:GetAttackTarget(true, nil, nil);
                    -- 排除盟友、墙、阿比盖尔等
                    if target and target:IsValid()
                            and (target:HasTag("INLIMBO")
                            or target:HasTag("companion")
                            or target:HasTag("wall")
                            or target:HasTag("abigail")
                            or target:HasTag("shadowminion")
                            or target:HasTag("playerghost"))
                    then
                        target = nil;
                    end
                end

                if target ~= nil then
                    while Attack(target) do
                        Move(target)
                    end
                end
            end
        end)
    end
end

local function Stop()
    if IsDefaultScreen() and ThePlayer ~= nil and ThePlayer.Cheatthread ~= nil then
        ThePlayer.Cheatthread:SetList(nil)
        ThePlayer.Cheatthread = nil
    end
end

local function GetKeyFromConfig(config)
    local key = GetModConfigData(config, true)
    if type(key) == "string" and GLOBAL:rawget(key) then
        key = GLOBAL[key]
    end
    return type(key) == "number" and key or -1
end

if GetKeyFromConfig("Attack_key") then
    TheInput:AddKeyDownHandler(GetKeyFromConfig("Attack_key"), Start);
    TheInput:AddKeyUpHandler(GetKeyFromConfig("Attack_key"), Stop);
end

if GetKeyFromConfig("Addattackdelay_key") then
    TheInput:AddKeyUpHandler(GetKeyFromConfig("Addattackdelay_key"), function()
        if IsDefaultScreen() then
            attackDelay = attackDelay + 2
            print("attackdelay=" .. tostring(attackDelay))
            if ThePlayer then
                ThePlayer.components.talker:Say("当前攻击延迟为：" .. tostring(attackDelay / 1000) .. " 秒");
            end
        end
    end)
end

if GetKeyFromConfig("Reduceattackdelay_key") then
    TheInput:AddKeyUpHandler(GetKeyFromConfig("Reduceattackdelay_key"), function()
        if IsDefaultScreen() then
            attackDelay = attackDelay - 2
            print("attackdelay=" .. tostring(attackDelay))
            if ThePlayer then
                ThePlayer.components.talker:Say("当前攻击延迟为：" .. tostring(attackDelay / 1000) .. " 秒");
            end
        end
    end)
end

if GetKeyFromConfig("Addmovedelay_key") then
    TheInput:AddKeyUpHandler(GetKeyFromConfig("Addmovedelay_key"), function()
        if IsDefaultScreen() then
            moveDelay = moveDelay + 2
            print("movedelay=" .. tostring(moveDelay))
            if ThePlayer then
                ThePlayer.components.talker:Say("当前移动延迟为：" .. tostring(moveDelay / 1000) .. " 秒");
            end
        end
    end)
end

if GetKeyFromConfig("Reducemovedelay_key") then
    TheInput:AddKeyUpHandler(GetKeyFromConfig("Reducemovedelay_key"), function()
        if IsDefaultScreen() then
            moveDelay = moveDelay - 2
            print("movedelay=" .. tostring(moveDelay))
            if ThePlayer then
                ThePlayer.components.talker:Say("当前移动延迟为：" .. tostring(moveDelay / 1000) .. " 秒");
            end
        end
    end)
end

