---
--- @author zsh in 2023/1/8 18:30
---


local locale = LOC.GetLocaleCode();
local L = (locale == "zh" or locale == "zht" or locale == "zhr") and true or false;

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

local MCB_capability = TUNING.MONE_TUNING.GET_MOD_CONFIG_DATA.mone_chests_boxs_capability;
local BALANCE = TUNING.MONE_TUNING.GET_MOD_CONFIG_DATA.BALANCE;

local prefabsInfo = {
    ["mone_spear_poison"] = {
        names = "毒矛",
        describe = "蜘蛛都给我死！",
        recipe_desc = "可以对目标周围造成1.5格范围伤害，固定为25点"
    },
    ["mone_storage_bag"] = {
        names = "保鲜袋",
        describe = "",
        recipe_desc = "4格，永久保鲜"
    },
    ["mone_candybag"] = {
        names = "材料袋",
        describe = "携带材料！",
        recipe_desc = "可随身携带、可以存放草、树枝、燧石、石头、金块、木头"
    },
    ["mone_tool_bag"] = {
        names = "工具袋",
        describe = "携带工具！",
        recipe_desc = "可随身携带、只允许存放有 tool 等标签的物品"
    },
    ["mone_icepack"] = {
        names = "食物袋",
        describe = "携带食物！",
        recipe_desc = "可随身携带、可以存放任何有新鲜度的物品、可以保鲜"
    },
    ["mone_backpack"] = {
        names = "装备袋",
        describe = "解决你装备太多的烦恼！",
        recipe_desc = "可随身携带、允许存放可被装备的物品"
    },
    ["mone_piggyback"] = {
        names = "收纳袋",
        describe = "统统打包带走！",
        recipe_desc = "40格容量、可随身携带"
    },
    ["mone_harvester_staff"] = {
        names = "收割者的砍刀",
        describe = "收集和行走",
        recipe_desc = "快速采集但采集降饥饿度、增加5%移速"
    },
    ["mone_harvester_staff_gold"] = {
        names = "收割者的黄金砍刀",
        describe = "收集和行走",
        recipe_desc = "快速采集但采集降饥饿度、增加10%移速"
    },
    ["mone_nightspace_cape"] = {
        names = "暗夜空间斗篷",
        describe = "这可真帅气",
        recipe_desc = "24格容量、类似骨甲、水上行走"
    },
    ["mone_seasack"] = {
        names = "海上麻袋",
        describe = "",
        recipe_desc = "14格，隔热120秒，移速10%"
    },
    ["mone_arborist"] = {
        names = "树木栽培家", -- 有待优化，太乱了
        describe = "想要解放双手吗？找我呀！",
        recipe_desc = "放入树种，会在半径2.5格地皮内圆形种植树木"
    },
    ["mone_firesuppressor"] = {
        names = "升级版·雪球发射机",
        describe = "一切都是为了便利！",
        recipe_desc = "增加了捡起周围物品并分类转移的功能"
    },
    ["mone_treasurechest"] = {
        names = "豪华箱子",
        describe = "我的肚子很大",
        recipe_desc = "16格或25格或36格，在模组配置里可以修改。", --string.format("%s", MCB_capability and "二十五格" or "十六格"),
    },
    ["mone_dragonflychest"] = {
        names = "豪华龙鳞宝箱",
        describe = "我的肚子很大",
        recipe_desc = "16格或25格或36格，在模组配置里可以修改。", --string.format("%s", MCB_capability and "二十五格" or "十六格"),
    },
    ["mone_icebox"] = {
        names = "豪华冰箱",
        describe = "我的肚子很大",
        recipe_desc = "16格或25格或36格，在模组配置里可以修改。", --string.format("%s", MCB_capability and "二十五格" or "十六格"),
    },
    ["mone_saltbox"] = {
        names = "豪华盐箱",
        describe = "我的肚子很大",
        recipe_desc = "16格或25格或36格，在模组配置里可以修改。", --string.format("%s", MCB_capability and "二十五格" or "十六格"),
    },
    ["mone_waterchest_inv"] = {
        names = "海上箱子·便携",
        describe = "你家呢？哦，有我在你不需要家。",
        recipe_desc = "120格、不可燃、只允许被玩家摧毁、可随身携带"
    },
    ["mone_waterchest"] = {
        names = "海上箱子·建筑",
        describe = "你家呢？哦，有我在你不需要家。",
        recipe_desc = "120格、不可燃、只允许被玩家摧毁、可随身携带"
    },
    ["mone_pith"] = {
        names = "小草帽",
        describe = "草制护具。肯定不能持久。",
        recipe_desc = "耐久度等于草甲，但防御度为70%"
    },
    ["mone_brainjelly"] = {
        names = "智慧帽",
        describe = "等等，有点痒，看样子我要长脑子了。",
        recipe_desc = "聪慧过人，佩戴这个帽子后居然可以控制体温？(四季控温)"
    },
    ["mone_moondial"] = {
        names = "升级版·月晷",
        describe = "即使是在日光之下，玛尼的模样也不变。",
        recipe_desc = "类似反作用的龙鳞火炉\n(一直处于满月的流水状态)"
    },
    ["mone_double_umbrella"] = {
        names = "双层伞帽",
        describe = "你这双层这么还漏雨啊？",
        recipe_desc = "70%防雨，隔热效果为眼球伞的2倍"
    },
    ["mone_pheromonestone"] = {
        names = "素石",
        describe = "我无敌你随意",
        recipe_desc = "使装备无耐久(新鲜度、燃料、使用次数、护甲)"
    },
    ["mone_pheromonestone2"] = {
        names = "荤石",
        describe = "我无敌你随意",
        recipe_desc = "使容器高速返鲜(若某容器该功能突然失效了，这并不能算是bug)"
    },
    ["mone_walking_stick"] = {
        names = "临时加速手杖",
        describe = "跑得快吗？寿命换的。",
        recipe_desc = "手持增加60%的移动速度，但有耐久。"
    },
    ["mone_wardrobe"] = {
        names = "你的装备柜",
        describe = "你家太乱了，快用我整理整理吧！",
        recipe_desc = "36格，存放你的装备。"
    },
    ["mone_halberd"] = {
        names = "多功能·戟",
        describe = "砍剁 劳作 毁灭",
        recipe_desc = "斧头+镐头+锤子(2.5倍效果)"
    },
    ["mone_chiminea"] = {
        names = "垃圾焚化炉",
        describe = "我要吞噬一切！",
        recipe_desc = "顾名思义"
    },
    ["mone_waterballoon"] = {
        names = "生命水球",
        describe = "作物直接巨大！(请在作物能够生长时使用)",
        recipe_desc = "作物直接巨大！\n(请在作物能够生长时使用)"
    },
    ["mone_city_lamp"] = {
        names = "路灯",
        describe = "只可惜这片大陆没有汽车",
        recipe_desc = "范围1.5格地皮"
    },
    ["mone_bathat"] = {
        names = "蝙蝠帽·测试版",
        describe = "嫌我丑，那我走",
        recipe_desc = "佩戴后右键人物可以飞行\n(目前体验不怎么好，有时间我修一修)"
    },
    --["mone_gogglesnormal"] = {
    --    names = L and "科技护目镜" or "Technology goggles",
    --    describe = nil,
    --    recipe_desc = L and "40%防御+色彩正常的且耐久为0不消失的鼹鼠帽" or "40% Defense + Normal Color Mole Cap"
    --},
    -- ??????
    ["mone_puppet"] = {
        names = "皮痒傀儡",
        describe = "有没有人想打我的，我最近皮子痒了。",
        recipe_desc = "丢在地上后变大，然后嘲讽周围敌对目标并反伤"
    },
    --["mone_shark_teeth"] = {
    --    names = L and "犬齿王冠" or "Canine crown",
    --    describe = nil,
    --    recipe_desc = L and "低理智时高防御和高攻击(写不下，具体看创意工坊介绍)" or "Low sanity is high defense and high attack"
    --},
    ["mone_gashat"] = {
        names = "燃气帽",
        describe = "燃气帽",
        recipe_desc = "把鼠标放到右侧的气球图案上可以看到详细介绍"
    },
    ["mone_piggybag"] = {
        names = "猪猪袋",
        describe = "猪猪袋~",
        recipe_desc = "九格、可以存放部分容器和部分其他物品"
    },
    --["mone_bandit"] = {
    --    names = L and "盗贼的帽子" or "Thief's hat",
    --    describe = L and "装备后不会被怪物主动攻击，包括Boss" or "Will not be actively attacked by monsters after equiping, including bosses",
    --    recipe_desc = L and "装备后不会被怪物主动攻击，包括Boss" or "Will not be actively attacked by monsters after equiping, including bosses"
    --},
    ["mone_garlic_structure"] = {
        names = "大蒜·建筑",
        describe = "这绝对不是防腐剂超标的大蒜，绝对不是",
        recipe_desc = "蝙蝠靠近1秒内被熏死\n(??? 蝙蝠 = 吸血鬼 ???)"
    },
    ["mone_beef_wellington"] = {
        names = "惠灵顿风干牛排",
        describe = "少年，你想要力量吗？",
        recipe_desc = "肉食，半天内增加2.5倍伤害\n" .. string.format("%s", BALANCE and "(一次制作四个)" or "(一次制作三个)")
    },
    ["mone_chicken_soup"] = {
        names = "馊鸡汤",
        describe = "鸡汤来咯！",
        recipe_desc = "肉食，有10%的概率回满三维\n(为什么会有这种设定？)"
    },
    ["mone_stomach_warming_hamburger"] = {
        names = "暖胃汉堡包",
        describe = "",
        recipe_desc = "永久增加1点饥饿值上限\n(仅原版，且排除机器人和小鱼人)"
    },
    ["mone_lifeinjector_vb"] = {
        names = "强心素食堡",
        describe = "",
        recipe_desc = "永久增加1点生命值上限\n(仅原版，且排除旺达和小鱼人)"
    },
    ["mone_wathgrithr_box"] = {
        names = "薇格弗德歌谣盒",
        describe = "我爱歌谣",
        recipe_desc = "存放女武神的歌谣\n(并无大用...)"
    },
    ["mone_wanda_box"] = {
        names = "旺达钟表盒",
        describe = "",
        recipe_desc = "存放旺达的钟表(死亡时，容器内的第二次机会表会掉落！)"
    },
    -- 旺达的？emm，暂时不玩旺达，不太懂。
    ["mone_seedpouch"] = {
        names = "妈妈放心种子袋",
        describe = "妈妈再也不用担心我种地吃土了",
        recipe_desc = "14格、种子永鲜、80%防雨"
    },
    ["mone_poisonblam"] = {
        names = "毒药膏",
        describe = "这东西真可怕",
        recipe_desc = "使有新鲜度的物品瞬间腐烂"
    },
    --["mone_bushhat"] = {
    --    names = "升级版·灌木丛帽",
    --    describe = "掩耳盗铃？错！",
    --    recipe_desc = "使用后，敌人会无视你的存在。\n但是还是有些限制的。红宝石修复。"
    --},
    --["mone_relic_2"] = {
    --    names = "神秘的图腾",
    --    describe = "古老而又神秘的存在",
    --    recipe_desc = "关闭图腾后，51%概率物品翻倍，49%概率直接消失。买定离手！"
    --},
    ["mone_honey_ham_stick"] = {
        names = "蜜汁大肉棒",
        describe = "",
        recipe_desc = "吃甜食，真开心。\n半天内效率提高一倍，时间可累加"
    },
    ["mone_guacamole"] = {
        names = "超级鳄梨酱",
        describe = "",
        recipe_desc = "夜视半天，无视沙尘暴，时间不可叠加\n(一次制作三个)"
    },
    ["mone_fish_box"] = {
        names = "大型储藏库",
        describe = "用于储藏的专有建筑",
        recipe_desc = "50格，10倍保鲜，只允许被玩家摧毁，可以制冷的噢！"
    },
    ["mone_empty_prefab"] = {
        names = "更多物品扩展包",
        describe = "",
        recipe_desc = "部分本模组的老玩家好像并不知道`更多物品扩展包`模组的存在" -- "制作后会跳转至 更多物品扩展包 的订阅页面"
    },
    --["mone_beef_bell"] = {
    --    names = "升级版·牛铃",
    --    describe = nil,
    --    recipe_desc = "绑定后将不可解绑，牛死亡3天后，原属性重生"
    --},
    --["pond"] = {
    --    names = nil,
    --    describe = nil,
    --    recipe_desc = "就是原版物品可以制作"
    --},
    --["pond_cave"] = {
    --    names = nil,
    --    describe = nil,
    --    recipe_desc = "就是原版物品可以制作"
    --},
    --["pond_mos"] = {
    --    names = nil,
    --    describe = nil,
    --    recipe_desc = "就是原版物品可以制作"
    --},
    --["meatrack_hermit"] = {
    --    names = nil,
    --    describe = nil,
    --    recipe_desc = "就是原版物品可以制作"
    --},
    --["beebox_hermit"] = {
    --    names = nil,
    --    describe = nil,
    --    recipe_desc = "就是原版物品可以制作"
    --},

}

--[[if TUNING.MONE_TUNING.WORKSHOP_2916323210_ON then
    prefabsInfo["mone_skin_seedpouch"] = {
        names = "阿狸种子袋",
        describe = nil,
        recipe_desc = "阿狸专属"
    }
end]]

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


