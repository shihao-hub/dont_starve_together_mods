-- FIXME: 不需要预测未来，比如这个 set_console 根本没有存在的必要！
local module = {}
local static = { console = function(msg) print(msg) end }

---将可变参数全部转为 string 并拼接后返回
local function _convert_to_message(...)
    local args = { ... }
    local n = select("#", ...)
    local res = {}
    for i = 1, n do
        table.insert(res, tostring(args[i]))
    end
    return table.concat(res, "\t")
end

---@param level string
local function _prefix(level)
    local asctime = os.date("%Y-%m-%d %H:%M:%S")
    local name
    local levelname = level

    -- name
    -- 为什么将 info 移出 xpcall？因为增加了栈帧...两个栈帧，在 xpcall 内需要 +2
    -- 2025-01-12：注释掉了，print 还得调用 debug，太消耗性能，还是不要了。当然，如果有 debug 开关功能倒还好！
    --local info = debug.getinfo(4, "S")
    --xpcall(function()
    --    --local info = debug.getinfo(6, "S")
    --    --print(inspect.inspect(info))
    --    name = info.short_src
    --    name = string.gsub(name, ".*[/\\]", "")
    --end, function()
    --    name = nil
    --end)

    if name == nil then
        return asctime .. " - " .. levelname .. " - "
    end
    return asctime .. " - " .. name .. " - " .. levelname .. " - "

end

---@param level string
local function _log_by_level(level, ...)
    static.console(_prefix(level) .. _convert_to_message(...))
end

function module.set_console(console, flush)
    local function _check_args()
        if type(console) == "function" and type(flush) == "function" then
            return
        end
        error(string.format("Expected console(function) and flush(function), got console(%s) and flush(%s)", type(console), type(flush)))
    end
    _check_args()

    static.console = console
    module.flush = flush
end

function module.flush()
    io.stdout:flush()
end

function module.debug(...)
    _log_by_level("DEBUG", ...)
end

function module.info(...)
    _log_by_level("INFO", ...)
end

function module.warning(...)
    _log_by_level("WARING", ...)
end

function module.error(...)
    -- 反正 Lua 是单线程执行的，那么就很轻松了（虽然我即使用 Java 或 Python 目前 99% 的情况也都是单线程）
    -- 这种方式让我改代码非常轻松！
    local old_console = static.console
    static.console = function(msg) io.stderr:write(msg, "\n") end

    _log_by_level("ERROR", ...)
    -- 打印回溯路径
    -- 不要用 io.stderr，因为没有缓存，会优先打印出来，即使我执行了 io.stdout:flush 也没有用
    --io.stdout:flush()
    --io.stderr:write(debug.traceback(), "\n")
    static.console(debug.traceback())

    static.console = old_console
end

if select("#", ...) == 0 then
    --local log_console = require("logging.console")
    --local logger = log_console()
    --
    --local inspect = require("moreitems.lib.thirdparty.inspect.inspect")
    ----print(inspect.inspect(module))
    --module.info(1, 2, 3, 4, 5)
    --logger:info(1)
end

return module
