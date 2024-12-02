---
--- @author zsh in 2023/2/5 14:20
---

local locale = LOC.GetLocaleCode();
local L = (locale == "zh" or locale == "zht" or locale == "zhr") and true or false;

local TEXT = {};

local COMMON_RECIPE_DESC = "鼠标放到右侧的气球图案上可以看到详细内容";

local prefabsInfo = {
    ["mie_relic_2"] = {
        names = "神秘的图腾",
        describe = "古老而又神秘的存在",
        recipe_desc = COMMON_RECIPE_DESC
    },
    ["mone_dummytarget"] = {
        names = "皮痒傀儡",
        describe = "有没有人想打我的？最近皮子有点痒。",
        recipe_desc = COMMON_RECIPE_DESC
    },
    ["mie_waterpump"] = {
        names = "升级版·消防泵",
        describe = "肥料掺了金坷垃，小麦亩产一千八。",
        recipe_desc = COMMON_RECIPE_DESC
    },
    ["mie_bushhat"] = {
        names = "升级版·灌木丛帽",
        describe = "真的是掩耳盗铃吗？",
        recipe_desc = COMMON_RECIPE_DESC
    },
    ["mie_tophat"] = {
        names = "沃尔夫冈的高礼帽",
        describe = "沃尔夫冈的高礼帽",
        recipe_desc = COMMON_RECIPE_DESC
    },
    ["mie_sand_pit"] = {
        names = "沙坑",
        describe = "这里好像沉睡着什么？",
        recipe_desc = COMMON_RECIPE_DESC
    },
    ["mie_icemaker"] = {
        names = "制冰机",
        describe = "它把火变成冰！",
        recipe_desc = COMMON_RECIPE_DESC
    },
    ["mie_bundle_state1"] = {
        names = "万物打包带",
        describe = "统统打包带走！",
        recipe_desc = COMMON_RECIPE_DESC
    },
    ["mie_fish_box"] = {
        names = "贮藏室",
        describe = "用于储藏的专用建筑",
        recipe_desc = COMMON_RECIPE_DESC
    },
    ["mie_book_silviculture"] = {
        names = "《论如何做一个懒人》",
        describe = "懒才是第一生产力！",
        recipe_desc = COMMON_RECIPE_DESC
    },
    ["mie_book_horticulture"] = {
        names = "《论如何做一个懒人+》",
        describe = "懒才是第一生产力！",
        recipe_desc = COMMON_RECIPE_DESC
    },
    ["mie_meatballs"] = {
        names = "绝对吃不完的肉丸",
        describe = "无穷无尽",
        recipe_desc = "你绝对吃不完~"
    },
    ["mie_bonestew"] = {
        names = "绝对吃不完的炖肉汤",
        describe = "无穷无尽",
        recipe_desc = "你绝对吃不完~"
    },
    ["mie_leafymeatsouffle"] = {
        names = "绝对吃不完的果冻沙拉",
        describe = "无穷无尽",
        recipe_desc = "你绝对吃不完~"
    },
    ["mie_perogies"] = {
        names = "绝对吃不完的波兰水饺",
        describe = "无穷无尽",
        recipe_desc = "你绝对吃不完~"
    },
    ["mie_dragonpie"] = {
        names = "绝对吃不完的火龙果派",
        describe = "无穷无尽",
        recipe_desc = "你绝对吃不完~"
    },
    ["mie_beefalofeed"] = {
        names = "绝对吃不完的蒸树枝",
        describe = "我的牛牛有福了~",
        recipe_desc = "牛牛有福了~"
    },
    ["mie_icecream"] = {
        names = "绝对吃不完的冰淇淋",
        describe = "无穷无尽",
        recipe_desc = "快造点黄油工厂吧！"
    },
    ["mie_lobsterdinner"] = {
        names = "绝对吃不完的龙虾正餐",
        describe = "无穷无尽",
        recipe_desc = "快造点黄油工厂吧！"
    },
    ["mie_obsidianfirepit"] = {
        names = "黑曜石火坑",
        describe = "",
        recipe_desc = COMMON_RECIPE_DESC
    },
    ["mie_bear_skin_cabinet"] = {
        names = "熊皮保鲜柜",
        describe = "熊皮保鲜柜！让新鲜度有保险！",
        recipe_desc = COMMON_RECIPE_DESC
    },
    ["mie_watersource"] = {
        names = "水桶",
        describe = "水资源！",
        recipe_desc = COMMON_RECIPE_DESC
    },
    ["mie_wooden_drawer"] = {
        names = "抽屉",
        describe = "平平无奇",
        recipe_desc = COMMON_RECIPE_DESC
    },
    --------------------------------------------------------------------------------------------------------
    ["mie_granary_meats"] = {
        names = "粮仓·肉",
        describe = "肉！",
        recipe_desc = COMMON_RECIPE_DESC
    },
    ["mie_granary_greens"] = {
        names = "粮仓·菜",
        describe = "菜！",
        recipe_desc = COMMON_RECIPE_DESC
    },

    ["mie_new_granary"] = {
        names = "谷仓",
        describe = "用于存放大量粮食的专有建筑",
        recipe_desc = COMMON_RECIPE_DESC
    },
    ["mie_well"] = {
        names = "水井",
        describe = "清甜甘洌，冬暖夏凉",
        recipe_desc = COMMON_RECIPE_DESC
    },
    ["mie_bananafan_big"] = {
        names = "芭蕉宝扇",
        describe = "珠光宝色淋漓尽致",
        recipe_desc = COMMON_RECIPE_DESC
    },
    ["mie_yjp"] = {
        names = "羊脂玉净瓶",
        describe = "充斥着生命气息的瓷瓶",
        recipe_desc = COMMON_RECIPE_DESC
    },
    ["mie_cash_tree_ground"] = {
        names = "摇钱树",
        describe = "源源不断生财的宝贝",
        recipe_desc = COMMON_RECIPE_DESC
    },
    ["mie_myth_fuchen"] = {
        names = "拂尘",
        describe = "时时拂拭，莫使惹尘",
        recipe_desc = COMMON_RECIPE_DESC
    },

    ["mie_poop_flingomatic"] = {
        names = "粪便机",
        describe = "它很臭，但很有用。",
        recipe_desc = COMMON_RECIPE_DESC
    },
    --------------------------------------------------------------------------------------------------------
    -- ["dirtpile"] = {
    --     names = nil,
    --     describe = nil,
    --     recipe_desc = "就是原版物品可以制作"
    -- },
    ["warg"] = {
        names = nil,
        describe = nil,
        recipe_desc = "就是原版物品可以制作"
    },
    ["portabletent_item"] = {
        names = nil,
        describe = nil,
        recipe_desc = "就是原版物品可以制作"
    },
    ["lureplantbulb"] = {
        names = nil,
        describe = nil,
        recipe_desc = "就是原版物品可以制作"
    },
    ["pond"] = {
        names = nil,
        describe = nil,
        recipe_desc = "就是原版物品可以制作"
    },
    ["pond_cave"] = {
        names = nil,
        describe = nil,
        recipe_desc = "就是原版物品可以制作"
    },
    ["pond_mos"] = {
        names = nil,
        describe = nil,
        recipe_desc = "就是原版物品可以制作"
    },
    ["moonbase"] = {
        names = nil,
        describe = nil,
        recipe_desc = "就是原版物品可以制作"
    },
    ["lava_pond"] = {
        names = nil,
        describe = nil,
        recipe_desc = "就是原版物品可以制作"
    },
    ["meatrack_hermit"] = {
        names = nil,
        describe = nil,
        recipe_desc = "就是原版物品可以制作"
    },
    ["beebox_hermit"] = {
        names = nil,
        describe = nil,
        recipe_desc = "就是原版物品可以制作"
    },
    ["pigtorch"] = {
        names = nil,
        describe = nil,
        recipe_desc = "就是原版物品可以制作"
    },
    ["tallbirdnest"] = {
        names = nil,
        describe = nil,
        recipe_desc = "就是原版物品可以制作"
    },
    ["catcoonden"] = {
        names = nil,
        describe = nil,
        recipe_desc = "这是中空树桩，是巢穴！"
    },
    ["slurtlehole"] = {
        names = nil,
        describe = nil,
        recipe_desc = "这是蛞蝓龟巢，是巢穴！"
    },
}

for k, v in pairs(prefabsInfo) do
    if v and v.recipe_desc == nil then
        v.recipe_desc = COMMON_RECIPE_DESC;
    end
end

for name, info in pairs(prefabsInfo) do
    for k, content in pairs(info) do
        do
            local condition = k;
            local switch = {
                ["names"] = function(n, c)
                    if c then
                        STRINGS.NAMES[n:upper()] = STRINGS.NAMES[n:upper()] or c;
                    end
                end,
                ["describe"] = function(n, c)
                    if c then
                        STRINGS.CHARACTERS.GENERIC.DESCRIBE[n:upper()] = STRINGS.CHARACTERS.GENERIC.DESCRIBE[n:upper()] or c;
                    end
                end,
                ["recipe_desc"] = function(n, c)
                    if c then
                        STRINGS.RECIPE_DESC[n:upper()] = STRINGS.RECIPE_DESC[n:upper()] or c;
                    end
                end
            };
            if switch[condition] then
                switch[condition](name, content); -- name, content 传参是为了避免闭包罢了
            end
        end
    end
end

TEXT.prefabsInfo = prefabsInfo;

return TEXT;