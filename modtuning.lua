---
--- @author zsh in 2023/3/24 13:31
---

-- modmain.lua 和 modworldgenmain.lua 的 env 是同一个！




local API = require("chang_mone.dsts.API");

TUNING.MORE_ITEMS_ON = true;

--TUNING.MONE_TUNING.GET_MOD_CONFIG_DATA.mods_nlxz_medal_box
TUNING.MONE_TUNING = {
    ENV = env;
    DebugCommands = {
        PrintSeq = function(seq)
            for i, v in ipairs(seq) do
                print("", "[" .. tostring(i) .. "]: " .. tostring(v));
            end
        end
    },
    MY_MODULES = {
        MOBILE_ATTACK = {
            ENV = setmetatable({}, { __index = env })
        },
    },
    MI_MODULES = {
        HAMLET_GROUND = {
            ENV = setmetatable({}, { __index = env })
        },
        WORMHOLE_MARKS = {
            ENV = setmetatable({}, { __index = env })
        },
        WATHGRITHR_EXCLUSIVE_EQUIPMENTS = {
            ENV = setmetatable({}, { __index = env })
        }
    },
    AUTO_SORTER = {
        whetherIsFull = env.GetModConfigData("auto_sorter_mode");
        nFullInterval = env.GetModConfigData("auto_sorter_is_full");
        auto_sorter_light = env.GetModConfigData("auto_sorter_light");
        auto_sorter_no_fuel = env.GetModConfigData("auto_sorter_no_fuel");
        auto_sorter_notags_extra = env.GetModConfigData("auto_sorter_notags_extra");
    };
    GET_MOD_CONFIG_DATA = {
        -- 2023-09-10
        mone_seasack_capacity_increase = env.GetModConfigData("mone_seasack_capacity_increase");
        --[[
            这个选项会导致已经制作出来的物品出问题，只有重新制作才会正常？开启之后再关掉就会这样！
            嗯，找到原因了，换了皮肤就会这样，问题不大。
        ]]
        mone_seasack_new_anim = false, -- 2024-10-30：该功能存在 bug，直接取消掉
        mone_boomerang_damage_multiple = env.GetModConfigData("mone_boomerang_damage_multiple");
        multiple_drop = env.GetModConfigData("multiple_drop");
        multiple_drop_probability = env.GetModConfigData("multiple_drop_probability");


        --BALANCE = env.GetModConfigData("balance");
        BALANCE = true; -- 该选项必定生效

        pheromone_stone_balance = env.GetModConfigData("pheromone_stone_balance");

        -- 辅助功能
        arrange_container = env.GetModConfigData("arrange_container");

        container_removable = env.GetModConfigData("container_removable");
        chests_arrangement = env.GetModConfigData("chests_arrangement");
        backpack_arrange_button = env.GetModConfigData("backpack_arrange_button");
        klei_chests_arrangement_button = env.GetModConfigData("klei_chests_arrangement_button");
        klei_chests_storage_button = env.GetModConfigData("klei_chests_storage_button");
        current_date = env.GetModConfigData("current_date");
        arborist_light = env.GetModConfigData("arborist_light");
        arborist_fire_extinction = env.GetModConfigData("arborist_fire_extinction");
        compatible_with_maxwell = env.GetModConfigData("compatible_with_maxwell");

        -- 模组内容设置
        all_items_one_recipetab = env.GetModConfigData("all_items_one_recipetab");

        containers_onpickupfn_cancel = env.GetModConfigData("containers_onpickupfn_cancel");
        storage_bag_auto_open = env.GetModConfigData("storage_bag_auto_open");
        tool_bag_auto_open = env.GetModConfigData("tool_bag_auto_open");
        wanda_box_auto_open = env.GetModConfigData("wanda_box_auto_open");
        containers_onpickupfn_piggybag = env.GetModConfigData("containers_onpickupfn_piggybag");

        IGICF = env.GetModConfigData("IGICF");
        IGICF_perishable_backpack = env.GetModConfigData("IGICF_perishable_backpack");
        IGICF_mone_piggyback = env.GetModConfigData("IGICF_mone_piggyback");
        IGICF_waterchest_inv = env.GetModConfigData("IGICF_waterchest_inv");

        item_go_into_waterchest_inv_or_piggyback = env.GetModConfigData("item_go_into_waterchest_inv_or_piggyback_new");
        direct_consumption = env.GetModConfigData("direct_consumption_new");

        -- 模组功能设置
        wardrobe_background = env.GetModConfigData("mone_wardrobe_background");
        mone_wardrobe_recovery_durability = env.GetModConfigData("mone_wardrobe_recovery_durability");

        mone_chests_boxs_capability = env.GetModConfigData("mone_chests_boxs_capability");
        chests_boxs_compatibility = env.GetModConfigData("chests_boxs_compatibility");

        candybag_itemtestfn = env.GetModConfigData("candybag_itemtestfn");

        mone_walking_stick_illusion = env.GetModConfigData("mone_walking_stick_illusion");

        mone_tool_bag_capacity = env.GetModConfigData("mone_tool_bag_capacity");
        mone_icepack_capacity = env.GetModConfigData("mone_icepack_capacity");
        mone_backpack_capacity = env.GetModConfigData("mone_backpack_capacity");
        mone_candybag_capacity = env.GetModConfigData("mone_candybag_capacity");
        mone_nightspace_cape_capacity = env.GetModConfigData("mone_nightspace_cape_capacity");


        mone_backpack_auto = env.GetModConfigData("mone_backpack_auto");
        cane_gointo_mone_backpack = env.GetModConfigData("cane_gointo_mone_backpack");

        mone_wanda_box_itemtestfn_extra1 = env.GetModConfigData("mone_wanda_box_itemtestfn_extra1");
        mone_wanda_box_itemtestfn_extra2 = env.GetModConfigData("mone_wanda_box_itemtestfn_extra2");
        mone_piggbag_itemtestfn = env.GetModConfigData("mone_piggbag_itemtestfn");
        --mone_city_lamp_reskin = env.GetModConfigData("mone_city_lamp_reskin");
        --mone_storage_bag_no_remove = env.GetModConfigData("mone_storage_bag_no_remove");
        greenamulet_pheromonestone = env.GetModConfigData("greenamulet_pheromonestone");
        --pheromonestone_bug_on = env.GetModConfigData("pheromonestone_bug_on");

        preserver_value = env.GetModConfigData("preserver_value");
        rewrite_storage_bag_45_slots = env.GetModConfigData("rewrite_storage_bag_45_slots");


        -- 取消某件物品及其相关内容
        madscience_lab = env.GetModConfigData("madscience_lab");

        more_equipments = env.GetModConfigData("more_equipments");
        more_equipments_debug = env.GetModConfigData("more_equipments_debug");

        never_finish_series = env.GetModConfigData("never_finish_series");

        redlantern = env.GetModConfigData("__redlantern");
        farm_plow = env.GetModConfigData("__farm_plow");
        walking_stick = env.GetModConfigData("__walking_stick");
        fishingnet = env.GetModConfigData("__fishingnet");
        spear_poison = env.GetModConfigData("__spear_poison");
        harvester_staff = env.GetModConfigData("__harvester_staff");
        halberd = env.GetModConfigData("__halberd");

        pith = env.GetModConfigData("__pith");
        gashat = env.GetModConfigData("__gashat");
        double_umbrella = env.GetModConfigData("__double_umbrella");
        brainjelly = env.GetModConfigData("__brainjelly");
        bathat = env.GetModConfigData("__bathat");

        bookstation = env.GetModConfigData("__bookstation");
        wathgrithr_box = env.GetModConfigData("__wathgrithr_box");
        wanda_box = env.GetModConfigData("__wanda_box");
        --backpack_piggyback = env.GetModConfigData("__backpack_piggyback");
        candybag = env.GetModConfigData("__candybag");
        backpack = env.GetModConfigData("__backpack");
        piggyback = env.GetModConfigData("__piggyback");
        storage_bag = env.GetModConfigData("__storage_bag");
        icepack = env.GetModConfigData("__icepack");
        tool_bag = env.GetModConfigData("__tool_bag");
        piggybag = env.GetModConfigData("__piggybag");
        seasack = env.GetModConfigData("__seasack");
        skull_chest = env.GetModConfigData("__skull_chest");
        nightspace_cape = env.GetModConfigData("__nightspace_cape");
        waterchest = env.GetModConfigData("__waterchest");
        mone_seedpouch = env.GetModConfigData("__mone_seedpouch");
        --beef_bell = env.GetModConfigData("__beef_bell");

        chiminea = env.GetModConfigData("__chiminea");
        garlic_structure = env.GetModConfigData("__garlic_structure");
        arborist = env.GetModConfigData("__arborist");
        city_lamp = env.GetModConfigData("__city_lamp");
        chests_boxs = env.GetModConfigData("__chests_boxs");
        firesuppressor = env.GetModConfigData("__firesuppressor");
        dragonflyfurnace = env.GetModConfigData("__dragonflyfurnace");
        moondial = env.GetModConfigData("__moondial");
        wardrobe = env.GetModConfigData("__wardrobe");
        orangestaff = env.GetModConfigData("__telestaff");
        boomerang = env.GetModConfigData("__boomerang");

        grass_umbrella = env.GetModConfigData("__grass_umbrella");
        winterometer = env.GetModConfigData("__winterometer");

        poisonblam = env.GetModConfigData("__poisonblam");
        waterballoon = env.GetModConfigData("__waterballoon");
        pheromonestone = env.GetModConfigData("__pheromonestone");
        pheromonestone2 = env.GetModConfigData("__pheromonestone2");

        mone_beef_wellington = env.GetModConfigData("__mone_beef_wellington");
        mone_chicken_soup = env.GetModConfigData("__mone_chicken_soup");
        mone_lifeinjector_vb = env.GetModConfigData("__mone_lifeinjector_vb");
        mone_stomach_warming_hamburger = env.GetModConfigData("__mone_stomach_warming_hamburger");
        mone_honey_ham_stick = env.GetModConfigData("__mone_honey_ham_stick");
        mone_guacamole = env.GetModConfigData("__mone_guacamole");
        glommer_poop_food = env.GetModConfigData("__glommer_poop_food");
        terraria = env.GetModConfigData("__terraria");
        armor_metalplate = env.GetModConfigData("__armor_metalplate");

        original_items_modifications_data = {};
        original_items_modifications = env.GetModConfigData("original_items_modifications");
        --beef_bell = env.GetModConfigData("beef_bell");
        batbat = env.GetModConfigData("batbat");
        nightstick = env.GetModConfigData("nightstick");
        whip = env.GetModConfigData("whip");
        wateringcan = env.GetModConfigData("wateringcan");
        premiumwateringcan = env.GetModConfigData("premiumwateringcan");
        hivehat = env.GetModConfigData("hivehat");
        --telebase = env.GetModConfigData("telebase");
        eyemaskhat = env.GetModConfigData("eyemaskhat");
        shieldofterror = env.GetModConfigData("shieldofterror");

        -- 其他辅助功能
        backpacks_light = env.GetModConfigData("backpacks_light");

        automatic_stacking = env.GetModConfigData("automatic_stacking");
        extra_equip_slots = env.GetModConfigData("extra_equip_slots");
        dont_drop_everything = env.GetModConfigData("dont_drop_everything");
        simple_global_position_system = env.GetModConfigData("simple_global_position_system");
        hawk_eye_and_night_vision = env.GetModConfigData("hawk_eye_and_night_vision");

        stackable_change_switch = env.GetModConfigData("stackable_change_switch");
        maxsize_change = env.GetModConfigData("maxsize_change");
        wortox_max_souls_change = env.GetModConfigData("wortox_max_souls_change");
        creatures_stackable = env.GetModConfigData("creatures_stackable");

        scroll_containers = env.GetModConfigData("scroll_containers");
        sc_candybag = env.GetModConfigData("sc_candybag");
        sc_seasack = env.GetModConfigData("sc_seasack");
        sc_nightspace_cape = env.GetModConfigData("sc_nightspace_cape");

        simple_garbage_collection = env.GetModConfigData("simple_garbage_collection");
        sgc_delay_take_effect = env.GetModConfigData("sgc_delay_take_effect");
        sgc_interval = env.GetModConfigData("sgc_interval");

        --sgc_blacklist = env.GetModConfigData("sgc_blacklist");
        --sgc_whitelist = env.GetModConfigData("sgc_whitelist");

        ------------------------------------------------------------------------------------------------
        --sgc_houndstooth = env.GetModConfigData("sgc_houndstooth"); -- 狗牙
        --sgc_stinger = env.GetModConfigData("sgc_stinger"); -- 蜂刺
        --sgc_guano = env.GetModConfigData("sgc_guano"); -- 鸟屎
        --sgc_poop = env.GetModConfigData("sgc_poop"); -- 便便
        --sgc_spoiled_food = env.GetModConfigData("sgc_spoiled_food"); -- 腐烂食物
        --sgc_rottenegg = env.GetModConfigData("sgc_rottenegg"); -- 腐烂鸡蛋
        --sgc_twigs = env.GetModConfigData("sgc_twigs"); -- 树枝
        --sgc_silk = env.GetModConfigData("sgc_silk"); -- 蜘蛛网
        --sgc_spidergland = env.GetModConfigData("sgc_spidergland"); -- 蜘蛛腺
        --
        --sgc_halloween_switch = env.GetModConfigData("sgc_halloween_switch"); -- 万圣节
        --sgc_halloween_ornament = env.GetModConfigData("sgc_halloween_ornament");
        --sgc_halloweencandy = env.GetModConfigData("sgc_halloweencandy");
        --
        --sgc_winter_switch = env.GetModConfigData("sgc_winter_switch"); -- 冬季盛宴
        --sgc_winter_ornament_light = env.GetModConfigData("sgc_winter_ornament_light");
        --sgc_winter_ornament_boss = env.GetModConfigData("sgc_winter_ornament_boss");
        --sgc_winter_food = env.GetModConfigData("sgc_winter_food");
        --sgc_winter_ornament = env.GetModConfigData("sgc_winter_ornament");
        ------------------------------------------------------------------------------------------------

        -- 更多辅助功能
        spawn_wormholes_worldpostinit = env.GetModConfigData("spawn_wormholes_worldpostinit");

        trap_auto_reset = env.GetModConfigData("trap_auto_reset");
        better_beefalo = env.GetModConfigData("better_beefalo");
        better_bundle = env.GetModConfigData("better_bundle");
        forced_attack_lightflier = env.GetModConfigData("forced_attack_lightflier");
        forced_attack_bound_beefalo = env.GetModConfigData("forced_attack_bound_beefalo");

        -- 人物改动
        wathgrithr_change_master_switch = env.GetModConfigData("wathgrithr_change_master_switch");
        wathgrithr_vegetarian = env.GetModConfigData("wathgrithr_vegetarian");

        wolfgang_change_master_switch = env.GetModConfigData("wolfgang_change_master_switch");
        wolfgang_mightiness = env.GetModConfigData("wolfgang_mightiness");
        wolfgang_mightiness_oneat = env.GetModConfigData("wolfgang_mightiness_oneat");

        willow_change_master_switch = env.GetModConfigData("willow_change_master_switch");
        willow_bernie = env.GetModConfigData("willow_bernie");
        willow_firestaff = env.GetModConfigData("willow_firestaff");
        willow_lighter = env.GetModConfigData("willow_lighter");
        willow_sewing_kit = env.GetModConfigData("willow_sewing_kit");
        willow_overheattemp = env.GetModConfigData("willow_overheattemp");
        willow_externaldamagemultiplier = env.GetModConfigData("willow_externaldamagemultiplier");
        willow_not_burning_loots = env.GetModConfigData("willow_not_burning_loots");

        -- 仅限于我自己使用的功能：彩虹虫洞给小王者和我自己留个入口，假如和朋友一起玩的时候好打开
        wormhole_marks = env.GetModConfigData("wormhole_marks");
        gem_crystal_cluster = env.GetModConfigData("gem_crystal_cluster");
        wathgrithr_exclusive_equipments = env.GetModConfigData("wathgrithr_exclusive_equipments");

        -- 对其他模组的一些修改
        mods_modification_switch = env.GetModConfigData("mods_modification_switch");
        mods_ms_playerspawn = env.GetModConfigData("mods_ms_playerspawn");
        -- 能力勋章
        mods_nlxz_medal_box_ms_playerspawn = env.GetModConfigData("mods_nlxz_medal_box_ms_playerspawn");
        mods_nlxz_medal_box = env.GetModConfigData("mods_nlxz_medal_box");
        -- 更多物品
        mods_more_items_containers = env.GetModConfigData("mods_more_items_containers");

        --insight_and_pheromonestone_permit = env.GetModConfigData("insight_and_pheromonestone_permit");
    };
};
