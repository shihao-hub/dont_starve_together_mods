---
--- @author zsh in 2023/3/26 12:25
---

do
    ---@deprecated
    return;
end

local config_data = TUNING.MONE_TUNING.GET_MOD_CONFIG_DATA;

if not config_data.original_items_modifications --[[总开关]] then
    return ;
end

-- 如果开启了永不妥协，为了避免覆盖，类似的功能失效。
if TUNING.DSTU then
    print("永不妥协已开启，相关功能失效。");
    config_data.wateringcan = false; -- DISABLED
    config_data.premiumwateringcan = false; -- DISABLED
    config_data.telebase = false; -- DISABLED
end

-- 如果开启了为爽而虐，为了避免覆盖，类似的功能失效。
if TUNING.HAPPYPATCHMOD then
    print("为爽而虐已开启，相关功能失效。");
    config_data.beef_bell = false; -- DISABLED
end

if IsModEnabled("2788995386") then
    print("巨兽掉落加强模组已开启");
else
    print("巨兽掉落加强模组未开启");
end

config_data.telebase = false; -- DISABLED
local PREFABS_TAB_AGENCY = {
    whip = config_data.whip; -- YES
    wateringcan = config_data.wateringcan; -- YES
    premiumwateringcan = config_data.premiumwateringcan; -- YES
    telebase = config_data.telebase; -- NO
    batbat = config_data.batbat; -- YES
    nightstick = config_data.nightstick; -- YES
    beef_bell = config_data.beef_bell; -- NO
}

local MODULE_ON; --[[精确总开关，只要有一个开了，模块就会导入。]]
for _, v in pairs(PREFABS_TAB_AGENCY) do
    if v then
        MODULE_ON = true; -- or
        break ;
    end
end
if not MODULE_ON then
    return ;
end

local API = require("chang_mone.dsts.API");
local TEXT = require("languages.mone.loc");

local containers = require("containers");
local params = containers.params;

local fns = {};

local PREFABS_TAB = {};
for k, v in pairs(PREFABS_TAB_AGENCY) do
    if v then
        table.insert(PREFABS_TAB, k);
    end
end

local WATERINGCAN_NAMED_ON = false; -- TEMP

-------------------------------------------------------------------------------------------------------
--[[ 容器添加 ]]
-------------------------------------------------------------------------------------------------------
local function fn(inst, doer)
    if inst.components.container ~= nil then
        API.arrangeContainer(inst);
    elseif inst.replica.container ~= nil and not inst.replica.container:IsBusy() then
        SendRPCToServer(RPC.DoWidgetButtonAction, nil, inst, nil)
    end
end

local function validfn(inst)
    return inst.replica.container ~= nil and not inst.replica.container:IsEmpty();
end

-- 算了，暂时不知道 OnLoad 这种方式如何执行客机的代码，那我只能将这个命名和预制物的名字匹配起来了。
---- emm, 好像问题不大。无所谓了！就这样吧！
if params.wateringcan == nil then
    params.wateringcan = {
        widget = {
            slotpos = {
                Vector3(0, 32 + 4, 0),
                Vector3(0, -(32 + 4), 0),
            },
            slotbg = {
                { image = "fish_slot.tex", atlas = "images/uiimages/fish_slot.xml" },
                { image = "fish_slot.tex", atlas = "images/uiimages/fish_slot.xml" },
            },
            animbank = "ui_cookpot_1x2",
            animbuild = "ui_cookpot_1x2",
            pos = Vector3(0, 105, 0),
            buttoninfo = {
                text = "整理",
                position = Vector3(0, -97 - 2, 0),
                fn = fn,
                validfn = validfn;
            },
        },
        type = "hand_inv",
        itemtestfn = function(container, item, slot)
            return item:HasTag("pondfish")
                    or item:HasTag("smalloceancreature");
        end
    }
else
    config_data.wateringcan = false;
end

