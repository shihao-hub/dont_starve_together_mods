---
--- @author zsh in 2023/2/20 8:55
---

local foods = {};

local config_data = TUNING.MIE_TUNING.MOD_CONFIG_DATA;

foods["mie_meatballs"] = {
    CanMake = config_data.mie_meatballs,
    name = "mie_meatballs",
    assets = {
        Asset("ANIM", "anim/cook_pot_food.zip"),
    },
    tags = { "mie_meatballs", "non_preparedfood", "mie_inf_food", "mie_inf_food_meat" },
    animdata = { bank = "cook_pot_food", build = "cook_pot_food", animation = "idle" },
    cs_fn = function(inst)
        inst.entity:AddMiniMapEntity();
        inst.MiniMapEntity:SetIcon("meatballs.tex");

        inst.AnimState:OverrideSymbol("swap_food", "cook_pot_food", "meatballs");
    end,
    client_fn = function(inst)

    end,
    server_fn = function(inst)
        inst.components.inventoryitem.imagename = "meatballs";
        inst.components.inventoryitem.atlasname = "images/inventoryimages.xml";

        inst.components.edible.hungervalue = 62.5;
        inst.components.edible.sanityvalue = 5;
        inst.components.edible.healthvalue = 3;
        inst.components.edible.foodtype = FOODTYPE.MEAT; --FOODTYPE.MIE_INF_FOOD;

        inst:RemoveComponent("stackable");
        inst:RemoveComponent("bait");
        inst:RemoveComponent("tradable");
    end
}

foods["mie_bonestew"] = {
    CanMake = config_data.mie_bonestew,
    name = "mie_bonestew",
    assets = {
        Asset("ANIM", "anim/cook_pot_food.zip"),
        --Asset("INV_IMAGE", "bonestew"),
    },
    tags = { "mie_bonestew", "non_preparedfood", "mie_inf_food", "mie_inf_food_meat" },
    animdata = { bank = "cook_pot_food", build = "cook_pot_food", animation = "idle" },
    cs_fn = function(inst)
        inst.entity:AddMiniMapEntity();
        inst.MiniMapEntity:SetIcon("bonestew.tex");

        inst.AnimState:OverrideSymbol("swap_food", "cook_pot_food", "bonestew");
    end,
    client_fn = function(inst)

    end,
    server_fn = function(inst)
        inst.components.inventoryitem.imagename = "bonestew";
        inst.components.inventoryitem.atlasname = "images/inventoryimages.xml";

        inst.components.edible.hungervalue = 150;
        inst.components.edible.sanityvalue = 5;
        inst.components.edible.healthvalue = 12;
        inst.components.edible.foodtype = FOODTYPE.MEAT; --FOODTYPE.MIE_INF_FOOD;

        inst:RemoveComponent("stackable");
        inst:RemoveComponent("bait");
        inst:RemoveComponent("tradable");
    end
}

foods["mie_leafymeatsouffle"] = {
    CanMake = config_data.mie_leafymeatsouffle,
    name = "mie_leafymeatsouffle",
    assets = {
        Asset("ANIM", "anim/cook_pot_food.zip"),
    },
    tags = { "mie_leafymeatsouffle", "non_preparedfood", "mie_inf_food", "mie_inf_food_meat" },
    animdata = { bank = "cook_pot_food", build = "cook_pot_food", animation = "idle" },
    cs_fn = function(inst)
        inst.entity:AddMiniMapEntity();
        inst.MiniMapEntity:SetIcon("leafymeatsouffle.tex");

        inst.AnimState:OverrideSymbol("swap_food", "cook_pot_food4", "leafymeatsouffle");
    end,
    client_fn = function(inst)

    end,
    server_fn = function(inst)
        inst.components.inventoryitem.imagename = "leafymeatsouffle";
        inst.components.inventoryitem.atlasname = "images/inventoryimages2.xml";

        inst.components.edible.hungervalue = 37.5;
        inst.components.edible.sanityvalue = 50;
        inst.components.edible.healthvalue = 0;
        inst.components.edible.foodtype = FOODTYPE.MEAT; --FOODTYPE.MIE_INF_FOOD;

        inst:RemoveComponent("stackable");
        inst:RemoveComponent("bait");
        inst:RemoveComponent("tradable");
    end
}

