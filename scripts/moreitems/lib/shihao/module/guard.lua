--[[
## guard
### 什么是 guard？
`guard` 在编程和软件开发中通常指的是一种用于保护和控制程序执行流程的机制或功能。

它的主要作用是用来 检查某些条件是否满足，以决定是否执行特定的代码块。

根据上下文，"guard" 可能会有以下几种含义：
1. **条件检查**：在编码时，“guard” 可以表示函数或条件，只有在特定条件为真时才会执行后续的代码。
   例如，在某些编程语言中 ，您可能会看到使用 guard 子句来在函数开始时检查有效性，以提前返回或触发错误。
2. **安全性措施**：在更广泛的上下文中，guard 也可以指代保护程序不受无效输入或状态影响的代码，确保系统稳健性。
3. **类型保护**：在某些编程语言中，guard 还可以指用于检查类型或条件的机制，以确保程序运行时类型安全。

对于您提到的 `if_present` 和 `if_present_or_else` 函数，如果它们的作用是检查某一值是否存在并从而决定后续执行的流程，

使用 `guard` 作为模块名称是合适的，因其强调了条件检查这一点。

### 关于 guard 的一些个人理解
> 可以参考卫语句的含义，guard 可以用于安全性措施、辅助代码等。

#### 辅助代码
- 判空
- 打印日志
- 鉴权
- 降级
- 缓存检查

...

这些代码往往会在多个函数中重复冗余。
]]

local base = require("moreitems.lib.shihao.base")
local log = base.log
local exception = require("moreitems.lib.shihao.exception")

local module = {}

local function _invoke(fn, ...)
    return fn(...)
end

---@param value any
---@param _type string
local function _check_template_method(value, _type)
    if type(value) == _type then
        return
    end
    exception.throw_IllegalArgumentException("Expected " .. _type .. ", got " .. type(value))
end


------------------------------------------------------------------------------------------------------------------------
---条件检查
------------------------------------------------------------------------------------------------------------------------

-- 2025-01-06，未来我认为该函数会移动到 module 目录下的模块中，只能说，项目永远都有遗产需要解决。到时候我要么重构，要么直接用委托，然后加一个 warning
function module.if_present(value, consumer_action)
    if value ~= nil then
        -- 注意，由于闭包的存在，value 传进去用不用都无所谓的，Java 没有闭包，所以需要这样
        -- 2025-01-06：我认为闭包比较方便，建议直接闭包
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


------------------------------------------------------------------------------------------------------------------------
---安全性措施
------------------------------------------------------------------------------------------------------------------------

---直接调用 fn 函数
---
---大部分使用场景为匿名函数，因为存在 upvalue，其实 `...` 可变参数应该没有什么存在的价值。
---因为对于 lua 而言，upvalue 我可以认为是参数输出，即指针。
function module.invoke(fn, ...)
    return _invoke(fn, ...)
end

function module.invoke_safe(fn, ...)
    local res
    local args = { n = select("#", ...), ... }
    xpcall(function()
        res = _invoke(fn, unpack(args, 1, args.n))
    end, function(msg)
        log.error(msg)
    end)
    return res
end


------------------------------------------------------------------------------------------------------------------------
---类型保护
------------------------------------------------------------------------------------------------------------------------
---注意，check 开头的，一律都会报错！
function module.check_string(value)
    _check_template_method(value, "string")
end

function module.check_function(value)
    _check_template_method(value, "function")
end

function module.require_not_nil(value, message)
    message = base.if_then_else(message, message, "Expected " .. "not nil" .. ", got " .. "nil")
    if value == nil then
        error(message)
    end
end

if select("#", ...) == 0 then
    --[[ check_string ]]
    xpcall(function()
        module.check_string("string")
    end, function(msg) io.stderr:write(msg, "\n") end)
end

return module