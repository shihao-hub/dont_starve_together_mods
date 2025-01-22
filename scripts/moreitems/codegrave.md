`preload.lua`
```lua
---
--- DateTime: 2024/12/4 9:21
---

local function is_dst_running_environment()
    return _G.TheSim ~= nil
end

if is_dst_running_environment() then
    return
end

------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
local old_package_path = package.path

local package_paths = {
    old_package_path, -- 注释的目的是，不要去 lua for windows 本地库中查找，我要自己找包用
    --string.sub(old_package_path, 1, 8), -- old_package_path 注释后，这个需要加上
    -- 2024-12-04：库删掉了
    --".\\lib\\luastdlib\\lib\\?.lua", -- 兼容 luastdlib
    --".\\lib\\lualogging\\src\\?.lua", -- 兼容 lualogging
    ".\\moreitems\\?.lua",
}
package.path = table.concat(package_paths, ";")

------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

```

---

`guard.lua`
```lua
---使用注意事项：
---1. 只能在 for 循环中使用（建议在大量循环时使用，比如五百次以上、上千次、上万次循环）
---2. loop_cache 每次循环都是同一个
---3. fn 不允许存在 for 循环中会发生变化的上值
---
---总结，本方法是在需要优化的时候才能使用的方法，因为第 2 点和第 3 点的条件过于苛刻，容易出错。
function module.__invoke_for_loop(loop_cache, fn, ...)
    -- NOTE: 这个实现方式是有问题的，因为与其这样，那我还在循环中创建函数干嘛？移出去定义一次不就行了？
    local args = { n = select("#", ...), ... }
    local key = ""
    for i = 1, args.n do
        key = key .. tostring(args[i])
    end
    if loop_cache[key] == nil then
        loop_cache[key] = fn
    end
    return _invoke(loop_cache[key], ...)
end
```