---
--- DateTime: 2024/12/5 16:51
---

-- class 将一律大写

-- 在我看来，dst 根本不需要 module 目录

return {
    class = require("moreitems.lib.dst.class.__init__"),
    --module = require("moreitems.lib.dst.module.__init__"),

    dst_namedtuples = require("moreitems.lib.dst.dst_namedtuples"),
    dst_utils = require("moreitems.lib.dst.dst_utils"),
    dst_service = require("moreitems.lib.dst.dst_service"),
}
