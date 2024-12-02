---
--- @author zsh in 2023/7/2 14:55
---

local FOOD_PREFIX = "mi_nfs_";

print(string.sub(foodname, #FOOD_PREFIX + 1, -1));