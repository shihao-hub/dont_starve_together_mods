---
--- @author zsh in 2023/5/15 15:33
---

local config_data = TUNING.MONE_TUNING.GET_MOD_CONFIG_DATA;

if not config_data.never_finish_series then
    return ;
end

table.insert(env.PrefabFiles, "mone/mine/never_finish_series");

TUNING.NEVER_FINISH_SERIES_ENABLED = true;

TUNING.NEVER_FINISH_SERIES = {};

local FOOD_PREFIX = "mi_nfs_";
local FOOD_TAG = FOOD_PREFIX .. "food_tag";

local SPICE_FUNCTIONALITY = false;

local function GenerateFoodRecipeName(food_name)
    return FOOD_PREFIX .. tostring(food_name);
end

local _preparedfoods = require("preparedfoods");
local _preparedfoods_warly = require("preparedfoods_warly");

local preparedfoods = {};
local preparedfoods_warly = {};

local function eliminate()
    for food_name, data in pairs(_preparedfoods) do
        if not string.find(food_name, "beefalotreat")
                and not string.find(food_name, "beefalofeed")
        then
            preparedfoods[food_name] = data;
        end
    end

    preparedfoods_warly = _preparedfoods_warly;
end
eliminate();

local mods_preparedfoods = {}; -- 算了，不方便...

local function compatible()

end
compatible();

