---
--- @author zsh in 2023/4/30 13:31
---

---幸运药水的 buff 效果
local LuckWaterBuff = Class(function(self, inst)
    self.inst = inst;

    self.lucktime = 480; -- 幸运时间：480s
    self.doomtime = 0; -- 厄运时间：5 * 480s
    self.duration = nil;
    self.currenteffect = 0;

    self.task = nil;
end);

--------------------------------------------------------------------------------------------------------
--[[ private ]]
--------------------------------------------------------------------------------------------------------

local LUCKY_INCREASED_CAP = 50;

local function OnTick(inst, self)
    self.duration = self.duration + 1;
    if self.duration <= self.lucktime then
        self.currenteffect = LUCKY_INCREASED_CAP;
    elseif self.lucktime < self.duration and self.duration <= self.lucktime + self.doomtime then
        self.currenteffect = Remap(self.duration - self.lucktime, 0, self.doomtime, -LUCKY_INCREASED_CAP, 0)
    elseif self.lucktime + self.doomtime < self.duration then
        self:StopTick();
    else
        assert(nil, "LuckWaterBuff: OnTick: Impossible!!!");
    end
end

function LuckWaterBuff:StartTick(init_duration)
    self:StopTick();
    self.duration = init_duration or 0;
    self.task = self.inst:DoPeriodicTask(1, OnTick, 0, self);
end

function LuckWaterBuff:StopTick()
    self.duration = nil;
    self.currenteffect = 0;
    self.task = self.task and self.task:Cancel() and nil;
end

--------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------

function LuckWaterBuff:GetDebugString()
    return string.format("%ds, value = %d\n", self.duration or 0, self.currenteffect)
end

---触发函数
function LuckWaterBuff:OnDrink()
    self:StartTick();
end

---Getter
function LuckWaterBuff:Get()
    return self.currenteffect;
end

---LongUpdate
function LuckWaterBuff:LongUpdate(dt)
    self.duration = self.duration and self.duration + dt or nil;
end

function LuckWaterBuff:OnSave()
    return self.duration ~= 0 and {
        duration = self.duration,
    }
end

function LuckWaterBuff:OnLoad(data)
    if data then
        if data.duration then
            self:StartTick(data.duration)
        end
    end
end

return LuckWaterBuff;