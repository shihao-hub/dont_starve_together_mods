---
--- @author zsh in 2023/1/8 17:34
---


local API = require("chang_mone.dsts.API");
local constants = require("more_items_constants")

local config_data = TUNING.MONE_TUNING.GET_MOD_CONFIG_DATA;
local BALANCE = TUNING.MONE_TUNING.GET_MOD_CONFIG_DATA.BALANCE;

local all_items_one_recipetab = config_data.all_items_one_recipetab;

---------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------
-- 添加新的制作栏
local RecipeTabs = {};

-- 新贴图的除食物类的物品
local key1 = "more_items1";
RecipeTabs[key1] = {
    filter_def = {
        name = "MONE_MORE_ITEMS1",
        atlas = "images/inventoryimages.xml",
        image = "amulet.tex"
    },
    index = nil
}
STRINGS.UI.CRAFTING_FILTERS[RecipeTabs[key1].filter_def.name] = "更多物品·一"
AddRecipeFilter(RecipeTabs[key1].filter_def, RecipeTabs[key1].index)

if not all_items_one_recipetab then
    -- 原版物品修改
    local key2 = "more_items2";
    RecipeTabs[key2] = {
        filter_def = {
            name = "MONE_MORE_ITEMS2",
            atlas = "images/inventoryimages.xml",
            image = "blueamulet.tex"
        },
        index = nil
    }
    STRINGS.UI.CRAFTING_FILTERS[RecipeTabs[key2].filter_def.name] = "更多物品·二"
    AddRecipeFilter(RecipeTabs[key2].filter_def, RecipeTabs[key2].index)

    -- 新贴图的食物类物品
    --local key3 = "more_items3";
    --RecipeTabs[key3] = {
    --    filter_def = {
    --        name = "MONE_MORE_ITEMS3",
    --        atlas = "images/inventoryimages.xml",
    --        image = "greenamulet.tex"
    --    },
    --    index = nil
    --}
    --STRINGS.UI.CRAFTING_FILTERS[RecipeTabs[key3].filter_def.name] = "更多物品·三"
    --AddRecipeFilter(RecipeTabs[key3].filter_def, RecipeTabs[key3].index)

    ---- 更多物品扩展包
    --local key4 = "more_items4";
    --RecipeTabs[key4] = {
    --    filter_def = {
    --        name = "MONE_MORE_ITEMS4",
    --        atlas = "images/inventoryimages.xml",
    --        image = "orangeamulet.tex"
    --    },
    --    index = nil
    --}
    --STRINGS.UI.CRAFTING_FILTERS[RecipeTabs[key4].filter_def.name] = "更多物品·扩展包"
    --AddRecipeFilter(RecipeTabs[key4].filter_def, RecipeTabs[key4].index)

    -- 再加这两个物品栏就太多了！
    --TUNING.MONE_TUNING.RECIPE_TABS_KEY5_HOT_UPDATE = false;
    --local key5 = "more_items5";
    --RecipeTabs[key5] = {
    --    filter_def = {
    --        name = "MONE_MORE_ITEMS5",
    --        atlas = "images/inventoryimages.xml",
    --        image = "purpleamulet.tex"
    --    },
    --    index = nil
    --}
    --STRINGS.UI.CRAFTING_FILTERS[RecipeTabs[key5].filter_def.name] = "更多物品·原版栏"
    --AddRecipeFilter(RecipeTabs[key5].filter_def, RecipeTabs[key5].index)
    --
    --TUNING.MONE_TUNING.RECIPE_TABS_KEY_SELF_USE_HOT_UPDATE = false;
    --local key_self_use = "more_items_self_use";
    --RecipeTabs[key_self_use] = {
    --    filter_def = {
    --        name = "MONE_MORE_ITEMS_SELF_USE",
    --        atlas = "images/inventoryimages.xml",
    --        image = "yellowamulet.tex"
    --    },
    --    index = nil
    --}
    --STRINGS.UI.CRAFTING_FILTERS[RecipeTabs[key_self_use].filter_def.name] = "其他物品栏"
    --AddRecipeFilter(RecipeTabs[key_self_use].filter_def, RecipeTabs[key_self_use].index)
end

--if config_data.hamlet_ground then
--    local key_decor = "more_items_decor";
--    RecipeTabs[key_decor] = {
--        filter_def = {
--            name = "MONE_MORE_ITEMS_DECOR",
--            atlas = resolvefilepath(CRAFTING_ICONS_ATLAS),
--            image = "filter_cosmetic.tex"
--        },
--        index = nil
--    }
--    STRINGS.UI.CRAFTING_FILTERS[RecipeTabs[key_decor].filter_def.name] = "更多物品·装饰栏"
--    AddRecipeFilter(RecipeTabs[key_decor].filter_def, RecipeTabs[key_decor].index)
--end
---------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------

local Recipes = {}
local Recipes_Locate = {};

Recipes_Locate["mone_spear_poison"] = true;
Recipes[#Recipes + 1] = {
    CanMake = env.GetModConfigData("__spear_poison"),
    name = "mone_spear_poison",
    ingredients = BALANCE and {
        Ingredient("spear", 2), Ingredient("goldnugget", 5)
    } or {
        Ingredient("spear", 1), Ingredient("goldnugget", 2)
    },
    tech = TECH.SCIENCE_TWO,
    config = {
        placer = nil,
        min_spacing = nil,
        nounlock = nil,
        numtogive = nil,
        builder_tag = nil,
        --atlas = "images/inventoryimages/mandrake_staff.xml",
        --image = "mandrake_staff.tex"
        atlas = "images/DLC0002/inventoryimages.xml",
        image = "spear_poison.tex"
    },
    filters = {
        "MONE_MORE_ITEMS1"
    }
};

Recipes_Locate["mone_harvester_staff"] = true;
Recipes[#Recipes + 1] = {
    CanMake = env.GetModConfigData("__harvester_staff"),
    name = "mone_harvester_staff",
    ingredients = BALANCE and {
        Ingredient("twigs", 4), Ingredient("cutgrass", 4)--, Ingredient("flint", 2)
    } or {
        Ingredient("twigs", 2), Ingredient("cutgrass", 2)--, Ingredient("flint", 1)
    },
    tech = TECH.NONE,
    config = {
        placer = nil,
        min_spacing = nil,
        nounlock = nil,
        numtogive = nil,
        builder_tag = nil,
        --atlas = "images/inventoryimages/mandrake_staff.xml",
        --image = "mandrake_staff.tex"
        atlas = "images/DLC0002/inventoryimages.xml",
        image = "machete.tex"
    },
    filters = {
        "MONE_MORE_ITEMS1"
    }
};

Recipes_Locate["mone_harvester_staff_gold"] = true;
Recipes[#Recipes + 1] = {
    CanMake = env.GetModConfigData("__harvester_staff"),
    name = "mone_harvester_staff_gold",
    ingredients = BALANCE and {
        Ingredient("twigs", 6), Ingredient("cutgrass", 6), Ingredient("goldnugget", 2)
    } or {
        Ingredient("twigs", 3), Ingredient("cutgrass", 3), Ingredient("goldnugget", 1)
    },
    tech = TECH.SCIENCE_TWO,
    config = {
        placer = nil,
        min_spacing = nil,
        nounlock = nil,
        numtogive = nil,
        builder_tag = nil,
        --atlas = "images/inventoryimages/mandrake_staff.xml",
        --image = "mandrake_staff.tex"
        atlas = "images/DLC0002/inventoryimages.xml",
        image = "goldenmachete.tex"
    },
    filters = {
        "MONE_MORE_ITEMS1"
    }
};

