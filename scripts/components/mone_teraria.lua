---
--- @author zsh in 2023/5/5 17:12
---

local Teraria = Class(function(self, inst)
    self.inst = inst;
end)

function Teraria:OnSave()
    local armor = self.inst.components.armor;
    if armor then
        local condition, maxcondition = armor.condition, armor.maxcondition;
        return condition ~= maxcondition and { condition = condition } or nil;
    end
end

function Teraria:OnLoad(data)
    if data.condition ~= nil then
        self.inst:DoTaskInTime(10, function(inst, data)
            local armor = inst.components.armor;
            if armor then
                print("","Teraria:OnLoad:"..tostring(data.condition))
                armor:SetCondition(data.condition);
            end
        end, data)
    end
end

return Teraria;