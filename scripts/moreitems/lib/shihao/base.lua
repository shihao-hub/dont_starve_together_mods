---
--- DateTime: 2024/12/3 21:00
---

local lustache = require("moreitems.lib.thirdparty.lustache.lustache")
local inspect = require("moreitems.lib.thirdparty.inspect.inspect")

local _log = require("moreitems.lib.shihao._log")

-- NOTE:
--  当初 log 转移的时候，为了偷懒保证兼容性，就代码并为删除，而是委托给 base.log，这不好！
--  应该及时重构，而在这个过程中，我深刻体会到为什么说测试覆盖越多，编程效率越快了！
--  测试覆盖越多，代码改动的时候越不会犹犹豫豫！
local module = {
    log = _log,
}

local function _string_format(str, context)
    return (string.gsub(str, "{{ *([a-zA-Z_]+) *}}", function(matched)
        return tostring(context[matched])
    end))
end

---将形如 {{ a }} {{ b }} 等格式的字符串全部替换为 tostring(a) 和 tostring(b)
function module.string_format(str, context)
    return _string_format(str, context)
end

function module.string_format2(template, context)
    return lustache.renderer:render(template, context)
end

---python f-string
function module.fs(str, context)
    return _string_format(str, context)
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


-- 大致简单模仿了 js 的参数归一化
local function _normalize_parameter(arg)
    -- JS:
    --  如果是函数，则设置返回的 get = arg, set = function() error("xxx was assigned to but it has no setter.") end
    --  如果不是函数，则设置返回的 get = arg.get, set = arg.set
    --  注意，JS 中全是对象，所以可以这样！
    -- Question: 那 Lua 中如何是好？好像几乎没有参考价值。。。
    --  按照目前的实现的话，其实设置一个 class，然后返回值是这个 class，挺好的，至少用户知道咋用就行了...

    if type(arg) ~= "function" then
        local old_arg = arg
        arg = function()
            return old_arg
        end
    end

    local obj = {}

    obj._value = arg()

    function obj:get()
        return self._value
    end

    function obj:set(value)
        self._value = value
    end

    return obj
end

function module.if_then_else(condition, expression_or_lazy_fn1, expression_or_lazy_fn2)
    -- 新想法：推荐始终使用 lazy_fn
    assert(type(expression_or_lazy_fn1) == "function")
    assert(type(expression_or_lazy_fn2) == "function")

    local arg2 = _normalize_parameter(expression_or_lazy_fn1)
    local arg3 = _normalize_parameter(expression_or_lazy_fn2)

    -- 不允许发生误解，一律转为 boolean 类型
    if _bool(condition) then
        return arg2:get()
    end
    return arg3:get()
end

---switch 只支持 string（YAGNI！KISS！），因为单纯我自己使用，只支持 string 即可
---软件是在需求中迭代出来的，我不是学术人才，做不到空想就能写出完美 api
---@param condition string
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
    local function check_value_type(value, _type)
        if type(value) == _type then
            return
        end
        error("Expected " .. _type .. ", got " .. type(value))
    end

    check_value_type(condition, "string")
    return function(t)
        local branch = t[condition]
        if branch == nil then
            branch = function() end
        end
        check_value_type(branch, "function")
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
    -- 2025-01-23：在测试中使用这个，不会导致循环依赖！因为 require 的时候不会执行这个判断语句！Python 妙哉！
    local assertion = require("moreitems.lib.shihao.assertion")

    --log.info(module.string_format("{{name}}", {
    --    name = 1
    --}))
    --
    ---- base.lua 中用到子目录中的内容是不合理的，但是这里属于测试区域，而且测试区域理论上应该移动到 tests 目录下
    ---- 应为上面的注释，我选择将 log 放入 base 中
    --log.info(module.string_format("{{ name         }}", { name = "zsh" }))
    --log.info(module.string_format2("{{name        }}", { name = "zsh" }))
    --
    --log.info(module.t_op(true, function() return 111 end, 222))

    --[[ module.switch ]]
    xpcall(function()
        local switch = module.switch

        local res = switch("123") {
            ["123"] = function() return 123 end
        }
        assertion.assert_true(res == 123)
    end, function(msg) io.stderr:write(msg, "\n") end)
end

return module
