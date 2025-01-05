---
--- @author zsh in 2023/3/22 19:51
---

local state, a, b = pcall(function(a, b)
    print("a+b: " .. tostring(a + b));
end, 11, 22);
print(state, a, b)

print(pcall(function(a, b)
    print("a+b: " .. tostring(a + b));
end, 11, 22));

local AClass = Class(function(self, inst)
    self.inst = inst;

    self.value = 0; -- 需要保存的值
end)

function AClass:OnSave()
    return {
        value = self.value;
    }
end

function AClass:OnLoad(data)
    if data then
        if data.value then
            self.value = data.value;
        end
    end
end