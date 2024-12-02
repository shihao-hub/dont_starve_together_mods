---
--- @author zsh in 2023/1/15 2:13
---

--[[ 以后有空再优化 2023/1/15 ]]

local locale = LOC.GetLocaleCode();
local L = (locale == "zh" or locale == "zht" or locale == "zhr") and true or false;

local function isFlying(inst)
    -- 客机
    return inst and inst:HasTag("mone_bathat_fly");
end

local function stopFlying(inst)
    -- 主机
    if inst and isFlying(inst) then
        inst.components.mone_bathat_fly:Land(inst);
    end
end

-- 给每个人物添加飞行组件
env.AddPlayerPostInit(function(inst)
    if not TheWorld.ismastersim then
        return inst;
    end
    inst:AddComponent("mone_bathat_fly");
end)

-- 动作相关修改
ACTIONS.MONE_BATHAT.strfn = function(act)
    return isFlying(act.doer) and "LAND" or "FLY";
end

STRINGS.ACTIONS.MONE_BATHAT = {
    FLY = L and "起飞" or "FLY",
    LAND = L and "降落" or "LAND"
}

--[[ hook run函数 ]]
do
    local function runfnhook(self)
        if not (self and self.states) then
            return
        end

        if self.states.run then
            local run = self.states.run
            local old_onenter = run.onenter

            function run.onenter(inst, ...)
                if old_onenter then
                    old_onenter(inst, ...)
                end
                if isFlying(inst) then
                    if not inst.AnimState:IsCurrentAnimation("idle_loop") then
                        inst.AnimState:PlayAnimation("idle_loop", true)
                    end
                    inst.sg:SetTimeout(inst.AnimState:GetCurrentAnimationLength() + 0.01)
                end
            end
        end

        if self.states.run_start then
            local run_start = self.states.run_start
            local old_onenter = run_start.onenter
            function run_start.onenter(inst, ...)
                if old_onenter then
                    old_onenter(inst, ...)
                end
                if isFlying(inst) then
                    inst.AnimState:PlayAnimation("idle_loop")
                end
            end
        end

        if self.states.run_stop then
            local run_stop = self.states.run_stop
            local old_onenter = run_stop.onenter
            function run_stop.onenter(inst, ...)
                if old_onenter then
                    old_onenter(inst, ...)
                end
                if isFlying(inst) then
                    inst.AnimState:PlayAnimation("idle_loop")
                end
            end
        end
    end

    AddStategraphPostInit("wilson", runfnhook)
    AddStategraphPostInit("wilson_client", runfnhook)
end

--[[ 去除脚步声 ]]
do
    local old_PlayFootstep = GLOBAL.PlayFootstep
    GLOBAL.PlayFootstep = function(inst, ...)
        --客机
        if inst and isFlying(inst) then
            return
        end
        return old_PlayFootstep and old_PlayFootstep(inst, ...)
    end

    env.AddComponentPostInit("locomotor", function(self)
        self.mone_bathat_height_override = 0

        local old_RunForward = self.RunForward
        function self:RunForward(direct, ...)
            if old_RunForward then
                old_RunForward(self, direct, ...)
            end

            if self.mone_bathat_height_override ~= 0 then
                if self.inst and self.inst.components.mone_bathat_fly and self.inst.Physics then
                    local vx, vy, vz = self.inst.Physics:GetMotorVel()

                    local pt = self.inst:GetPosition()

                    local height = self.inst.components.mone_bathat_fly:GetHeight()

                    if height and pt.y then
                        self.inst.Physics:SetMotorVel(vx, (height - pt.y) * 32, vz)
                    end
                end
            end
        end

        local old_GetRunSpeed = self.GetRunSpeed
        function self:GetRunSpeed(...)
            if isFlying(self.inst) then
                --正常移动速度是6
                local runspeed = 6 * 3 --3倍速，不开洞穴刚刚好，开了洞穴因为延迟。导致一卡一卡的。
                --self:RunSpeed() * self:GetSpeedMultiplier() * 2.5
                -- print("runspeed:"..runspeed)
                -- 所以一卡一卡是速度过快吗？ -- 不是，就是卡，为什么卡待解决。
                runspeed = 6 * 2;
                return runspeed
            end
            return old_GetRunSpeed and old_GetRunSpeed(self, ...)
        end
    end)
end


--[[ 冰冻结束飞行 ]]
do
    env.AddComponentPostInit("freezable", function(self)
        local old_Freeze = self.Freeze
        self.Freeze = function(self, freezetime, ...)
            stopFlying(self.inst);
            return old_Freeze(self, freezetime, ...)
        end
    end)
end

--[[ 睡眠结束飞行 ]]
do
    env.AddComponentPostInit("grogginess", function(self)
        local old_KnockOut = self.KnockOut
        self.KnockOut = function(self, ...)
            stopFlying(self.inst);
            return old_KnockOut(self, ...)
        end
    end)
end

