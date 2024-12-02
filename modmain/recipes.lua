---
--- @author zsh in 2023/2/5 14:29
---

local API = require("chang_mone.dsts.API");

local more_items = TUNING.MIE_TUNING.MORE_ITEMS;
local BALANCE = more_items.BALANCE;
local config_data = TUNING.MIE_TUNING.MOD_CONFIG_DATA;

local Recipes = {}
local Recipes_Locate = {};

-- TL: 以后加个火焰在图层上方
Recipes_Locate["mie_relic_2"] = true;
Recipes[#Recipes + 1] = {
    CanMake = env.GetModConfigData("relic_2"),
    name = "mie_relic_2",
    ingredients = {
        Ingredient("redgem", 2), Ingredient("goldnugget", 10)
    },
    tech = TECH.SCIENCE_TWO,
    config = {
        placer = "mie_relic_2_placer",
        min_spacing = 1,
        nounlock = nil,
        numtogive = nil,
        builder_tag = nil,
        atlas = "images/DLC0003/inventoryimages.xml",
        image = "relic_2.tex"
    },
    filters = {
        "MONE_MORE_ITEMS1"
    }
};

-- 算原版也不算原版吧！
Recipes_Locate["mone_dummytarget"] = true;
Recipes[#Recipes + 1] = {
    CanMake = env.GetModConfigData("dummytarget"),
    name = "mone_dummytarget",
    ingredients = BALANCE and {
        Ingredient("boards", 10), Ingredient("goldnugget", 10),
        Ingredient(CHARACTER_INGREDIENT.HEALTH, 50)
    } or {
        Ingredient("boards", 5), Ingredient("goldnugget", 5),
        Ingredient(CHARACTER_INGREDIENT.HEALTH, 25)
    },
    tech = TECH.SCIENCE_TWO,
    config = {
        placer = "mone_dummytarget_placer",
        min_spacing = 1,
        nounlock = nil,
        numtogive = nil,
        builder_tag = nil,
        atlas = "images/inventoryimages.xml",
        image = "resurrectionstatue.tex"
    },
    filters = {
        "MONE_MORE_ITEMS2"
    }
};

Recipes_Locate["mie_waterpump"] = true;
Recipes[#Recipes + 1] = {
    CanMake = env.GetModConfigData("waterpump"),
    name = "mie_waterpump",
    ingredients = {
        Ingredient("rope", 5), Ingredient("boards", 5), Ingredient("goldnugget", 5),
        Ingredient("gears", 5)
    },
    tech = TECH.SCIENCE_TWO,
    config = {
        placer = "mie_waterpump_placer",
        min_spacing = 1,
        nounlock = nil,
        numtogive = nil,
        builder_tag = nil,
        atlas = "images/inventoryimages3.xml",
        image = "waterpump_item.tex"
    },
    filters = {
        "MONE_MORE_ITEMS2"
    }
};

Recipes_Locate["mie_sand_pit"] = true;
Recipes[#Recipes + 1] = {
    CanMake = env.GetModConfigData("sand_pit"),
    name = "mie_sand_pit",
    ingredients = {
        Ingredient("boards", 2), Ingredient("cutstone", 1),
    },
    tech = TECH.SCIENCE_TWO,
    config = {
        placer = "mie_sand_pit_placer",
        min_spacing = 1.5,
        nounlock = nil,
        numtogive = nil,
        builder_tag = nil,
        atlas = "images/inventoryimages/tall_pre.xml",
        image = "tall_pre.tex",
    },
    filters = {
        "MONE_MORE_ITEMS2"
    }
};

Recipes_Locate["mie_icemaker"] = true;
Recipes[#Recipes + 1] = {
    CanMake = env.GetModConfigData("icemaker"),
    name = "mie_icemaker",
    ingredients = {
        Ingredient("gears", 2), Ingredient("boards", 5), Ingredient("cutstone", 5),
    },
    tech = TECH.SCIENCE_TWO,
    config = {
        placer = "mie_icemaker_placer",
        min_spacing = 1.5,
        nounlock = nil,
        numtogive = nil,
        builder_tag = nil,
        atlas = "images/inventoryimages/icemaker.xml",
        image = "icemaker.tex",
    },
    filters = {
        "MONE_MORE_ITEMS1"
    }
};

