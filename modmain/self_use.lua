---
--- @author zsh in 2023/2/8 9:48
---


--if TUNING.MONE_TUNING.RECIPE_TABS_KEY_SELF_USE_HOT_UPDATE ~= false then
--    local RecipeTabs = {};
--
--    local key_self_use = "more_items_self_use";
--    RecipeTabs[key_self_use] = {
--        filter_def = {
--            name = "MONE_MORE_ITEMS_SELF_USE",
--            atlas = "images/inventoryimages.xml",
--            image = "yellowamulet.tex"
--        },
--        index = nil
--    }
--    STRINGS.UI.CRAFTING_FILTERS[RecipeTabs[key_self_use].filter_def.name] = "其他物品栏"
--    AddRecipeFilter(RecipeTabs[key_self_use].filter_def, RecipeTabs[key_self_use].index)
--end

-----------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------

local user_right = env.GetModConfigData("user_right");
local self_use_switch = env.GetModConfigData("self_use_switch");

local function selfUse()
    if not self_use_switch then
        return false;
    end
    if user_right or not string.find(modname, "workshop%-") then
        return true;
    end
    return false;
end

if not selfUse() then
    return ;
end

-----------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------

if env.GetModConfigData("granary") then
    table.insert(env.PrefabFiles, "mie/self_use/granary"); -- 粮仓
end

-----------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------
local function poop_flingomatic()
    if not env.GetModConfigData("mie_poop_flingomatic") then
        return ;
    end
    --AddAssets(env,{
    --
    --})

    -- 2023-08-01：不排除这里有问题，但是 99.5% 无关
    --AddPrefabFiles(env, {
    --    "mie/self_use/poop_flingomatic/poop_flingomatic",
    --    "mie/self_use/poop_flingomatic/fertilizer_projectile"
    --})
    table.insert(env.PrefabFiles, "mie/self_use/poop_flingomatic/poop_flingomatic");
    table.insert(env.PrefabFiles, "mie/self_use/poop_flingomatic/fertilizer_projectile");

    local fertilizer_list = {
        ["fertilizer"] = true,
        ["glommerfuel"] = true,
        ["rottenegg"] = true,
        ["spoiled_food"] = true,
        ["guano"] = true,
        ["poop"] = true,
        ["compostwrap"] = true,
    }
    for k, v in pairs(fertilizer_list) do
        AddPrefabPostInit(k, function(inst)
            inst:AddTag("mie_poop_flingomatic_fertilizer")
        end)
    end

    env.AddMinimapAtlas("images/modules/poop_flingomatic/minimap/poop_flingomatic.xml");

    local containers = require("containers");
    local params = containers.params;

    params.mie_poop_flingomatic = {
        widget = {
            slotpos = {},
            animbank = "ui_chest_3x3",
            animbuild = "ui_chest_3x3",
            pos = Vector3(0, 200, 0),
            side_align_tip = 160,
        },
        type = "chest",
        itemtestfn = function(container, item, slot)
            return item:HasTag("mie_poop_flingomatic_fertilizer")
        end
    }

    for y = 2, 0, -1 do
        for x = 0, 2 do
            table.insert(params.mie_poop_flingomatic.widget.slotpos, Vector3(80 * x - 80 * 2 + 80, 80 * y - 80 * 2 + 80, 0))
        end
    end

    for k, v in pairs(params) do
        containers.MAXITEMSLOTS = math.max(containers.MAXITEMSLOTS, v.widget.slotpos ~= nil and #v.widget.slotpos or 0)
    end
end
poop_flingomatic();
-----------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------

local myth_on = env.GetModConfigData("mie_yjp");

-- 相关物品导入
env.modimport("modmain/self_use_import.lua");

-- 相关配置、数据等导入
if myth_on then
    env.modimport("modmain/self_use_myth_on.lua");
end

-----------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------

-- 配方导入
env.modimport("modmain/self_use_recipes.lua");

