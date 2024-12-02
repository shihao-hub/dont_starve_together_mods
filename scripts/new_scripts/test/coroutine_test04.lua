---
--- Created by zsh
--- DateTime: 2023/11/28 4:29
---

local co = coroutine.wrap(function()
    while true do
        coroutine.yield({})
    end
end)

local co2 = coroutine.create(function()
    while true do
        coroutine.yield({})
    end
end)

print(co())
print(co())
print(coroutine.resume(co2))
print(coroutine.resume(co2))