local function recipes()
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

    local function getRecipe(food_name)
        local number = 300;

        -- 修改一下一些物品所需要的数量
        if string.find(food_name, "voltgoatjelly")
                or string.find(food_name, "icecream")
                or string.find(food_name, "lobsterdinner") then
            number = 100;
        end

        local recipe = setmetatable({
            name = GenerateFoodRecipeName(food_name);
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
        return recipe;
    end

    local function addCommonStrings(food_name, extra_fn)
        if extra_fn then
            return extra_fn();
        end
        local game_real_name = STRINGS.NAMES[string.upper(food_name)];
        local upper_name = string.upper(GenerateFoodRecipeName(food_name));
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
    for food_name, _ in pairs(mods_preparedfoods) do
        env.AddRecipe2(getRecipe(food_name)());
        addCommonStrings(food_name);
    end

    -- 单独处理一下
    for food_name, _ in pairs(preparedfoods) do
        env.RemoveRecipeFromFilter(GenerateFoodRecipeName(food_name), "MODS");
    end
    for food_name, _ in pairs(preparedfoods_warly) do
        env.RemoveRecipeFromFilter(GenerateFoodRecipeName(food_name), "MODS");
    end
    for food_name, _ in pairs(mods_preparedfoods) do
        env.RemoveRecipeFromFilter(GenerateFoodRecipeName(food_name), "MODS");
    end
end
recipes();

-- 需要修的bug...处理一下相关动作
local function actions()
    local feedplayer = ACTIONS and ACTIONS.FEEDPLAYER;
    if feedplayer then
        local old_fn = feedplayer.fn;
        if old_fn then
            local function new_fn(act, ...)
                if act.target ~= nil and
                        act.target:IsValid() and
                        act.target.sg:HasStateTag("idle") and
                        not (act.target.sg:HasStateTag("busy") or
                                act.target.sg:HasStateTag("attacking") or
                                act.target.sg:HasStateTag("sleeping") or
                                act.target:HasTag("playerghost") or
                                act.target:HasTag("wereplayer")) and
                        act.target.components.eater ~= nil and
                        act.invobject.components.edible ~= nil and
                        act.target.components.eater:CanEat(act.invobject) and
                        (TheNet:GetPVPEnabled() or
                                (act.target:HasTag("strongstomach") and
                                        act.invobject:HasTag("monstermeat")) or
                                (act.invobject:HasTag("spoiled") and act.target:HasTag("ignoresspoilage") and not
                                (act.invobject:HasTag("badfood") or act.invobject:HasTag("unsafefood"))) or
                                not (act.invobject:HasTag("badfood") or
                                        act.invobject:HasTag("unsafefood") or
                                        act.invobject:HasTag("spoiled"))) then
                    if act.target.components.eater:PrefersToEat(act.invobject) then
                        --local food = act.invobject.components.inventoryitem:RemoveFromOwner()
                        local food = act.invobject;
                        if food ~= nil then
                            --act.target:AddChild(food)
                            --food:RemoveFromScene()
                            --food.components.inventoryitem:HibernateLivingItem()
                            --food.persists = false
                            act.target.sg:GoToState(
                                    food.components.edible.foodtype == FOODTYPE.MEAT and "eat" or "quickeat",
                                    { feed = food, feeder = act.doer }
                            )
                            return true
                        end
                    else
                        act.target:PushEvent("wonteatfood", { food = act.invobject })
                        return true -- the action still "succeeded", there's just no result on this end
                    end
                end
            end

            ACTIONS.FEEDPLAYER.fn = function(act, ...)
                if isValid(act.invobject) and act.invobject:HasTag(FOOD_TAG) then
                    return new_fn(act, ...);
                else
                    return old_fn(act, ...);
                end
            end
        end
    end
end
--actions();

local function postinit()
    env.AddPrefabPostInit("greenstaff", function(inst)
        if not TheWorld.ismastersim then
            return inst;
        end
        if inst.components.spellcaster then
            local old_spell = inst.components.spellcaster.spell;
            inst.components.spellcaster.spell = function(inst, target, pos, doer, ...)
                if target and target:HasTag(FOOD_TAG) then
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

-- 提前执行
local function generate_spiced_foods()
    local gsf_preparedfoods = {};
    local gsf_preparedfoods_warly = {};

    -- 执行前
    for foodname, fooddata in pairs(preparedfoods) do
        gsf_preparedfoods[GenerateFoodRecipeName(foodname)] = fooddata;
    end

    for foodname, fooddata in pairs(preparedfoods_warly) do
        gsf_preparedfoods_warly[GenerateFoodRecipeName(foodname)] = fooddata;
    end

    GenerateSpicedFoods(gsf_preparedfoods);
    GenerateSpicedFoods(gsf_preparedfoods_warly);

    -- 执行后
    for foodname, fooddata in pairs(preparedfoods) do
        gsf_preparedfoods[string.sub(foodname, #FOOD_PREFIX + 1, -1)] = fooddata;
    end

    for foodname, fooddata in pairs(preparedfoods_warly) do
        gsf_preparedfoods_warly[string.sub(foodname, #FOOD_PREFIX + 1, -1)] = fooddata;
    end

    preparedfoods = gsf_preparedfoods;
    preparedfoods_warly = gsf_preparedfoods_warly;

    -- 修改相关组件和内容
    HookComponent("stewer", function(self)

    end)
end
--generate_spiced_foods(); -- 调料不方便统一生成...

-- TODO: 添加新动作，给予料理调味粉末，拥有调味料理的能力
local function new_actions()
    if not SPICE_FUNCTIONALITY then
        return;
    end

end
new_actions();

-- TEST
-- ShiHao.printTable(require("spicedfoods"))

-- 提供给 scrips/prefabs/... 使用的函数，用于注册预制物
-- Tip: 这个函数在调用完毕后应该释放掉的吧？以后再说吧。
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

        local spicename_enabled; -- 备注：调料的话有点麻烦，不方便统一生成... cooking.GetRecipe、stewer 等等
        --local spicename = data.spice ~= nil and string.lower(data.spice) or nil
        --if spicename ~= nil then
        --    table.insert(foodassets, Asset("ANIM", "anim/spices.zip"))
        --    table.insert(foodassets, Asset("ANIM", "anim/plate_food.zip"))
        --    table.insert(foodassets, Asset("INV_IMAGE", spicename .. "_over"))
        --    spicename_enabled = true;
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

        local function DisplayNameFn(inst)
            return "绝对吃不完的" .. subfmt(STRINGS.NAMES[data.spice .. "_FOOD"], { food = STRINGS.NAMES[string.upper(data.basename)] })
        end

        local function OnSave(inst, data)
            data.more_items_spice_type = inst.more_items_spice_type;
            data.more_items_spice_number = inst.more_items_spice_number;
        end

        local function OnLoad(inst, data)
            if data ~= nil then
                inst.more_items_spice_type = data.more_items_spice_type;
                inst.more_items_spice_number = data.more_items_spice_number;
            end
        end

        local function fn()
            local inst = CreateEntity()

            inst.entity:AddTransform()
            inst.entity:AddAnimState()
            inst.entity:AddNetwork()

            MakeInventoryPhysics(inst)

            local spicename = spicename_enabled and spicename or nil;

            local food_symbol_build = nil
            if spicename ~= nil then
                inst.AnimState:SetBuild("plate_food")
                inst.AnimState:SetBank("plate_food")
                inst.AnimState:OverrideSymbol("swap_garnish", "spices", spicename)

                inst:AddTag("spicedfood")

                inst.inv_image_bg = { image = (data.basename or data.name) .. ".tex" }
                inst.inv_image_bg.atlas = GetInventoryItemAtlas(inst.inv_image_bg.image)

                food_symbol_build = data.overridebuild or "cook_pot_food"
            else
                inst.AnimState:SetBuild(data.overridebuild or "cook_pot_food")
                inst.AnimState:SetBank("cook_pot_food")
            end

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

            -- NEW!
            inst.components.inventoryitem.imagename = data.name
            inst.components.inventoryitem.atlasname = GetInventoryItemAtlas(data.name .. ".tex")

            if spicename ~= nil then
                inst.components.inventoryitem:ChangeImageName(spicename .. "_over")
            elseif data.basename ~= nil then
                inst.components.inventoryitem:ChangeImageName(data.basename)
            end

            -- NEW!
            inst.OnSave = OnSave;
            inst.OnLoad = OnLoad;

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

    for _, data in pairs(mods_preparedfoods) do
        table.insert(prefs, MakePreparedFood(data))
    end

    return prefs;
end

TUNING.NEVER_FINISH_SERIES.MakeFoods = MakeFoods;

