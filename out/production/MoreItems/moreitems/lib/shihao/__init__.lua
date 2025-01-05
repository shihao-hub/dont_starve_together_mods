-- 将 __init__.lua 类比 Python 的 __init__.py 即可，外界需要导入库的话都从这里取

return {
    base = require("moreitems.lib.shihao.base"),
    utils = require("moreitems.lib.shihao.utils"),
    log = require("moreitems.lib.shihao.module.log"),
    checker = require("moreitems.lib.shihao.module.checker"),
}