Recipes_Locate["mie_fish_box"] = true;
Recipes[#Recipes + 1] = {
    CanMake = env.GetModConfigData("mie_fish_box"),
    name = "mie_fish_box",
    ingredients = {
        Ingredient("bearger_fur", 1), Ingredient("cutreeds", 40), Ingredient("boards", 20),
    },
    tech = TECH.SCIENCE_TWO,
    --tech = TECH.ANCIENT_TWO,
    config = {
        placer = "mie_fish_box_placer",
        min_spacing = 1.5,
        nounlock = nil,
        numtogive = nil,
        builder_tag = nil,
        atlas = config_data.mie_fish_box_animstate and "images/inventoryimages2.xml" or "images/inventoryimages1.xml",
        image = config_data.mie_fish_box_animstate and "saltbox.tex" or "fish_box.tex",
    },
    filters = {
        "MONE_MORE_ITEMS2"
        --"CRAFTING_STATION"
    }
};

Recipes_Locate["mie_bundle_state1"] = true;
Recipes[#Recipes + 1] = {
    CanMake = env.GetModConfigData("bundle"),
    name = "mie_bundle_state1",
    ingredients = {
        Ingredient("purplegem", 1), Ingredient("rope", 4)
    },
    tech = TECH.SCIENCE_TWO,
    config = {
        placer = nil,
        min_spacing = nil,
        nounlock = nil,
        numtogive = nil,
        builder_tag = nil,
        atlas = "images/inventoryimages.xml",
        image = "bundlewrap.tex",
    },
    filters = {
        "MONE_MORE_ITEMS2"
    }
};

Recipes_Locate["mie_bushhat"] = true;
Recipes[#Recipes + 1] = {
    CanMake = env.GetModConfigData("bushhat"),
    name = "mie_bushhat",
    ingredients = BALANCE and {
        Ingredient("dug_berrybush", 25) -- 一个大地图变异的大概39个，没变异的213、150个。。。
    } or {
        Ingredient("dug_berrybush", 15)
    },
    tech = TECH.SCIENCE_TWO,
    config = {
        placer = nil,
        min_spacing = nil,
        nounlock = nil,
        numtogive = nil,
        builder_tag = nil,
        atlas = "images/inventoryimages.xml",
        image = "bushhat.tex",
    },
    filters = {
        "MONE_MORE_ITEMS2"
    }
};

Recipes_Locate["mie_tophat"] = true;
Recipes[#Recipes + 1] = {
    CanMake = env.GetModConfigData("tophat"),
    name = "mie_tophat",
    ingredients = BALANCE and {
        Ingredient("tophat", 2), Ingredient("walrushat", 2), Ingredient("purplegem", 4), Ingredient("greengem", 2)
    } or {
        Ingredient("tophat", 1), Ingredient("walrushat", 1), Ingredient("purplegem", 2), Ingredient("greengem", 1)
    },
    tech = TECH.SCIENCE_TWO,
    config = {
        placer = nil,
        min_spacing = nil,
        nounlock = nil,
        numtogive = nil,
        builder_tag = nil,
        atlas = "images/inventoryimages.xml",
        image = "tophat.tex",
    },
    filters = {
        "MONE_MORE_ITEMS2"
    }
};

-- 有贴图问题，不行
--Recipes_Locate["mie_walterhat"] = true;
--Recipes[#Recipes + 1] = {
--    CanMake = env.GetModConfigData("walterhat") ,
--    name = "mie_walterhat",
--    ingredients = BALANCE and {
--        Ingredient("tophat", 1),Ingredient("walrushat", 1),Ingredient("purplegem", 4)
--    } or {
--        Ingredient("tophat", 1),Ingredient("walrushat", 1),Ingredient("purplegem", 2)
--    },
--    tech = TECH.NONE,
--    config = {
--        placer = nil,
--        min_spacing = nil,
--        nounlock = nil,
--        numtogive = nil,
--        builder_tag = nil,
--        atlas = "images/inventoryimages2.xml",
--        image = "walterhat.tex",
--    },
--    filters = {
--        "MONE_MORE_ITEMS4"
--    }
--};

