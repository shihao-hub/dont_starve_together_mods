---
--- DateTime: 2025/1/6 17:18
---

local inspect = require("moreitems.lib.thirdparty.inspect.inspect")

local module = {}

function module.split(str, sep)
    -- local i, j = 0, 0
    local sep, fields = sep or ":", {}
    local pattern = string.format("([^%s]+)", sep)
    string.gsub(str, pattern, function(c)
        -- 输出参数 fields
        fields[#fields + 1] = c
    end)
    return fields
end

if select("#", ...) == 0 then
    print(inspect.inspect(module.split("↑ ↓ ← → ↖ ↗ ↘ ↙ ↕", " ")))
end

return module