Recipes_Locate["mone_halberd"] = true;
Recipes[#Recipes + 1] = {
    CanMake = env.GetModConfigData("__halberd"),
    name = "mone_halberd",
    ingredients = BALANCE and {
        Ingredient("goldenaxe", 1), Ingredient("goldenpickaxe", 1), Ingredient("hammer", 1),
        Ingredient("marble", 5)
    } or {
        Ingredient("goldenaxe", 1), Ingredient("goldenpickaxe", 1), Ingredient("hammer", 1),
        Ingredient("marble", 2)
    },
    tech = TECH.SCIENCE_TWO,
    config = {
        placer = nil,
        min_spacing = nil,
        nounlock = nil,
        numtogive = nil,
        builder_tag = nil,
        atlas = "images/DLC0003/inventoryimages.xml",
        image = "halberd.tex"
    },
    filters = {
        "MONE_MORE_ITEMS1"
    }
};

Recipes_Locate["mone_redlantern"] = true;
Recipes[#Recipes + 1] = {
    CanMake = env.GetModConfigData("__redlantern"),
    name = "mone_redlantern",
    ingredients = {
        Ingredient("twigs", 3), Ingredient("rope", 2), Ingredient("lightbulb", 2)
    },
    tech = TECH.SCIENCE_TWO,
    config = {
        placer = nil,
        min_spacing = nil,
        nounlock = nil,
        numtogive = nil,
        builder_tag = nil,
        atlas = "images/inventoryimages.xml",
        image = "redlantern.tex"
    },
    filters = {
        "MONE_MORE_ITEMS1"
    }
};

Recipes_Locate["mone_pith"] = true;
Recipes[#Recipes + 1] = {
    CanMake = env.GetModConfigData("__pith"),
    name = "mone_pith",
    ingredients = BALANCE and {
        Ingredient("cutgrass", 4), Ingredient("twigs", 4)
    } or {
        Ingredient("cutgrass", 4), Ingredient("twigs", 4)
    },
    tech = TECH.NONE,
    config = {
        placer = nil,
        min_spacing = nil,
        nounlock = nil,
        numtogive = nil,
        builder_tag = nil,
        --atlas = "images/inventoryimages/mandrake_staff.xml",
        --image = "mandrake_staff.tex"
        atlas = "images/DLC0003/inventoryimages.xml",
        image = "pithhat.tex"
    },
    filters = {
        "MONE_MORE_ITEMS1"
    }
};

Recipes_Locate["mone_armor_metalplate"] = true;
Recipes[#Recipes + 1] = {
    CanMake = env.GetModConfigData("__armor_metalplate"),
    name = "mone_armor_metalplate",
    ingredients = {
        Ingredient("marble", 6), Ingredient("rope", 2)
    },
    tech = TECH.SCIENCE_TWO,
    config = {
        placer = nil,
        min_spacing = nil,
        nounlock = nil,
        numtogive = nil,
        builder_tag = nil,
        atlas = "images/DLC0003/inventoryimages.xml",
        image = "armor_metalplate.tex"
    },
    filters = {
        "MONE_MORE_ITEMS1"
    }
};

Recipes_Locate["mone_gashat"] = true;
Recipes[#Recipes + 1] = {
    CanMake = env.GetModConfigData("__gashat"),
    name = "mone_gashat",
    ingredients = BALANCE and {
        Ingredient("green_cap", 20), Ingredient("nightmarefuel", 6), Ingredient("silk", 8),
    } or {
        Ingredient("green_cap", 10), Ingredient("nightmarefuel", 3), Ingredient("silk", 4),
    },
    tech = TECH.SCIENCE_TWO,
    config = {
        placer = nil,
        min_spacing = nil,
        nounlock = nil,
        numtogive = nil,
        builder_tag = nil,
        atlas = "images/DLC0003/inventoryimages.xml",
        image = "gashat.tex"
    },
    filters = {
        "MONE_MORE_ITEMS1"
    }
};

Recipes_Locate["mone_double_umbrella"] = true;
Recipes[#Recipes + 1] = {
    CanMake = env.GetModConfigData("__double_umbrella"),
    name = "mone_double_umbrella",
    ingredients = BALANCE and {
        Ingredient("goose_feather", 25), Ingredient("umbrella", 1), Ingredient("strawhat", 1)
    } or {
        Ingredient("goose_feather", 15), Ingredient("umbrella", 1), Ingredient("strawhat", 1)
    },
    tech = TECH.SCIENCE_TWO,
    config = {
        placer = nil,
        min_spacing = nil,
        nounlock = nil,
        numtogive = nil,
        builder_tag = nil,
        atlas = "images/DLC0002/inventoryimages.xml",
        image = "double_umbrellahat.tex"
    },
    filters = {
        "MONE_MORE_ITEMS1"
    }
};

Recipes_Locate["mone_brainjelly"] = true;
Recipes[#Recipes + 1] = {
    CanMake = env.GetModConfigData("__brainjelly"),
    name = "mone_brainjelly",
    ingredients = BALANCE and {
        Ingredient("walrushat", 2), Ingredient("beefalohat", 2), Ingredient("beargervest", 2),
        Ingredient("greengem", 2), Ingredient("opalpreciousgem", 2)
    } or {
        Ingredient("walrushat", 1), Ingredient("beefalohat", 1), Ingredient("beargervest", 1),
        Ingredient("greengem", 1)
    },
    tech = TECH.SCIENCE_TWO,
    --tech = TECH.ANCIENT_TWO,
    config = {
        placer = nil,
        min_spacing = nil,
        nounlock = nil,
        numtogive = nil,
        builder_tag = nil,
        atlas = "images/DLC0002/inventoryimages.xml",
        image = "brainjellyhat.tex"
    },
    filters = {
        "MONE_MORE_ITEMS1"
        --"CRAFTING_STATION"
    }
};

Recipes_Locate["mone_bathat"] = true;
Recipes[#Recipes + 1] = {
    CanMake = env.GetModConfigData("__bathat"),
    name = "mone_bathat",
    ingredients = BALANCE and {
        Ingredient("batwing", 60), Ingredient("silk", 60)
    } or {
        Ingredient("batwing", 30), Ingredient("silk", 30),
    },
    --tech = TECH.NONE,
    tech = TECH.ANCIENT_TWO,
    config = {
        placer = nil,
        min_spacing = nil,
        nounlock = BALANCE and true or nil,
        numtogive = nil,
        builder_tag = nil,
        atlas = "images/DLC0003/inventoryimages.xml",
        image = "bathat.tex"
    },
    filters = BALANCE and {
        "CRAFTING_STATION"
    } or {
        "MONE_MORE_ITEMS1"
    }
};

