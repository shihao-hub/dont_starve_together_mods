---
--- @author zsh in 2023/2/8 16:46
---


local config_data = TUNING.MIE_TUNING.MOD_CONFIG_DATA;

if not config_data.klei_items_switch then
    return ;
end

-- 可以被摧毁
local hermits = {};
if config_data.meatrack_hermit then
    table.insert(hermits, "meatrack_hermit");
end

if config_data.beebox_hermit then
    table.insert(hermits, "beebox_hermit");
end

if config_data.meatrack_hermit_beebox_hermit then
    for _, v in ipairs(hermits) do
        env.AddPrefabPostInit(v, function(inst)
            if not TheWorld.ismastersim then
                return inst;
            end
            local prefabname = inst.prefab;
            inst:AddComponent("lootdropper")
            inst:AddComponent("workable")
            inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
            inst.components.workable:SetWorkLeft(3)
            inst.components.workable:SetOnFinishCallback(prefabname == "meatrack_hermit" and function(inst, worker)
                if inst.components.burnable ~= nil and inst.components.burnable:IsBurning() then
                    inst.components.burnable:Extinguish()
                end
                inst.components.lootdropper:DropLoot()
                if inst.components.dryer ~= nil then
                    inst.components.dryer:DropItem()
                end
                local fx = SpawnPrefab("collapse_small")
                fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
                fx:SetMaterial("wood")
                inst:Remove()
            end or function(inst, worker)
                if inst.components.burnable ~= nil and inst.components.burnable:IsBurning() then
                    inst.components.burnable:Extinguish()
                end
                inst.SoundEmitter:KillSound("loop")
                if inst.components.harvestable ~= nil then
                    inst.components.harvestable:Harvest()
                end
                inst.components.lootdropper:DropLoot()
                local fx = SpawnPrefab("collapse_small")
                fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
                fx:SetMaterial("wood")
                inst:Remove()
            end)
        end)
    end
end

local more_items = TUNING.MIE_TUNING.MORE_ITEMS;
local BALANCE = more_items.BALANCE;

local RecipeTabs = {};

-- 更多物品·原版栏
local key4 = "more_items4";
RecipeTabs[key4] = {
    filter_def = {
        name = "MONE_MORE_ITEMS4",
        atlas = "images/inventoryimages1.xml",
        image = "bernie_cat.tex"
    },
    index = nil
}
STRINGS.UI.CRAFTING_FILTERS[RecipeTabs[key4].filter_def.name] = "更多物品·原版栏"
AddRecipeFilter(RecipeTabs[key4].filter_def, RecipeTabs[key4].index)

local Recipes = {};
local Recipes_Locate = {};

-- Recipes_Locate["dirtpile"] = true;
-- Recipes[#Recipes + 1] = {
--     CanMake = env.GetModConfigData("dirtpile"),
--     name = "dirtpile_copy",
--     ingredients = {
--         Ingredient("meat", 10)
--     },
--     tech = TECH.NONE,
--     config = {
--         product = "dirtpile",
--         atlas="images/minimapimages/icons.xml",
--         image="dirtpile.tex";
--     },
--     filters = {
--         "MONE_MORE_ITEMS1"
--     }
-- };

Recipes_Locate["madscience_lab"] = true;
Recipes[#Recipes + 1] = {
    CanMake = env.GetModConfigData("madscience_lab"),
    name = "madscience_lab_copy",
    ingredients = {
        Ingredient("cutstone", 2), Ingredient("transistor", 2)
    },
    tech = TECH.NONE,
    config = {
        product = "madscience_lab",
        placer = "madscience_lab_placer",
        hint_msg = "NEEDSHALLOWED_NIGHTS",
    },
    filters = {
        "MONE_MORE_ITEMS1"
    }
};