Recipes_Locate["mie_book_silviculture"] = true;
Recipes[#Recipes + 1] = {
    CanMake = env.GetModConfigData("mie_book_silviculture"),
    name = "mie_book_silviculture",
    ingredients = BALANCE and {
        Ingredient("papyrus", 10), Ingredient("rope", 10), Ingredient("goldnugget", 10)
    } or {
        Ingredient("papyrus", 5), Ingredient("rope", 5), Ingredient("goldnugget", 5)
    },
    tech = TECH.SCIENCE_TWO,
    config = {
        placer = nil,
        min_spacing = nil,
        nounlock = nil,
        numtogive = nil,
        builder_tag = nil,
        atlas = "images/inventoryimages1.xml",
        image = "book_silviculture.tex",
    },
    filters = {
        "MONE_MORE_ITEMS2"
    }
};

Recipes_Locate["mie_book_horticulture"] = true;
Recipes[#Recipes + 1] = {
    CanMake = env.GetModConfigData("mie_book_horticulture"),
    name = "mie_book_horticulture",
    ingredients = BALANCE and {
        Ingredient("papyrus", 15), Ingredient("rope", 15), Ingredient("goldnugget", 15)
    } or {
        Ingredient("papyrus", 10), Ingredient("rope", 10), Ingredient("goldnugget", 10)
    },
    tech = TECH.SCIENCE_TWO,
    config = {
        placer = nil,
        min_spacing = nil,
        nounlock = nil,
        numtogive = nil,
        builder_tag = nil,
        atlas = "images/inventoryimages1.xml",
        image = "book_horticulture.tex",
    },
    filters = {
        "MONE_MORE_ITEMS2"
    }
};

Recipes_Locate["mie_wooden_drawer"] = true;
Recipes[#Recipes + 1] = {
    CanMake = env.GetModConfigData("mie_wooden_drawer"),
    name = "mie_wooden_drawer",
    ingredients = {
        Ingredient("boards", 3)
    },
    tech = TECH.SCIENCE_ONE,
    config = {
        placer = "mie_wooden_drawer_placer",
        min_spacing = 1,
        nounlock = nil,
        numtogive = nil,
        builder_tag = nil,
        atlas = "images/inventoryimages/tap_buildingimages.xml",
        image = "kyno_drawerchest.tex",
    },
    filters = {
        "MONE_MORE_ITEMS1"
    }
};

Recipes_Locate["mie_watersource"] = true;
Recipes[#Recipes + 1] = {
    CanMake = env.GetModConfigData("mie_watersource"),
    name = "mie_watersource",
    ingredients = {
        Ingredient("shovel", 1), Ingredient("farm_hoe", 1), Ingredient("hammer", 1),
        Ingredient("boards", 10)
    },
    tech = TECH.SCIENCE_TWO,
    config = {
        placer = "mie_watersource_placer",
        min_spacing = 1.5,
        nounlock = nil,
        numtogive = nil,
        builder_tag = nil,
        --atlas = "images/inventoryimages/water_bucket.xml",
        --image = "water_bucket.tex",

        -- NEW
        atlas = "images/inventoryimages/tap_buildingimages.xml",
        image = "kyno_bucket.tex",
    },
    filters = {
        "MONE_MORE_ITEMS1"
    }
};

Recipes_Locate["mie_bear_skin_cabinet"] = true;
Recipes[#Recipes + 1] = {
    CanMake = env.GetModConfigData("mie_bear_skin_cabinet"),
    name = "mie_bear_skin_cabinet",
    ingredients = {
        Ingredient("bearger_fur", 1), Ingredient("bundlewrap", 3)
    },
    tech = TECH.NONE,
    --tech = TECH.SCIENCE_TWO,
    --tech = TECH.ANCIENT_TWO, -- 为什么更新之后放置不了了？
    config = {
        placer = "mie_bear_skin_cabinet_placer",
        min_spacing = 1.5,
        nounlock = nil, -- true
        numtogive = nil,
        builder_tag = nil,
        atlas = "images/inventoryimages/tap_buildingimages.xml",
        image = "kyno_safe.tex",
    },
    filters = {
        "MONE_MORE_ITEMS1"
        --"CRAFTING_STATION"
    }
};

