---
--- @author zsh in 2023/5/15 15:33
---

local config_data = TUNING.MONE_TUNING.GET_MOD_CONFIG_DATA;

if not config_data.never_finish_series then
    return ;
end

TUNING.NEVER_FINISH_SERIES_ENABLED = true;

TUNING.NEVER_FINISH_SERIES = {};

local FOOD_PREFIX = "mi_nfs_";
local FOOD_TAG = FOOD_PREFIX .. "food_tag";

local _preparedfoods = require("preparedfoods");
local _preparedfoods_warly = require("preparedfoods_warly");
--local _spicedfoods = require("spicedfoods");

local preparedfoods = {};
local preparedfoods_warly = {};
--local spicedfoods = {};

local function eliminate()
    for food_name, data in pairs(_preparedfoods) do
        if not string.find(food_name, "beefalotreat") then
            preparedfoods[food_name] = data;
        end
    end

    preparedfoods_warly = _preparedfoods_warly;
    --spicedfoods = _spicedfoods;
end
eliminate();

local function recipes()
    -- 添加新的制作栏
    local RecipeTabs = {};
    local key1 = "more_items_nfs";
    RecipeTabs[key1] = {
        filter_def = {
            name = "MONE_MORE_ITEMS_NFS",
            atlas = "images/inventoryimages2.xml",
            image = "voltgoatjelly.tex"
        },
        index = nil
    }
    STRINGS.UI.CRAFTING_FILTERS[RecipeTabs[key1].filter_def.name] = "更多物品·绝对吃不完系列"
    AddRecipeFilter(RecipeTabs[key1].filter_def, RecipeTabs[key1].index)

    -- 添加配方
    local function getRecipe(food_name, isspicedfood, spicename)
        local number = 150;
        local recipe = setmetatable({
            name = FOOD_PREFIX .. food_name;
            ingredients = { Ingredient(food_name, number) };
            tech = TECH.SCIENCE_TWO;
            config = {
                atlas = GetInventoryItemAtlas(food_name .. ".tex");
                image = food_name .. ".tex";
            };
            filters = { "MONE_MORE_ITEMS_NFS" }
        }, { __call = function(t, ...)
            return t.name, t.ingredients, t.tech, t.config, t.filters;
        end })

        --if isspicedfood and spicename then
        --    recipe.config.atlas = GetInventoryItemAtlas(spicename .. "_over" .. ".tex");
        --    recipe.config.image = spicename .. "_over" .. ".tex";
        --end

        return recipe;
    end

    local function addCommonStrings(food_name, extra_fn, isspicedfood, spicename)
        if extra_fn then
            return extra_fn();
        end

        --if isspicedfood and spicename then
        --    local function DisplayNameFn(inst)
        --        if oneOfNull(2, STRINGS.NAMES[string.lower(spicename) .. "_FOOD"], STRINGS.NAMES[string.upper(food_name)]) then
        --            return "未知";
        --        end
        --        return subfmt(STRINGS.NAMES[string.lower(spicename) .. "_FOOD"], { food = "绝对吃不完的" .. STRINGS.NAMES[string.upper(food_name)] })
        --    end
        --
        --    local game_real_name = DisplayNameFn();
        --    local upper_name = string.upper(FOOD_PREFIX .. food_name);
        --    STRINGS.NAMES[upper_name] = "绝对吃不完的" .. game_real_name;
        --    STRINGS.RECIPE_DESC[upper_name] = "绝对吃不完的" .. game_real_name;
        --    STRINGS.CHARACTERS.GENERIC.DESCRIBE[upper_name] = "绝对吃不完的" .. game_real_name;
        --    return ;
        --end

        local game_real_name = STRINGS.NAMES[string.upper(food_name)];
        local upper_name = string.upper(FOOD_PREFIX .. food_name);
        STRINGS.NAMES[upper_name] = "绝对吃不完的" .. game_real_name;
        STRINGS.RECIPE_DESC[upper_name] = "绝对吃不完的" .. game_real_name;
        STRINGS.CHARACTERS.GENERIC.DESCRIBE[upper_name] = "绝对吃不完的" .. game_real_name;
    end

    for food_name, _ in pairs(preparedfoods) do
        env.AddRecipe2(getRecipe(food_name)());
        addCommonStrings(food_name);
    end
    for food_name, _ in pairs(preparedfoods_warly) do
        env.AddRecipe2(getRecipe(food_name)());
        addCommonStrings(food_name);
    end
    --for food_name, data in pairs(spicedfoods) do
    --    local spicename = data.spice ~= nil and string.lower(data.spice) or nil
    --    env.AddRecipe2(getRecipe(food_name, true, spicename)());
    --    addCommonStrings(food_name, nil, true, spicename);
    --end
