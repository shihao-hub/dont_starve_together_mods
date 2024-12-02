---
--- @author zsh in 2023/2/5 14:23
---

GLOBAL.setmetatable(env, { __index = function(_, k)
    return GLOBAL.rawget(GLOBAL, k);
end });

if IsRail() then
    error("Ban WeGame");
end

if not TUNING.MORE_ITEMS_ON then
    print("更多物品未开启，更多物品扩展包失效。");
    return ;
end


-- 导入更多物品模组中的模组全局变量
-- 2023-07-03：卧槽，这是个大坑！！！
-- 我在 ShiHao 塞了更多物品的 ShiHao.env = env。。。所以导致崩溃发生了...
local ShiHao = rawget(GLOBAL, "ShiHao");
if ShiHao then
    for k, v in pairs(ShiHao) do
        if k ~= "GLOBAL" then
            env[k] = v;
        end
    end
end

local API = require("chang_mone.dsts.API");

TUNING.MORE_ITEMS_EXPANSION_ON = true;

--TUNING.MIE_TUNING.MOD_CONFIG_DATA.rewrite_storage_bag_45_slots
TUNING.MIE_TUNING = {
    MORE_ITEMS = {
        config_data = TUNING.MONE_TUNING.GET_MOD_CONFIG_DATA;
        BALANCE = TUNING.MONE_TUNING.GET_MOD_CONFIG_DATA.BALANCE;
    },
    MOD_CONFIG_DATA = {
        show_prefab_name = env.GetModConfigData("show_prefab_name");

        --chests_boxs_compatibility = env.GetModConfigData("chests_boxs_compatibility");
        --chests_boxs_capacity = env.GetModConfigData("chests_boxs_capacity");
        --mone_wardrobe_recovery_durability = env.GetModConfigData("mone_wardrobe_recovery_durability");
        --mone_walking_stick_illusion = env.GetModConfigData("mone_walking_stick_illusion");
        --kill_dummytarget = env.GetModConfigData("kill_dummytarget");
        bundle_irreplaceable = env.GetModConfigData("bundle_irreplaceable");
        --mone_backpack_update = env.GetModConfigData("mone_backpack_update"); ---@deprecated
        --rewrite_storage_bag = env.GetModConfigData("rewrite_storage_bag");
        --rewrite_arborist = env.GetModConfigData("rewrite_arborist");
        --rewrite_storage_bag_45_slots = env.GetModConfigData("rewrite_storage_bag_45_slots");
        --storage_bag_chest_open_simultaneously = env.GetModConfigData("storage_bag_chest_open_simultaneously");
        --log_charcoal = env.GetModConfigData("log_charcoal");
        --candybag_itemtestfn = env.GetModConfigData("candybag_itemtestfn");

        meatrack_hermit_beebox_hermit = env.GetModConfigData("meatrack_hermit_beebox_hermit");

        relic_2 = env.GetModConfigData("relic_2");
        dummytarget = env.GetModConfigData("dummytarget");
        waterpump = env.GetModConfigData("waterpump");
        sand_pit = env.GetModConfigData("sand_pit");
        icemaker = env.GetModConfigData("icemaker");
        bundle = env.GetModConfigData("bundle");
        bushhat = env.GetModConfigData("bushhat");
        mie_book_silviculture = env.GetModConfigData("mie_book_silviculture");
        mie_book_horticulture = env.GetModConfigData("mie_book_horticulture");
        fishingnet = env.GetModConfigData("fishingnet");
        mie_obsidianfirepit = env.GetModConfigData("mie_obsidianfirepit");
        mie_bear_skin_cabinet = env.GetModConfigData("mie_bear_skin_cabinet");
        mie_watersource = env.GetModConfigData("mie_watersource");
        mie_wooden_drawer = env.GetModConfigData("mie_wooden_drawer");
        tophat = env.GetModConfigData("tophat");
        walterhat = env.GetModConfigData("walterhat"); -- 有贴图问题，不行
        mie_fish_box = env.GetModConfigData("mie_fish_box");

        mie_fish_box_animstate = env.GetModConfigData("mie_fish_box_animstate");

        mie_meatballs = env.GetModConfigData("mie_meatballs");
        mie_bonestew = env.GetModConfigData("mie_bonestew");
        mie_leafymeatsouffle = env.GetModConfigData("mie_leafymeatsouffle");
        mie_perogies = env.GetModConfigData("mie_perogies");
        mie_beefalofeed = env.GetModConfigData("mie_beefalofeed");
        mie_icecream = env.GetModConfigData("mie_icecream");
        mie_lobsterdinner = env.GetModConfigData("mie_lobsterdinner");
        mie_dragonpie = env.GetModConfigData("mie_dragonpie");

        klei_items_switch = env.GetModConfigData("klei_items_switch");

        fast_farmplot = env.GetModConfigData("fast_farmplot");

        armor_bramble = env.GetModConfigData("armor_bramble");
        trap_bramble = env.GetModConfigData("trap_bramble");

        featherpencil = env.GetModConfigData("featherpencil");

        lureplantbulb = env.GetModConfigData("lureplantbulb");

        giftwrap = env.GetModConfigData("giftwrap");
        portabletent_item = env.GetModConfigData("portabletent_item");

        ponds = env.GetModConfigData("ponds");
        moonbase = env.GetModConfigData("moonbase");
        pigtorch = env.GetModConfigData("pigtorch");
        catcoonden = env.GetModConfigData("catcoonden");
        tallbirdnest = env.GetModConfigData("tallbirdnest");
        slurtlehole = env.GetModConfigData("slurtlehole");
        beebox_hermit = env.GetModConfigData("beebox_hermit");
        meatrack_hermit = env.GetModConfigData("meatrack_hermit");
    }
};

