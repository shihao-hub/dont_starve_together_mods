---
--- DateTime: 2024/12/3 20:42
---

local inspect = require("lib.inspect.inspect")
local lustache = require("lib.lustache.lustache")

local base = require("lib.shihao.base")
local log = require("lib.shihao.module.log")

local module = {}

-------------------------------------------------------------------------------
---生成一个用于当前模块的环境
---Usage: local env = module.get_module_env() setfenv(1, env)
-------------------------------------------------------------------------------
function module.get_module_env()
    local res = {}
    local mt = {}
    mt.__index = _G
    setmetatable(res, mt)
    return res
end

local function _invoke(fn, ...)
    return fn(...)
end

function module.invoke(fn, ...)
    return _invoke(fn, ...)
end

function module.invoke_safe(fn, ...)
    local res
    local args = { ... }
    local n = select("#", ...)
    xpcall(function()
        res = fn(unpack(args, n))
    end, function(err)
        log.error(err)
    end)
    return res
end

---@param void_fn function 没有返回值的一个执行块
function module.time_block(void_fn)
    xpcall(function()
        local socket = require("socket")

        local info = debug.getinfo(fn, "S")
        local start = socket.gettime()

        void_fn()

        log.info(base.string_format("函数 [{{ source }}:{{ linedefined }}] 的执行耗时：{{ elapsed_time }} s", {
            source = tostring(info.source),
            linedefined = tostring(info.linedefined),
            elapsed_time = socket.gettime() - start
        }))
    end, log.error)
end

if select('#', ...) == 0 then
    --print(inspect.inspect(module.get_module_env(), { depth = 2 }))

    print(module.invoke(function(a, b)
        return a + b
    end, 1, 2))
end

return module




