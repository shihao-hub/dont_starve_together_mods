---
--- @author zsh in 2023/7/9 1:23
---

local co = coroutine.create(
        function(input)
            print("input : " .. input)
            --local param1, param2 = coroutine.yield("yield")
            --print("param1 is : " .. param1)
            --print("param2 is : " .. param2)
            return "return" -- return 也会将结果返回给 resume
        end)

print(coroutine.resume(co,"first resume"));