Recipes_Locate["mie_obsidianfirepit"] = true;
Recipes[#Recipes + 1] = {
    CanMake = env.GetModConfigData("mie_obsidianfirepit"),
    name = "mie_obsidianfirepit",
    ingredients = {
        Ingredient("lavae_egg", 1), Ingredient("redgem", 3), Ingredient("charcoal", 30), Ingredient("rocks", 30)
    },
    tech = TECH.SCIENCE_TWO,
    config = {
        placer = "mie_obsidianfirepit_placer",
        min_spacing = nil,
        nounlock = nil,
        numtogive = nil,
        builder_tag = nil,
        atlas = "images/DLC0002/inventoryimages.xml",
        image = "obsidianfirepit.tex",
    },
    filters = {
        "MONE_MORE_ITEMS1"
    }
};

Recipes_Locate["mie_beefalofeed"] = true;
Recipes[#Recipes + 1] = {
    CanMake = env.GetModConfigData("mie_beefalofeed"),
    name = "mie_beefalofeed",
    ingredients = BALANCE and {
        Ingredient("beefalofeed", 100)
    } or {
        Ingredient("beefalofeed", 50)
    },
    tech = TECH.SCIENCE_TWO,
    config = {
        placer = nil,
        min_spacing = nil,
        nounlock = nil,
        numtogive = nil,
        builder_tag = nil,
        atlas = "images/inventoryimages1.xml",
        image = "beefalofeed.tex",
    },
    filters = {
        --"MONE_MORE_ITEMS3"
        "MONE_MORE_ITEMS2"
    }
};

