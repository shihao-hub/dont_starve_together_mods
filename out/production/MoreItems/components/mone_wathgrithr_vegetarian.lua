---
--- @author zsh in 2023/1/22 23:31
---

--[[ 女武神可以吃素，但是生存天数超过一定天数后就不能再吃素了 ]]

local VB = Class(function(self, inst)
    self.inst = inst;
    self.SURVIVAL_TIME = 20;

    self.mone_survival_time = nil;
end)

function VB:IsTooLongToLive()
    if self.mone_survival_time and self.mone_survival_time > self.SURVIVAL_TIME then
        return true;
    end
end

function VB:SetDiet(caneat, preferseating)
    if self.inst.components.eater then
        self.inst.components.eater:SetDiet(caneat, preferseating);
    end
end

function VB:OnSave()
    return {
        mone_survival_time = self.mone_survival_time;
    };
end

function VB:OnLoad(data)
    if data then
        if data.mone_survival_time then
            self.mone_survival_time = data.mone_survival_time;
        end
    end
end

return VB;