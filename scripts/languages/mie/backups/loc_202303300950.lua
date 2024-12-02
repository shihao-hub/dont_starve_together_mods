---
--- @author zsh in 2023/2/5 14:20
---

local locale = LOC.GetLocaleCode();
local L = (locale == "zh" or locale == "zht" or locale == "zhr") and true or false;

local TEXT = {};

local prefabsInfo = {
    ["mie_relic_2"] = {
        names = "神秘的图腾",
        describe = "古老而又神秘的存在",
        recipe_desc = "关闭图腾后，55%概率物品翻倍，45%概率直接消失。买定离手！"
    },
    ["mone_dummytarget"] = {
        names = "皮痒傀儡",
        describe = "有没有人想打我的？最近皮子有点痒。",
        recipe_desc = "嘲讽4格内目标，并反伤。击杀傀儡者，会受到10%生命的真实伤害。"
    },
    ["mie_waterpump"] = {
        names = "升级版·消防泵",
        describe = "肥料掺了金坷垃，小麦亩产一千八。",
        recipe_desc = "可以给周围缺水的农田浇水，也可以和植物对话。也能灭火。"
    },
    ["mie_bushhat"] = {
        names = "升级版·灌木丛帽",
        describe = "真的是掩耳盗铃吗？",
        recipe_desc = "可以让大多数生物直接丢失仇恨。红宝石可以修复。"
    },
    ["mie_tophat"] = {
        names = "沃尔夫冈的高礼帽",
        describe = "沃尔夫冈的高礼帽",
        recipe_desc = "拥有贝雷帽的全部效果，沃尔夫冈佩戴后不掉力量值。"
    },
    ["mie_walterhat"] = {
        names = "沃尔夫冈的帽子",
        describe = "沃尔夫冈的帽子",
        recipe_desc = "拥有贝雷帽的全部效果，沃尔夫冈佩戴后不掉力量值。"
    },
    ["mie_sand_pit"] = {
        names = "沙坑",
        describe = "这里好像沉睡着什么？",
        recipe_desc = "蚁狮的沙坑贴图。等价于半自动的物品转移功能，但是占地面积小。"
    },
    ["mie_icemaker"] = {
        names = "制冰机",
        describe = "它把火变成冰！",
        recipe_desc = "它把火变成冰！"
    },
    ["mie_bundle_state1"] = {
        names = "万物打包带",
        describe = "统统打包带走！",
        recipe_desc = "主要可以打包有建筑标签的物体、一些指定物体（告诉作者就行了）"
    },
    ["mie_bundle_state2"] = {
        names = "万物打包带",
        describe = "统统打包带走！",
        recipe_desc = "主要可以打包有建筑标签的物体、一些指定物体（告诉作者就行了）！"
    },
    ["mie_fish_box"] = {
        names = "贮藏室",
        describe = "用于储藏的专有建筑",
        recipe_desc = "60格，10倍保鲜，只允许被玩家摧毁，可以制冷的噢！"
    },
    ["mie_book_silviculture"] = {
        names = "《论如何做一个懒人》",
        describe = "懒才是第一生产力！",
        recipe_desc = "阅读时，收纳半径3.75格内的物品。如果是树根，会帮你铲除！"
    },
    ["mie_book_horticulture"] = {
        names = "《论如何做一个懒人+》",
        describe = "懒才是第一生产力！",
        recipe_desc = "阅读时，采集半径3.75格内的植株等。采集巨大作物要小心噢。"
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
        recipe_desc = "照明范围和燃烧时间都是普通火坑的3倍有余"
    },
    ["mie_bear_skin_cabinet"] = {
        names = "熊皮保鲜柜",
        describe = "熊皮保鲜柜！让新鲜度有保险！",
        recipe_desc = "永久保鲜、可以存放任何有新鲜度的物体。"
    },
    ["mie_watersource"] = {
        names = "水桶",
        describe = "水资源！",
        recipe_desc = "水资源、25格、可以存放`食物和耕作`栏以及一些种田必需的物品"
    },
    ["mie_wooden_drawer"] = {
        names = "抽屉",
        describe = "平平无奇",
        recipe_desc = "不可燃的箱子，只允许玩家摧毁。分拣机不会将物品转移到其中。"
    },

    ["mie_fishnet"] = {
        names = "渔网",
        describe = "渔网",
        recipe_desc = "官方的废稿，还未完善。\n不知道能不能捕鱼。"
    },


    ["mie_granary_meats"] = {
        names = "粮仓·肉",
        describe = "肉！",
        recipe_desc = "10倍保鲜"
    },
    ["mie_granary_greens"] = {
        names = "粮仓·菜",
        describe = "菜！",
        recipe_desc = "10倍保鲜"
    },

    ["mie_new_granary"] = {
        names = "谷仓",
        describe = "用于存放大量粮食的专有建筑",
        recipe_desc = "50格，10倍保鲜，可以放蔬菜、水果、种子。"
    },
    ["mie_well"] = {
        names = "水井",
        describe = "清甜甘洌，冬暖夏凉",
        recipe_desc = "水井、可以遏制半径4格内的焖烧"
    },
    ["mie_bananafan_big"] = {
        names = "芭蕉宝扇",
        describe = "珠光宝色淋漓尽致",
        recipe_desc = "呼风唤雨"
    },
    ["mie_yjp"] = {
        names = "羊脂玉净瓶",
        describe = "充斥着生命气息的瓷瓶",
        recipe_desc = "满水满肥，雨水补给。\n枯萎的作物复活、灭火、停雨。"
    },

    ["portabletent_item"] = {
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
local config_data = TUNING.MIE_TUNING.MOD_CONFIG_DATA;

--if config_data.rewrite_storage_bag then
--    prefabsInfo["mone_storage_bag"] = {
--        names = "保鲜袋·重制版",
--        describe = "",
--        recipe_desc = "可随身携带、永久保鲜、4格、无耐久"
--    }
--end
--if config_data.rewrite_arborist then
--    prefabsInfo["mone_arborist"] = {
--        names = "树木栽培家",
--        describe = "想要解放双手吗？找我呀！",
--        recipe_desc = "放入树种，会在半径2.5格地皮内圆形种植树木"
--    }
--end

for name, info in pairs(prefabsInfo) do
    for k, content in pairs(info) do
        do
            local condition = k;
            local switch = {
                ["names"] = function(n, c)
                    if c then
                        -- 补丁
                        if n == "mone_storage_bag" then
                            STRINGS.NAMES[n:upper()] = c;
                            return ;
                        end
                        if n == "mone_arborist" then
                            STRINGS.NAMES[n:upper()] = c;
                            return ;
                        end
                        STRINGS.NAMES[n:upper()] = STRINGS.NAMES[n:upper()] or c;
                    end
                end,
                ["describe"] = function(n, c)
                    if c then
                        -- 补丁
                        if n == "mone_storage_bag" then
                            STRINGS.CHARACTERS.GENERIC.DESCRIBE[n:upper()] = c;
                            return ;
                        end
                        if n == "mone_arborist" then
                            STRINGS.CHARACTERS.GENERIC.DESCRIBE[n:upper()] = c;
                            return ;
                        end
                        STRINGS.CHARACTERS.GENERIC.DESCRIBE[n:upper()] = STRINGS.CHARACTERS.GENERIC.DESCRIBE[n:upper()] or c;
                    end
                end,
                ["recipe_desc"] = function(n, c)
                    if c then
                        -- 补丁
                        if n == "mone_storage_bag" then
                            STRINGS.RECIPE_DESC[n:upper()] = c;
                            return ;
                        end
                        if n == "mone_arborist" then
                            STRINGS.RECIPE_DESC[n:upper()] = c;
                            return ;
                        end
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

return TEXT;