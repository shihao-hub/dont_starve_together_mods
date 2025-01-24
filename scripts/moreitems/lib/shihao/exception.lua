-- TODO: exception.lua 和 base.lua 同级真的合理吗？
-- 其实说实在的，总是循环依赖，肯定是分组分的不好！还是说应该给 base.lua 赋于特殊的地位？
-- 之所以将 exception.lua 移出来，那是因为 module 目录下需要大量使用 exception.lua
-- 很烦，太别扭了啊！感觉两个文件很容易相互依赖，虽然将依赖的部分移入 __shared__.lua 是个好办法，但是阅读起来太难受。

local base = require("moreitems.lib.shihao.base")

local module = {}
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

---@param msg string
---@param level number
---@param exception_name string
local function throw_exception(msg, level, exception_name)
    level = level and level + 2 or 3 -- please make sure that the type of `level` is not a boolean.
    msg = base.if_then_else(msg, function()
        return static[exception_name] .. ": " .. msg
    end, function()
        return static[exception_name]
    end)
    error(msg, level)
end

function module.is_IllegalArgumentException(error_msg)
    return is_exception(error_msg, "IllegalArgumentException")
end

function module.throw_IllegalArgumentException(msg, level)
    throw_exception(msg, level, "IllegalArgumentException")
end

function module.is_NotImpletedException(error_msg)
    return is_exception(error_msg, "NotImpletedException")
end

function module.throw_NotImpletedException(msg, level)
    throw_exception(msg, level, "NotImpletedException")
end

if select("#", ...) == 0 then
    local assertion = require("moreitems.lib.shihao.assertion")

    --[[ is_IllegalArgumentException ]]
    xpcall(function()
        assertion.assert_true(module.is_IllegalArgumentException("IllegalArgumentException: 123") == true)
    end, function(msg)
        io.stderr:write(msg, "\n")
    end)
end

return module