if params.premiumwateringcan == nil then
    -- 不舒服，hand_inv 让格子有点小。
    params.premiumwateringcan = {
        widget = {
            slotpos = {
                Vector3(0, 64 + 32 + 8 + 4, 0),
                Vector3(0, 32 + 4, 0),
                Vector3(0, -(32 + 4), 0),
                Vector3(0, -(64 + 32 + 8 + 4), 0),
            },
            slotbg = {
                { image = "fish_slot.tex", atlas = "images/uiimages/fish_slot.xml" },
                { image = "fish_slot.tex", atlas = "images/uiimages/fish_slot.xml" },
                { image = "fish_slot.tex", atlas = "images/uiimages/fish_slot.xml" },
                { image = "fish_slot.tex", atlas = "images/uiimages/fish_slot.xml" },
            },
            animbank = "ui_cookpot_1x4",
            animbuild = "ui_cookpot_1x4",
            pos = Vector3(0, 125, 0),
            buttoninfo = {
                text = "整理",
                position = Vector3(0, -165, 0),
                fn = fn,
                validfn = validfn;
            },
        },
        type = "hand_inv",
        itemtestfn = function(container, item, slot)
            return item:HasTag("pondfish")
                    or item:HasTag("smalloceancreature");
        end
    }
    -- NEW!
    params.premiumwateringcan = {
        widget = {
            slotpos = {},
            slotbg = {
                { image = "fish_slot.tex", atlas = "images/uiimages/fish_slot.xml" },
                { image = "fish_slot.tex", atlas = "images/uiimages/fish_slot.xml" },
                { image = "fish_slot.tex", atlas = "images/uiimages/fish_slot.xml" },
                { image = "fish_slot.tex", atlas = "images/uiimages/fish_slot.xml" },
            },
            animbank = "ui_lamp_1x4",
            animbuild = "ui_lamp_1x4",
            pos = Vector3(0, 125, 0),
        },
        type = "hand_inv",
        itemtestfn = function(container, item, slot)
            return item:HasTag("smalloceancreature");
        end
    }
    for y = 0, 3 do
        table.insert(params.premiumwateringcan.widget.slotpos, Vector3(-1, -75 * y + 110, 0))
    end
else
    config_data.premiumwateringcan = false;
end