env.PrefabFiles = {
    "mie/game/placers",

    "mie/game/hats",
    "mie/game/simplebooks",
    "mie/game/fxs",

    "mie/mine/foods", -- 绝对吃不完系列
}

env.Assets = {
    Asset("ANIM", "anim/my_ui_cookpot_1x1.zip"),
    Asset("ANIM", "anim/ui_largechest_5x5.zip"),
    Asset("ANIM", "anim/ui_chest_5x12.zip"),

    Asset("IMAGE", "images/minimapimages/icons.tex"),
    Asset("ATLAS", "images/minimapimages/icons.xml"),
}

require("languages.mie.loc");
--require("hodgepodge.mie.containers_ui");
env.modimport("scripts/hodgepodge/mie/containers_ui.lua");
env.modimport("scripts/hodgepodge/mie/self_use/containers_ui.lua");
require("mie.hot_update");

env.modimport("modmain/compatibility.lua");

env.modimport("modmain/reskin.lua");
env.modimport("modmain/minimap.lua");
env.modimport("modmain/actions.lua");
env.modimport("modmain/recipes.lua");

env.modimport("modmain/recipes_cover.lua");
env.modimport("modmain/original_items.lua");
env.modimport("modmain/self_use.lua");

env.modimport("modmain/PostInit/prefabs.lua");
env.modimport("modmain/PostInit/simplebooks.lua");
env.modimport("modmain/PostInit/foods.lua"); -- 绝对吃不完系列

local config_data = TUNING.MIE_TUNING.MOD_CONFIG_DATA;

if config_data.relic_2 then
    table.insert(env.PrefabFiles, "mie/mine/relic_2");
end
if config_data.dummytarget then
    table.insert(env.PrefabFiles, "mie/game/dummytarget");
end
if config_data.waterpump then
    table.insert(env.PrefabFiles, "mie/game/waterpump");
    env.modimport("modmain/PostInit/waterpump.lua");
end
if config_data.sand_pit then
    table.insert(env.PrefabFiles, "mie/game/sand_pit");
