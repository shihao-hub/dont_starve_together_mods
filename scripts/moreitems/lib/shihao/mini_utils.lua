-- 尽可能少依赖，base.lua 视为 built-in，那么 mini_utils.lua 就是存放各种最小工作集，几乎只依赖 base.lua

local base = require("moreitems.lib.shihao.base")

-- 【不确定，暂且定义于此】
local module = {}


-- FClassName -> F: struct
-- IClassName -> interface
-- EClassName -> enum
-- U++ 是什么？

---我的约定：数组应该
function module.get_empty_array()
    ---@class MArray
    local res = { n = 0 }
    local mt = {
        __newindex = function(t, k, v)
            if not base.is_number(k) then
                error("Array data type can't have non-numeric key.")
            end
            rawset(t, k, v)
        end
    }
    return setmetatable(res, mt)
end

if select("#", ...) == 0 then
    local assertion = require("moreitems.lib.shihao.assertion")

    local stl_string = require("moreitems.lib.shihao.module.stl_string")

    --[[ get_empty_array ]]
    xpcall(function()
        local arr = module.get_empty_array()
        local success, result = pcall(function()
            arr["1"] = 1
        end)
        if not success then
            assertion.assert_true(stl_string.endswith(result, "Array data type can't have non-numeric key."))
        end
    end, print)
end

return module