-- TODO: Recipes 应该分担给 prefabs 中的文件吧？还是说饥荒其实不同人复杂不同内容...
Recipes_Locate["mone_single_dog"] = true;
Recipes[#Recipes + 1] = {
    CanMake = env.GetModConfigData("__single_dog"),
    name = "mone_single_dog",
    ingredients = {
        Ingredient("greengem", 1),
        Ingredient("houndstooth", 200)
    },
    tech = TECH.SCIENCE_TWO,
    config = {
        placer = "mone_single_dog_placer",
        min_spacing = 1,
        nounlock = nil,
        numtogive = nil,
        builder_tag = nil,
        atlas = "images/inventoryimages1.xml",
        image = "chesspiece_clayhound.tex"
    },
    filters = {
        "MONE_MORE_ITEMS2"
    }
};

Recipes_Locate["mone_bookstation"] = true;
Recipes[#Recipes + 1] = {
    CanMake = env.GetModConfigData("__bookstation"),
    name = "mone_bookstation",
    ingredients = {
        Ingredient("livinglog", 2), Ingredient("papyrus", 4), Ingredient("featherpencil", 1),
        Ingredient("greengem", 1)
    },
    --tech = TECH.NONE,
    tech = TECH.SCIENCE_TWO,
    config = {
        placer = nil,
        min_spacing = nil,
        nounlock = nil,
        numtogive = nil,
        --builder_tag = "bookbuilder",
        atlas = "images/DLC/inventoryimages1.xml",
        image = "bookstation.tex"
    },
    filters = {
        --"CHARACTER"
        "MONE_MORE_ITEMS2"
    }
};

Recipes_Locate["mone_wathgrithr_box"] = true;
Recipes[#Recipes + 1] = {
    CanMake = env.GetModConfigData("__wathgrithr_box"),
    name = "mone_wathgrithr_box",
    ingredients = {
        Ingredient("wathgrithrhat", 2), Ingredient("papyrus", 2), Ingredient("featherpencil", 2)
    },
    tech = TECH.NONE,
    config = {
        placer = nil,
        min_spacing = nil,
        nounlock = nil,
        numtogive = nil,
        builder_tag = "battlesinger",
        atlas = "images/inventoryimages/mone_wathgrithr_box.xml",
        image = "mone_wathgrithr_box.tex"
    },
    filters = {
        "CHARACTER"
    }
};

Recipes_Locate["mone_wanda_box"] = true;
Recipes[#Recipes + 1] = {
    CanMake = env.GetModConfigData("__wanda_box"),
    name = "mone_wanda_box",
    ingredients = {
        Ingredient("twigs", 12), Ingredient("cutgrass", 12), Ingredient("goldnugget", 4)
    },
    tech = TECH.NONE,
    config = {
        placer = nil,
        min_spacing = nil,
        nounlock = nil,
        numtogive = nil,
        builder_tag = "clockmaker",
        atlas = "images/inventoryimages/mone_wanda_box.xml",
        image = "mone_wanda_box.tex"
    },
    filters = {
        "CHARACTER"
    }
};

Recipes_Locate["mone_storage_bag"] = true;
Recipes[#Recipes + 1] = {
    CanMake = env.GetModConfigData("__storage_bag"),
    name = "mone_storage_bag",
    ingredients = BALANCE and {
        Ingredient("papyrus", 30), Ingredient("petals", 30), Ingredient("purplegem", 6)
    } or {
        Ingredient("papyrus", 20), Ingredient("petals", 20)
    },
    tech = TECH.SCIENCE_TWO,
    config = {
        placer = nil,
        min_spacing = nil,
        nounlock = nil,
        numtogive = nil,
        builder_tag = nil,
        atlas = "images/DLC0002/inventoryimages.xml",
        image = "thatchpack.tex"
    },
    filters = {
        "MONE_MORE_ITEMS1"
    }
};

Recipes_Locate["mone_tool_bag"] = true;
Recipes[#Recipes + 1] = {
    CanMake = env.GetModConfigData("__tool_bag"),
    name = "mone_tool_bag",
    ingredients = BALANCE and {
        Ingredient("cutgrass", 12), Ingredient("twigs", 12), Ingredient("goldnugget", 4),
    } or {
        Ingredient("cutgrass", 6), Ingredient("twigs", 6)
    },
    tech = TECH.SCIENCE_ONE,
    config = {
        placer = nil,
        min_spacing = nil,
        nounlock = nil,
        numtogive = nil,
        builder_tag = nil,
        atlas = "images/inventoryimages/mandrake_backpack.xml",
        image = "mandrake_backpack.tex"
    },
    filters = {
        "MONE_MORE_ITEMS1"
    }
};

Recipes_Locate["mone_piggybag"] = true;
Recipes[#Recipes + 1] = {
    CanMake = env.GetModConfigData("__piggybag"),
    name = "mone_piggybag",
    ingredients = BALANCE and {
        Ingredient("pigskin", 15)
    } or {
        Ingredient("pigskin", 10)
    },
    tech = TECH.SCIENCE_TWO,
    config = {
        placer = nil,
        min_spacing = nil,
        nounlock = nil,
        numtogive = nil,
        builder_tag = nil,
        atlas = "images/inventoryimages/mone_piggybag.xml",
        image = "mone_piggybag.tex"
    },
    filters = {
        "MONE_MORE_ITEMS1"
    }
};

Recipes_Locate["mone_waterchest_inv"] = true;
Recipes[#Recipes + 1] = {
    CanMake = env.GetModConfigData("__waterchest"),
    name = "mone_waterchest_inv",
    ingredients = BALANCE and {
        Ingredient("boards", 40), Ingredient("bluegem", 20), Ingredient("redgem", 20), Ingredient("minotaurhorn", 2)
    } or {
        Ingredient("boards", 20), Ingredient("bluegem", 10), Ingredient("minotaurhorn", 1)
    },
    tech = TECH.ANCIENT_TWO,
    config = {
        placer = nil,
        min_spacing = nil,
        nounlock = BALANCE and true or nil, -- 所以这个到底啥意思？nounlock？锁住？感觉没啥用呀。
        numtogive = nil,
        builder_tag = nil,
        atlas = "images/DLC0002/inventoryimages.xml",
        image = "waterchest.tex"
    },
    filters = BALANCE and {
        "CRAFTING_STATION"
    } or {
        "MONE_MORE_ITEMS1"
    }
};

local new_anim = config_data.mone_seasack_new_anim;
Recipes_Locate["mone_seasack"] = true;
Recipes[#Recipes + 1] = {
    CanMake = env.GetModConfigData("__seasack"),
    name = "mone_seasack",
    ingredients = BALANCE and {
        Ingredient("kelp", 40), Ingredient("rope", 10)
    } or {
        Ingredient("kelp", 20), Ingredient("rope", 5)
    },
    tech = TECH.SCIENCE_TWO,
    config = {
        placer = nil,
        min_spacing = nil,
        nounlock = nil,
        numtogive = nil,
        builder_tag = nil,
        atlas = new_anim and "images/DLC/inventoryimages.xml" or "images/DLC0003/inventoryimages.xml",
        image = new_anim and "krampus_sack.tex" or "seasack.tex"
    },
    filters = {
        "MONE_MORE_ITEMS1"
    }
};

