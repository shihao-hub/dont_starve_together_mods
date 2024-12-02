---
--- @author zsh in 2023/3/20 8:53
---

local hard_coded_data = {
    -- klei
    ["armor_bramble"] = { "armor_bramble", "swap_body" }; -- Bramble Husk
    ["armordragonfly"] = { "torso_dragonfly", "swap_body" }; -- Scalemail
    ["armorgrass"] = { "armor_grass", "swap_body" }; -- Grass Suit
    ["armormarble"] = { "armor_marble", "swap_body" }; -- Marble Suit
    ["armorruins"] = { "armor_ruins", "swap_body" }; -- Thulecite Suit
    ["armor_sanity"] = { "armor_sanity", "swap_body" }; -- Night Armour
    ["armorskeleton"] = { "armor_skeleton", "swap_body" }; -- Bone Armor
    ["armorwood"] = { "armor_wood", "swap_body" }; -- Log Suit
    ["armorslurper"] = { "armor_slurper", "swap_body" }; -- Belt of Hunger
    ["beargervest"] = { "torso_bearger", "swap_body" }; -- Hibearnation Vest
    ["hawaiianshirt"] = { "torso_hawaiian", "swap_body" }; -- Floral Shirt
    ["raincoat"] = { "torso_rain", "swap_body" }; -- Rain Coat
    ["reflectivevest"] = { "torso_reflective", "swap_body" }; -- Summer Frest
    ["sweatervest"] = { "armor_sweatervest", "swap_body" }; -- Dapper Vest
    ["trunkvest_summer"] = { "armor_trunkvest_summer", "swap_body" }; -- Breezy Vest
    ["trunkvest_winter"] = { "armor_trunkvest_winter", "swap_body" }; -- Puffy Vest
    ["carnival_vest_a"] = { "carnival_vest_a", "swap_body" }; -- Chirpy Scarf
    ["carnival_vest_b"] = { "carnival_vest_b", "swap_body" }; -- Chirpy Cloak
    ["carnival_vest_c"] = { "carnival_vest_c", "swap_body" }; -- Chirpy Capelet

    -- klei Heavy
    ["cavein_boulder"]       = {"swap_cavein_boulder", "swap_body"}; -- Boulder -- TODO: variations.
    ["glassspike_short"]     = {"swap_glass_spike", "swap_body_short"}; -- Glass Spike - Short
    ["glassspike_med"]       = {"swap_glass_spike", "swap_body_med"};   -- Glass Spike - Medium
    ["glassspike_tall"]      = {"swap_glass_spike", "swap_body_tall"};  -- Glass Spike - Tall
    ["glassblock"]           = {"swap_glass_block", "swap_body"};       -- Glass Castle
    ["moon_altar_idol"]      = {"swap_altar_idolpiece",  "swap_body"}; -- Celestial Altar Idol
    ["moon_altar_glass"]     = {"swap_altar_glasspiece", "swap_body"}; -- Celestial Altar Base
    ["moon_altar_seed"]      = {"swap_altar_seedpiece",  "swap_body"}; -- Celestial Altar Orb
    ["moon_altar_crown"]     = {"swap_altar_crownpiece", "swap_body"}; -- Inactive Celestial Tribute
    ["moon_altar_ward"]      = {"swap_altar_wardpiece",  "swap_body"}; -- Celestial Sanctum Ward
    ["moon_altar_icon"]      = {"swap_altar_iconpiece",  "swap_body"}; -- Celestial Sanctum Icon
    ["sculpture_knighthead"] = {"swap_sculpture_knighthead", "swap_body"}; -- Suspicious Marble - Knight Head
    ["sculpture_bishophead"] = {"swap_sculpture_bishophead", "swap_body"}; -- Suspicious Marble - Bishop Head
    ["sculpture_rooknose"]   = {"swap_sculpture_rooknose",   "swap_body"}; -- Suspicious Marble - Rook Nose
    ["shell_cluster"]        = {"singingshell_cluster", "swap_body"}; -- Shell Cluster
    ["sunkenchest"]          = {"swap_sunken_treasurechest", "swap_body"}; -- Sunken Chest
    ["oceantreenut"]         = {"oceantreenut", "swap_body"}, -- Knobbly Tree Nut
    -- Heavy [Moving Box](https://steamcommunity.com/sharedfiles/filedetails/?id=1079538195)
    ["moving_box_full"]      = {"swap_box_full", "swap_body"}; -- Moving Box (Full)

    -- 棱镜
    ["sachet"] = { "sachet", "swap_body" };

    -- 能力勋章
    ["armor_medal_obsidian"] = { "armor_medal_obsidian", "swap_body" };
    ["armor_blue_crystal"] = { "armor_blue_crystal", "swap_body" };
    ["down_filled_coat"] = { "down_filled_coat", "swap_body" };

    -- 神话书说
    ["golden_armor_mk"] = { "golden_armor_mk", "swap_body" };
    ["yangjian_armor"] = { "yangjian_armor", "swap_body" };
    ["armorsiving"] = { "armorsiving", "swap_body" };
    ["nz_damask"] = { "nz_damask", "swap_body" };
    ["myth_iron_battlegear"] = { "myth_iron_battlegear", "swap_body" };
    ["cassock"] = { "cassock", "swap_body" };
    ["kam_lan_cassock"] = { "kam_lan_cassock", "swap_body" };
    ["madameweb_armor"] = { "madameweb_armor", "swap_body" };

    -- 璇儿
    ["xe_bag"] = { "xe_bag", "swap_body" };

    -- 玉子yuki
    ["icearmor"] = { "icearmor", "swap_body" };

    -- 乃木園子
    ["yuanzi_armor_lv1"] = { "yuanzi_armor_lv1", "swap_body" };
    ["yuanzi_armor_lv2"] = { "yuanzi_armor_lv2", "swap_body" };

    -- 伊蕾娜
    ["monvfu"] = { "monvfu", "swap_body" };
    ["bule_fairyskirt"] = { "bule_fairyskirt", "swap_body" };
    ["red_fairyskirt"] = { "red_fairyskirt", "swap_body" };

    -- 小穹
    ["sora2armor"] = { "sora2armor", "swap_body" };
    ["soraclothes"] = { "soraclothes", "swap_body" };

    -- 艾露莎
    ["purgatory_armor"] = { "purgatory_armor", "swap_body" };

    -- 千年狐
    ["wharang_amulet_sack"] = { "wharang_amulet_sack", "swap_body" };

    -- 富贵险中求
    ["ndnr_armorobsidian"] = { "ndnr_armorobsidian", "swap_body" };

    -- 战舰少女
    ["changchunjz"] = { "changchunjz", "swap_body" };
    ["veneto_jz"] = { "veneto_jz", "swap_body" };
    ["veneto_jzyf"] = { "veneto_jzyf", "swap_body" };
    ["fubuki_jz"] = { "fubuki_jz", "swap_body" };
    ["veneto_yifu"] = { "veneto_yifu", "swap_body" };

    -- 战舰少女补给包
    ["lijie_jz"] = { "lijie_jz", "swap_body" };
    ["jianzhuang"] = { "jianzhuang", "swap_body" };
    ["fbk_jz"] = { "fbk_jz", "swap_body" };
    ["lex_jz"] = { "lex_jz", "swap_body" };
    ["yukikaze_jz"] = { "yukikaze_jz", "swap_body" };
    ["zhifu"] = { "zhifu", "swap_body" };

    -- 希儿
    ["uniform_firemoths"] = { "uniform_firemoths", "swap_body" };
    ["dress_sea"] = { "dress_sea", "swap_body" };
    ["seele_swimsuit"] = { "seele_swimsuit ", "swap_body" };

    -- 和平鸽
    ["ov_armor"] = { "ov_armor", "swap_body" };

    -- [More Armor](https://steamcommunity.com/sharedfiles/filedetails/?id=1153998909)
    ["armor_bone"] = { "armor_bone", "armor_my_folder" };
    ["armor_stone"] = { "armor_stone", "armor_my_folder" };

    -- 其他
    ["kahiro_dress"] = { "kahiro_dress", "swap_body" }; -- kahiro 学院袍
    ["bf_nightmarearmor"] = { "bf_nightmarearmor", "swap_body" }; -- 恶魔花护甲
    ["bf_rosearmor"] = { "bf_rosearmor", "swap_body" }; -- 玫瑰护甲
    ["balloonvest"] = { "balloonvest", "swap_body" }; -- 救生衣
}


-- TEST
hard_coded_data = {};

-- BODY??? BODY 不必修改吧。主要是找出哪些是 BACK or NECK，其余都是 BODY 的吧？
local function isBody(inst)
    --if not (inst.components.equippable
    --        and inst.components.equippable.equipslot == EQUIPSLOTS.BODY)
    --then
    --    return false;
    --end
    --for k, v in pairs(hard_coded_data) do
    --    if inst.prefab == k then
    --        return true;
    --    end
    --end
    return inst.components.equippable and inst.components.equippable.equipslot == EQUIPSLOTS.BODY;
end

return {
    hard_coded_data = hard_coded_data;
    isBody = isBody;
}