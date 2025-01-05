---
--- DateTime: 2024/12/3 10:04
--- Description: 项目启动入口，放在模组中，则视为第三方库引入入口
---


return {
    thirdparty = require("moreitems.lib.thirdparty.__init__"),
    shihao = require("moreitems.lib.shihao.__init__"),
    dst = require("moreitems.lib.dst.__init__"),
}


