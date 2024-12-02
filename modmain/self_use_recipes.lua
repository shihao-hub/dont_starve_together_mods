---
--- @author zsh in 2023/3/1 12:57
---


local Recipes = {};
local Recipes_Locate = {};

Recipes_Locate["mie_granary_meats"] = true;
Recipes[#Recipes + 1] = {
    CanMake = env.GetModConfigData("granary"),
    name = "mie_granary_meats",
    ingredients = {
        Ingredient("bearger_fur", 1), Ingredient("gears", 2), Ingredient("boards", 5), Ingredient("cutstone", 5),
    },
    tech = TECH.NONE,
    config = {
        placer = "mie_granary_meats_placer",
        min_spacing = 3.2,
        nounlock = nil,
        numtogive = nil,
        builder_tag = nil,
        atlas = "images/inventoryimages/zx_granary_meat.xml",
        image = "zx_granary_meat.tex",
    },
    filters = {
        "MONE_MORE_ITEMS_SELF_USE"
    }
};

Recipes_Locate["mie_granary_greens"] = true;
Recipes[#Recipes + 1] = {
    CanMake = env.GetModConfigData("granary"),
    name = "mie_granary_greens",
    ingredients = {
        Ingredient("bearger_fur", 1), Ingredient("gears", 2), Ingredient("boards", 5), Ingredient("cutstone", 5),
    },
    tech = TECH.NONE,
    config = {
        placer = "mie_granary_greens_placer",
        min_spacing = 3.2,
        nounlock = nil,
        numtogive = nil,
        builder_tag = nil,
        atlas = "images/inventoryimages/zx_granary_veggie.xml",
        image = "zx_granary_veggie.tex",
    },
    filters = {
        "MONE_MORE_ITEMS_SELF_USE"
    }
};

Recipes_Locate["mie_poop_flingomatic"] = true;
Recipes[#Recipes + 1] = {
    CanMake = env.GetModConfigData("mie_poop_flingomatic"),
    name = "mie_poop_flingomatic",
    ingredients = {
        Ingredient("transistor", 2),Ingredient("poop", 5),Ingredient("boards", 4),
    },
    tech = TECH.NONE,
    config = {
        placer = "mie_poop_flingomatic_placer",
        min_spacing = 1.5,
        nounlock = nil,
        numtogive = nil,
        builder_tag = nil,
        atlas = "images/modules/poop_flingomatic/inventoryimages/poop_flingomatic.xml",
        image = "poop_flingomatic.tex",
    },
    filters = {
        "MONE_MORE_ITEMS_SELF_USE"
    }
};

Recipes_Locate["mie_new_granary"] = true;
Recipes[#Recipes + 1] = {
    CanMake = env.GetModConfigData("new_granary"),
    name = "mie_new_granary",
    ingredients = {
        Ingredient("boards", 15), Ingredient("cutreeds", 20), Ingredient("rope", 9),
    },
    tech = TECH.NONE,
    config = {
        placer = "mie_new_granary_placer",
        min_spacing = 3.2,
        nounlock = nil,
        numtogive = nil,
        builder_tag = nil,
        atlas = "images/inventoryimages/self_use/map_icons/myth_granary.xml",
        image = "myth_granary.tex",
        testfn = function(pt)
            local ents = TheWorld.Map:GetEntitiesOnTileAtPoint(pt.x, 0, pt.z)
            for _, ent in ipairs(ents) do
                if not ent:HasTag("player") and not (ent:HasTag("NOBLOCK") or ent:HasTag("locomotor") or ent:HasTag("NOCLICK") or ent:HasTag("FX") or ent:HasTag("DECOR")) then
                    return false
                end
            end
            return true
        end
    },
    filters = {
        "MONE_MORE_ITEMS_SELF_USE"
    }
};

Recipes_Locate["mie_well"] = true;
Recipes[#Recipes + 1] = {
    CanMake = env.GetModConfigData("mie_well"),
    name = "mie_well",
    ingredients = {
        Ingredient("cutstone", 3), Ingredient("shovel", 1), Ingredient("pickaxe", 1),
    },
    tech = TECH.NONE,
    config = {
        placer = "mie_well_placer",
        min_spacing = 3.2,
        nounlock = nil,
        numtogive = nil,
        builder_tag = nil,
        atlas = "images/inventoryimages/self_use/map_icons/myth_well.xml",
        image = "myth_well.tex",
        testfn = function(pt)
            local ents = TheWorld.Map:GetEntitiesOnTileAtPoint(pt.x, 0, pt.z)
            for _, ent in ipairs(ents) do
                if not ent:HasTag("player") and not (ent:HasTag("NOBLOCK") or ent:HasTag("locomotor") or ent:HasTag("NOCLICK") or ent:HasTag("FX") or ent:HasTag("DECOR")) then
                    return false
                end
            end
            return true
        end
    },
    filters = {
        "MONE_MORE_ITEMS_SELF_USE"
    }
};

