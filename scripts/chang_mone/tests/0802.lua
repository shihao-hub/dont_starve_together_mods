---
--- @author zsh in 2023/8/2 0:40
---

local str = "whip|升级版·猫尾鞭";

print(string.match(str,"[^|]+"));
str = string.match(str,"[^|]+") or str;

print(str);