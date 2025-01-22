---
--- DateTime: 2024/12/3 20:42
---

-- 【待定】其实在我看来，utils 可以囊括所有内容了... 不需要那么多文件，我的模组根本用不到，一把梭即可

local base = require("moreitems.lib.shihao.base")
local mini_utils = require("moreitems.lib.shihao.mini_utils")

local log = base.log
local guard = require("moreitems.lib.shihao.module.guard")




-- NOTE: 曾经 setmetatable({}, { __index = function(t, k) return base[k] end })，但是这是副作用，因此我选择避免
local module = setmetatable({ mini = mini_utils }, { __index = mini_utils })

--module.emojis = { "↑", "↓", "←", "→", "↖", "↗", "↘", "↙", "↕" }

-- Legacy compatibility:
--  运用重构将相关位置替换后，就会注释掉。这就是重构的魅力，改错！
--  此处存在的原因是，最初一些不知道归类到哪些地方的函数统一都放在 utils 里面了！utils 毕竟太通用了...
--module.get_call_location = stl_debug.get_call_location
--module.switch = base.switch
module.if_present = guard.if_present
module.if_present_or_else = guard.if_present_or_else
module.invoke = guard.invoke
module.invoke_safe = guard.invoke_safe

local function _iter_varargs(process_each_element, ...)
    local args = { n = select("#", ...), ... }
    for i = 1, args.n do
        process_each_element(args[i])
    end
end

local function _do_nothing()

end

module.dummy = _do_nothing
module.do_nothing = _do_nothing

---@param values table<any>
---@return table<any,boolean>
function module.generate_set(values)
    local res = {}
    for _, v in ipairs(values) do
        res[v] = true
    end
    return res
end

function module.all_null(...)
    local args = { n = select("#", ...), ... }
    for i = 1, args.n do
        if args[i] ~= nil then
            return false
        end
    end
    return true
end

function module.oneof_null(...)
    local args = { n = select("#", ...), ... }
    for i = 1, args.n do
        if args[i] == nil then
            return true
        end
    end
    return false
end

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

---打印某个函数的执行消耗时间
---@param runable function 没有返回值和没有参数的一个执行块，runable 的命名可以联想 Java
---@return number 执行消耗的时间，-1 代表执行失败
function module.time_block(runable)
    local res = -1
    xpcall(function()
        -- try
        local socket = require("socket")

        local info = debug.getinfo(runable, "S")
        local start = socket.gettime() -- os.time() 是时间戳，单位是秒，os.clock() 只统计 cpu。所以选择用 socket.gettime()

        runable()

        local elapsed_time = socket.gettime() - start
        log.info(base.string_format("函数 [{{ source }}:{{ linedefined }}] 的执行耗时：{{ elapsed_time }} s", {
            source = tostring(info.source),
            linedefined = tostring(info.linedefined),
            elapsed_time = elapsed_time
        }))
        res = elapsed_time
    end, function(msg)
        -- catch
        log.error(msg)
    end)
    -- finally
    local finally = function()

    end
    finally()

    return res
end

--local BASE_DATA_TYPE = {
--    TYPES = {
--        -- json
--        "nil",
--        "number",
--        "string",
--        "list",
--        "dict",
--        -- redis
--        "string",
--        "list",
--        "set",
--        "zset",
--        "hash",
--    },
--}

--local set = invoke(function()
--    -- class 定义满足如下条件如何？
--    -- static 放到 static 属性内？其余都是 instance 属性？
--
--    local cls = {}
--
--    cls.__call__ = function(t, key, value)
--
--    end
--
--    return cls
--end)

-- NOTE: 刚刚突然意识到一个问题，为什么要 require 都放在文件开头呢？除了必要的一些常用模块，不常用的模块我直接在函数中引用不好吗？封装性强还能避免循环依赖。
function module.namedtuple(fields)
    local NamedTuple = require("moreitems.lib.shihao.class.NamedTuple")
    error("NotImpletedError")
end

if select('#', ...) == 0 then

    local function test()
        --print(inspect.inspect(module.get_module_env(), { depth = 2 }))

        log.info(module.invoke(function(a, b)
            return a + b
        end, 1, 2))

        log.info(base.string_format("{{ a }}", { a = "a" }))
        log.info(module.time_block(function()
            for _ = 1, 1000 do
                --log.info("hello world")
            end
        end))
        log.info(math.huge)
        log.info(0 / 0)
        log.info(math.sqrt(-1))

        log.info(os.time())
        log.info(os.clock())
    end
    --test()

end

return module




