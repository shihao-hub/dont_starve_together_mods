---
--- DateTime: 2024/12/3 21:01
---


local log = {}

---将可变参数全部转为 string 并拼接后返回
local function _convert(...)
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
    return "" .. os.date("%Y-%m-%d %H:%M:%S") .. " - " .. level .. " - "
end

---@param level string
local function _log_by_level(level, ...)
    print(_prefix(level) .. _convert(...))
end

function log.debug(...)
    _log_by_level("DEBUG", ...)
end

function log.info(...)
    _log_by_level("INFO", ...)
end

function log.warning(...)
    _log_by_level("WARING", ...)
end

function log.error(...)
    _log_by_level("ERROR", ...)
    -- 打印回溯路径
    -- 不要用 io.stderr，因为没有缓存，会优先打印出来，即使我执行了 io.stdout:flush 也没有用
    --io.stdout:flush()
    --io.stderr:write(debug.traceback(), "\n")
    print(debug.traceback())
end

if select('#', ...) == 0 then
    local log_console = require("logging.console")
    logger = log_console()

    local inspect = require("lib.inspect.inspect")
    print(inspect.inspect(log))
    log.info(1, 2, 3, 4, 5)
    logger:info(1)
end

return log
