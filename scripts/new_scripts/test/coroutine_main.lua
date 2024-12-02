---
--- Created by zsh
--- DateTime: 2023/11/27 18:38
---


-- coroutine 的使用
local co = coroutine.create(function()
    -- 第一个 resume 执行到这里时会挂起
    -- 第二个 resume 执行时传递的信息是这个 yield 的返回值
    print(coroutine.yield("[message] co-a"))
    return "coroutine instance end"
end)
-- 此处的返回值是协程中遇到的第一个 yield
print(coroutine.resume(co))
print(coroutine.resume(co, "[message] main-a"))

-- 总之，
-- 除了第一次 resume 用来启动协程外，后面 resume 调用时会传递信息给 yield
-- 协程在被挂起的位置会传递信息给刚刚唤醒它的位置
-- 协程在上次被挂起的位置会接收到来自这次唤醒它的位置处传递的信息


-- 上面的代码运行过程：
-- 首先启动协程，运行到第一个 yield 的时候挂起协程，resume 执行结束，返回值为第一个 yield 传递的信息
-- 然后从第一个 yield 处唤醒协程，yield 的返回值为这次 resume 传递的信息，而这次 resume 的返回值是协程的返回值

