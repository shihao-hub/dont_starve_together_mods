-- 将 __init__.lua 类比 Python 的 __init__.py 即可，外界需要导入库的话都从这里取

return {
    class = require("moreitems.lib.shihao.class.__init__"),
    module = require("moreitems.lib.shihao.module.__init__"),

    base = require("moreitems.lib.shihao.base"),
    builtin = require("moreitems.lib.shihao.builtin"),
    mini_utils = require("moreitems.lib.shihao.mini_utils"),
    utils = require("moreitems.lib.shihao.utils"),
    warnings = require("moreitems.lib.shihao.warnings"),
}
