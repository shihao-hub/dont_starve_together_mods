---
--- DateTime: 2025/1/6 17:18
---

local inspect = require("moreitems.lib.thirdparty.inspect.inspect")

local module_shared = require("moreitems.lib.shihao.module.__shared__")
local stl_shared = require("moreitems.lib.shihao.module.stl.__shared__")

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

function module.startswith(str, prefix)
    return string.sub(str, 1, string.len(prefix)) == prefix
end

function module.endswith(str, suffix)
    return string.sub(str, -string.len(suffix), -1) == suffix
end

if select("#", ...) == 0 then
    local assertion = module_shared.assertion

    --[[ split ]]
    xpcall(function()
        local test_cases = {

        }
        for _, case in ipairs(test_cases) do
            assertion.assert_true()
        end
    end,print)

    --[[ startswith ]]
    xpcall(function()
        local str, prefix = "123456789", "123456"
        assertion.assert_true(module.startswith(str, prefix))
    end, print)

    --[[ endswith ]]
    xpcall(function()
        local test_cases = {
            { "789", "89" },
            --{ "9", "89" },
        }
        for _, case in ipairs(test_cases) do
            assertion.assert_true(module.endswith(unpack(case, 1, table.maxn(case))), case)
        end
    end, print)

    -- 在 Lua 5.1 及之前的版本中，`table.maxn` 函数确实可以用来获取一个表的最大整数索引
    --print(table.maxn({ nil, nil, nil, 1, 2, 3, nil, 5, nil, 7, nil, nil, 10, nil }))
end

return module
