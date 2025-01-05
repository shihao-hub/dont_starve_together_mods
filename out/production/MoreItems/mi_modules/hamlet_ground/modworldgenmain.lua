---
--- @author zsh in 2023/3/24 13:07
---

-- 环境设置
local ENV = TUNING.MONE_TUNING.MI_MODULES.HAMLET_GROUND.ENV;
setfenv(1, ENV);

-- 此处是导入的第一个文件！
modimport("scripts/mi_modules/hamlet_ground/tileadder.lua")

-- 添加新地皮
AddTiles();
