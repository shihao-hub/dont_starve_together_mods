---
--- Created by zsh
--- DateTime: 2023/11/26 2:27
---

require("new_scripts.mod_a.main")

local tasks = {
    coroutine.create(function()
        print("--1")
        coroutine.yield("sleep", 1)
    end),
    coroutine.create(function()
        print("--2")
        coroutine.yield("sleep", 2)
    end),
    coroutine.create(function()
        print("--3")
        coroutine.yield("sleep", 3)
    end)
}

local co = coroutine.create(function()
    for i = 1, math.huge do
        morel_print_flush(coroutine.yield("sleep", i))
    end
end)

while true do
    local str = io.read()
    morel_print_flush(coroutine.resume(co, str))
end