Recipes_Locate["giftwrap"] = true;
Recipes[#Recipes + 1] = {
    CanMake = env.GetModConfigData("giftwrap"),
    name = "giftwrap_copy",
    ingredients = {
        Ingredient("papyrus", 1), Ingredient("petals", 1)
    },
    tech = TECH.NONE,
    config = {
        product = "giftwrap",
        placer = nil,
        min_spacing = nil,
        nounlock = nil,
        numtogive = 4,
        builder_tag = nil,
        atlas = "images/inventoryimages.xml",
        image = "giftwrap.tex"
    },
    filters = {
        "MONE_MORE_ITEMS5"
    }
};

Recipes_Locate["featherpencil"] = true;
Recipes[#Recipes + 1] = {
    CanMake = env.GetModConfigData("featherpencil"),
    name = "featherpencil_copy",
    ingredients = {
        Ingredient("twigs", 1), Ingredient("charcoal", 1), Ingredient("feather_crow", 1)
    },
    tech = TECH.NONE,
    config = {
        product = "featherpencil",
        placer = nil,
        min_spacing = nil,
        nounlock = nil,
        numtogive = 4,
        builder_tag = nil,
        atlas = "images/inventoryimages.xml",
        image = "featherpencil.tex"
    },
    filters = {
        "MONE_MORE_ITEMS5"
    }
};

Recipes_Locate["armor_bramble"] = true;
Recipes[#Recipes + 1] = {
    CanMake = env.GetModConfigData("armor_bramble"),
    name = "armor_bramble_copy",
    ingredients = {
        Ingredient("livinglog", 2), Ingredient("stinger", 4)
    },
    tech = TECH.NONE,
    config = {
        product = "armor_bramble",
        placer = nil,
        min_spacing = nil,
        nounlock = nil,
        numtogive = nil,
        builder_tag = nil,
        atlas = "images/inventoryimages1.xml",
        image = "armor_bramble.tex"
    },
    filters = {
        "MONE_MORE_ITEMS5"
    }
};

Recipes_Locate["trap_bramble"] = true;
Recipes[#Recipes + 1] = {
    CanMake = env.GetModConfigData("trap_bramble"),
    name = "trap_bramble_copy",
    ingredients = {
        Ingredient("livinglog", 1), Ingredient("stinger", 1)
    },
    tech = TECH.NONE,
    config = {
        product = "trap_bramble",
        placer = nil,
        min_spacing = nil,
        nounlock = nil,
        numtogive = nil,
        builder_tag = nil,
        atlas = "images/inventoryimages2.xml",
        image = "trap_bramble.tex"
    },
    filters = {
        "MONE_MORE_ITEMS5"
    }
};

Recipes_Locate["portabletent_item"] = true;
Recipes[#Recipes + 1] = {
    CanMake = env.GetModConfigData("portabletent_item"),
    name = "portabletent_item_copy",
    ingredients = {
        Ingredient("bedroll_straw", 1), Ingredient("twigs", 4), Ingredient("rope", 2)
    },
    tech = TECH.NONE,
    config = {
        placer = nil,
        product = "portabletent_item",
        min_spacing = nil,
        nounlock = nil,
        numtogive = nil,
        builder_tag = nil,
        atlas = "images/inventoryimages2.xml",
        image = "portabletent_item.tex"
    },
    filters = {
        "MONE_MORE_ITEMS5"
    }
};

Recipes_Locate["lureplantbulb"] = true;
Recipes[#Recipes + 1] = {
    CanMake = env.GetModConfigData("lureplantbulb"),
    name = "lureplantbulb_copy",
    ingredients =  {
        Ingredient("plantmeat", 20),Ingredient("yellowgem", 1),Ingredient("reviver", 1)
    },
    tech = TECH.NONE,
    config = {
        product = "lureplantbulb",
        placer = nil,
        min_spacing = nil,
        nounlock = nil,
        numtogive = nil,
        builder_tag = nil,
        atlas = "images/inventoryimages.xml",
        image = "lureplantbulb.tex"
    },
    filters = {
        "MONE_MORE_ITEMS5"
    }
};

