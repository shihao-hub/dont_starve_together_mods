---
--- @author zsh in 2023/4/30 4:37
---


local skinname = "bundlewrap_cawnival";
local prefix_i, prefix_j = string.find(skinname, "^bundle");
print(prefix_i, prefix_j);
local suffix_i, suffix_j = string.find(skinname, "_.+$");
print(suffix_i, suffix_j);
print(string.sub(skinname, prefix_i, prefix_j) .. string.sub(skinname, suffix_i, suffix_j));
print(skinname);