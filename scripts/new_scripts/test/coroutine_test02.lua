---
--- Created by zsh
--- DateTime: 2023/11/25 7:35
---

require("new_scripts.mod_a.main")
local function interrupt() io.read() end
local function bruce_sleep(time)
    local start = os.clock()
    --morel_print_flush(start)
    repeat
        local now = os.clock()
        --morel_print_flush(now)
    until now - start > time
end

local co1_wrap = coroutine.wrap(function()
    local cnt = 0
    local max = 100
    while cnt < max do
        cnt = cnt + 1
        --bruce_sleep(1)
        morel_print_flush("coroutine --1")
    end
end)

local co2_wrap = coroutine.wrap(function()
    local cnt = 0
    local max = 1000
    while cnt < max do
        cnt = cnt + 1
        --bruce_sleep(1)
        morel_print_flush("coroutine --2")
    end
end)

-- 暂时得到的不确定的结论：Lua 的协程在底层也不是一个单独线程，主进程和协程并不是交替执行的，是顺序执行的。啊？
while true do
    morel_print_flush("main --1")
    if co1_wrap then
        local co1 = co1_wrap()
        co1_wrap = nil
        --if coroutine.status(co1) == "dead" then co1 = nil end
    end
    morel_print_flush("main --1.2")
    if co2_wrap then
        local co2 = co2_wrap()
        co2_wrap = nil
        --if coroutine.status(co2) == "dead" then co2 = nil end
    end
    --morel_print_flush(res)
    io.read()
end
--interrupt()
