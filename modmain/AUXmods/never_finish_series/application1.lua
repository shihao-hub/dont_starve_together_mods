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

local function GetFoodRecipeName(food_name)
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

local function recipes()
    -- 添加新的制作栏
    local RecipeTabs = {};
    local key1 = "more_items_nfs";
    RecipeTabs[key1] = {
        filter_def = {
            name = "MONE_MORE_ITEMS_NFS",
            atlas = "images/DLC/inventoryimages2.xml",
            image = "voltgoatjelly.tex"
        },
        index = nil
    }
    STRINGS.UI.CRAFTING_FILTERS[RecipeTabs[key1].filter_def.name] = "更多物品·绝对吃不完系列"
    AddRecipeFilter(RecipeTabs[key1].filter_def, RecipeTabs[key1].index)

    -- 添加配方
    local function getRecipe(food_name)
        local number = 300;

        -- 修改一下一些物品所需要的数量
        if string.find(food_name, "voltgoatjelly")
                or string.find(food_name, "icecream")
                or string.find(food_name, "lobsterdinner") then
            number = 100;
        end

        local recipe = setmetatable({
            name = GetFoodRecipeName(food_name);
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
        local upper_name = string.upper(GetFoodRecipeName(food_name));
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

    -- 单独处理一下
    for food_name, _ in pairs(preparedfoods) do
        env.RemoveRecipeFromFilter(GetFoodRecipeName(food_name), "MODS");
    end
    for food_name, _ in pairs(preparedfoods_warly) do
        env.RemoveRecipeFromFilter(GetFoodRecipeName(food_name), "MODS");
    end
end
recipes();

-- 需要修的bug...处理一下相关动作
local function actions()
    local feedplayer = ACTIONS and ACTIONS.FEEDPLAYER;
    if feedplayer then
        local old_fn = feedplayer.fn;
        if old_fn then
            --local function new_fn(act, ...)
            --    if act.target ~= nil and
            --            act.target:IsValid() and
            --            act.target.sg:HasStateTag("idle") and
            --            not (act.target.sg:HasStateTag("busy") or
            --                    act.target.sg:HasStateTag("attacking") or
            --                    act.target.sg:HasStateTag("sleeping") or
            --                    act.target:HasTag("playerghost") or
            --                    act.target:HasTag("wereplayer")) and
            --            act.target.components.eater ~= nil and
            --            act.invobject.components.edible ~= nil and
            --            act.target.components.eater:CanEat(act.invobject) and
            --            (TheNet:GetPVPEnabled() or
            --                    (act.target:HasTag("strongstomach") and
            --                            act.invobject:HasTag("monstermeat")) or
            --                    (act.invobject:HasTag("spoiled") and act.target:HasTag("ignoresspoilage") and not
            --                    (act.invobject:HasTag("badfood") or act.invobject:HasTag("unsafefood"))) or
            --                    not (act.invobject:HasTag("badfood") or
            --                            act.invobject:HasTag("unsafefood") or
            --                            act.invobject:HasTag("spoiled"))) then
            --        if act.target.components.eater:PrefersToEat(act.invobject) then
            --            --local food = act.invobject.components.inventoryitem:RemoveFromOwner()
            --            local food = act.invobject;
            --            if food ~= nil then
            --                --act.target:AddChild(food)
            --                --food:RemoveFromScene()
            --                --food.components.inventoryitem:HibernateLivingItem()
            --                --food.persists = false
            --                --act.doer.components.inventory:GiveItem(food,dct.target:GetPosition());
            --                act.target.sg:GoToState(
            --                        food.components.edible.foodtype == FOODTYPE.MEAT and "eat" or "quickeat",
            --                        { feed = food, feeder = act.doer }
            --                )
            --                -- 呃，GoToState执行结束还是会被移除...话说为什么只是喂食的时候被移除呢？我自己吃为什么不会？
            --                return true
            --            end
            --        else
            --            act.target:PushEvent("wonteatfood", { food = act.invobject })
            --            return true -- the action still "succeeded", there's just no result on this end
            --        end
            --    end
            --end

            ACTIONS.FEEDPLAYER.fn = function(act, ...)
                if isValid(act.invobject) and act.invobject:HasTag(FOOD_TAG) then
                    local old_food = act.invobject;
                    local old_food_record = isValid(old_food) and old_food:GetSaveRecord();

                    local res = { old_fn(act, ...) };

                    if res[1] then
                        if old_food_record and isValid(act.target) and isValid(act.doer) then
                            act.doer.components.inventory:GiveItem(SpawnSaveRecord(old_food_record), nil, act.target:GetPosition());
                        end
                    end

                    return unpack(res, 1, table.maxn(res));
                else
                    return old_fn(act, ...);
                end
            end
        end
    end
end
actions();

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

-- 提供给 scrips/prefabs/... 使用的函数，用于注册预制物
-- Tip: 这个函数在调用完毕后应该释放掉的。以后再说吧。
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

        local foodprefabs = prefabs
        if data.prefabs ~= nil then
            foodprefabs = shallowcopy(prefabs)
            for i, v in ipairs(data.prefabs) do
                if not table.contains(foodprefabs, v) then
                    table.insert(foodprefabs, v)
                end
            end
        end

        -- 2023-06-25：这个函数我调用的不对，第二个参数必须传入一张表
        local function DisplayNameFn(inst)
            return subfmt("绝对吃不完的" .. tostring(STRINGS.NAMES[string.upper(data.basename)]))
        end

        local function fn()
            local inst = CreateEntity()

            inst.entity:AddTransform()
            inst.entity:AddAnimState()
            inst.entity:AddNetwork()

            MakeInventoryPhysics(inst)

            local food_symbol_build = nil
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

    return prefs;
end

TUNING.NEVER_FINISH_SERIES.MakeFoods = MakeFoods;