foods["mie_perogies"] = {
    CanMake = config_data.mie_perogies,
    name = "mie_perogies",
    assets = {
        Asset("ANIM", "anim/cook_pot_food.zip"),
        --Asset("INV_IMAGE", "bonestew"),
    },
    tags = { "mie_perogies", "non_preparedfood", "mie_inf_food", "mie_inf_food_meat" },
    animdata = { bank = "cook_pot_food", build = "cook_pot_food", animation = "idle" },
    cs_fn = function(inst)
        inst.entity:AddMiniMapEntity();
        inst.MiniMapEntity:SetIcon("perogies.tex");

        inst.AnimState:OverrideSymbol("swap_food", "cook_pot_food", "perogies");
    end,
    client_fn = function(inst)

    end,
    server_fn = function(inst)
        inst.components.inventoryitem.imagename = "perogies";
        inst.components.inventoryitem.atlasname = "images/inventoryimages.xml";

        inst.components.edible.hungervalue = 37.5;
        inst.components.edible.sanityvalue = 5;
        inst.components.edible.healthvalue = 40;
        inst.components.edible.foodtype = FOODTYPE.MEAT; --FOODTYPE.MIE_INF_FOOD;

        inst:RemoveComponent("stackable");
        inst:RemoveComponent("bait");
        inst:RemoveComponent("tradable");

    end
}

foods["mie_icecream"] = {
    CanMake = config_data.mie_icecream,
    name = "mie_icecream",
    assets = {
        Asset("ANIM", "anim/cook_pot_food.zip"),
    },
    tags = { "mie_icecream", "non_preparedfood", "mie_inf_food", "mie_inf_food_goodies" },
    animdata = { bank = "cook_pot_food", build = "cook_pot_food", animation = "idle" },
    cs_fn = function(inst)
        inst.entity:AddMiniMapEntity();
        inst.MiniMapEntity:SetIcon("icecream.tex");

        inst.AnimState:OverrideSymbol("swap_food", "cook_pot_food", "icecream");
    end,
    client_fn = function(inst)

    end,
    server_fn = function(inst)
        inst.components.inventoryitem.imagename = "icecream";
        inst.components.inventoryitem.atlasname = "images/inventoryimages.xml";

        inst.components.edible.hungervalue = 25;
        inst.components.edible.sanityvalue = 50;
        inst.components.edible.healthvalue = 0;
        inst.components.edible.temperaturedelta = TUNING.COLD_FOOD_BONUS_TEMP;
        inst.components.edible.temperatureduration = TUNING.FOOD_TEMP_LONG;
        inst.components.edible.foodtype = FOODTYPE.GOODIES; --FOODTYPE.MIE_INF_FOOD;

        inst:RemoveComponent("stackable");
        inst:RemoveComponent("bait");
        inst:RemoveComponent("tradable");

    end
}

foods["mie_lobsterdinner"] = {
    CanMake = config_data.mie_lobsterdinner,
    name = "mie_lobsterdinner",
    assets = {
        Asset("ANIM", "anim/cook_pot_food.zip"),
    },
    tags = { "mie_lobsterdinner", "non_preparedfood", "mie_inf_food", "mie_inf_food_meat" },
    animdata = { bank = "cook_pot_food", build = "cook_pot_food", animation = "idle" },
    cs_fn = function(inst)
        inst.entity:AddMiniMapEntity();
        inst.MiniMapEntity:SetIcon("lobsterdinner.tex");

        inst.AnimState:OverrideSymbol("swap_food", "cook_pot_food3", "lobsterdinner");
    end,
    client_fn = function(inst)

    end,
    server_fn = function(inst)
        inst.components.inventoryitem.imagename = "lobsterdinner";
        inst.components.inventoryitem.atlasname = "images/inventoryimages2.xml";

        inst.components.edible.hungervalue = 37.5;
        inst.components.edible.sanityvalue = 50;
        inst.components.edible.healthvalue = 60;
        inst.components.edible.foodtype = FOODTYPE.MEAT; --FOODTYPE.MIE_INF_FOOD;

        inst:RemoveComponent("stackable");
        inst:RemoveComponent("bait");
        inst:RemoveComponent("tradable");

    end
}

