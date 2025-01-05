---
--- @author zsh in 2023/1/8 18:30
---


local locale = LOC.GetLocaleCode();
local L = (locale == "zh" or locale == "zht" or locale == "zhr") and true or false;

---@class DstText
local TEXT = {
    HARVESTER_STAFF_USES = 100,
    HARVESTER_STAFF_SHADOW_LEVEL = 1,

    HARVESTER_STAFF_GOLD_USES = 100,
    HARVESTER_STAFF_GOLD_SHADOW_LEVEL = 1,

    SANITY_SUPERTINY = 1,
    SANITY_TINY = 5,
    SANITY_SMALL = 10,
    SANITY_MED = 15,
    SANITY_MEDLARGE = 20,
    SANITY_LARGE = 33,
    SANITY_HUGE = 50,

    TIDY = L and "一键整理" or "One-button finishing";
    PICK = L and "一键捡起" or "One click pick up";
    DELETE = L and "一键销毁" or "One-click destruction";
    OPEN_STATUS = "√√√";
    CLOSE_STATUS = "×××";
};

local COMMON_RECIPE_DESC = "鼠标放到右侧的气球图案上可以看到详细内容";

local prefabsInfo = {
    ["mone_watertree_pillar"] = {
        names = "神树",
        describe = "神树的庇护",
        recipe_desc = nil
    },

    ["mone_fishingnet"] = {
        names = "渔网",
        describe = "捕鱼达人",
        recipe_desc = COMMON_RECIPE_DESC
    },
    ["mone_spear_poison"] = {
        names = "毒矛",
        describe = "蜘蛛都给我死！",
        recipe_desc = COMMON_RECIPE_DESC
    },
    ["mone_redlantern"] = {
        names = "灯笼",
        describe = "",
        recipe_desc = COMMON_RECIPE_DESC
    },
    ["mone_storage_bag"] = {
        names = "保鲜袋",
        describe = "",
        recipe_desc = COMMON_RECIPE_DESC
    },
    ["mone_candybag"] = {
        names = "材料袋",
        describe = "携带材料！",
        recipe_desc = COMMON_RECIPE_DESC
    },
    ["mone_tool_bag"] = {
        names = "工具袋",
        describe = "携带工具！",
        recipe_desc = COMMON_RECIPE_DESC
    },
    ["mone_icepack"] = {
        names = "食物袋",
        describe = "携带食物！",
        recipe_desc = COMMON_RECIPE_DESC
    },
    ["mone_backpack"] = {
        names = "装备袋",
        describe = "解决你装备太多的烦恼！",
        recipe_desc = COMMON_RECIPE_DESC
    },
    ["mone_piggyback"] = {
        names = "收纳袋",
        describe = "统统打包带走！",
        recipe_desc = COMMON_RECIPE_DESC
    },
    ["mone_harvester_staff"] = {
        names = "收割者的砍刀",
        describe = "收集和行走",
        recipe_desc = COMMON_RECIPE_DESC
    },
    ["mone_harvester_staff_gold"] = {
        names = "收割者的黄金砍刀",
        describe = "收集和行走",
        recipe_desc = COMMON_RECIPE_DESC
    },
    ["mone_nightspace_cape"] = {
        names = "暗夜空间斗篷",
        describe = "这可真帅气",
        recipe_desc = COMMON_RECIPE_DESC
    },
    ["mone_seasack"] = {
        names = "海上麻袋",
        describe = "",
        recipe_desc = COMMON_RECIPE_DESC
    },
    ["mone_arborist"] = {
        names = "树木栽培家",
        describe = "想要解放双手吗？找我呀！",
        recipe_desc = COMMON_RECIPE_DESC
    },
    ["mone_skull_chest"] = {
        names = "杂物箱",
        describe = nil,
        recipe_desc = COMMON_RECIPE_DESC
    },
    ["mone_bookstation"] = {
        names = "小书架",
        describe = "求知若渴的头脑应当永远有机会去图书馆博览群书",
        recipe_desc = COMMON_RECIPE_DESC
    },
    ["mone_firesuppressor"] = {
        names = "升级版·雪球发射机",
        describe = nil,
        recipe_desc = COMMON_RECIPE_DESC
    },
    ["mone_orangestaff"] = {
        names = "升级版·懒人魔杖",
        describe = nil,
        recipe_desc = COMMON_RECIPE_DESC
    },
    ["mone_boomerang"] = {
        names = "升级版·回旋镖",
        describe = nil,
        recipe_desc = COMMON_RECIPE_DESC
    },
    ["mone_farm_plow_item"] = {
        names = "升级版·耕地机",
        describe = nil,
        recipe_desc = COMMON_RECIPE_DESC
    },
    ["mone_farm_plow"] = {
        names = "升级版·耕地机",
        describe = nil,
        recipe_desc = COMMON_RECIPE_DESC
    },
    ["mone_eyemaskhat"] = {
        names = "升级版·眼面具",
        describe = nil,
        recipe_desc = COMMON_RECIPE_DESC
    },
    ["mone_shieldofterror"] = {
        names = "升级版·恐怖盾牌",
        describe = nil,
        recipe_desc = COMMON_RECIPE_DESC
    },
    ["mone_treasurechest"] = {
        names = "豪华箱子",
        describe = "我的肚子很大",
        recipe_desc = COMMON_RECIPE_DESC
    },
    ["mone_dragonflychest"] = {
        names = "豪华龙鳞宝箱",
        describe = "我的肚子很大",
        recipe_desc = COMMON_RECIPE_DESC
    },
    ["mone_icebox"] = {
        names = "豪华冰箱",
        describe = "我的肚子很大",
        recipe_desc = COMMON_RECIPE_DESC
    },
    ["mone_saltbox"] = {
        names = "豪华盐箱",
        describe = "我的肚子很大",
        recipe_desc = COMMON_RECIPE_DESC
    },
    ["mone_waterchest_inv"] = {
        names = "海上箱子·便携",
        describe = "你家呢？哦，有我在你不需要家。",
        recipe_desc = COMMON_RECIPE_DESC
    },
    ["mone_waterchest"] = {
        names = "海上箱子·建筑",
        describe = "你家呢？哦，有我在你不需要家。",
        recipe_desc = COMMON_RECIPE_DESC
    },
    ["mone_pith"] = {
        names = "小草帽",
        describe = "草制护具。肯定不能持久。",
        recipe_desc = COMMON_RECIPE_DESC
    },
    ["mone_armor_metalplate"] = {
        names = "铁甲",
        describe = "近乎无法穿透！",
        recipe_desc = COMMON_RECIPE_DESC
    },
    ["mone_brainjelly"] = {
        names = "智慧帽",
        describe = "等等，有点痒，看样子我要长脑子了。",
        recipe_desc = COMMON_RECIPE_DESC
    },
    ["mone_dragonflyfurnace"] = {
        names = "升级版·龙鳞火炉",
        describe = "我想我陷入爱情了",
        recipe_desc = COMMON_RECIPE_DESC
    },
    ["mone_moondial"] = {
        names = "升级版·月晷",
        describe = "即使是在日光之下，玛尼的模样也不变。",
        recipe_desc = COMMON_RECIPE_DESC
    },
    ["mone_double_umbrella"] = {
        names = "双层伞帽",
        describe = "你这双层这么还漏雨啊？",
        recipe_desc = COMMON_RECIPE_DESC
    },
    ["mone_pheromonestone"] = {
        names = "素石",
        describe = "我无敌你随意",
        recipe_desc = COMMON_RECIPE_DESC
    },
    ["mone_pheromonestone2"] = {
        names = "荤石",
        describe = "我无敌你随意",
        recipe_desc = COMMON_RECIPE_DESC
    },
    ["mone_walking_stick"] = {
        names = "临时加速手杖",
        describe = "跑得快吗？寿命换的。",
        recipe_desc = COMMON_RECIPE_DESC
    },
    ["mone_wardrobe"] = {
        names = "你的装备柜",
        describe = "你家太乱了，快用我整理整理吧！",
        recipe_desc = COMMON_RECIPE_DESC
    },
    ["mone_halberd"] = {
        names = "多功能·戟",
        describe = "砍剁 劳作 毁灭",
        recipe_desc = COMMON_RECIPE_DESC
    },
    ["mone_chiminea"] = {
        names = "垃圾焚化炉",
        describe = "我要吞噬一切！",
        recipe_desc = COMMON_RECIPE_DESC
    },
    ["mone_waterballoon"] = {
        names = "生命水球",
        describe = "作物直接巨大！(请在作物能够生长时使用)",
        recipe_desc = COMMON_RECIPE_DESC
    },
    ["mone_city_lamp"] = {
        names = "路灯",
        describe = "只可惜这片大陆没有汽车",
        recipe_desc = COMMON_RECIPE_DESC
    },
    ["mone_bathat"] = {
        names = "蝙蝠帽·测试版",
        describe = "嫌我丑，那我走",
        recipe_desc = COMMON_RECIPE_DESC
    },
    ["mone_gashat"] = {
        names = "燃气帽",
        describe = "燃气帽",
        recipe_desc = COMMON_RECIPE_DESC
    },
    ["mone_piggybag"] = {
        names = "猪猪袋",
        describe = "猪猪袋~",
        recipe_desc = COMMON_RECIPE_DESC
    },
    ["mone_garlic_structure"] = {
        names = "大蒜·建筑",
        describe = "这绝对不是防腐剂超标的大蒜，绝对不是",
        recipe_desc = COMMON_RECIPE_DESC
    },
    ["mone_beef_wellington"] = {
        names = "惠灵顿风干牛排",
        describe = "少年，你想要力量吗？",
        recipe_desc = COMMON_RECIPE_DESC
    },
    ["mone_chicken_soup"] = {
        names = "馊鸡汤",
        describe = "鸡汤来咯！",
        recipe_desc = COMMON_RECIPE_DESC
    },
    ["mone_stomach_warming_hamburger"] = {
        names = "暖胃汉堡包",
        describe = "",
        recipe_desc = COMMON_RECIPE_DESC
    },
    ["mone_lifeinjector_vb"] = {
        names = "强心素食堡",
        describe = "",
        recipe_desc = COMMON_RECIPE_DESC
    },
    ["mone_wathgrithr_box"] = {
        names = "薇格弗德歌谣盒",
        describe = "我爱歌谣",
        recipe_desc = COMMON_RECIPE_DESC
    },
    ["mone_wanda_box"] = {
        names = "旺达钟表盒",
        describe = "",
        recipe_desc = COMMON_RECIPE_DESC
    },
    ["mone_seedpouch"] = {
        names = "妈妈放心种子袋",
        describe = "妈妈再也不用担心我种地吃土了",
        recipe_desc = COMMON_RECIPE_DESC
    },
    ["mone_poisonblam"] = {
        names = "毒药膏",
        describe = "这东西真可怕",
        recipe_desc = COMMON_RECIPE_DESC
    },
    ["mone_honey_ham_stick"] = {
        names = "蜜汁大肉棒",
        describe = "",
        recipe_desc = COMMON_RECIPE_DESC
    },
    ["mone_guacamole"] = {
        names = "超级鳄梨酱",
        describe = "",
        recipe_desc = COMMON_RECIPE_DESC
    },
    ["mone_glommer_poop_food"] = {
        names = "格罗姆拉肚子奶昔",
        describe = "",
        recipe_desc = COMMON_RECIPE_DESC
    },

    ["hivehat"] = {
        names = nil,
        describe = nil,
        recipe_desc = COMMON_RECIPE_DESC
    },
    ["eyemaskhat"] = {
        names = nil,
        describe = nil,
        recipe_desc = COMMON_RECIPE_DESC
    },
    ["shieldofterror"] = {
        names = nil,
        describe = nil,
        recipe_desc = COMMON_RECIPE_DESC
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


