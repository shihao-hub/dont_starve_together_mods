---
--- DateTime: 2025/1/6 16:27
---

local module_shared = require("moreitems.lib.shihao.module.__shared__")

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

module.array_equals = module_shared.array_equals

if select("#", ...) == 0 then

end

return module
