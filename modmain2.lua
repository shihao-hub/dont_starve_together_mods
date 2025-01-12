---
--- DateTime: 2024/12/5 16:35
---

-- 2025-01-12-23:00 发布的版本，此处的代码居然会导致游戏启动时卡在导入 modmain2.lua 文件处？注释掉就正常了。。。

local dst = require("moreitems.main").dst

local dst_utils = dst.class.DSTUtils(env)

env.modimport("mod_config.lua")


-- 2024-12-05-17:30 止于此，今日只是将模组整理了一番，本周暂且如此吧。接下来两天优先 java 和 js，但是这两天关于 Lua 可以总结一下。
