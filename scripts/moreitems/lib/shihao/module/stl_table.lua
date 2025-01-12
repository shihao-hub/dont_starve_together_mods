---
--- DateTime: 2025/1/6 16:27
---

local _shared = require("moreitems.lib.shihao.module.__shared__")

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

-- TODO
--function module.is_array(t)
--
--end

function module.array_equals(array1, array2)
    return _shared.array_equals(array1, array2)
end

if select("#", ...) == 0 then

end

return module