Recipes_Locate["mone_nightspace_cape"] = true;
Recipes[#Recipes + 1] = {
    CanMake = env.GetModConfigData("__nightspace_cape"),
    name = "mone_nightspace_cape",
    ingredients = {
        Ingredient("armorskeleton", 2), Ingredient("malbatross_feather", 20), Ingredient("greengem", 2)
    },
    tech = TECH.SCIENCE_TWO,
    config = {
        placer = nil,
        min_spacing = nil,
        nounlock = nil,
        numtogive = nil,
        builder_tag = nil,
        atlas = "images/inventoryimages/ndnr_armorvortexcloak.xml",
        image = "ndnr_armorvortexcloak.tex"
    },
    filters = {
        "MONE_MORE_ITEMS1"
    }
};

Recipes_Locate["mone_skull_chest"] = true;
Recipes[#Recipes + 1] = {
    CanMake = env.GetModConfigData("__skull_chest"),
    name = "mone_skull_chest",
    ingredients = {
        Ingredient("boards", 3)
    },
    tech = TECH.SCIENCE_ONE,
    config = {
        placer = "mone_skull_chest_placer",
        min_spacing = 1,
        nounlock = nil,
        numtogive = nil,
        builder_tag = nil,
        atlas = "images/modules/architect_pack/tap_buildingimages.xml",
        image = "kyno_skullchest.tex"
    },
    filters = {
        "MONE_MORE_ITEMS1"
    }
};

Recipes_Locate["mone_chiminea"] = true;
Recipes[#Recipes + 1] = {
    CanMake = env.GetModConfigData("__chiminea"),
    name = "mone_chiminea",
    ingredients = BALANCE and {
        Ingredient("boards", 4), Ingredient("cutstone", 2)
    } or {
        Ingredient("boards", 2), Ingredient("cutstone", 1)
    },
    tech = TECH.SCIENCE_ONE,
    config = {
        placer = "mone_chiminea_placer",
        min_spacing = nil,
        nounlock = nil,
        numtogive = nil,
        builder_tag = nil,
        atlas = "images/DLC0002/inventoryimages.xml",
        image = "chiminea.tex"
    },
    filters = {
        "MONE_MORE_ITEMS1"
    }
};

Recipes_Locate["mone_arborist"] = true;
Recipes[#Recipes + 1] = {
    CanMake = env.GetModConfigData("__arborist"),
    name = "mone_arborist",
    ingredients = BALANCE and {
        Ingredient("pinecone", 20), Ingredient("acorn", 20), Ingredient("marblebean", 10)
    } or {
        Ingredient("pinecone", 10), Ingredient("acorn", 10), Ingredient("marblebean", 5)
    },
    tech = TECH.SCIENCE_TWO,
    config = {
        placer = "mone_arborist_placer",
        min_spacing = nil,
        nounlock = nil,
        numtogive = nil,
        builder_tag = nil,
        atlas = "images/DLC0002/inventoryimages.xml",
        image = "sand_castle.tex"
    },
    filters = {
        "MONE_MORE_ITEMS1"
    }
};

Recipes_Locate["mone_city_lamp"] = true;
Recipes[#Recipes + 1] = {
    CanMake = env.GetModConfigData("__city_lamp"),
    name = "mone_city_lamp",
    ingredients = BALANCE and {
        Ingredient("lantern", 1), Ingredient("transistor", 2), Ingredient("cutstone", 2)
    } or {
        Ingredient("lantern", 1), Ingredient("transistor", 1), Ingredient("cutstone", 1)
    },
    tech = TECH.SCIENCE_TWO,
    config = {
        placer = "mone_city_lamp_placer",
        min_spacing = 1,
        nounlock = nil,
        numtogive = nil,
        builder_tag = nil,
        atlas = "images/DLC0003/inventoryimages.xml",
        image = "city_lamp.tex"
    },
    filters = {
        "MONE_MORE_ITEMS1"
    }
};

local pheromone_tech = TECH.ANCIENT_TWO;
if config_data.pheromone_stone_balance then
    pheromone_tech = TECH.LUNARFORGING_TWO;
end

Recipes_Locate["mone_pheromonestone"] = true;
Recipes[#Recipes + 1] = {
    CanMake = env.GetModConfigData("__pheromonestone"),
    name = "mone_pheromonestone",
    ingredients = BALANCE and {
        Ingredient("opalpreciousgem", 2), Ingredient("greengem", 4),
        Ingredient("bluegem", 20), Ingredient("redgem", 20),
    } or {
        Ingredient("greengem", 2),
        Ingredient("bluegem", 10), Ingredient("redgem", 10),
    },
    tech = pheromone_tech,
    config = {
        placer = nil,
        min_spacing = nil,
        nounlock = BALANCE and true or nil,
        numtogive = nil,
        builder_tag = nil,
        atlas = "images/DLC0003/inventoryimages.xml",
        image = "pheromonestone.tex"
    },
    filters = BALANCE and {
        "CRAFTING_STATION"
    } or {
        "MONE_MORE_ITEMS1"
    }
};

Recipes_Locate["mone_pheromonestone2"] = true;
Recipes[#Recipes + 1] = {
    CanMake = env.GetModConfigData("__pheromonestone2"),
    name = "mone_pheromonestone2",
    ingredients = BALANCE and {
        Ingredient("opalpreciousgem", 3), Ingredient("greengem", 4),
        Ingredient("orangegem", 10), Ingredient("yellowgem", 10),
    } or {
        Ingredient("opalpreciousgem", 1), Ingredient("greengem", 2),
        Ingredient("orangegem", 5), Ingredient("yellowgem", 5),
    },
    tech = pheromone_tech,
    config = {
        placer = nil,
        min_spacing = nil,
        nounlock = BALANCE and true or nil,
        numtogive = nil,
        builder_tag = nil,
        atlas = "images/DLC0003/inventoryimages.xml",
        image = "relic_5.tex"
    },
    filters = BALANCE and {
        "CRAFTING_STATION"
    } or {
        "MONE_MORE_ITEMS1"
    }
};

Recipes_Locate["mone_walking_stick"] = true;
Recipes[#Recipes + 1] = {
    CanMake = env.GetModConfigData("__walking_stick"),
    name = "mone_walking_stick",
    ingredients = BALANCE and {
        Ingredient("cutgrass", 4), Ingredient("twigs", 4), Ingredient("goldnugget", 2)
    } or {
        Ingredient("cutgrass", 4), Ingredient("twigs", 4), Ingredient("goldnugget", 2)
    },
    tech = TECH.SCIENCE_TWO,
    config = {
        placer = nil,
        min_spacing = nil,
        nounlock = nil,
        numtogive = nil,
        builder_tag = nil,
        atlas = "images/DLC0003/inventoryimages_2.xml",
        image = "walkingstick.tex"
    },
    filters = {
        "MONE_MORE_ITEMS1"
    }
};


--Recipes_Locate["mone_empty_prefab"] = true;
--Recipes[#Recipes + 1] = {
--    CanMake = true;
--    name = "mone_empty_prefab",
--    ingredients = {
--        Ingredient("goldnugget",1) -- 加个可以制作吧，不然玩家一点就全局访问了。。。
--    },
--    tech = TECH.NONE,
--    config = {
--        placer = nil,
--        min_spacing = nil,
--        nounlock = nil,
--        numtogive = nil,
--        builder_tag = nil,
--        atlas = "images/inventoryimages1.xml",
--        image = "balloonparty.tex" -- "balloonparty.tex" -- "nightmare_timepiece_warn.tex" -- "nightmare_timepiece.tex"
--    },
--    filters = {
--        "MONE_MORE_ITEMS1"
--    }
--};
---------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------

