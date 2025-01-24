-- 尽可能少依赖，base.lua 视为 built-in，那么 mini_utils.lua 就是存放各种最小工作集，几乎只依赖 base.lua
-- 一些依赖较少的函数可以放在 mini_utils.lua 中，base.lua 主要存放更原始的内容。utils.lua 依赖又太多，所以 mini_utils.lua 挺好

local base = require("moreitems.lib.shihao.base")
local assertion = require("moreitems.lib.shihao.assertion")
local exception = require("moreitems.lib.shihao.exception")
local stl_string = require("moreitems.lib.shihao.module.stl_string")

local module = { unittests = {} }

function module.wrap_function(fn, length)
    exception.throw_NotImpletedException()

    local res = setmetatable({}, { __call = fn })
    res.length = length
    return res
end

---在 JS 中，函数的 length 属性提供了一种机制，判断定义时和调用时参数的差异，以便实现面向对象编程的“方法重载”（overload）。
function module.get_function_length(fn)
    exception.throw_NotImpletedException()

    assert(type(fn) == "table")
    local mt = getmetatable(fn)
    local call = mt.__call
    return fn.length
end



-- FClassName -> F: struct
-- IClassName -> interface
-- EClassName -> enum
-- U++ 是什么？

function module.unittests.get_empty_array()
    local arr = module.get_empty_array()
    local success, result = pcall(function()
        arr["1"] = 1
    end)
    if not success then
        -- 去除 result 的报错路径，形如：`moreitems/lib/shihao/mini_utils.lua:50: XXX`
        result = string.gsub(result, "^.*[/\\].*:%s*", "")
        assertion.assert_string_equals("Array data type can't have non-numeric key.", result)
    end
end

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
    local unittest = require("moreitems.lib.shihao.module.unittest")
    unittest.run_unittests(module.unittests)
end

return module
