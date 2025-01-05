---
--- @author zsh in 2023/3/22 9:04
---

return {
    fns = {
        hasPercent = function(inst)
            return inst.components.finiteuses
                    or inst.components.fueled
                    or inst.components.armor;
        end
    },
    backpacks = {
        -- klei
        "backpack", "candybag", "icepack", "krampus_sack", "piggyback", "seedpouch", "spicepack",
    },
    amulets = {
        -- klei
        "amulet", "blueamulet", "purpleamulet", "orangeamulet", "greenamulet", "yellowamulet",
        -- 伊蕾雅
        "brooch1", "brooch2", "brooch3", "brooch4", "brooch5", "brooch6",
        "brooch7", "brooch8", "brooch9", "moon_brooch", "star_brooch",
        -- 小穹
        "sora2amulet", "sorabowknot",
        -- 经济学
        "luckamulet",
        -- 千年狐
        "wharang_amulet",
        -- 富贵险中求
        "ndnr_opalpreciousamulet",
        -- 光棱剑
        "terraprisma",
        -- 艾丽娅
        "aria_seaamulet",
        -- 小狐狸
        "kemomimi_new_xianglian", "kemomimi_bell", "kemomimi_utr_xl",
        -- 托托莉
        "philosopherstone",
        -- 和平鸽
        "ov_amulet1", "ov_amulet2", "ov_bag2",
        -- 永不妥协
        "klaus_amulet", "ancient_amulet_red_demoneye", "oculet", "ancient_amulet_red",
        -- 泰拉物品
        "jinshudaikou", "zaishengshouhuan", "ruchongweijin"
    },
    -- 包括护甲和衣服！
    armors = {
        -- klei
        "armor_bramble", "armordragonfly", "armorgrass", "armormarble", "armorruins", "armor_sanity", "armorskeleton", "armorwood",
        -- 能力勋章
        "armor_medal_obsidian", "armor_blue_crystal",
        -- 神话书说
        "golden_armor_mk", "yangjian_armor", "nz_damask",
        "armorsiving", "myth_iron_battlegear",
        -- 璇儿
        "xe_bag",
        -- 玉子yuki
        "icearmor",
        -- 乃木園子
        "yuanzi_armor_lv1", "yuanzi_armor_lv2",
        -- 伊蕾娜
        "monvfu", "red_fairyskirt", "bule_fairyskirt",
        -- 小穹
        "sora2armor", "soraclothes",
        -- 艾露莎
        "purgatory_armor",
        -- 千年狐
        "wharang_amulet_sack",
        -- 富贵险中求
        "ndnr_armorobsidian",
        -- 战舰少女
        "changchunjz",
        "veneto_jz",
        "veneto_jzyf",
        "fubuki_jz",
        -- 希儿
        "uniform_firemoths",
        -- 战舰少女补给包
        "lijie_jz",
        "jianzhuang",
        "fbk_jz",
        "lex_jz",
        "yukikaze_jz",
        -- kahiro学院袍
        "kahiro_dress",
        "bf_nightmarearmor",
        "bf_rosearmor",
        -- 艾丽娅·克莉丝塔露（RE）
        "aria_armor_red",
        "aria_armor_blue",
        "aria_armor_green",
        "aria_armor_purple",
        -- 海难
        "armorlimestone",
        "armorcactus",
        "armorobsidian",
        "armorseashell",
        -- 更多武器
        "suozi", "bingxin", "zhenfen",
        "huomu", "landun", "riyan", "kj", "banjia",
        -- 小狐狸
        "kemomiminewyifu",
        -- 熔炉
        "featheredtunic",
        "forge_woodarmor",
        "jaggedarmor",
        "silkenarmor",
        "splintmail",
        "steadfastarmor",
        "armor_hpextraheavy",
        "armor_hpdamager",
        "armor_hprecharger",
        "armor_hppetmastery",
        "reedtunic",
        -- 和平鸽
        "ov_armor", --和平鸽
        -- 永不妥协
        "armor_glassmail",
        "feather_frock_fancy",
        "feather_frock",
        -- 泰拉物品
        "xianrenzhangjia",
        "nanguahujia",
        "jinjia",
        -- 希儿
        "seele_twinsdress",
        -- [More Armor](https://steamcommunity.com/sharedfiles/filedetails/?id=1153998909)
        "armor_bone", -- Bone Suit
        "armor_stone", -- Stone Suit
    }
}