---
--- DateTime: 2025/1/6 16:27
---

local module = {}


function module.contains_key(t, key)
    for i, v in pairs(t) do
        if i == key then
            return true
        end
    end
    return false
end


function module.contains_value(t, value)
    for i, v in pairs(t) do
        if v == value then
            return true
        end
    end
    return false
end


return module