foods["mie_dragonpie"] = {
    CanMake = config_data.mie_dragonpie,
    name = "mie_dragonpie",
    assets = {
        Asset("ANIM", "anim/cook_pot_food.zip"),
    },
    tags = { "mie_dragonpie", "non_preparedfood", "mie_inf_food", "mie_inf_food_veggie" },
    animdata = { bank = "cook_pot_food", build = "cook_pot_food", animation = "idle" },
    cs_fn = function(inst)
        inst.entity:AddMiniMapEntity();
        inst.MiniMapEntity:SetIcon("dragonpie.tex");

        inst.AnimState:OverrideSymbol("swap_food", "cook_pot_food", "dragonpie");
    end,
    client_fn = function(inst)

    end,
    server_fn = function(inst)
        inst.components.inventoryitem.imagename = "dragonpie";
        inst.components.inventoryitem.atlasname = "images/inventoryimages.xml";

        inst.components.edible.hungervalue = 75;
        inst.components.edible.sanityvalue = 5;
        inst.components.edible.healthvalue = 40;
        inst.components.edible.foodtype = FOODTYPE.VEGGIE; --FOODTYPE.MIE_INF_FOOD;

        inst:RemoveComponent("stackable");
        inst:RemoveComponent("bait");
        inst:RemoveComponent("tradable");
    end
}

-- 蒸树枝，需要交易组件，故移除 mie_inf_food 标签，改用交易后还一个实现？
foods["mie_beefalofeed"] = {
    CanMake = config_data.mie_beefalofeed,
    name = "mie_beefalofeed",
    assets = {
        Asset("ANIM", "anim/cook_pot_food.zip"),
    },
    tags = { "mie_beefalofeed", "non_preparedfood", "mie_inf_roughage" },
    animdata = { bank = "cook_pot_food", build = "cook_pot_food", animation = "idle" },
    cs_fn = function(inst)
        inst.entity:AddMiniMapEntity();
        inst.MiniMapEntity:SetIcon("beefalofeed.tex");

        inst.AnimState:OverrideSymbol("swap_food", "cook_pot_food11", "beefalofeed");
    end,
    client_fn = function(inst)

    end,
    server_fn = function(inst)
        inst.components.inventoryitem.imagename = "beefalofeed";
        inst.components.inventoryitem.atlasname = "images/inventoryimages1.xml";

        -- 这是干嘛的？
        --inst:ListenForEvent("onputininventory", function(inst, owner)
        --    if owner ~= nil and owner:IsValid() then
        --        owner:PushEvent("learncookbookstats", inst.food_basename or inst.prefab)
        --    end
        --end)

        inst.components.edible.hungervalue = TUNING.CALORIES_MOREHUGE;
        inst.components.edible.sanityvalue = 0;
        inst.components.edible.healthvalue = TUNING.HEALING_MEDLARGE / 2;
        --inst.components.edible.foodtype = FOODTYPE.VEGGIE;
        inst.components.edible.foodtype = FOODTYPE.ROUGHAGE;
        inst.components.edible.secondaryfoodtype = FOODTYPE.WOOD;

        inst:RemoveComponent("stackable");
        inst:RemoveComponent("bait");
        --inst:RemoveComponent("tradable");

    end
}

if TUNING.NEVER_FINISH_SERIES_ENABLED then
    local must_foods = {};
    for k, v in pairs(foods) do
        if table.contains({ "mie_beefalofeed" }, k) then
            must_foods[k] = v;
        end
    end
    foods = must_foods;
end

return foods;