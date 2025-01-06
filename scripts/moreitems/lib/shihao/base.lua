---
--- DateTime: 2024/12/3 21:00
---

local lustache = require("moreitems.lib.thirdparty.lustache.lustache")

local module = {

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
    print(module.string_format("{{name}}", {
        name = 1
    }))
end

return module
