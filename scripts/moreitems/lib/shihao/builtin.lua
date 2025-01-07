---
--- DateTime: 2024/12/3 21:00
---

local lustache = require("moreitems.lib.thirdparty.lustache.lustache")
local inspect = require("moreitems.lib.thirdparty.inspect.inspect")

local function _log(debug_flag)
    local module = {}

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
        local info = debug.getinfo(4, "S")
        --print(inspect.inspect(info))
        xpcall(function()
            --local info = debug.getinfo(6, "S")
            --print(inspect.inspect(info))
            name = info.short_src
            name = string.gsub(name, ".*/", "")
        end, function()
            name = nil
        end)

        if name == nil then
            return asctime .. " - " .. levelname .. " - "
        end
        return asctime .. " - " .. name .. " - " .. levelname .. " - "

    end

    ---@param level string
    local function _log_by_level(level, ...)
        print(_prefix(level) .. _convert_to_message(...))
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
        _log_by_level("ERROR", ...)
        -- 打印回溯路径
        -- 不要用 io.stderr，因为没有缓存，会优先打印出来，即使我执行了 io.stdout:flush 也没有用
        --io.stdout:flush()
        --io.stderr:write(debug.traceback(), "\n")
        print(debug.traceback())
    end

    if debug_flag then
        --local log_console = require("logging.console")
        --local logger = log_console()
        --
        --local inspect = require("moreitems.lib.thirdparty.inspect.inspect")
        ----print(inspect.inspect(module))
        --module.info(1, 2, 3, 4, 5)
        --logger:info(1)
    end

    return module
end

------------------------------------------------------------------------------------------------------------------------


-- 2024-01-07：我认为，log 应该放在这里面

local module = {
    log = _log(false), -- log 不必测试了，每次运行都会打印内容，不好
}

---将形如 {{ a }} {{ b }} 等格式的字符串全部替换为 tostring(a) 和 tostring(b)
function module.string_format(str, context)
    return (string.gsub(str, "{{ *([a-zA-Z_]+) *}}", function(matched)
        return tostring(context[matched])
    end))
end

function module.string_format2(template, context)
    return lustache.renderer:render(template, context)
end

-- 这个方法应该是回答了之前的疑问：如果 module.fn1 需要用到 module.fn2，如何避免一不小心写出循环依赖的情况？这种方式应该可以
local function _bool(val)
    if val == nil or val == false then
        return false
    end
    return true
end

function module.bool(val)
    return _bool(val)
end

function module.ternary_operator(condition, expression1, expression2)
    if _bool(condition) then
        return expression1
    end
    return expression2
end

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
    -- 2025-01-06：因为要将 switch 移动到 base 内，但是 base 不允许依赖其他库，因此选择将 checker.check_function 内联
    local function check_function(value)
        local _type = "function"
        if type(value) == _type then
            return
        end
        error("Expected " .. _type .. ", got " .. type(value))
    end

    return function(t)
        local branch = t[condition]
        if branch == nil then
            branch = function() end
        end
        check_function(branch)
        return branch()
    end
end

function module.is_nil(v)
    return type(v) == "nil"
end

function module.is_boolean(v)
    return type(v) == "boolean"
end

function module.is_number(v)
    return type(v) == "number"
end

function module.is_string(v)
    return type(v) == "string"
end

function module.is_table(v)
    return type(v) == "table"
end

function module.is_function(v)
    return type(v) == "function"
end

function module.is_thread(v)
    return type(v) == "thread"
end

function module.is_userdata(v)
    return type(v) == "userdata"
end

if select("#", ...) == 0 then
    local log = module.log

    log.info(module.string_format("{{name}}", {
        name = 1
    }))

    -- base.lua 中用到子目录中的内容是不合理的，但是这里属于测试区域，而且测试区域理论上应该移动到 tests 目录下
    -- 应为上面的注释，我选择将 log 放入 base 中
    --local log = require("moreitems.lib.shihao.module.log")
    log.info(module.string_format("{{ name         }}", { name = "zsh" }))
    log.info(module.string_format2("{{name        }}", { name = "zsh" }))
end

return module
