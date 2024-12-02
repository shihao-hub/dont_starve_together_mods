---
--- @author zsh in 2023/4/27 3:09
---


local t = { 1, 2, 3, nil, 4 };
print(unpack(t, 1, table.maxn(t)));