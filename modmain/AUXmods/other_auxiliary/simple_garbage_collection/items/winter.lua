---
--- @author zsh in 2023/5/5 19:11
---

local items = {};

local winter_ornament = {}; -- 节日挂饰
local winter_ornament_boss = {}; -- 豪华装饰
local winter_food = {}; -- 冬季零食
local winter_ornament_light = {}; -- 圣诞彩灯

-- 节日挂饰
if SgcCleanListSwitchImported("winter_ornament") then
    winter_ornament = {
        "winter_ornament_fancy1", "winter_ornament_fancy2", "winter_ornament_fancy3",
        "winter_ornament_fancy4", "winter_ornament_fancy5", "winter_ornament_fancy6",
        "winter_ornament_fancy7", "winter_ornament_fancy8", "winter_ornament_plain1",
        "winter_ornament_plain2", "winter_ornament_plain3", "winter_ornament_plain4",
        "winter_ornament_plain5", "winter_ornament_plain6", "winter_ornament_plain7",
        "winter_ornament_plain8", "winter_ornament_plain9", "winter_ornament_plain10",
        "winter_ornament_plain11", "winter_ornament_plain12",
    }
end


-- 豪华装饰
if SgcCleanListSwitchImported("winter_ornament_boss") then
    winter_ornament_boss = {
        "winter_ornament_boss_bearger", "winter_ornament_boss_deerclops", "winter_ornament_boss_moose",
        "winter_ornament_boss_dragonfly", "winter_ornament_boss_beequeen", "winter_ornament_boss_toadstool",
        "winter_ornament_boss_antlion", "winter_ornament_boss_fuelweaver", "winter_ornament_boss_klaus",
        "winter_ornament_boss_malbatross", "winter_ornament_boss_krampus", "winter_ornament_boss_noeyered",
        "winter_ornament_boss_noeyeblue", "winter_ornament_boss_crabking", "winter_ornament_boss_crabkingpearl",
        "winter_ornament_boss_hermithouse", "winter_ornament_boss_minotaur", "winter_ornament_boss_pearl",
        "winter_ornament_boss_toadstool_misery",
    }
end

-- 冬季零食
if SgcCleanListSwitchImported("winter_food") then
    winter_food = {
        "winter_food1", -- 姜饼人
        "winter_food2", -- 糖屑曲奇
        "winter_food3", -- 拐杖糖
        "winter_food4", -- 不朽的水果蛋糕
        "winter_food5", -- 巧克力原木蛋糕
        "winter_food6", -- 干果布丁
        "winter_food7", -- 苹果酒
        "winter_food8", -- 热可可
        "winter_food9", -- 神圣的蛋奶酒
    }
end

-- 圣诞彩灯
if SgcCleanListSwitchImported("winter_ornament_light") then
    winter_ornament_light = {
        "winter_ornament_light1", "winter_ornament_light2", "winter_ornament_light3",
        "winter_ornament_light4", "winter_ornament_light5", "winter_ornament_light6",
        "winter_ornament_light7", "winter_ornament_light8",
    }
end

UnionSeq(items, winter_ornament, winter_ornament_boss, winter_food, winter_ornament_light);

return items;