---
--- DateTime: 2024/12/3 10:04
--- Description: 项目启动入口，放在模组中，则视为第三方库引入入口
---

-- 如何测试依赖是否有问题：只要 require("moreitems.main") 即可。虽然一次性全加载进了内存，但是方便啊。反正不过是小项目，就用小项目的设计思路呗。
return {
    thirdparty = require("moreitems.lib.thirdparty.__init__"),
    shihao = require("moreitems.lib.shihao.__init__"),
    dst = require("moreitems.lib.dst.__init__"),
}