Recipes_Locate["fast_farmplot"] = true;
Recipes[#Recipes + 1] = {
    CanMake = env.GetModConfigData("fast_farmplot"),
    name = "fast_farmplot",
    ingredients = {
        Ingredient("cutgrass", 3), Ingredient("poop", 2), Ingredient("rocks", 1)
    },
    tech = TECH.NONE,
    config = {
        product = "fast_farmplot",
        placer = "fast_farmplot_placer",
        min_spacing = nil,
        nounlock = nil,
        numtogive = nil,
        builder_tag = nil,
        atlas = "images/inventoryimages.xml",
        image = "fast_farmplot.tex"
    },
    filters = {
        "MONE_MORE_ITEMS5"
    }
};

Recipes_Locate["pond"] = true;
Recipes[#Recipes + 1] = {
    CanMake = env.GetModConfigData("ponds"),
    name = "pond_copy",
    ingredients = BALANCE and {
        Ingredient("pondfish", 30)
    } or {
        Ingredient("pondfish", 15)
    },
    tech = TECH.NONE,
    config = {
        product = "pond",
        placer = "pond_placer",
        min_spacing = 4,
        nounlock = nil,
        numtogive = nil,
        builder_tag = nil,
        atlas = "minimap/minimap_data.xml",
        image = "pond.png"
    },
    filters = {
        "MONE_MORE_ITEMS5"
    }
};

Recipes_Locate["pond_cave"] = true;
Recipes[#Recipes + 1] = {
    CanMake = env.GetModConfigData("ponds"),
    name = "pond_cave_copy",
    ingredients = BALANCE and {
        Ingredient("pondeel", 30)
    } or {
        Ingredient("pondeel", 15)
    },
    tech = TECH.NONE,
    config = {
        product = "pond_cave",
        placer = "pond_cave_placer",
        min_spacing = 4,
        nounlock = nil,
        numtogive = nil,
        builder_tag = nil,
        atlas = "minimap/minimap_data.xml",
        image = "pond_cave.png"
    },
    filters = {
        "MONE_MORE_ITEMS5"
    }
};

Recipes_Locate["pond_mos"] = true;
Recipes[#Recipes + 1] = {
    CanMake = env.GetModConfigData("ponds"),
    name = "pond_mos_copy",
    ingredients = BALANCE and {
        Ingredient("mosquito", 30)
    } or {
        Ingredient("mosquito", 15)
    },
    tech = TECH.NONE,
    config = {
        product = "pond_mos",
        placer = "pond_mos_placer",
        min_spacing = 4,
        nounlock = nil,
        numtogive = nil,
        builder_tag = nil,
        atlas = "minimap/minimap_data.xml",
        image = "pond_mos.png"
    },
    filters = {
        "MONE_MORE_ITEMS5"
    }
};

Recipes_Locate["lava_pond"] = true;
Recipes[#Recipes + 1] = {
    CanMake = env.GetModConfigData("ponds"),
    name = "lava_pond_copy",
    ingredients = {
        Ingredient("dragon_scales", 1), Ingredient("ash", 30)
    },
    tech = TECH.NONE,
    config = {
        product = "lava_pond",
        placer = "lava_pond_placer",
        min_spacing = 4,
        nounlock = nil,
        numtogive = nil,
        builder_tag = nil,
        atlas = "minimap/minimap_data.xml",
        image = "lava_pond.png"
    },
    filters = {
        "MONE_MORE_ITEMS5"
    }
};

Recipes_Locate["tallbirdnest"] = true;
Recipes[#Recipes + 1] = {
    CanMake = env.GetModConfigData("tallbirdnest"),
    name = "tallbirdnest_copy",
    ingredients = BALANCE and {
        Ingredient("tallbirdegg", 4)
    } or {
        Ingredient("tallbirdegg", 4)
    },
    tech = TECH.NONE,
    config = {
        product = "tallbirdnest",
        placer = "tallbirdnest_placer",
        min_spacing = 1.5, -- 3.2
        nounlock = nil,
        numtogive = nil,
        builder_tag = nil,
        atlas = "minimap/minimap_data.xml",
        image = "tallbirdnest.png"
    },
    filters = {
        "MONE_MORE_ITEMS5"
    }
};

