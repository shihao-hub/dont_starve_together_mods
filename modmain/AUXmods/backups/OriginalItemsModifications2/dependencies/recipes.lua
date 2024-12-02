---
--- @author zsh in 2023/4/24 14:42
---

local config_data = TUNING.MONE_TUNING.GET_MOD_CONFIG_DATA;

local RecipeTabs = {};
local key_modify = "more_items_modify";
RecipeTabs[key_modify] = {
    filter_def = {
        name = "MONE_MORE_ITEMS_MODIFY",
        atlas = "images/inventoryimages1.xml",
        image = "bernie_cat.tex"
    },
    index = nil
}
STRINGS.UI.CRAFTING_FILTERS[RecipeTabs[key_modify].filter_def.name] = "更多物品·修改栏"
AddRecipeFilter(RecipeTabs[key_modify].filter_def, RecipeTabs[key_modify].index)

local Recipes = {};
local Recipes_Locate = {};

Recipes_Locate["whip"] = true;
Recipes[#Recipes + 1] = {
    CanMake = config_data.whip,
    name = "whip_mi_copy",
    ingredients = {
        Ingredient("coontail", 3), Ingredient("tentaclespots", 1)
    },
    tech = TECH.NONE,
    config = {
        product = "whip",
        placer = nil,
        min_spacing = nil,
        nounlock = nil,
        numtogive = 1,
        builder_tag = nil,
        atlas = "images/inventoryimages.xml",
        image = "whip.tex"
    },
    filters = {
        "MONE_MORE_ITEMS_MODIFY"
    }
};

Recipes_Locate["wateringcan"] = true;
Recipes[#Recipes + 1] = {
    CanMake = config_data.wateringcan,
    name = "wateringcan_mi_copy",
    ingredients = {
        Ingredient("boards", 2), Ingredient("rope", 1)
    },
    tech = TECH.NONE,
    config = {
        product = "wateringcan",
        placer = nil,
        min_spacing = nil,
        nounlock = nil,
        numtogive = 1,
        builder_tag = nil,
        atlas = "images/inventoryimages2.xml",
        image = "wateringcan.tex"
    },
    filters = {
        "MONE_MORE_ITEMS_MODIFY"
    }
};

Recipes_Locate["premiumwateringcan"] = true;
Recipes[#Recipes + 1] = {
    CanMake = config_data.premiumwateringcan,
    name = "premiumwateringcan_mi_copy",
    ingredients = {
        Ingredient("driftwood_log", 2), Ingredient("rope", 1), Ingredient("malbatross_beak", 1)
    },
    tech = TECH.NONE,
    config = {
        product = "premiumwateringcan",
        placer = nil,
        min_spacing = nil,
        nounlock = nil,
        numtogive = 1,
        builder_tag = nil,
        atlas = "images/inventoryimages2.xml",
        image = "premiumwateringcan.tex"
    },
    filters = {
        "MONE_MORE_ITEMS_MODIFY"
    }
};

Recipes_Locate["telebase"] = true;
Recipes[#Recipes + 1] = {
    CanMake = config_data.telebase,
    name = "telebase_mi_copy",
    ingredients = {
        Ingredient("nightmarefuel", 4), Ingredient("livinglog", 4), Ingredient("goldnugget", 8)
    },
    tech = TECH.NONE,
    config = {
        product = "telebase",
        placer = nil,
        min_spacing = nil,
        nounlock = nil,
        numtogive = 1,
        builder_tag = nil,
        atlas = "images/inventoryimages.xml",
        image = "telebase.tex"
    },
    filters = {
        "MONE_MORE_ITEMS_MODIFY"
    }
};

Recipes_Locate["batbat"] = true;
Recipes[#Recipes + 1] = {
    CanMake = config_data.batbat,
    name = "batbat_mi_copy",
    ingredients = {
        Ingredient("batwing", 3), Ingredient("livinglog", 2), Ingredient("purplegem", 1)
    },
    tech = TECH.NONE,
    config = {
        product = "batbat",
        placer = nil,
        min_spacing = nil,
        nounlock = nil,
        numtogive = 1,
        builder_tag = nil,
        atlas = "images/inventoryimages.xml",
        image = "batbat.tex"
    },
    filters = {
        "MONE_MORE_ITEMS_MODIFY"
    }
};

Recipes_Locate["nightstick"] = true;
Recipes[#Recipes + 1] = {
    CanMake = config_data.nightstick,
    name = "nightstick_mi_copy",
    ingredients = {
        Ingredient("lightninggoathorn", 1), Ingredient("transistor", 2), Ingredient("nitre", 2)
    },
    tech = TECH.NONE,
    config = {
        product = "nightstick",
        placer = nil,
        min_spacing = nil,
        nounlock = nil,
        numtogive = 1,
        builder_tag = nil,
        atlas = "images/inventoryimages.xml",
        image = "nightstick.tex"
    },
    filters = {
        "MONE_MORE_ITEMS_MODIFY"
    }
};

Recipes_Locate["hivehat"] = true;
Recipes[#Recipes + 1] = {
    CanMake = config_data.hivehat,
    name = "hivehat_mi_copy",
    ingredients = {
        Ingredient("hivehat", 1), Ingredient("greengem", 1)
    },
    tech = TECH.NONE,
    config = {
        product = "hivehat",
        placer = nil,
        min_spacing = nil,
        nounlock = nil,
        numtogive = 1,
        builder_tag = nil,
        atlas = "images/inventoryimages.xml",
        image = "hivehat.tex"
    },
    filters = {
        "MONE_MORE_ITEMS_MODIFY"
    }
};

Recipes_Locate["eyemaskhat"] = true;
Recipes[#Recipes + 1] = {
    CanMake = config_data.eyemaskhat,
    name = "eyemaskhat_mi_copy",
    ingredients = {
        Ingredient("eyemaskhat", 1), Ingredient("greengem", 1)
    },
    tech = TECH.NONE,
    config = {
        product = "eyemaskhat",
        placer = nil,
        min_spacing = nil,
        nounlock = nil,
        numtogive = 1,
        builder_tag = nil,
        atlas = "images/inventoryimages1.xml",
        image = "eyemaskhat.tex"
    },
    filters = {
        "MONE_MORE_ITEMS_MODIFY"
    }
};

Recipes_Locate["shieldofterror"] = true;
Recipes[#Recipes + 1] = {
    CanMake = config_data.shieldofterror,
    name = "shieldofterror_mi_copy",
    ingredients = {
        Ingredient("shieldofterror", 1), Ingredient("greengem", 1)
    },
    tech = TECH.NONE,
    config = {
        product = "shieldofterror",
        placer = nil,
        min_spacing = nil,
        nounlock = nil,
        numtogive = 1,
        builder_tag = nil,
        atlas = "images/inventoryimages2.xml",
        image = "shieldofterror.tex"
    },
    filters = {
        "MONE_MORE_ITEMS_MODIFY"
    }
};

for _, v in pairs(Recipes) do
    if v.CanMake then
        env.AddRecipe2(v.name, v.ingredients, v.tech, v.config, v.filters);
    end
end