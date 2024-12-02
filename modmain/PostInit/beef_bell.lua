---
--- @author zsh in 2023/2/27 15:08
---

-- 不只是 postinit，动作之类也在这里面！为了方便！

local API = require("chang_mone.dsts.API");
local more_items = TUNING.MIE_TUNING.MORE_ITEMS;
local BALANCE = more_items.BALANCE;





---------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------

local custom_actions = {
    ["MIE_BEEF_BELL_ACTION"] = {
        execute = false, -- TEMP
        id = "MIE_BEEF_BELL_ACTION",
        str = "召唤/收回",
        fn = function(act)

        end,
        actiondata = {
            strfn = function(act)
                return true and "CALL" or "RECALL"
            end
        },
        state = "dolongaction"
    },
}

local component_actions = {
    {
        actiontype = "INVENTORY",
        component = "mie_beef_bell_action",
        tests = {
            {
                execute = custom_actions["MIE_BEEF_BELL_ACTION"].execute,
                id = "MIE_BEEF_BELL_ACTION",
                testfn = function(inst, doer, actions, right)
                    return inst and inst:HasTag("mie_beef_bell") and right;
                end
            }
        }
    },
}

API.addCustomActions(env, custom_actions, component_actions);

STRINGS.ACTIONS.MIE_BEEF_BELL_ACTION = {
    EXCEPTION = "EXCEPTION",
    CALL = "召唤",
    RECALL = "收回"
}

---------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------

local Recipes = {}
local Recipes_Locate = {};

Recipes_Locate["mie_beef_bell"] = true;
Recipes[#Recipes + 1] = {
    CanMake = env.GetModConfigData("mie_beef_bell") ~= false,
    name = "mie_beef_bell",
    ingredients = {
        Ingredient("redgem", 2), Ingredient("goldnugget", 10)
    },
    tech = TECH.NONE,
    config = {
        placer = nil,
        min_spacing = nil,
        nounlock = nil,
        numtogive = nil,
        builder_tag = nil,
        atlas = "images/inventoryimages1.xml",
        image = "beef_bell.tex"
    },
    filters = {
        "MONE_MORE_ITEMS4"
    }
};

if not BALANCE then
    for _, v in pairs(Recipes) do
        v.tech = TECH.NONE;
    end
end

for _, v in pairs(Recipes) do
    if v.CanMake ~= false then
        env.AddRecipe2(v.name, v.ingredients, v.tech, v.config, v.filters);
    end
end