Recipes_Locate["pigtorch"] = true;
Recipes[#Recipes + 1] = {
    CanMake = env.GetModConfigData("pigtorch"),
    name = "pigtorch_copy",
    ingredients = BALANCE and {
        Ingredient("boards", 4), Ingredient("cutstone", 3), Ingredient("pigskin", 4)
    } or {
        Ingredient("boards", 4), Ingredient("cutstone", 3), Ingredient("pigskin", 4)
    },
    tech = TECH.NONE,
    config = {
        product = "pigtorch",
        placer = "pigtorch_placer",
        min_spacing = 3.2,
        nounlock = nil,
        numtogive = nil,
        builder_tag = nil,
        atlas = "images/minimapimages/icons.xml",
        image = "pigtorch.tex"
    },
    filters = {
        "MONE_MORE_ITEMS5"
    }
};

Recipes_Locate["catcoonden"] = true;
Recipes[#Recipes + 1] = {
    CanMake = env.GetModConfigData("catcoonden"),
    name = "catcoonden_copy",
    ingredients = BALANCE and {
        Ingredient("coontail", 3), Ingredient("tentaclespots", 1), Ingredient("boards", 2)
    } or {
        Ingredient("coontail", 3), Ingredient("tentaclespots", 1), Ingredient("boards", 2)
    },
    tech = TECH.NONE,
    config = {
        product = "catcoonden",
        placer = "catcoonden_placer",
        min_spacing = 3.2,
        nounlock = nil,
        numtogive = nil,
        builder_tag = nil,
        atlas = "minimap/minimap_data.xml",
        image = "catcoonden.png"
    },
    filters = {
        "MONE_MORE_ITEMS5"
    }
};

Recipes_Locate["slurtlehole"] = true;
Recipes[#Recipes + 1] = {
    CanMake = env.GetModConfigData("slurtlehole"),
    name = "slurtlehole_copy",
    ingredients = BALANCE and {
        Ingredient("slurtlehat", 1), --[[Ingredient("armorsnurtleshell", 1),]]
        Ingredient("slurtleslime", 6), Ingredient("slurtle_shellpieces", 2)
    } or {
        Ingredient("mosquito", 1)
    },
    tech = TECH.NONE,
    config = {
        product = "slurtlehole",
        placer = "slurtlehole_placer",
        min_spacing = 3.2,
        nounlock = nil,
        numtogive = nil,
        builder_tag = nil,
        atlas = "minimap/minimap_data.xml",
        image = "slurtle_den.png"
    },
    filters = {
        "MONE_MORE_ITEMS5"
    }
};

Recipes_Locate["meatrack_hermit"] = true;
Recipes[#Recipes + 1] = {
    CanMake = env.GetModConfigData("meatrack_hermit"),
    name = "meatrack_hermit_copy",
    ingredients = {
        Ingredient("twigs", 3), Ingredient("charcoal", 2), Ingredient("rope", 3)
    },
    tech = TECH.NONE,
    config = {
        product = "meatrack_hermit",
        placer = "meatrack_hermit_placer",
        min_spacing = 3.2,
        nounlock = nil,
        numtogive = nil,
        builder_tag = nil,
        atlas = "minimap/minimap_data.xml",
        image = "meatrack_hermit.png"
    },
    filters = {
        "MONE_MORE_ITEMS5"
    }
};

