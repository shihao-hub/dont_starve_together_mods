---
--- @author zsh in 2023/3/25 13:55
---

-- 2023-03-25：此处不行，我想太简单了。有机会再研究吧！主要 entityscripts.lua 里面上值太多了，不好修改。
return Class(function(self, inst)
    self.inst = inst;

    self.wormhole_marks = {
        -- 主客机
        wormhole_marks = require("mi_modules.wormhole_marks.scripts.components.wormhole_marks");
        -- 主机
        wormhole_counter = require("mi_modules.wormhole_marks.scripts.components.wormhole_counter");
    }
end)