---
--- @author zsh in 2023/6/13 16:05
---


--print(string.find("plant_xxx_111", "^plant_(.+)_(.+)$"))
print(string.find("plant_garlic_1", "^plant_(.-)_(%d+)$"))
--print(string.find("_111", "_(%d+)"))