Recipes_Locate["beebox_hermit"] = true;
Recipes[#Recipes + 1] = {
    CanMake = env.GetModConfigData("beebox_hermit"),
    name = "beebox_hermit_copy",
    ingredients = {
        Ingredient("boards", 2), Ingredient("honeycomb", 1), Ingredient("bee", 4)
    },
    tech = TECH.NONE,
    config = {
        product = "beebox_hermit",
        placer = "beebox_hermit_placer",
        min_spacing = 3.2,
        nounlock = nil,
        numtogive = nil,
        builder_tag = nil,
        atlas = "minimap/minimap_data.xml",
        image = "beebox_hermitcrab.png"
    },
    filters = {
        "MONE_MORE_ITEMS5"
    }
};

Recipes_Locate["moonbase"] = true;
Recipes[#Recipes + 1] = {
    CanMake = env.GetModConfigData("moonbase"),
    name = "moonbase_copy",
    ingredients = {
        Ingredient("opalpreciousgem", 3), Ingredient("alterguardianhatshard", 3), Ingredient("moonrocknugget", 40)
    },
    tech = TECH.NONE,
    config = {
        product = "moonbase",
        placer = "moonbase_placer",
        min_spacing = 3.2,
        nounlock = nil,
        numtogive = nil,
        builder_tag = nil,
        atlas = "minimap/minimap_data.xml",
        image = "moonbase.png"
    },
    filters = {
        "MONE_MORE_ITEMS5"
    }
};

Recipes_Locate["handpillow_petals"] = true;
Recipes[#Recipes + 1] = {
    CanMake = env.GetModConfigData("handpillows"),
    name = "handpillow_petals_copy",
    ingredients =  {
        Ingredient("silk", 2),Ingredient("petals", 3)
    },
    tech = TECH.NONE,
    config = {
        product = "handpillow_petals",
    },
    filters = {
        "MONE_MORE_ITEMS5"
    }
};

Recipes_Locate["handpillow_kelp"] = true;
Recipes[#Recipes + 1] = {
    CanMake = env.GetModConfigData("handpillows"),
    name = "handpillow_kelp_copy",
    ingredients =  {
        --Ingredient("lucky_goldnugget", 2),
        Ingredient("silk", 2), Ingredient("kelp", 3)
    },
    tech = TECH.NONE,
    config = {
        product = "handpillow_kelp",
    },
    filters = {
        "MONE_MORE_ITEMS5"
    }
};

Recipes_Locate["handpillow_beefalowool"] = true;
Recipes[#Recipes + 1] = {
    CanMake = env.GetModConfigData("handpillows"),
    name = "handpillow_beefalowool_copy",
    ingredients =  {
        --Ingredient("lucky_goldnugget", 3),
        Ingredient("silk", 2), Ingredient("beefalowool", 3)
    },
    tech = TECH.NONE,
    config = {
        product = "handpillow_beefalowool",
    },
    filters = {
        "MONE_MORE_ITEMS5"
    }
};

Recipes_Locate["handpillow_steelwool"] = true;
Recipes[#Recipes + 1] = {
    CanMake = env.GetModConfigData("handpillows"),
    name = "handpillow_steelwool_copy",
    ingredients =  {
        --Ingredient("lucky_goldnugget", 5),
        Ingredient("silk", 2), Ingredient("steelwool", 2)
    },
    tech = TECH.NONE,
    config = {
        product = "handpillow_steelwool",
    },
    filters = {
        "MONE_MORE_ITEMS5"
    }
};

-- 座狼...
Recipes_Locate["warg"] = true;
Recipes[#Recipes + 1] = {
    CanMake = env.GetModConfigData("warg"),
    name = "warg_copy",
    ingredients = {
        Ingredient("houndstooth", 300)
        ,Ingredient("opalpreciousgem", 1)
    },
    tech = TECH.NONE,
    config = {
        product = "warg",
        atlas="images/minimapimages/icons.xml",
        image="warg.tex";
    },
    filters = {
        "MONE_MORE_ITEMS1"
    }
};

-- 统统移到扩展包栏，统一起来。科技栏太多太乱了！
for _, v in pairs(Recipes) do
    if v.CanMake then
        v.filters = { "MONE_MORE_ITEMS4" };
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