Recipes_Locate["mone_waterballoon"] = true;
Recipes[#Recipes + 1] = {
    CanMake = env.GetModConfigData("__waterballoon"),
    name = "mone_waterballoon",
    ingredients = {
        Ingredient("greengem", 1)
    },
    tech = TECH.SCIENCE_TWO,
    config = {
        placer = nil,
        min_spacing = nil,
        nounlock = nil,
        numtogive = 6,
        builder_tag = nil,
        atlas = "images/inventoryimages.xml",
        image = "waterballoon.tex"
    },
    filters = {
        "MONE_MORE_ITEMS2"
    }
};

Recipes_Locate["mone_boomerang"] = true;
Recipes[#Recipes + 1] = {
    CanMake = env.GetModConfigData("__boomerang"),
    name = "mone_boomerang",
    ingredients = {
        Ingredient("boomerang", 1), Ingredient("greengem", 1)
        --Ingredient("boards", 1), Ingredient("silk", 1), Ingredient("charcoal", 1),
        --Ingredient("greengem", 1)
    },
    tech = TECH.SCIENCE_TWO,
    config = {
        placer = nil,
        min_spacing = nil,
        nounlock = nil,
        numtogive = 1,
        builder_tag = nil,
        atlas = "images/DLC/inventoryimages.xml", -- inventoryimages2
        image = "boomerang.tex"
    },
    filters = {
        "MONE_MORE_ITEMS2"
    }
};

Recipes_Locate["mone_orangestaff"] = true;
Recipes[#Recipes + 1] = {
    CanMake = env.GetModConfigData("__telestaff"),
    name = "mone_orangestaff",
    ingredients = BALANCE and {
        Ingredient("orangestaff", 1), Ingredient("greengem", 1), Ingredient("nightmarefuel", 40)
    } or {
        Ingredient("orangestaff", 1), Ingredient("greengem", 1), Ingredient("nightmarefuel", 40)
    },
    tech = TECH.SCIENCE_TWO,
    config = {
        placer = nil,
        min_spacing = nil,
        nounlock = nil,
        numtogive = 1,
        builder_tag = nil,
        atlas = "images/DLC/inventoryimages.xml", -- inventoryimages2
        image = "orangestaff.tex"
    },
    filters = {
        "MONE_MORE_ITEMS2"
    }
};

Recipes_Locate["mone_eyemaskhat"] = true;
Recipes[#Recipes + 1] = {
    CanMake = env.GetModConfigData("__terraria"),
    name = "mone_eyemaskhat",
    ingredients = {
        Ingredient("eyemaskhat", 1), Ingredient("purplegem", 4), Ingredient("greengem", 2)
    },
    tech = TECH.SCIENCE_TWO,
    config = {
        placer = nil,
        min_spacing = nil,
        nounlock = nil,
        numtogive = 1,
        builder_tag = nil,
        atlas = "images/DLC/inventoryimages1.xml", -- inventoryimages2
        image = "eyemaskhat.tex"
    },
    filters = {
        "MONE_MORE_ITEMS2"
    }
};

Recipes_Locate["mone_shieldofterror"] = true;
Recipes[#Recipes + 1] = {
    CanMake = env.GetModConfigData("__terraria"),
    name = "mone_shieldofterror",
    ingredients = {
        Ingredient("shieldofterror", 1), Ingredient("purplegem", 8), Ingredient("greengem", 2)
    },
    tech = TECH.SCIENCE_TWO,
    config = {
        placer = nil,
        min_spacing = nil,
        nounlock = nil,
        numtogive = 1,
        builder_tag = nil,
        atlas = "images/DLC/inventoryimages2.xml",
        image = "shieldofterror.tex"
    },
    filters = {
        "MONE_MORE_ITEMS2"
    }
};

Recipes_Locate["mone_fishingnet"] = true;
Recipes[#Recipes + 1] = {
    CanMake = env.GetModConfigData("__fishingnet"),
    name = "mone_fishingnet",
    ingredients = {
        Ingredient("rope", 2), Ingredient("silk", 3)
    },
    tech = TECH.SCIENCE_TWO,
    config = {
        placer = nil,
        min_spacing = nil,
        nounlock = nil,
        numtogive = 1,
        builder_tag = nil,
        atlas = "images/modules/uc/inventoryimages/uncompromising_fishingnet.xml",
        image = "uncompromising_fishingnet.tex"
    },
    filters = {
        "MONE_MORE_ITEMS2"
    }
};

Recipes_Locate["mone_farm_plow_item"] = true;
Recipes[#Recipes + 1] = {
    CanMake = env.GetModConfigData("__farm_plow"),
    name = "mone_farm_plow_item",
    ingredients = {
        Ingredient("twigs", 4), Ingredient("goldnugget", 2)
    },
    tech = TECH.SCIENCE_TWO,
    config = {
        placer = nil,
        min_spacing = nil,
        nounlock = nil,
        numtogive = 1,
        builder_tag = nil,
        atlas = "images/inventoryimages1.xml",
        image = "farm_plow_item.tex"
    },
    filters = {
        "MONE_MORE_ITEMS2"
    }
};

Recipes_Locate["mone_backpack"] = true;
Recipes[#Recipes + 1] = {
    CanMake = env.GetModConfigData("__backpack"),
    name = "mone_backpack",
    ingredients = BALANCE and {
        Ingredient("cutgrass", 12), Ingredient("twigs", 12), Ingredient("goldnugget", 4),
    } or {
        Ingredient("cutgrass", 6), Ingredient("twigs", 6)
    },
    tech = TECH.SCIENCE_ONE,
    config = {
        placer = nil,
        min_spacing = nil,
        nounlock = nil,
        numtogive = nil,
        builder_tag = nil,
        atlas = "images/inventoryimages1.xml",
        image = "backpack.tex"
    },
    filters = {
        "MONE_MORE_ITEMS2"
    }
};

Recipes_Locate["mone_piggyback"] = true;
Recipes[#Recipes + 1] = {
    CanMake = env.GetModConfigData("__piggyback"),
    name = "mone_piggyback",
    ingredients = BALANCE and {
        Ingredient("pigskin", 30), Ingredient("silk", 30), Ingredient("rope", 30)
    } or {
        Ingredient("pigskin", 20), Ingredient("silk", 20), Ingredient("rope", 20)
    },
    tech = TECH.SCIENCE_TWO,
    config = {
        placer = nil,
        min_spacing = nil,
        nounlock = nil,
        numtogive = nil,
        builder_tag = nil,
        atlas = "images/inventoryimages.xml",
        image = "piggyback.tex"
    },
    filters = {
        "MONE_MORE_ITEMS2"
    }
};