for k, v in pairs(params) do
    containers.MAXITEMSLOTS = math.max(containers.MAXITEMSLOTS, v.widget.slotpos ~= nil and #v.widget.slotpos or 0)
end
-------------------------------------------------------------------------------------------------------
--[[ 内容修改 ]]
-------------------------------------------------------------------------------------------------------
-- onpreload 函数中添加组件！ onload 函数中不要添加组件！
---- 游戏内给物品添加组件的话，就得这样，因为 onpreload(...) -> 执行各种组件的 OnLoad 函数 -> onload(...)

local function decision_fn(inst, prefabname)
    return inst.prefab == prefabname and inst.mi_ori_item_modify_tag and config_data[prefabname];
end
-------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------
function fns.whip_onpreload(inst)
    if not decision_fn(inst, "whip") then
        return ;
    end
end
function fns.whip_onload(inst)
    if not decision_fn(inst, "whip") then
        return ;
    end
    if inst.components.named then
        inst.components.named:SetName("修改版·" .. tostring(STRINGS.NAMES[inst.prefab:upper()]));
    end
    -- 武器伤害翻倍
    if inst.components.weapon then
        inst.components.weapon:SetDamage(TUNING.WHIP_DAMAGE * 2);
    end
end
-------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------
function fns.nightstick_onpreload(inst)
    if not decision_fn(inst, "nightstick") then
        return ;
    end
end
function fns.nightstick_onload(inst)
    if not decision_fn(inst, "nightstick") then
        return ;
    end
    if inst.components.named then
        inst.components.named:SetName("修改版·" .. tostring(STRINGS.NAMES[inst.prefab:upper()]));
    end
    -- 可以修复
    -- 这里是主机部分，但是我的 mone_repair_materials 需要添加在主客机，懒得修改了，打个补丁吧！
    inst.mone_repair_materials = { transistor = 0.5 };
    inst:AddTag("mone_can_be_repaired");
    inst:AddTag("mone_can_be_repaired_modify_nightstick");
end
-------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------
function fns.batbat_onpreload(inst)
    if not decision_fn(inst, "batbat") then
        return ;
    end
end
function fns.batbat_onload(inst)
    if not decision_fn(inst, "batbat") then
        return ;
    end
    if inst.components.named then
        inst.components.named:SetName("修改版·" .. tostring(STRINGS.NAMES[inst.prefab:upper()]));
    end
    -- 耐久翻倍
    if inst.components.finiteuses then
        inst.components.finiteuses:SetMaxUses(TUNING.BATBAT_USES * 2);
        inst.components.finiteuses:SetUses(TUNING.BATBAT_USES * 2);
    end
end
-------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------
function fns.telebase_onpreload(inst)
    if not decision_fn(inst, "telebase") then
        return ;
    end
end
function fns.telebase_onload(inst)
    if not decision_fn(inst, "telebase") then
        return ;
    end

    if inst.components.named then
        inst.components.named:SetName("修改版·" .. tostring(STRINGS.NAMES[inst.prefab:upper()]));
    end

end
if config_data.telebase then
    env.AddPrefabPostInit("gemsocket", function(inst)
        if not TheWorld.ismastersim then
            return inst;
        end

        -- 覆写法
        inst.components.inspectable.getstatus = function(inst)
            return "VALID";
        end

        inst.DestroyGemFn = function(inst)
            inst.components.trader:Enable()
            inst.components.pickable.caninteractwith = false
            inst:DoTaskInTime(math.random() * 0.5, function(inst)
                inst.SoundEmitter:KillSound("hover_loop")
                inst.AnimState:ClearBloomEffectHandle()
                inst.AnimState:PlayAnimation("shatter")
                inst.AnimState:PushAnimation("idle_empty")
                inst.SoundEmitter:PlaySound("dontstarve/common/gem_shatter")
            end)
        end
    end)
end
-------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------
local wateringcan_fns = {
    onopenfn = function(inst)
        inst.SoundEmitter:PlaySound("dontstarve/wilson/chest_open")
    end,
    onclosefn = function(inst)
        inst.SoundEmitter:PlaySound("dontstarve/wilson/chest_close")
    end
};

-- 此处只允许添加组件。。。因为其他组件都没添加呢。。。
function fns.wateringcan_onpreload(inst)
    if not decision_fn(inst, "wateringcan") then
        return ;
    end

    --[[ 截断 ]]
    if inst.components.container or inst.components.preserver then
        return ;
    end

    inst.more_items_modify_enter_tag = true;
    -- 水壶添加容器，同时具有返鲜功能
    inst:AddTag("tool_bag_notag");
    inst:AddComponent("container");
    inst.components.container:WidgetSetup("wateringcan");
    inst.components.container.skipclosesnd = true;
    inst.components.container.skipopensnd = true;
    inst.components.container.onopenfn = wateringcan_fns.onopenfn;
    inst.components.container.onclosefn = wateringcan_fns.onclosefn;

    inst:AddComponent("preserver");
    inst.components.preserver:SetPerishRateMultiplier(TUNING.FISH_BOX_PRESERVER_RATE);
end

function fns.wateringcan_onload(inst)
    if not decision_fn(inst, "wateringcan") then
        return ;
    end

    --[[ 截断 ]]
    if not inst.more_items_modify_enter_tag then
        return ;
    end

    if inst.components.named then
        if inst.components.finiteuses and inst.components.finiteuses.current > 0 then
            inst.components.named:SetName("修改版·" .. tostring(STRINGS.NAMES[inst.prefab:upper() .. "_NOT_EMPTY"]));
        elseif inst.components.finiteuses then
            inst.components.named:SetName("修改版·" .. tostring(STRINGS.NAMES[inst.prefab:upper()]));
        end
    end

    if inst.components.equippable then
        local old_onequipfn = inst.components.equippable.onequipfn;
        local old_onunequipfn = inst.components.equippable.onunequipfn;
        inst.components.equippable:SetOnEquip(function(inst, owner, ...)
            if old_onequipfn then
                old_onequipfn(inst, owner, ...);
            end
            if inst.components.container then
                inst.components.container:Open(owner);
            end
        end);
        inst.components.equippable:SetOnUnequip(function(inst, owner, ...)
            if old_onunequipfn then
                old_onunequipfn(inst, owner, ...);
            end
            if inst.components.container then
                inst.components.container:Close();
            end
        end);
    end
end
-------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------
local premiumwateringcan_fns = {
    onopenfn = function(inst)
        inst.SoundEmitter:PlaySound("dontstarve/wilson/chest_open")
    end,
    onclosefn = function(inst)
        inst.SoundEmitter:PlaySound("dontstarve/wilson/chest_close")
    end
};

function fns.premiumwateringcan_onpreload(inst)
    if not decision_fn(inst, "premiumwateringcan") then
        return ;
    end

    --[[ 截断 ]]
    if inst.components.container or inst.components.preserver then
        return ;
    end

    inst.more_items_modify_enter_tag = true;
    -- 水壶添加容器，同时具有返鲜功能
    inst:AddTag("tool_bag_notag");
    inst:AddComponent("container");
    inst.components.container:WidgetSetup("premiumwateringcan");
    inst.components.container.skipclosesnd = true;
    inst.components.container.skipopensnd = true;
    inst.components.container.onopenfn = premiumwateringcan_fns.onopenfn;
    inst.components.container.onclosefn = premiumwateringcan_fns.onclosefn;

    inst:AddComponent("preserver");
    inst.components.preserver:SetPerishRateMultiplier(TUNING.FISH_BOX_PRESERVER_RATE * 2);
end

function fns.premiumwateringcan_onload(inst)
    if not decision_fn(inst, "premiumwateringcan") then
        return ;
    end

    --[[ 截断 ]]
    if not inst.more_items_modify_enter_tag then
        return ;
    end

    if inst.components.named then
        if inst.components.finiteuses and inst.components.finiteuses.current > 0 then
            inst.components.named:SetName("修改版·" .. tostring(STRINGS.NAMES[inst.prefab:upper() .. "_NOT_EMPTY"]));
        elseif inst.components.finiteuses then
            inst.components.named:SetName("修改版·" .. tostring(STRINGS.NAMES[inst.prefab:upper()]));
        end
    end

    if inst.components.equippable then
        local old_onequipfn = inst.components.equippable.onequipfn;
        local old_onunequipfn = inst.components.equippable.onunequipfn;
        inst.components.equippable:SetOnEquip(function(inst, owner, ...)
            if old_onequipfn then
                old_onequipfn(inst, owner, ...);
            end
            if inst.components.container then
                inst.components.container:Open(owner);
            end
        end);
        inst.components.equippable:SetOnUnequip(function(inst, owner, ...)
            if old_onunequipfn then
                old_onunequipfn(inst, owner, ...);
            end
            if inst.components.container then
                inst.components.container:Close();
            end
        end);
    end
end
-------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------
for _, name in ipairs(PREFABS_TAB) do
    env.AddPrefabPostInit(name, function(inst)
        if not TheWorld.ismastersim then
            return inst;
        end

        if inst.components.named == nil then
            inst:AddComponent("named");
        end

        -- 改名字，由于这两个水壶有两个名字。。。不合理，不应该这么麻烦的。
        if WATERINGCAN_NAMED_ON and (inst.prefab == "wateringcan" or inst.prefab == "premiumwateringcan") then
            inst:DoTaskInTime(0, function(inst)
                if inst.mi_ori_item_modify_tag then
                    if inst.components.finiteuses and inst.components.finiteuses.current > 0 then
                        inst.components.named:SetName("修改版·" .. tostring(STRINGS.NAMES[inst.prefab:upper() .. "_NOT_EMPTY"]));
                    elseif inst.components.finiteuses then
                        inst.components.named:SetName("修改版·" .. tostring(STRINGS.NAMES[inst.prefab:upper()]));
                    end
                end
            end)
            inst:ListenForEvent("percentusedchange", function(inst, data)
                local percent = data and data.percent;
                if percent and inst.mi_ori_item_modify_tag then
                    if percent > 0 then
                        inst.components.named:SetName("修改版·" .. tostring(STRINGS.NAMES[inst.prefab:upper() .. "_NOT_EMPTY"]));
                    else
                        inst.components.named:SetName("修改版·" .. tostring(STRINGS.NAMES[inst.prefab:upper()]));
                    end
                end
            end)
        end

        -- 此处客机是不会执行的！！！OnSave OnPreLoad OnLoad
        local old_OnSave = inst.OnSave;
        inst.OnSave = function(inst, data)
            if old_OnSave then
                old_OnSave(inst, data);
            end
            --print(inst.prefab .. "-OnSave-tag: " .. tostring(inst.mi_ori_item_modify_tag));
            data.mi_ori_item_modify_tag = inst.mi_ori_item_modify_tag;
        end

        local old_OnPreLoad = inst.OnPreLoad;
        inst.OnPreLoad = function(inst, data)
            if old_OnPreLoad then
                old_OnPreLoad(inst, data);
            end
            if data then
                --print(inst.prefab .. "-OnPreLoad-tag: " .. tostring(data.mi_ori_item_modify_tag));
                inst.mi_ori_item_modify_tag = data.mi_ori_item_modify_tag;
                if inst.mi_ori_item_modify_tag then
                    for _, prefab_name in ipairs(PREFABS_TAB) do
                        if inst.prefab == prefab_name and fns[prefab_name .. "_onpreload"] then
                            fns[prefab_name .. "_onpreload"](inst);
                            break ;
                        end
                    end
                end
            end
        end

        local old_OnLoad = inst.OnLoad;
        inst.OnLoad = function(inst, data)
            if old_OnLoad then
                old_OnLoad(inst, data);
            end
            if data then
                --print(inst.prefab .. "-OnLoad-tag: " .. tostring(data.mi_ori_item_modify_tag));
                inst.mi_ori_item_modify_tag = data.mi_ori_item_modify_tag;
                if inst.mi_ori_item_modify_tag then
                    for _, prefab_name in ipairs(PREFABS_TAB) do
                        if inst.prefab == prefab_name and fns[prefab_name .. "_onload"] then
                            fns[prefab_name .. "_onload"](inst);
                            break ;
                        end
                    end
                end
            end
        end
    end)
end

-- 已经进行了条件判断，此函数直接执行即可！
local function original_items_modifications(player, prod, ...)
    if not (prod and prod:IsValid()) then
        return ;
    end
    prod.mi_ori_item_modify_tag = true;
    for _, prefab_name in ipairs(PREFABS_TAB) do
        if prod.prefab == prefab_name and player.mi_temp_recname == prefab_name .. "_copy" then
            if fns[prefab_name .. "_onpreload"] then
                fns[prefab_name .. "_onpreload"](prod);
            end
            if fns[prefab_name .. "_onload"] then
                fns[prefab_name .. "_onload"](prod);
            end
            break ;
        end
    end
    player.mi_temp_recname = nil;
end

env.AddPlayerPostInit(function(inst)
    if not TheWorld.ismastersim then
        return inst;
    end
    if inst.components.builder == nil then
        return inst;
    end
    local old_DoBuild = inst.components.builder.DoBuild;
    function inst.components.builder:DoBuild(recname, ...)
        self.inst.mi_temp_recname = recname;
        return old_DoBuild(self, recname, ...);
    end

    -- 此函数是在 DoBuild 内执行的！
    local old_onBuild = inst.components.builder.onBuild;
    inst.components.builder.onBuild = function(player, prod, ...)
        if old_onBuild then
            old_onBuild(player, prod, ...);
        end
        original_items_modifications(player, prod, ...);
    end
end)
-------------------------------------------------------------------------------------------------------
--[[ 制作栏和配方添加 ]]
-------------------------------------------------------------------------------------------------------
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
-------------------------------------------------------------------------------------------------------
local Recipes = {};
local Recipes_Locate = {};

Recipes_Locate["whip"] = true;
Recipes[#Recipes + 1] = {
    CanMake = env.GetModConfigData("whip"),
    name = "whip_copy",
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
    CanMake = env.GetModConfigData("wateringcan"),
    name = "wateringcan_copy",
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
    CanMake = env.GetModConfigData("premiumwateringcan"),
    name = "premiumwateringcan_copy",
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

--Recipes_Locate["telebase"] = true;
--Recipes[#Recipes + 1] = {
--    CanMake = env.GetModConfigData("telebase"),
--    name = "telebase_copy",
--    ingredients = {
--        Ingredient("nightmarefuel", 4), Ingredient("livinglog", 4), Ingredient("goldnugget", 8)
--    },
--    tech = TECH.NONE,
--    config = {
--        product = "telebase",
--        placer = nil,
--        min_spacing = nil,
--        nounlock = nil,
--        numtogive = 1,
--        builder_tag = nil,
--        atlas = "images/inventoryimages.xml",
--        image = "telebase.tex"
--    },
--    filters = {
--        "MONE_MORE_ITEMS_MODIFY"
--    }
--};

Recipes_Locate["batbat"] = true;
Recipes[#Recipes + 1] = {
    CanMake = env.GetModConfigData("batbat"),
    name = "batbat_copy",
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
    CanMake = env.GetModConfigData("nightstick"),
    name = "nightstick_copy",
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

for _, v in pairs(Recipes) do
    if v.CanMake then
        env.AddRecipe2(v.name, v.ingredients, v.tech, v.config, v.filters);
    end
end