if not TUNING.NEVER_FINISH_SERIES_ENABLED then
    Recipes_Locate["mie_meatballs"] = true;
    Recipes[#Recipes + 1] = {
        CanMake = env.GetModConfigData("mie_meatballs"),
        name = "mie_meatballs",
        ingredients = BALANCE and {
            Ingredient("meatballs", 300)
        } or {
            Ingredient("meatballs", 150)
        },
        tech = TECH.SCIENCE_TWO,
        config = {
            placer = nil,
            min_spacing = nil,
            nounlock = nil,
            numtogive = nil,
            builder_tag = nil,
            atlas = "images/inventoryimages.xml",
            image = "meatballs.tex",
        },
        filters = {
            --"MONE_MORE_ITEMS3"
            "MONE_MORE_ITEMS2"
        }
    };

    Recipes_Locate["mie_bonestew"] = true;
    Recipes[#Recipes + 1] = {
        CanMake = env.GetModConfigData("mie_bonestew"),
        name = "mie_bonestew",
        ingredients = BALANCE and {
            Ingredient("bonestew", 300)
        } or {
            Ingredient("bonestew", 150)
        },
        tech = TECH.SCIENCE_TWO,
        config = {
            placer = nil,
            min_spacing = nil,
            nounlock = nil,
            numtogive = nil,
            builder_tag = nil,
            atlas = "images/inventoryimages.xml",
            image = "bonestew.tex",
        },
        filters = {
            --"MONE_MORE_ITEMS3"
            "MONE_MORE_ITEMS2"
        }
    };

    Recipes_Locate["mie_leafymeatsouffle"] = true;
    Recipes[#Recipes + 1] = {
        CanMake = env.GetModConfigData("mie_leafymeatsouffle"),
        name = "mie_leafymeatsouffle",
        ingredients = BALANCE and {
            Ingredient("leafymeatsouffle", 300)
        } or {
            Ingredient("leafymeatsouffle", 150)
        },
        tech = TECH.SCIENCE_TWO,
        config = {
            placer = nil,
            min_spacing = nil,
            nounlock = nil,
            numtogive = nil,
            builder_tag = nil,
            atlas = "images/inventoryimages2.xml",
            image = "leafymeatsouffle.tex",
        },
        filters = {
            --"MONE_MORE_ITEMS3"
            "MONE_MORE_ITEMS2"
        }
    };

    Recipes_Locate["mie_perogies"] = true;
    Recipes[#Recipes + 1] = {
        CanMake = env.GetModConfigData("mie_perogies"),
        name = "mie_perogies",
        ingredients = BALANCE and {
            Ingredient("perogies", 300)
        } or {
            Ingredient("perogies", 150)
        },
        tech = TECH.SCIENCE_TWO,
        config = {
            placer = nil,
            min_spacing = nil,
            nounlock = nil,
            numtogive = nil,
            builder_tag = nil,
            atlas = "images/inventoryimages.xml",
            image = "perogies.tex",
        },
        filters = {
            --"MONE_MORE_ITEMS3"
            "MONE_MORE_ITEMS2"
        }
    };

    Recipes_Locate["mie_dragonpie"] = true;
    Recipes[#Recipes + 1] = {
        CanMake = env.GetModConfigData("mie_dragonpie"),
        name = "mie_dragonpie",
        ingredients = BALANCE and {
            Ingredient("dragonpie", 300)
        } or {
            Ingredient("dragonpie", 150)
        },
        tech = TECH.SCIENCE_TWO,
        config = {
            placer = nil,
            min_spacing = nil,
            nounlock = nil,
            numtogive = nil,
            builder_tag = nil,
            atlas = "images/inventoryimages.xml",
            image = "dragonpie.tex",
        },
        filters = {
            --"MONE_MORE_ITEMS3"
            "MONE_MORE_ITEMS2"
        }
    };

    Recipes_Locate["mie_icecream"] = true;
    Recipes[#Recipes + 1] = {
        CanMake = env.GetModConfigData("mie_icecream"),
        name = "mie_icecream",
        ingredients = BALANCE and {
            Ingredient("icecream", 100)
        } or {
            Ingredient("icecream", 50)
        },
        tech = TECH.SCIENCE_TWO,
        config = {
            placer = nil,
            min_spacing = nil,
            nounlock = nil,
            numtogive = nil,
            builder_tag = nil,
            atlas = "images/inventoryimages.xml",
            image = "icecream.tex",
        },
        filters = {
            --"MONE_MORE_ITEMS3"
            "MONE_MORE_ITEMS2"
        }
    };

    Recipes_Locate["mie_lobsterdinner"] = true;
    Recipes[#Recipes + 1] = {
        CanMake = env.GetModConfigData("mie_lobsterdinner"),
        name = "mie_lobsterdinner",
        ingredients = BALANCE and {
            Ingredient("lobsterdinner", 100)
        } or {
            Ingredient("lobsterdinner", 50)
        },
        tech = TECH.SCIENCE_TWO,
        config = {
            placer = nil,
            min_spacing = nil,
            nounlock = nil,
            numtogive = nil,
            builder_tag = nil,
            atlas = "images/inventoryimages2.xml",
            image = "lobsterdinner.tex",
        },
        filters = {
            --"MONE_MORE_ITEMS3"
            "MONE_MORE_ITEMS2"
        }
    };
end


-- 之后说！
--Recipes_Locate["mie_fishnet"] = true;
--Recipes[#Recipes + 1] = {
--    CanMake = env.GetModConfigData("fishingnet") ,
--    name = "mie_fishnet",
--    ingredients = {
--        Ingredient("silk", 4), Ingredient("rocks", 4), Ingredient("rope", 2)
--    },
--    tech = TECH.NONE,
--    config = {
--        placer = nil,
--        min_spacing = nil,
--        nounlock = nil,
--        numtogive = nil,
--        builder_tag = nil,
--        atlas = "images/inventoryimages/mie_fishnet.xml",
--        image = "mie_fishnet.tex"
--    },
--    filters = {
--        "MONE_MORE_ITEMS4"
--    }
--};


if not BALANCE then
    for _, v in pairs(Recipes) do
        v.tech = TECH.NONE;
    end
end

for _, v in pairs(Recipes) do
    if v.CanMake then
        local all_items_one_recipetab = TUNING.MONE_TUNING.GET_MOD_CONFIG_DATA.all_items_one_recipetab;
        if all_items_one_recipetab then
            v.filters = { "MONE_MORE_ITEMS1" };
        end
        env.AddRecipe2(v.name, v.ingredients, v.tech, v.config, v.filters);
    end
end

for _, v in pairs(Recipes) do
    if v.CanMake then
        env.RemoveRecipeFromFilter(v.name, "MODS");
    end
end