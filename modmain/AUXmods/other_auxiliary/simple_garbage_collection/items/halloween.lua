---
--- @author zsh in 2023/5/5 19:16
---

local items = {};

local halloween_ornament = {}; -- 万圣节装饰
local halloweencandy = {}; -- 万圣节糖果

-- 万圣节装饰
if SgcCleanListSwitchImported.halloween_ornament then
    halloween_ornament = {
        "halloween_ornament_1", "halloween_ornament_2", "halloween_ornament_3",
        "halloween_ornament_4", "halloween_ornament_5", "halloween_ornament_6",
    }
end


-- 万圣节糖果
if SgcCleanListSwitchImported.halloweencandy then
    halloweencandy = {
        "halloweencandy_1", "halloweencandy_2", "halloweencandy_3",
        "halloweencandy_4", "halloweencandy_5", "halloweencandy_6",
        "halloweencandy_7", "halloweencandy_8", "halloweencandy_9",
        "halloweencandy_10", "halloweencandy_11", "halloweencandy_12",
        "halloweencandy_13", "halloweencandy_14",
    }
end

UnionSeq(items, halloween_ornament, halloweencandy);

return items;