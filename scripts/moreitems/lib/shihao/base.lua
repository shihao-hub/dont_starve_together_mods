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

local function _string_format(template, context)
    return (string.gsub(template, "{{ *([a-zA-Z_]+) *}}", function(matched)
        return tostring(context[matched])
    end))
end

local function _string_format2(template, context)
    return lustache.renderer:render(template, context)
end

---将形如 {{ a }} {{ b }} 等格式的字符串全部替换为 tostring(a) 和 tostring(b)
function module.string_format(template, context)
    return _string_format(template, context)
end

---python f-string
function module.f_string(str, context)
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

    -- normalize，这也算归一化。
    if type(arg) ~= "function" then
        local old_arg = arg
        arg = function()
            return old_arg
        end
    end

    -- normalize
    local obj = {}

    obj._value = nil

    function obj:get()
        if self._value == nil then
            self._value = arg()
        end
        return self._value
    end

    function obj:set(value)
        self._value = value
    end

    return obj
end

function module.if_then_else(condition, true_branch, false_branch)
    -- 新想法：推荐始终使用 lazy_fn
    assert(type(true_branch) == "function")
    assert(type(false_branch) == "function")

    -- 注意，此处的代码写法是没意义的，但是主要是简单模仿 js 视频中的关于参数归一化的技巧。（只要会嘎嘎叫那就是鸭子）
    local arg2 = _normalize_parameter(true_branch)
    local arg3 = _normalize_parameter(false_branch)

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

local function _get_args(...)
    return { n = select("#", ...), ... }
end

function module.get_args(...)
    return _get_args(...)
end

local function _ipairs_has_hole(t)
    local len = t.n
    if len == nil then
        --error("The `t` don't have the key `n`.", 2)
        local n = #t
        local maxn = table.maxn(t)
        assert(n == maxn)
        len = math.max(n, maxn)
    end
    local index = 1
    return function()
        if index > len then
            return nil
        end
        index = index + 1
        return index - 1, t[index - 1]
    end
end

function module.ipairs_has_hole(t)
    return _ipairs_has_hole(t)
end

---依次检查每个键的存在性。如果在某个阶段找不到对应的键，函数将返回 `nil`，而不会抛出错误。
---
---可变参数为空时，返回 chain 链末尾值。可变参数不为空时，调用函数。
---@param root table
---@param chain string
function module.optional_chain(root, chain, ...)
    local res
    local args = _get_args(...)

    local chain_elems = {}
    local _, n = string.gsub(chain, "([^.]+)", function(capture)
        table.insert(chain_elems, capture)
    end)
    chain_elems.n = n

    local elem = root
    for i = 2, chain_elems.n do
        if elem == nil then
            return nil
        end
        elem = elem[chain_elems[i]]
    end

    if args.n == 0 then
        res = elem
    else
        if type(elem) ~= "function" then
            error("The last value of `" .. chain .. "`" .. " is unexpected ==> expected: a function type, but was: " .. type(elem) .. ".", 2)
        end
        res = elem(unpack(args, 1, args.n))
    end
    return res
end

---Usage:
---
---if br_1 elseif br_2 ... else base.never() end
---
---程序是可以扩展的，为此，在最初实现的时候，永远都要写一个 else 分支。
function module.should_never_reach_here()
    error("should never reach here.", 3)
end

---需要保证整个 for 循环体的逻辑全放在 fn 里面
---@return boolean true 为 break，false/nil 为 continue
function module.continue_or_break(fn)
    return fn()
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

    --[[ optional_chain ]]
    print(module.optional_chain({}, "inst"))

    local function foreachWithNil(array, callback)
        -- 遍历整个数组，包括 nil 值
        for i = 1, #array do
            callback(array[i], i) -- 直接调用回调，允许为 nil
        end
    end

    local myArray = { 1, 2, nil, 4, nil, 6 }
    print(#myArray) -- # 居然和 table.maxn 一样？不对啊，# 不是和 ipairs 一样吗
    print(table.maxn(myArray))

    foreachWithNil(myArray, function(value, index)
        if value == nil then
            print("Element at index " .. index .. " is nil")
        else
            print("Element at index " .. index .. " is " .. value)
        end
    end)
    print("------")

    --[[ ipairs_has_hole ]]
    local t = { 1, 2, nil, 4, 5, nil, 7, 8 }
    for i, v in module.ipairs_has_hole(t) do
        print(i, v)
    end
    print("------")
    for i, v in ipairs(t) do
        print(i, v)
    end
end

return module
