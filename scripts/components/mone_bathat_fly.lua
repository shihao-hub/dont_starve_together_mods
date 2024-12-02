---
--- @author zsh in 2023/1/15 2:39
---

local function SpawnFx(self, inst)
    inst:AddTag("mone_bathat_fly")

    self.isspawning = true

    inst:DoTaskInTime(0.1, function(inst)
        -- 未添加飞行动作和降落动作，所以没有动作时间间隔。。。
        if inst.mone_bathat_cloud == nil then
            inst.mone_bathat_cloud = inst:SpawnChild("mone_bathat_fx")
        end
    end)
end

local function RemoveFx(self, inst)
    inst:RemoveTag("mone_bathat_fly");

    self.isremoving = true

    inst:DoTaskInTime(2.3, function(inst)
        if inst.mone_bathat_cloud then
            inst:RemoveChild(inst.mone_bathat_cloud)
            inst.mone_bathat_cloud:Remove()
            inst.mone_bathat_cloud = nil
        end
    end)
end

local function changephysics(inst, data)
    if inst.Physics then
        if inst.Physics:GetCollisionMask() ~= 32 then
            RemovePhysicsColliders(inst)
        end
    end
end

local function GetHopDistance(inst, speed_mult)
    return speed_mult < 0.8 and TUNING.WILSON_HOP_DISTANCE_SHORT or speed_mult >= 1.2 and TUNING.WILSON_HOP_DISTANCE_FAR or
            TUNING.WILSON_HOP_DISTANCE
end

local Flyer = Class(function(self, inst)
    self.inst = inst

    self.height = 2 --设置高度（高度2可以让蜂后召唤的小蜜蜂无法攻击你）

    self.owner = nil

    self.inst:ListenForEvent("ms_becameghost",
            function()
                RemoveFx(self, self.inst)
            end)
end, nil, {})

function Flyer:IsFlying()
    return self.inst:HasTag("mone_bathat_fly")
end

function Flyer:isFlying()
    return self.inst:HasTag("mone_bathat_fly")
end

function Flyer:GetHeight()
    return self.height
end

function Flyer:OnUpdate(dt)
    if self.inst.Physics then
        local vx, vy, vz = self.inst.Physics:GetMotorVel()
        local pt = self.inst:GetPosition()

        if self.height and pt.y then
            self.inst.Physics:SetMotorVel(vx, (self.height - pt.y) * 32, vz)
        end
    end
end

local cancelActions = {
    [ACTIONS.PICKUP] = true, --拾取
    [ACTIONS.PICK] = true, --采集
    [ACTIONS.SLEEPIN] = true, --睡觉
    --[ACTIONS.MYTH_ENTER_HOUSE or "MONE_PLACEHOLDER"] = true, --小房子
    [ACTIONS.MOUNT] = true, --骑牛
    [ACTIONS.MIGRATE] = true,
    [ACTIONS.HAUNT] = true,
    [ACTIONS.JUMPIN] = true,

    --[ACTIONS.CHOP] = true
}

--table<string:prefabname,table<action,boolean>>
local specialActions = {}

local function seqContainVal(list, val)
    for _, v in ipairs(list) do
        if v == val then
            return true;
        end
    end
end
local function printTest(t, val, flag)
    if seqContainVal(t, val) then
        print("FlyActionFilter--" .. tostring(val) .. "--" .. tostring(flag));
    end
end

local function FlyActionFilter(inst, action)
    if specialActions[inst.prefab] and specialActions[inst.prefab][action] then
        return specialActions[inst.prefab][action];
    end
    printTest({
        "PICK", "HARVEST", "TAKEITEM",
        "CHOP", "PICKUP", "MINE", "DIG", "HAMMER"
    }, action.mone_id, not cancelActions[action]);
    return not cancelActions[action];
end

function Flyer:Fly(doer, onload)
    if doer and doer == self.inst then

        local player = self.inst

        self.owner = doer

        SpawnFx(self, player);

        -- Push 动作过滤器 -- emm，未成功，算了！
        --if self.inst.components.playeractionpicker then
        --    self.inst.components.playeractionpicker:PushActionFilter(FlyActionFilter, 555);
        --end

        --移除人物碰撞体积
        if player.Physics then
            RemovePhysicsColliders(player)
        end

        if player.components.locomotor then
            player.components.locomotor.mone_bathat_height_override = self.height
            if true then
                player.components.locomotor:SetSlowMultiplier(0.6)
                player.components.locomotor.pathcaps = { player = true, ignorecreep = true, allowocean = true }
                player.components.locomotor.fasteronroad = false
                player.components.locomotor:SetTriggersCreep(false)
                player.components.locomotor:SetAllowPlatformHopping(false)
            end
        end

        if player.components.drownable and player.components.drownable.enabled ~= false then
            player.components.drownable.enabled = false
        end

        self.inst:StartUpdatingComponent(self)

        return true
    end
    return false
end

function Flyer:Land(doer)
    if doer and doer == self.inst then
        local player = self.inst

        self.owner = nil

        RemoveFx(self, player)

        -- Pop 动作过滤器
        --if self.inst.components.playeractionpicker then
        --    self.inst.components.playeractionpicker:PopActionFilter(FlyActionFilter)
        --end

        if player.Physics then
            ChangeToCharacterPhysics(player)
        end

        if player.components.locomotor then
            player.components.locomotor.mone_bathat_height_override = 0
            if true then
                player.components.locomotor:SetSlowMultiplier(0.6)
                player.components.locomotor.pathcaps = { player = true, ignorecreep = true }
                player.components.locomotor.fasteronroad = true
                player.components.locomotor:SetTriggersCreep(not player:HasTag("spiderwhisperer"))
                player.components.locomotor:SetAllowPlatformHopping(true)
                player.components.locomotor.hop_distance_fn = GetHopDistance
            end
        end

        if player.components.drownable and player.components.drownable.enabled == false then
            player.components.drownable.enabled = true
        end

        self.inst:StopUpdatingComponent(self)

        return true
    end
    return false
end

function Flyer:OnSave()
    return {
        isflying = self:IsFlying()
    }
end

function Flyer:OnLoad(data)
    if data then
        if data.isflying then
            self:Fly(self.inst, true)
        end
    end
end

return Flyer