Recipes_Locate["mone_candybag"] = true;
Recipes[#Recipes + 1] = {
    CanMake = env.GetModConfigData("__candybag"),
    name = "mone_candybag",
    ingredients = BALANCE and {
        Ingredient("cutgrass", 12), Ingredient("twigs", 12), Ingredient("goldnugget", 4),
    } or {
        Ingredient("cutgrass", 6), Ingredient("twigs", 6)
    },
    --ingredients = BALANCE and {
    --    Ingredient("cutgrass", 15),
    --    Ingredient("twigs", 15),
    --    Ingredient("flint", 15),
    --    Ingredient("rocks", 15),
    --    Ingredient("log", 15),
    --} or {
    --    Ingredient("cutgrass", 10),
    --    Ingredient("twigs", 10),
    --    Ingredient("flint", 10),
    --    Ingredient("rocks", 10),
    --    Ingredient("log", 10),
    --},
    tech = TECH.SCIENCE_ONE,
    config = {
        placer = nil,
        min_spacing = nil,
        nounlock = nil,
        numtogive = nil,
        builder_tag = nil,
        atlas = "images/inventoryimages.xml",
        image = "candybag.tex"
    },
    filters = {
        "MONE_MORE_ITEMS2"
    }
};

Recipes_Locate["mone_icepack"] = true;
Recipes[#Recipes + 1] = {
    CanMake = env.GetModConfigData("__icepack"),
    name = "mone_icepack",
    ingredients = BALANCE and {
        Ingredient("goldnugget", 8), Ingredient("gears", 4), Ingredient("furtuft", 30)
    } or {
        Ingredient("goldnugget", 4), Ingredient("gears", 2), Ingredient("furtuft", 30)
    },
    tech = TECH.SCIENCE_TWO,
    config = {
        placer = nil,
        min_spacing = nil,
        nounlock = nil,
        numtogive = nil,
        builder_tag = nil,
        atlas = "images/inventoryimages.xml",
        image = "icepack.tex"
    },
    filters = {
        "MONE_MORE_ITEMS2"
    }
};

Recipes_Locate["mone_seedpouch"] = true;
Recipes[#Recipes + 1] = {
    CanMake = env.GetModConfigData("__mone_seedpouch"),
    name = "mone_seedpouch",
    ingredients = BALANCE and {
        Ingredient("bundlewrap", 5), Ingredient("gears", 4), Ingredient("seeds", 30),
        Ingredient("goldnugget", 10)
    } or {
        Ingredient("bundlewrap", 5), Ingredient("gears", 4), Ingredient("seeds", 30),
        Ingredient("goldnugget", 10)
    },
    tech = TECH.SCIENCE_TWO,
    config = {
        placer = nil,
        min_spacing = nil,
        nounlock = nil,
        numtogive = nil,
        builder_tag = nil,
        atlas = "images/inventoryimages2.xml",
        image = "seedpouch.tex"
    },
    filters = {
        "MONE_MORE_ITEMS2"
    }
};

local MCB_capability = TUNING.MONE_TUNING.GET_MOD_CONFIG_DATA.mone_chests_boxs_capability;

local mone_treasurechest_ingredients = { Ingredient("boards", 6) };
if MCB_capability == 2 then
    mone_treasurechest_ingredients = { Ingredient("boards", 9) }
elseif MCB_capability == 3 then
    mone_treasurechest_ingredients = { Ingredient("boards", 12) }
end

Recipes_Locate["mone_treasurechest"] = true;
Recipes[#Recipes + 1] = {
    CanMake = env.GetModConfigData("__chests_boxs"),
    name = "mone_treasurechest",
    ingredients = mone_treasurechest_ingredients,
    tech = TECH.SCIENCE_ONE,
    config = {
        placer = "mone_treasurechest_placer",
        min_spacing = 1,
        nounlock = nil,
        numtogive = nil,
        builder_tag = nil,
        atlas = "images/inventoryimages.xml",
        image = "treasurechest.tex"
    },
    filters = {
        "MONE_MORE_ITEMS2"
    }
};

local mone_dragonflychest_ingredients = { Ingredient("dragon_scales", 1), Ingredient("boards", 6), Ingredient("goldnugget", 10) };
if MCB_capability == 2 then
    mone_dragonflychest_ingredients = { Ingredient("dragon_scales", 2), Ingredient("boards", 8), Ingredient("goldnugget", 20) }
elseif MCB_capability == 3 then
    mone_dragonflychest_ingredients = { Ingredient("dragon_scales", 3), Ingredient("boards", 10), Ingredient("goldnugget", 30) }
end

Recipes_Locate["mone_dragonflychest"] = true;
Recipes[#Recipes + 1] = {
    CanMake = env.GetModConfigData("__chests_boxs"),
    name = "mone_dragonflychest",
    ingredients = mone_dragonflychest_ingredients,
    tech = TECH.SCIENCE_TWO,
    config = {
        placer = "mone_dragonflychest_placer",
        min_spacing = 1.5,
        nounlock = nil,
        numtogive = nil,
        builder_tag = nil,
        atlas = "images/inventoryimages.xml",
        image = "dragonflychest.tex"
    },
    filters = {
        "MONE_MORE_ITEMS2"
    }
};

local mone_icebox_ingredients = { Ingredient("goldnugget", 4), Ingredient("gears", 2), Ingredient("cutstone", 2) };
if MCB_capability == 2 then
    mone_icebox_ingredients = { Ingredient("goldnugget", 6), Ingredient("gears", 3), Ingredient("cutstone", 3) }
elseif MCB_capability == 3 then
    mone_icebox_ingredients = { Ingredient("goldnugget", 8), Ingredient("gears", 4), Ingredient("cutstone", 4) }
end

Recipes_Locate["mone_icebox"] = true;
Recipes[#Recipes + 1] = {
    CanMake = env.GetModConfigData("__chests_boxs"),
    name = "mone_icebox",
    ingredients = mone_icebox_ingredients,
    tech = TECH.SCIENCE_TWO,
    config = {
        placer = "mone_icebox_placer",
        min_spacing = 1.5,
        nounlock = nil,
        numtogive = nil,
        builder_tag = nil,
        atlas = "images/inventoryimages.xml",
        image = "icebox.tex"
    },
    filters = {
        "MONE_MORE_ITEMS2"
    }
};

local mone_saltbox_ingredients = { Ingredient("saltrock", 20), Ingredient("bluegem", 2), Ingredient("cutstone", 2) };
if MCB_capability == 2 then
    mone_saltbox_ingredients = { Ingredient("saltrock", 30), Ingredient("bluegem", 3), Ingredient("cutstone", 3) }
elseif MCB_capability == 3 then
    mone_saltbox_ingredients = { Ingredient("saltrock", 40), Ingredient("bluegem", 4), Ingredient("cutstone", 4) }
end

Recipes_Locate["mone_saltbox"] = true;
Recipes[#Recipes + 1] = {
    CanMake = env.GetModConfigData("__chests_boxs"),
    name = "mone_saltbox",
    ingredients = mone_saltbox_ingredients,
    tech = TECH.SCIENCE_TWO,
    config = {
        placer = "mone_saltbox_placer",
        min_spacing = 1.5,
        nounlock = nil,
        numtogive = nil,
        builder_tag = nil,
        atlas = "images/inventoryimages2.xml",
        image = "saltbox.tex"
    },
    filters = {
        "MONE_MORE_ITEMS2"
    }
};