end
if config_data.icemaker then
    table.insert(env.PrefabFiles, "mie/mine/icemaker");
end
if config_data.bundle then
    table.insert(env.PrefabFiles, "mie/game/bundle");
end
if config_data.mie_fish_box then
    table.insert(env.PrefabFiles, "mie/game/fish_box");
    env.modimport("modmain/PostInit/fish_box.lua");
end
if config_data.bushhat then
    env.modimport("modmain/PostInit/bushhat.lua");
end
if config_data.tophat then
    env.modimport("modmain/PostInit/tophat.lua");
end
--if config_data.walterhat then
--    env.modimport("modmain/PostInit/walterhat.lua");
--end
--if config_data.rewrite_storage_bag and TUNING.MONE_TUNING.GET_MOD_CONFIG_DATA.storage_bag then
--    table.insert(env.PrefabFiles, "mie/rewrite/storage_bag.lua");
--end
--if config_data.rewrite_arborist and TUNING.MONE_TUNING.GET_MOD_CONFIG_DATA.arborist then
--    table.insert(env.PrefabFiles, "mie/rewrite/arborist.lua");
--end
if config_data.fishingnet then
    table.insert(env.PrefabFiles, "mie/mine/fishnet");
end
if config_data.mie_obsidianfirepit then
    table.insert(env.PrefabFiles, "mie/mine/obsidianfirepit");
    table.insert(env.PrefabFiles, "mie/mine/obsidianfirefire");
end
if config_data.mie_bear_skin_cabinet then
    table.insert(env.PrefabFiles, "mie/mine/bear_skin_cabinet");
    env.modimport("modmain/PostInit/bear_skin_cabinet.lua");
end
if config_data.mie_watersource then
    table.insert(env.PrefabFiles, "mie/mine/watersource");
end
if config_data.mie_wooden_drawer then
    table.insert(env.PrefabFiles, "mie/mine/wooden_drawer");
end

-- 先算了，不知道具体应该咋写。稍微有点复杂，不想写。
--if API.isDebug(env) then
--    table.insert(env.PrefabFiles, "mie/game/beef_bell");
--    env.modimport("modmain/PostInit/beef_bell.lua");
--end

if TUNING.MIE_TUNING.MOD_CONFIG_DATA.show_prefab_name then
    env.AddClassPostConstruct("widgets/hoverer", function(self)
        local old_SetString = self.text.SetString
        self.text.SetString = function(text, str)
            local target = TheInput:GetHUDEntityUnderMouse() -- NOTE
            if target ~= nil then
                target = (target.widget ~= nil and target.widget.parent ~= nil) and target.widget.parent.item
            else
                target = TheInput:GetWorldEntityUnderMouse()
            end
            if target and target.entity ~= nil then
                if target.prefab ~= nil then
                    str = str .. "\n" .. "代码: " .. target.prefab
                end
            end
            return old_SetString(text, str)
        end
    end)
end

-- 热更新！
--if not TUNING.MONE_TUNING.FIND_BEST_CONTAINER_ON then
--    if TUNING.MONE_TUNING.GET_MOD_CONFIG_DATA.storage_bag then
--        env.modimport("modmain/AUXmods/find_best_container.lua");
--    end
--end

--if TUNING.MONE_TUNING.GET_MOD_CONFIG_DATA.storage_bag then
--    if TUNING.MIE_TUNING.MOD_CONFIG_DATA.rewrite_storage_bag_45_slots then
--        env.AddPrefabPostInit("mone_storage_bag", function(inst)
--            if not TheWorld.ismastersim then
--                return inst;
--            end
--            local containers = require "containers";
--            local params = containers.params;
--            if params.mone_storage_bag then
--                params.mone_storage_bag.widget.pos = Vector3(0, 500, 0);
--                params.mone_storage_bag.type = "rewrite_storage_bag_45_slots";
--            end
--        end)
--    end
--end