Recipes_Locate["mie_yjp"] = true;
Recipes[#Recipes + 1] = {
    CanMake = env.GetModConfigData("mie_yjp"),
    name = "mie_yjp",
    ingredients = {
        -- Ingredient("moonglass", 6), Ingredient("moonbutterfly", 1),
        Ingredient("purplegem", 1),
        Ingredient("bluegem", 1),
        Ingredient("redgem", 1),
        Ingredient("orangegem", 1),
        Ingredient("yellowgem", 1),
        Ingredient("greengem", 1),
        --Ingredient("opalpreciousgem", 1),
    },
    tech = TECH.NONE,
    config = {
        nounlock = nil,
        numtogive = nil,
        builder_tag = nil,
        atlas = "images/inventoryimages/self_use/inventoryimages/myth_yjp.xml",
        image = "myth_yjp.tex"
    },
    filters = {
        "MONE_MORE_ITEMS_SELF_USE"
    }
};

Recipes_Locate["mie_bananafan_big"] = true;
Recipes[#Recipes + 1] = {
    CanMake = env.GetModConfigData("mie_bananafan_big"),
    name = "mie_bananafan_big",
    ingredients = {
        Ingredient("featherfan", 1), Ingredient("lavae_egg", 1), Ingredient("greengem", 1)
    },
    tech = TECH.NONE,
    config = {
        nounlock = nil,
        numtogive = nil,
        builder_tag = nil,
        atlas = "images/inventoryimages/self_use/inventoryimages/bananafan_big.xml",
        image = "bananafan_big.tex"
    },
    filters = {
        "MONE_MORE_ITEMS_SELF_USE"
    }
};

Recipes_Locate["mie_cash_tree_ground"] = true;
Recipes[#Recipes + 1] = {
    CanMake = env.GetModConfigData("mie_cash_tree_ground"),
    name = "mie_cash_tree_ground",
    ingredients = {
        --Ingredient("purplegem", 3),
        --Ingredient("bluegem", 3),
        --Ingredient("redgem", 3),
        --Ingredient("orangegem", 3),
        --Ingredient("yellowgem", 3),
        --Ingredient("greengem", 3),
        --Ingredient("opalpreciousgem", 3),

        --Ingredient("purplegem", 2),
        --Ingredient("bluegem", 2),
        --Ingredient("redgem", 2),
        --Ingredient("orangegem", 2),
        --Ingredient("yellowgem", 2),
        --Ingredient("greengem", 2),
        --Ingredient("opalpreciousgem", 2),
        --Ingredient("mandrakesoup", 1),

        Ingredient("orangegem", 3),
        Ingredient("yellowgem", 3),
        Ingredient("greengem", 3),
        Ingredient("opalpreciousgem", 3),
        Ingredient("mandrakesoup", 1),
    },
    tech = TECH.NONE,
    config = {
        placer = "mie_cash_tree_ground_placer",
        min_spacing = 3.5,
        nounlock = nil,
        numtogive = nil,
        builder_tag = nil,
        atlas = "images/inventoryimages/self_use/inventoryimages/myth_cash_tree.xml",
        image = "myth_cash_tree.tex"
    },
    filters = {
        "MONE_MORE_ITEMS_SELF_USE"
    }
};

--Recipes_Locate["mie_myth_fuchen"] = true;
--Recipes[#Recipes + 1] = {
--    CanMake = env.GetModConfigData("mie_myth_fuchen"),
--    name = "mie_myth_fuchen",
--    ingredients = {
--        Ingredient("cane", 1), Ingredient("greengem", 1),
--    },
--    tech = TECH.NONE,
--    config = {
--        atlas = "images/inventoryimages/self_use/inventoryimages/myth_fuchen.xml",
--        image = "myth_fuchen.tex"
--    },
--    filters = {
--        "MONE_MORE_ITEMS_SELF_USE"
--    }
--};

-- 统统移到扩展包栏，统一起来。科技栏太多太乱了！
for _, v in pairs(Recipes) do
    if v.CanMake then
        v.filters = { "MONE_MORE_ITEMS1" };
        local all_items_one_recipetab = TUNING.MONE_TUNING.GET_MOD_CONFIG_DATA.all_items_one_recipetab;
        if all_items_one_recipetab then
            v.filters = { "MONE_MORE_ITEMS1" };
        end
    end
end

for _, v in pairs(Recipes) do
    if v.CanMake then
        --local all_items_one_recipetab = TUNING.MONE_TUNING.GET_MOD_CONFIG_DATA.all_items_one_recipetab;
        --if all_items_one_recipetab then
        --    v.filters = { "MONE_MORE_ITEMS1" };
        --end
        env.AddRecipe2(v.name, v.ingredients, v.tech, v.config, v.filters);
    end
end

for _, v in pairs(Recipes) do
    if v.CanMake then
        env.RemoveRecipeFromFilter(v.name, "MODS");
    end
end