Recipes_Locate["mone_firesuppressor"] = true;
Recipes[#Recipes + 1] = {
    CanMake = env.GetModConfigData("__firesuppressor"),
    name = "mone_firesuppressor",
    ingredients = BALANCE and {
        Ingredient("gears", 2), Ingredient("transistor", 2), Ingredient("boards", 10)
    } or {
        Ingredient("gears", 2), Ingredient("transistor", 2), Ingredient("boards", 10)
    },
    tech = TECH.SCIENCE_TWO,
    config = {
        placer = "mone_firesuppressor_placer",
        min_spacing = nil,
        nounlock = nil,
        numtogive = nil,
        builder_tag = nil,
        atlas = "images/inventoryimages.xml",
        image = "firesuppressor.tex"
    },
    filters = {
        "MONE_MORE_ITEMS2"
    }
};

Recipes_Locate["mone_dragonflyfurnace"] = true;
Recipes[#Recipes + 1] = {
    CanMake = env.GetModConfigData("__dragonflyfurnace"),
    name = "mone_dragonflyfurnace",
    ingredients = {
        Ingredient("redmooneye", 1), Ingredient("redgem", 2), Ingredient("charcoal", 10)
    },
    tech = TECH.SCIENCE_TWO,
    config = {
        placer = "mone_dragonflyfurnace_placer",
        min_spacing = nil,
        nounlock = nil,
        numtogive = nil,
        builder_tag = nil,
        atlas = "images/inventoryimages1.xml",
        image = "dragonflyfurnace.tex"
    },
    filters = {
        "MONE_MORE_ITEMS2"
    }
};

Recipes_Locate["mone_moondial"] = true;
Recipes[#Recipes + 1] = {
    CanMake = env.GetModConfigData("__moondial"),
    name = "mone_moondial",
    ingredients = BALANCE and {
        Ingredient("bluemooneye", 1), Ingredient("bluegem", 2), Ingredient("ice", 10)
    } or {
        Ingredient("bluemooneye", 1), Ingredient("bluegem", 2), Ingredient("ice", 10)
    },
    tech = TECH.SCIENCE_TWO,
    config = {
        placer = "mone_moondial_placer",
        min_spacing = nil,
        nounlock = nil,
        numtogive = nil,
        builder_tag = nil,
        atlas = "images/inventoryimages.xml",
        image = "moondial.tex"
    },
    filters = {
        "MONE_MORE_ITEMS2"
    }
};

Recipes_Locate["mone_wardrobe"] = true;
Recipes[#Recipes + 1] = {
    CanMake = env.GetModConfigData("__wardrobe"),
    name = "mone_wardrobe",
    ingredients = BALANCE and {
        Ingredient("boards", 12), Ingredient("cutgrass", 3)
    } or {
        Ingredient("boards", 12), Ingredient("cutgrass", 3)
    },
    tech = TECH.SCIENCE_TWO,
    config = {
        placer = "mone_wardrobe_placer",
        min_spacing = 1.5,
        nounlock = nil,
        numtogive = nil,
        builder_tag = nil,
        atlas = "images/inventoryimages.xml",
        image = "wardrobe.tex"
    },
    filters = {
        "MONE_MORE_ITEMS2"
    }
};

--Recipes_Locate["mone_fish_box"] = true;
--Recipes[#Recipes + 1] = {
--    CanMake = env.GetModConfigData("__fish_box") ,
--    name = "mone_fish_box",
--    ingredients = {
--        Ingredient("bearger_fur", 1), Ingredient("cutreeds", 40), Ingredient("rope", 10),
--    },
--    tech = TECH.SCIENCE_TWO,
--    config = {
--        placer = "mone_fish_box_placer",
--        min_spacing = 1.5,
--        nounlock = nil,
--        numtogive = nil,
--        builder_tag = nil,
--        atlas = "images/inventoryimages1.xml",
--        image = "fish_box.tex",
--        --testfn = function(pt)
--        --    local ents = TheWorld.Map:GetEntitiesOnTileAtPoint(pt.x, 0, pt.z)
--        --    for _, ent in ipairs(ents) do
--        --        if not ent:HasTag("player") and not (ent:HasTag("NOBLOCK") or ent:HasTag("locomotor") or ent:HasTag("NOCLICK") or ent:HasTag("FX") or ent:HasTag("DECOR")) then
--        --            return false
--        --        end
--        --    end
--        --    return true
--        --end
--    },
--    filters = {
--        "MONE_MORE_ITEMS2"
--    }
--};

Recipes_Locate["mone_garlic_structure"] = true;
Recipes[#Recipes + 1] = {
    CanMake = env.GetModConfigData("__garlic_structure"),
    name = "mone_garlic_structure",
    ingredients = BALANCE and {
        Ingredient("garlic", 5), Ingredient("garlic_seeds", 3), Ingredient("beeswax", 1)
    } or {
        Ingredient("garlic", 5), Ingredient("garlic_seeds", 3), Ingredient("beeswax", 1)
    },
    tech = TECH.SCIENCE_TWO,
    config = {
        placer = "mone_garlic_structure_placer",
        min_spacing = nil,
        nounlock = nil,
        numtogive = nil,
        builder_tag = nil,
        atlas = "images/inventoryimages/garlic_bat.xml",
        image = "garlic_bat.tex"
    },
    filters = {
        "MONE_MORE_ITEMS2"
    }
};


--Recipes_Locate["mone_beef_bell"] = true;
--Recipes[#Recipes + 1] = {
--    CanMake = env.GetModConfigData("__beef_bell") ,
--    name = "mone_beef_bell",
--    ingredients = {
--        Ingredient("goldnugget", 15), Ingredient("flint", 5)
--    },
--    tech = TECH.NONE,
--    config = {
--        placer = nil,
--        min_spacing = nil,
--        nounlock = nil,
--        numtogive = 1,
--        builder_tag = nil,
--        atlas = "images/inventoryimages1.xml",
--        image = "beef_bell.tex"
--    },
--    filters = {
--        "MONE_MORE_ITEMS2"
--    }
--};

---------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------

Recipes_Locate["mone_chicken_soup"] = true;
Recipes[#Recipes + 1] = {
    CanMake = env.GetModConfigData("__mone_chicken_soup"),
    name = "mone_chicken_soup",
    ingredients = BALANCE and {
        Ingredient("drumstick", 1)
    } or {
        Ingredient("drumstick", 1)
    },
    tech = TECH.SCIENCE_TWO,
    config = {
        placer = nil,
        min_spacing = nil,
        nounlock = nil,
        numtogive = 1,
        builder_tag = nil,
        atlas = "images/foodimages/mone_chicken_soup.xml",
        image = "mone_chicken_soup.tex"
    },
    filters = {
        --"MONE_MORE_ITEMS3"
        "MONE_MORE_ITEMS2"
    }
};

Recipes_Locate["mone_lifeinjector_vb"] = true;
Recipes[#Recipes + 1] = {
    CanMake = env.GetModConfigData("__mone_lifeinjector_vb"),
    name = "mone_lifeinjector_vb",
    ingredients = BALANCE and {
        Ingredient("spoiled_food", 10 * constants.LIFE_INJECTOR_VB__PER_ADD_NUM) -- 20
    } or {
        Ingredient("spoiled_food", 5 * constants.LIFE_INJECTOR_VB__PER_ADD_NUM)
    },
    tech = TECH.NONE,
    config = {
        placer = nil,
        min_spacing = nil,
        nounlock = nil,
        numtogive = 1,
        builder_tag = nil,
        atlas = "images/foodimages/mone_lifeinjector_vb.xml",
        image = "mone_lifeinjector_vb.tex"
    },
    filters = {
        --"MONE_MORE_ITEMS3"
        "MONE_MORE_ITEMS1"
    }
};

