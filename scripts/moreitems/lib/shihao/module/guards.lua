--[[
    “guards” 在编程和软件开发中通常指的是一种用于保护和控制程序执行流程的机制或功能。它的主要作用是用来 检查某些条件是否满足，以决定是否执行特定的代码块。根据上下文，"guards" 可能会有以下几种含义：
    1. **条件检查**：在编码时，“guard” 可以表示函数或条件，只有在特定条件为真时才会执行后续的代码。例如，在某些编程语言中 ，您可能会看到使用 guard 子句来在函数开始时检查有效性，以提前返回或触发错误。
    2. **安全性措施**：在更广泛的上下文中，guards 也可以指代保护程序不受无效输入或状态影响的代码，确保系统稳健性。
    3. **类型保护**：在某些编程语言中，guards 还可以指用于检查类型或条件的机制，以确保程序运行时类型安全。
    对于您提到的 `if_present` 和 `if_present_or_else` 函数，如果它们的作用是检查某一值是否存在并从而决定后续执行的流程，使用“guards”作为模块名称是合适的，因其强调了条件检查这一点。
]]

local module = {}

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


return module