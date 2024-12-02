---
--- @author zsh in 2023/2/7 9:13
---

local more_items = TUNING.MIE_TUNING.MORE_ITEMS;
local BALANCE = more_items.BALANCE;

local config_data = TUNING.MIE_TUNING.MOD_CONFIG_DATA;

local GetValidRecipe = env.GLOBAL.GetValidRecipe; -- recipe.lua function GetValidRecipe(recname);


--if config_data.mone_backpack_update then
--    local mone_backpack = GetValidRecipe("mone_backpack");
--    if mone_backpack then
--        mone_backpack.ingredients = BALANCE and {
--            Ingredient("cutgrass", 24), Ingredient("twigs", 24), Ingredient("goldnugget", 8),
--        } or {
--            Ingredient("cutgrass", 12), Ingredient("twigs", 12)
--        }
--    end
--end

--if config_data.rewrite_storage_bag then
--    local mone_storage_bag = GetValidRecipe("mone_storage_bag");
--    if mone_storage_bag then
--        mone_storage_bag.ingredients = BALANCE and {
--            Ingredient("papyrus", 20), Ingredient("petals", 40)
--        } or {
--            Ingredient("papyrus", 10), Ingredient("petals", 20)
--        }
--    end
--end

--if config_data.rewrite_arborist then
--    local mone_arborist = GetValidRecipe("mone_arborist");
--    if mone_arborist then
--        -- 我去，这咋写的。咋报错了？。。。ingredients == nil? v.ingredienttype == nil? 算了，硬编码吧。
--        --local function ingredientsMultiple(ingredients, multiple, operator)
--        --    if operator ~= "*" and operator ~= "/" then
--        --        return ingredients;
--        --    end
--        --
--        --    local new_ingredients = {};
--        --    for _, v in ipairs(ingredients) do
--        --        local amount = math.floor(operator == "*" and v.amount * multiple or v.amount / multiple);
--        --        table.insert(new_ingredients, Ingredient(v.ingredienttype, amount));
--        --    end
--        --    return new_ingredients;
--        --end
--        --local old_ingredients = mone_arborist.ingredients;
--        --mone_arborist.ingredients = ingredientsMultiple(old_ingredients, 1.5, "/");
--        mone_arborist.ingredients = BALANCE and {
--            Ingredient("pinecone", 20), Ingredient("acorn", 20), Ingredient("marblebean", 10)
--        } or {
--            Ingredient("pinecone", 10), Ingredient("acorn", 10), Ingredient("marblebean", 5)
--        }
--    end
--end

--if CAPACITY then
--    local mone_treasurechest = GetValidRecipe("mone_treasurechest");
--    local mone_dragonflychest = GetValidRecipe("mone_dragonflychest");
--    local mone_icebox = GetValidRecipe("mone_icebox");
--    local mone_saltbox = GetValidRecipe("mone_saltbox");
--
--    if mone_treasurechest and mone_dragonflychest and mone_icebox and mone_saltbox then
--        mone_treasurechest.ingredients = {
--            Ingredient("boards", 12)
--        }
--        mone_dragonflychest.ingredients = {
--            Ingredient("dragon_scales", 3), Ingredient("boards", 10), Ingredient("goldnugget", 30)
--        }
--        mone_icebox.ingredients = {
--            Ingredient("goldnugget", 8), Ingredient("gears", 4), Ingredient("cutstone", 4)
--        }
--        mone_saltbox.ingredients = {
--            Ingredient("saltrock", 40), Ingredient("bluegem", 4), Ingredient("cutstone", 4)
--        }
--    end
--end