end
recipes();

local function postinit()
    env.AddPrefabPostInit("greenstaff", function(inst)
        if not TheWorld.ismastersim then
            return inst;
        end
        if inst.components.spellcaster then
            local old_spell = inst.components.spellcaster.spell;
            inst.components.spellcaster.spell = function(inst, target, pos, doer, ...)
                if target:HasTag(FOOD_TAG) then
                    if doer.components.talker then
                        doer.components.talker:Say("我根本拆不掉它！");
                    end
                    return ;
                end
                if old_spell then
                    old_spell(inst, target, pos, doer, ...);
                end
            end
        end
    end)

    HookComponent("eater", function(self)
        local old_Eat = self.Eat;
        function self:Eat(food, ...)
            local old_Remove;
            if isValid(food) and food:HasTag(FOOD_TAG) then
                old_Remove = food.Remove;
                food.Remove = DoNothing;
            end

            local success;
            if old_Eat then
                success = old_Eat(self, food, ...);
            end

            if old_Remove then
                if isValid(food) then
                    food.Remove = old_Remove;
                end
            end

            return success;
        end
    end)
end
postinit();

-- 提供给 scrips/prefabs/... 使用的函数，用于注册预制物
local function MakeFoods()
    local prefabs = {
        "spoiled_food",
    }

    local function MakePreparedFood(data)
        local foodassets = {
            Asset("ANIM", "anim/cook_pot_food.zip"),
            Asset("INV_IMAGE", data.name),
        }

        if data.overridebuild then
            table.insert(foodassets, Asset("ANIM", "anim/" .. data.overridebuild .. ".zip"))
        end

        --local spicename = data.spice ~= nil and string.lower(data.spice) or nil
        --if spicename ~= nil then
        --    table.insert(foodassets, Asset("ANIM", "anim/spices.zip"))
        --    table.insert(foodassets, Asset("ANIM", "anim/plate_food.zip"))
        --    table.insert(foodassets, Asset("INV_IMAGE", spicename .. "_over"))
        --end

        local foodprefabs = prefabs
        if data.prefabs ~= nil then
            foodprefabs = shallowcopy(prefabs)
            for i, v in ipairs(data.prefabs) do
                if not table.contains(foodprefabs, v) then
                    table.insert(foodprefabs, v)
                end
            end
        end

        --local function DisplayNameFn(inst)
        --    if oneOfNull(2, STRINGS.NAMES[data.spice .. "_FOOD"], STRINGS.NAMES[string.upper(data.basename)]) then
        --        return "未知";
        --    end
        --    return subfmt(STRINGS.NAMES[data.spice .. "_FOOD"], { food = "绝对吃不完的" .. STRINGS.NAMES[string.upper(data.basename)] })
        --end

        local function DisplayNameFn(inst)
            return subfmt("绝对吃不完的" .. STRINGS.NAMES[string.upper(data.basename)])
        end

        local function fn()
            local inst = CreateEntity()

            inst.entity:AddTransform()
            inst.entity:AddAnimState()
            inst.entity:AddNetwork()

            MakeInventoryPhysics(inst)

            local food_symbol_build = nil

            --if spicename ~= nil then
            --    inst.AnimState:SetBuild("plate_food")
            --    inst.AnimState:SetBank("plate_food")
            --    inst.AnimState:OverrideSymbol("swap_garnish", "spices", spicename)
            --
            --    inst:AddTag("spicedfood")
            --
            --    inst.inv_image_bg = { image = (data.basename or data.name) .. ".tex" }
            --    inst.inv_image_bg.atlas = GetInventoryItemAtlas(inst.inv_image_bg.image)
            --
            --    food_symbol_build = data.overridebuild or "cook_pot_food"
            --else
            --    inst.AnimState:SetBuild(data.overridebuild or "cook_pot_food")
            --    inst.AnimState:SetBank("cook_pot_food")
            --end

            inst.AnimState:SetBuild(data.overridebuild or "cook_pot_food")
            inst.AnimState:SetBank("cook_pot_food")

            inst.AnimState:PlayAnimation("idle")
            inst.AnimState:OverrideSymbol("swap_food", data.overridebuild or "cook_pot_food", data.basename or data.name)

            inst:AddTag("preparedfood");
            inst:AddTag(FOOD_TAG);
            if data.tags ~= nil then
                for i, v in pairs(data.tags) do
                    inst:AddTag(v)
                end
            end

            if data.basename ~= nil then
                inst:SetPrefabNameOverride(data.basename)
                if data.spice ~= nil then
                    inst.displaynamefn = DisplayNameFn
                end
            end

            if data.floater ~= nil then
                MakeInventoryFloatable(inst, data.floater[1], data.floater[2], data.floater[3])
            else
                MakeInventoryFloatable(inst)
            end

            inst.entity:SetPristine()

            if not TheWorld.ismastersim then
                return inst
            end

            inst.food_symbol_build = food_symbol_build or data.overridebuild
            inst.food_basename = data.basename

            inst:AddComponent("edible")
            inst.components.edible.healthvalue = data.health
            inst.components.edible.hungervalue = data.hunger
            inst.components.edible.foodtype = data.foodtype or FOODTYPE.GENERIC
            inst.components.edible.secondaryfoodtype = data.secondaryfoodtype or nil
            inst.components.edible.sanityvalue = data.sanity or 0
            inst.components.edible.temperaturedelta = data.temperature or 0
            inst.components.edible.temperatureduration = data.temperatureduration or 0
            inst.components.edible.nochill = data.nochill or nil
            inst.components.edible.spice = data.spice
            inst.components.edible:SetOnEatenFn(data.oneatenfn)

            inst:AddComponent("inspectable")
            inst.wet_prefix = data.wet_prefix

            inst:AddComponent("inventoryitem")
            if data.OnPutInInventory then
                inst:ListenForEvent("onputininventory", data.OnPutInInventory)
            end

            --if spicename ~= nil then
            --    --inst.components.inventoryitem.imagename = spicename .. "_over";
            --    inst.components.inventoryitem.atlasname = GetInventoryItemAtlas(spicename .. "_over" .. ".tex")
            --    inst.components.inventoryitem:ChangeImageName(spicename.."_over")
            --elseif data.basename ~= nil then
            --    inst.components.inventoryitem.imagename = data.name
            --    inst.components.inventoryitem.atlasname = GetInventoryItemAtlas(data.name .. ".tex")
            --end

            inst.components.inventoryitem.imagename = data.name
            inst.components.inventoryitem.atlasname = GetInventoryItemAtlas(data.name .. ".tex")

            if data.basename ~= nil then
                inst.components.inventoryitem:ChangeImageName(data.basename)
            end

            return inst
        end
        -- NOTES(JBK): Use this to help export the bottom table to make this file findable.
        --print(string.format("%s %s", data.foodtype or FOODTYPE.GENERIC, data.name))
        return Prefab(FOOD_PREFIX .. data.name, fn, foodassets, foodprefabs)
    end

    local prefs = {};

    for _, data in pairs(preparedfoods) do
        table.insert(prefs, MakePreparedFood(data))
    end

    for _, data in pairs(preparedfoods_warly) do
        table.insert(prefs, MakePreparedFood(data))
    end

    --for _, data in pairs(spicedfoods) do
    --    table.insert(prefs, MakePreparedFood(data))
    --end

    return prefs;
end

TUNING.NEVER_FINISH_SERIES.MakeFoods = MakeFoods;

