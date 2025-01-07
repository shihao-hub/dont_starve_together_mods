-- 2025-01-07：
-- 还是那个问题，如何解决循环依赖问题。
-- 如果 module 目录下的文件只依赖 base.lua，那么其他文件就可以随意引用了！
-- 也就是说，要求 module 目录下的文件不依赖外部文件！顶多依赖自己。而依赖自己的话，可以将方法抽入 __shared__.lua 文件中！

-- 继续补充：
--  根目录不能依赖子目录的 __shared__.lua！

-- 继续补充：
--  我发现，如果不存在循环依赖，那么任何一个 lua 文件都可以在任何地点执行测试？
--  【编程规范】
--      1. 父目录绝不允许依赖子目录
--      2. 同一目录下的文件相互依赖的话，应该将其抽取到 __shared__.lua 文件中

-- 【约定】【暂定】
--  shihao.module 目录下的文件将被 class 目录 和 shihao 目录下的 .lua 文件依赖
--  因此目前的情况是：shihao.module 只依赖 base.lua 文件，其他文件绝对不会依赖！
--  那这意味着什么？同级文件只依赖 __shared__.lua 文件被破坏！所以有问题！【待解决】

-- module 目录下的文件允许 class 目录下的文件调用，反之不允许？【待定】



return {
    stl = require("moreitems.lib.shihao.module.stl.__init__"),

    assertion = require("moreitems.lib.shihao.module.assertion"),
    checker = require("moreitems.lib.shihao.module.checker"),
    guards = require("moreitems.lib.shihao.module.guards"),
    log = require("moreitems.lib.shihao.module.log"),
}
