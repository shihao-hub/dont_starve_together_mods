---
--- Created by zsh
--- DateTime: 2023/10/1 0:14
---

-- 23/10/29 这里有问题，lib.shlib 用了 package.loaded 避免循环加载，但是神话的更新导致这种形式出问题了，所以注意一下

-- COMMON_LUA
require("lib.shlib.main")

-- DST_LUA
ShiHaoEnv.DstModEnv = env

require("lib.shlib.dstlib.main")

-- 看样子文件读写只能放到其他地方了？罢了罢了，C 层强制崩溃没办法啊。
--require("lib.shlib.logger")(ShiHaoEnv.DstModEnv.MODROOT .. "/scripts/")
