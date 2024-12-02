---
--- @author zsh in 2023/5/6 8:23
---

local API = require("more_items.changscripts.main.lua.dst.API");

--if not API.isClient() then
--    return ;
--end

-- 添加一些快捷键：Ctrl+1
local CONTAINER_KEYS = {
    [""] = { priority = 999, key = "KEY_1" };
    [""] = { priority = 999, key = "KEY_2" };
}

---遍历所有打开的容器，找到其中的指定容器
local function findFirstContainer(name)

end