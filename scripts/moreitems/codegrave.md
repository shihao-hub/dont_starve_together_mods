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