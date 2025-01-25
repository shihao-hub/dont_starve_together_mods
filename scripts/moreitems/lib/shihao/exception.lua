-- TODO: exception.lua 和 base.lua 同级真的合理吗？
-- 其实说实在的，总是循环依赖，肯定是分组分的不好！还是说应该给 base.lua 赋于特殊的地位？
-- 之所以将 exception.lua 移出来，那是因为 module 目录下需要大量使用 exception.lua
-- 很烦，太别扭了啊！感觉两个文件很容易相互依赖，虽然将依赖的部分移入 __shared__.lua 是个好办法，但是阅读起来太难受。

local base = require("moreitems.lib.shihao.base")
local assertion = require("moreitems.lib.shihao.assertion")

local module = { unittests = {} }
local static = {}

static.IllegalArgumentException = "IllegalArgumentException"
static.NotImpletedException = "NotImpletedException"

---@param error_msg string
local function _get_exception_name(error_msg)
    local name = error_msg:match("^.*Exception: ")
    assert(type(name) ~= "boolean")
    return base.if_then_else(name == nil, function() return name end, function() return name:sub(1, -3) end)
end

---@param error_msg string
---@param target_exception_name string
local function is_exception(error_msg, target_exception_name)
    local name = _get_exception_name(error_msg)
    if name == nil then
        return false
    end
    return name == static[target_exception_name]
end

---@overload fun(error_msg:string, exception_name:string)
---@overload fun(error_msg:string, level:number, exception_name:string)
local function throw_exception(...)
    local function main(error_msg, level, exception_name)
        level = level and level + 2 or 3 -- please make sure that the type of `level` is not a boolean.
        error_msg = base.if_then_else(error_msg, function()
            return static[exception_name] .. ": " .. error_msg
        end, function()
            return static[exception_name]
        end)
        error(error_msg, level)
    end

    local args = base.get_args(...)

    if args.n == 2 then
        main(args[1], args[2])
    elseif args.n == 3 then
        main(args[1], args[2], args[3])
    else
        base.should_never_reach_here()
    end
end

function module.is_IllegalArgumentException(msg)
    return is_exception(msg, static.IllegalArgumentException)
end

function module.unittests.throw_IllegalArgumentException()
    -- FIXME: Lua 的错误处理函数里面如果发生错误居然会导致 C stack overflow？这有什么意义？
    --xpcall(function()
    --    module.throw_IllegalArgumentException()
    --end, function(msg)
    --    --print(msg)
    --    error(2222)
    --end)
end

---@overload fun()
function module.throw_IllegalArgumentException(msg)
    throw_exception(msg, static.IllegalArgumentException)
end

function module.is_NotImpletedException(msg)
    return is_exception(msg, static.NotImpletedException)
end

---@overload fun()
function module.throw_NotImpletedException(msg)
    throw_exception(msg, static.NotImpletedException)
end

if select("#", ...) == 0 then
    local unittest = require("moreitems.lib.shihao.module.unittest")

    local unittests = {}
    function unittests.is_IllegalArgumentException()
        assertion.assert_true(module.is_IllegalArgumentException("IllegalArgumentException: 123") == true)
    end

    unittest.run_unittests(unittests)
end

return module
