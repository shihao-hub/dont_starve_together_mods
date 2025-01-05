---
--- @author zsh in 2023/7/31 15:31
---

path = "xxx1.lua"
local i, j = string.find(path, "%.lua$");
if i ~= nil then
    path = string.sub(path, 1, i - 1);
end

print(path);