Recipes[#Recipes + 1] = {
    CanMake = env.GetModConfigData("__mone_lifeinjector_vb"),
    name = "mone_lifeinjector_vb_copy",
    ingredients = BALANCE and {
        Ingredient("spoiled_food", 100 * constants.LIFE_INJECTOR_VB__PER_ADD_NUM)
    } or {
        Ingredient("spoiled_food", 50 * constants.LIFE_INJECTOR_VB__PER_ADD_NUM)
    },
    tech = TECH.NONE,
    config = {
        product = "mone_lifeinjector_vb",
        placer = nil,
        min_spacing = nil,
        nounlock = nil,
        numtogive = 10,
        builder_tag = nil,
        atlas = "images/foodimages/mone_lifeinjector_vb.xml",
        image = "mone_lifeinjector_vb.tex"
    },
    filters = {
        --"MONE_MORE_ITEMS3"
        "MONE_MORE_ITEMS1"
    }
};

Recipes_Locate["mone_stomach_warming_hamburger"] = true;
Recipes[#Recipes + 1] = {
    CanMake = env.GetModConfigData("__mone_stomach_warming_hamburger"),
    name = "mone_stomach_warming_hamburger",
    ingredients = BALANCE and {
        Ingredient("spoiled_food", 5)
    } or {
        Ingredient("spoiled_food", 5)
    },
    tech = TECH.NONE,
    config = {
        placer = nil,
        min_spacing = nil,
        nounlock = nil,
        numtogive = 1,
        builder_tag = nil,
        atlas = "images/foodimages/bs_food_33.xml",
        image = "bs_food_33.tex"
    },
    filters = {
        --"MONE_MORE_ITEMS3"
        "MONE_MORE_ITEMS1"
    }
};
Recipes[#Recipes + 1] = {
    CanMake = env.GetModConfigData("__mone_stomach_warming_hamburger"),
    name = "mone_stomach_warming_hamburger_copy",
    ingredients = BALANCE and {
        Ingredient("spoiled_food", 50)
    } or {
        Ingredient("spoiled_food", 50)
    },
    tech = TECH.NONE,
    config = {
        product = "mone_stomach_warming_hamburger",
        placer = nil,
        min_spacing = nil,
        nounlock = nil,
        numtogive = 10,
        builder_tag = nil,
        atlas = "images/foodimages/bs_food_33.xml",
        image = "bs_food_33.tex"
    },
    filters = {
        --"MONE_MORE_ITEMS3"
        "MONE_MORE_ITEMS1"
    }
};

Recipes_Locate["mone_glommer_poop_food"] = true;
Recipes[#Recipes + 1] = {
    CanMake = env.GetModConfigData("__glommer_poop_food"),
    name = "mone_glommer_poop_food",
    ingredients = {
        Ingredient("cave_banana", 4)
    },
    tech = TECH.SCIENCE_TWO,
    config = {
        placer = nil,
        min_spacing = nil,
        nounlock = nil,
        numtogive = 1,
        builder_tag = nil,
        atlas = "images/inventoryimages1.xml",
        image = "bananajuice.tex"
    },
    filters = {
        --"MONE_MORE_ITEMS3"
        "MONE_MORE_ITEMS2"
    }
};

Recipes_Locate["mone_guacamole"] = true;
Recipes[#Recipes + 1] = {
    CanMake = env.GetModConfigData("__mone_guacamole"),
    name = "mone_guacamole",
    ingredients = {
        Ingredient("mole", 1), Ingredient("lightbulb", 10)
    },
    tech = TECH.SCIENCE_TWO,
    config = {
        placer = nil,
        min_spacing = nil,
        nounlock = nil,
        numtogive = 3,
        builder_tag = nil,
        atlas = "images/inventoryimages.xml",
        image = "guacamole.tex"
    },
    filters = {
        --"MONE_MORE_ITEMS3"
        "MONE_MORE_ITEMS2"
    }
};

Recipes_Locate["mone_honey_ham_stick"] = true;
Recipes[#Recipes + 1] = {
    CanMake = env.GetModConfigData("__mone_honey_ham_stick"),
    name = "mone_honey_ham_stick",
    ingredients = {
        Ingredient("hambat", 1), Ingredient("honey", 10), Ingredient("green_cap", 3)
    },
    tech = TECH.SCIENCE_TWO,
    config = {
        placer = nil,
        min_spacing = nil,
        nounlock = nil,
        numtogive = 3,
        builder_tag = nil,
        atlas = "images/foodimages/bs_food_58.xml",
        image = "bs_food_58.tex"
    },
    filters = {
        --"MONE_MORE_ITEMS3"
        "MONE_MORE_ITEMS1"
    }
};

Recipes_Locate["mone_beef_wellington"] = true;
Recipes[#Recipes + 1] = {
    CanMake = env.GetModConfigData("__mone_beef_wellington"),
    name = "mone_beef_wellington",
    ingredients = BALANCE and {
        Ingredient("cookedmeat", 20), Ingredient("beefalowool", 25), Ingredient("horn", 2)
    } or {
        Ingredient("cookedmeat", 10), Ingredient("beefalowool", 15), Ingredient("horn", 1)
    },
    tech = TECH.SCIENCE_TWO,
    config = {
        placer = nil,
        min_spacing = nil,
        nounlock = nil,
        numtogive = BALANCE and 4 or 3,
        builder_tag = nil,
        atlas = "images/foodimages/mone_beef_wellington.xml",
        image = "mone_beef_wellington.tex"
    },
    filters = {
        --"MONE_MORE_ITEMS3"
        "MONE_MORE_ITEMS1"
    }
};

Recipes_Locate["mone_poisonblam"] = true;
Recipes[#Recipes + 1] = {
    CanMake = env.GetModConfigData("__poisonblam"),
    name = "mone_poisonblam",
    ingredients = {
        Ingredient(CHARACTER_INGREDIENT.HEALTH, 10)
    },
    tech = TECH.SCIENCE_TWO,
    config = {
        placer = nil,
        min_spacing = nil,
        nounlock = nil,
        numtogive = 1,
        builder_tag = nil,
        atlas = "images/DLC0003/inventoryimages.xml",
        image = "poisonbalm.tex"
    },
    filters = {
        --"MONE_MORE_ITEMS3"
        "MONE_MORE_ITEMS1"
    }
};


---------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------
-- 全部设置成不要科技
if not TUNING.MONE_TUNING.GET_MOD_CONFIG_DATA.BALANCE then
    for _, v in pairs(Recipes) do
        v.tech = TECH.NONE;
    end
end

for _, v in pairs(Recipes) do
    if v.CanMake then
        if all_items_one_recipetab then
            if not table.contains(v.filters, "CHARACTER")
                    and not table.contains(v.filters, "CRAFTING_STATION")
            then
                v.filters = { "MONE_MORE_ITEMS1" };
            end
        end
        env.AddRecipe2(v.name, v.ingredients, v.tech, v.config, v.filters);
    end
end

for _, v in pairs(Recipes) do
    if v.CanMake then
        env.RemoveRecipeFromFilter(v.name, "MODS");
    end
end