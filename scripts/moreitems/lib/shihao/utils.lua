---
--- DateTime: 2024/12/3 20:42
---

-- 【待定】其实在我看来，utils 可以囊括所有内容了... 不需要那么多文件，我的模组根本用不到，一把梭即可

local base = require("moreitems.lib.shihao.base")
local log = require("moreitems.lib.shihao.module.log")
local checker = require("moreitems.lib.shihao.module.checker")

local module = setmetatable({}, {
    __index = function(t, k)
        return base[k]
    end
})

module.emojis = { "↑", "↓", "←", "→", "↖", "↗", "↘", "↙", "↕" }

function module.switch(condition)
    --[[
        形如 jdk17：
        return switch(week) {
            case null -> 1;
            case MONDAY -> 2;
            case TUESDAY -> 3;
            default -> 4;
        };
        Lua switch 可以这样使用：

    ]]
    return function(t)
        local branch = t[condition]
        if branch == nil then
            branch = function() end
        end
        checker.check_function(branch)
        return branch()
    end
end

local function _do_nothing()

end

module.dummy = _do_nothing
module.do_nothing = _do_nothing

---@return string
function module.get_call_location(level_incr)
    --[[
        -- debug.getinfo(thread, what), the below content refers to "what"
        -- S: source, short_src, linedefined, lastlinedefined, what
        -- l: currentline
        -- u: nups
        -- n: name, namewhat
        -- L: activelines
        -- f: func
    ]]

    -- level_incr, incr(增量)
    level_incr = level_incr and level_incr or 0
    -- It is better to provide a second param, because it can improve performance(改善性能). (maybe?)
    -- but I think this is meaningless.
    local info = debug.getinfo(2 + level_incr)
    if info and info.short_src and info.currentline then
        return (string.gsub(string.format("[file %s, line %s]", info.short_src, info.currentline), "\\", "/"))
    end
    return ""
end

---@param values table<any>
---@return table<any,boolean>
function module.generate_set(values)
    local res = {}
    for _, v in ipairs(values) do
        res[v] = true
    end
    return res
end

-- Question: 如果 get_varargs 变成 public，岂不是在 utils 中出现了循环依赖？这种问题如何解决为好呢？
-- Answer: 以下列方式可以解决，只要保证 _get_varargs 不要用到 module 中的方法即可
local function _get_varargs(...)
    return { n = select("#", ...), ... }
end

function module.get_varargs(...)
    return _get_varargs(...)
end

local function iter_varargs(process_each_element, ...)
    local args = _get_varargs(...)
    for i = 1, args.n do
        process_each_element(args[i])
    end
end

function module.all_null(...)
    local args = _get_varargs(...)
    for i = 1, args.n do
        if args[i] ~= nil then
            return false
        end
    end
    return true
end

function module.oneof_null(...)
    local args = _get_varargs(...)
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

local function _invoke(fn, ...)
    return fn(...)
end

---直接调用 fn 函数
---大部分使用场景为匿名函数，因为存在 upvalue，其实 `...` 可变参数应该没有什么存在的价值。
---因为对于 lua 而言，upvalue 我可以认为是参数输出，即指针
function module.invoke(fn, ...)
    return _invoke(fn, ...)
end

function module.invoke_safe(fn, ...)
    local res
    local args = { ... }
    local n = select("#", ...)
    xpcall(function()
        res = fn(unpack(args, n))
    end, function(msg)
        log.error(msg)
    end)
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

function module.if_present(value, consumer_action)
    if value ~= nil then
        consumer_action(value)
    end
end

function module.if_present_or_else(value, consumer_action, empty_action)
    if value ~= nil then
        consumer_action(value)
    else
        empty_action()
    end
end

if select('#', ...) == 0 then
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

    log.info(module.string_format("{{ name         }}", { name = "zsh" }))
    log.info(module.string_format2("{{name        }}", { name = "zsh" }))

    log.info(os.time())
    log.info(os.clock())

    log.info(module.get_call_location())
end

return module




