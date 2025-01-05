---
--- @author zsh in 2023/4/30 13:23
---

---幸运属性
local Luck = Class(function(self, inst)
    self.inst = inst;

    self.current = 0; -- 按道理是有厄运的，但是算了。所以默认 current 必定大于等于 0
    self.max = 100;

    self.luck_percent = self.current / self.max; -- 此处就是幸运涉及的概率修改了

    self.bonus = {};
end)

--------------------------------------------------------------------------------------------------------
--[[ 按道理应该是私有变量：提示，元表代理的方式其实是可以实现私有的功能的... ]]
--------------------------------------------------------------------------------------------------------
function self:CalcBonus()
    local value = 0;
    for k, v in pairs(self.bonus) do
        value = value + v;
    end
    return value;
end

function self:LuckWaterBonus()
    if self.inst.components.mone_luckwater_buff == nil then
        return 0;
    end
    return self.inst.components.mone_luckwater_buff:Get();
end
--------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------

function Luck:GetDebugString()
    return string.format("CURRENT: %.1f + BONUS: %.1f", self.current, self:CalcBonus())
end

function Luck:PushBonus(key, value)
    key = key or "unknown";
    value = type(value) == "number" and value or 0;
    self.bonus[key] = value;
end

function Luck:PopBonus(key)
    key = key or "unknown";
    self.bonus[key] = nil;
end

function Luck:Get()
    return self.current + self:CalcBonus() + self:LuckWaterBonus();
end

return Luck;