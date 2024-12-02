---
--- @author zsh in 2023/2/5 14:17
---

-- 在修改屏幕自适应的时候发现
-- 官方添加按钮，或者说官方的ui，都是可以自适应的！
-- 如果我真的有这个自适应的需求的话，我可以去找找看！

local API = require("chang_mone.dsts.API");

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

local StorageButton = API.StorageButton;

local storage_fn = StorageButton and StorageButton.storage_fn or ShiHao.DoNothing;
local storage_validfn = StorageButton and StorageButton.storage_validfn or ShiHao.DoNothing;

local function isIcebox(container, item, slot)
    if item:HasTag("icebox_valid") then
        return true
    end

    --Perishable
    if not (item:HasTag("fresh") or item:HasTag("stale") or item:HasTag("spoiled")) then
        return false
    end

    if item:HasTag("smallcreature") then
        return false
    end

    --Edible
    for k, v in pairs(FOODTYPE) do
        if item:HasTag("edible_" .. v) then
            return true
        end
    end

    return false
end

local function isSaltbox(container, item, slot)
    return ((item:HasTag("fresh") or item:HasTag("stale") or item:HasTag("spoiled"))
            and item:HasTag("cookable")
            and not item:HasTag("deployable")
            and not item:HasTag("smallcreature")
            and item.replica.health == nil)
            or item:HasTag("saltbox_valid")
end

local containers = require("containers");
local params = containers.params;

local cooking = require("cooking");

local config_data = TUNING.MIE_TUNING.MOD_CONFIG_DATA;
--local CAPACITY = config_data.chests_boxs_capacity;

------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------

params.mie_relic_2 = {
    widget = {
        slotpos = {
            Vector3(0 + 2, 0, 0)
        },
        animbank = "my_ui_cookpot_1x1",
        animbuild = "my_ui_cookpot_1x1",
        pos = Vector3(0, 200, 0),
        side_align_tip = 160
    },
    type = "chest",
}

-- NEW!
local mie_relic_2_Remaking = false;
if mie_relic_2_Remaking then
    params.mie_relic_2 = {
        widget = {
            slotpos = {},
            animbank = "ui_chest_3x3",
            animbuild = "ui_chest_3x3",
            pos = Vector3(0, 200, 0),
            side_align_tip = 160,
        },
        acceptsstacks = false,
        type = "chest",
    }

    for y = 2, 0, -1 do
        for x = 0, 2 do
            table.insert(params.mie_relic_2.widget.slotpos, Vector3(80 * x - 80 * 2 + 80, 80 * y - 80 * 2 + 80, 0))
        end
    end
end

-- !!!
params.mie_relic_2.itemtestfn = function(container, item, slot)
    for _, v in ipairs({}) do
        if v == item.prefab then
            return false;
        end
    end
    for _, v in ipairs({ "irreplaceable", "_container", "bundle", "nobundling" }) do
        if item:HasTag(v) then
            return false;
        end
    end

    return true;
end

--[[params.mie_bear_skin_cabinet = {
    widget = {
        slotpos = {},
        animbank = "ui_chest_3x3",
        animbuild = "ui_chest_3x3",
        pos = Vector3(0, 200, 0),
        side_align_tip = 160,
        buttoninfo = {
            text = "一键整理",
            position = Vector3(0, -140, 0),
            fn = fn,
            validfn = validfn
        }
    },
    type = "chest",
    itemtestfn = function(container, item, slot)
        if item:HasTag("_perishable_mie") then
            return true;
        end
        return false;
    end
}

for y = 2, 0, -1 do
    for x = 0, 2 do
        table.insert(params.mie_bear_skin_cabinet.widget.slotpos, Vector3(80 * x - 80 * 2 + 80, 80 * y - 80 * 2 + 80, 0))
    end
end]]

params.mie_bear_skin_cabinet = {
    widget = {
        slotpos = {},
        animbank = "ui_chester_shadow_3x4",
        animbuild = "ui_chester_shadow_3x4",
        pos = Vector3(0, 220, 0),
        side_align_tip = 160,
        buttoninfo = {
            text = "一键整理",
            position = Vector3(0, -140 - 25 - 5 - 3 - 3, 0),
            fn = fn,
            validfn = validfn
        },
        more_items_storage_buttoninfo = {
            text = "收纳",
            position = Vector3(-1, 177, 0),
            fn = storage_fn,
            validfn = storage_validfn
        };
    },
    type = "chest",
    itemtestfn = function(container, item, slot)
        if item:HasTag("_perishable_mie") then
            return true;
        end
        return false;
    end
}

for y = 2.5, -0.5, -1 do
    for x = 0, 2 do
        table.insert(params.mie_bear_skin_cabinet.widget.slotpos, Vector3(75 * x - 75 * 2 + 75, 75 * y - 75 * 2 + 75, 0))
    end
end

params.mie_sand_pit = {
    widget = {
        slotpos = {},
        --[[        animbank = "ui_largechest_5x5",
                animbuild = "ui_largechest_5x5",]]
        animbank = "my_chest_ui_5x5",
        animbuild = "my_chest_ui_5x5",
        pos = Vector3(0, 200, 0),
        buttoninfo = {
            text = "一键捡起",
            position = Vector3(0, -75 * 3 + 10, 0),
            fn = function(inst, doer)
                if inst.components.container ~= nil then
                    API.AutoSorter.pickObjectOnFloorOnClick(inst);
                elseif inst.replica.container ~= nil and not inst.replica.container:IsBusy() then
                    SendRPCToServer(RPC.DoWidgetButtonAction, nil, inst, nil);
                end
            end,
            validfn = function(inst)
                return true;
            end
        }
    },
    type = "chest",
    itemtestfn = function(inst, item, slot)
        if item:HasTag("_container") then
            return false;
        end
        return true;
    end
}

--[[for y = 3, -1, -1 do
    for x = -1, 3 do
        table.insert(params.mie_sand_pit.widget.slotpos, Vector3(80 * x - 80 * 2 + 80, 80 * y - 80 * 2 + 80, 0))
    end
end]]

for y = 2, -2, -1 do
    for x = -2, 2 do
        table.insert(params.mie_sand_pit.widget.slotpos, Vector3(75 * x, 75 * y, 0))
    end
end

params.mie_book_silviculture = {
    widget = {
        slotpos = {},
        animbank = "ui_chester_shadow_3x4",
        animbuild = "ui_chester_shadow_3x4",
        --pos = Vector3(0, 220, 0),
        pos = Vector3(220, 220, 0),
        --pos = Vector3(453, -74, 0),
        side_align_tip = 160,
        buttoninfo = {
            text = "一键整理",
            position = Vector3(-2, -177, 0),
            fn = function(inst, doer)
                if inst.components.container ~= nil then
                    API.arrangeContainer(inst);
                elseif inst.replica.container ~= nil and not inst.replica.container:IsBusy() then
                    SendRPCToServer(RPC.DoWidgetButtonAction, nil, inst, nil)
                end
            end,
            validfn = function(inst)
                return inst.replica.container ~= nil and not inst.replica.container:IsEmpty()
            end
        }
    },
    type = "chest_simplebooks",
    itemtestfn = function(container, item, slot)
        if container.inst.prefab == item.prefab then
            return false;
        end
        return not (item:HasTag("irreplaceable") or item:HasTag("_container") or item:HasTag("bundle") or item:HasTag("nobundling"));
    end
}

for y = 2.5, -0.5, -1 do
    for x = 0, 2 do
        table.insert(params.mie_book_silviculture.widget.slotpos, Vector3(75 * x - 75 * 2 + 75, 75 * y - 75 * 2 + 75, 0))
    end
end

params.mie_book_horticulture = {
    widget = {
        slotpos = {},
        animbank = "ui_chester_shadow_3x4",
        animbuild = "ui_chester_shadow_3x4",
        pos = Vector3(220, 220, 0),
        side_align_tip = 160,
        buttoninfo = {
            text = "一键整理",
            position = Vector3(-125 + 90 + 30 + 1 + 2, -270 + 80 + 10 + 1 + 2, 0),
            fn = function(inst, doer)
                if inst.components.container ~= nil then
                    API.arrangeContainer(inst);
                elseif inst.replica.container ~= nil and not inst.replica.container:IsBusy() then
                    SendRPCToServer(RPC.DoWidgetButtonAction, nil, inst, nil)
                end
            end,
            validfn = function(inst)
                return inst.replica.container ~= nil and not inst.replica.container:IsEmpty()
            end
        }
    },
    type = "chest_simplebooks",
    itemtestfn = function(container, item, slot)
        if container.inst.prefab == item.prefab then
            return false;
        end
        return not (item:HasTag("irreplaceable") or item:HasTag("_container") or item:HasTag("bundle") or item:HasTag("nobundling"));
    end
}

for y = 2.5, -0.5, -1 do
    for x = 0, 2 do
        table.insert(params.mie_book_horticulture.widget.slotpos, Vector3(75 * x - 75 * 2 + 75, 75 * y - 75 * 2 + 75, 0))
    end
end

params.mie_watersource = {
    widget = {
        slotpos = {},
        animbank = "my_chest_ui_5x5",
        animbuild = "my_chest_ui_5x5",
        pos = Vector3(0, 200, 0),
        buttoninfo = {
            text = "一键整理",
            position = Vector3(0, -75 * 3 + 10, 0),
            fn = fn,
            validfn = validfn
        }
    },
    type = "chest",
    itemtestfn = function(container, item, slot)
        local recipes = CRAFTING_FILTERS.GARDENING.recipes;
        if recipes and type(recipes) == "table" then
            for _, v in ipairs(recipes) do
                if item.prefab == v then
                    return true;
                end
            end
        end
        if item:HasTag("hammer")
                or item:HasTag("fertilizerresearchable")
        then
            return true;
        end
        if item.prefab == "shovel"
                or item.prefab == "goldenshovel"
                or item.prefab == "hammer"
                or item.prefab == "horn"
                or item.prefab == "fruitflyfruit"
                or item.prefab == "nutrientsgoggleshat"
                or item.prefab == "mie_yjp"
                or item.prefab == "mie_bananafan_big"
                or item.prefab == "cookbook"
        then
            return true;
        end

        return false;
    end
}

for y = 2, -2, -1 do
    for x = -2, 2 do
        table.insert(params.mie_watersource.widget.slotpos, Vector3(75 * x, 75 * y, 0))
    end
end

params.mie_fish_box = {
    widget = {
        slotpos = {},
        animbank = "ui_zx_5x10", -- 这玩意移动的时候经常有 bug，应该是动画文件的问题！
        animbuild = "ui_zx_5x10",
        pos = Vector3(0, 220, 0),
        side_align_tip = 160,
        buttoninfo = {
            text = "一键整理",
            position = Vector3(0, -200 - 20 - 10, 0),
            fn = fn,
            validfn = validfn
        }
    },
    type = "chest",
}

for y = 4, 0, -1 do
    for x = 0, 9 do
        local offsetX = x <= 4 and -20 or 10
        table.insert(params.mie_fish_box.widget.slotpos, Vector3(80 * (x - 5) + 40 + offsetX, 80 * (y - 3) + 80, 0))
    end
end

-- NEW
params.mie_fish_box = nil;

local fish_box_vars = {
    animbank = "ui_chest_5x12",
    animbuild = "ui_chest_5x12",
    X = 11, Y = 4, posX = 98, posY = 42,
    pos = Vector3(360 - (60 * 4.5), 150 + 80, 0)
}
fish_box_vars.button_pos = Vector3(10 + 80 * fish_box_vars.X / 2 - 346 * 2 + fish_box_vars.posX, 80 * 0 - 100 * 2 + fish_box_vars.posY - 53, 0)

params.mie_fish_box = {
    widget = {
        slotpos = {},
        animbank = fish_box_vars.animbank,
        animbuild = fish_box_vars.animbuild,
        pos = fish_box_vars.pos,
        side_align_tip = 160,
        buttoninfo = {
            text = "一键整理",
            position = fish_box_vars.button_pos,
            fn = fn,
            validfn = validfn
        }
    },
    type = "chest",
}

for y = fish_box_vars.Y, 0, -1 do
    for x = 0, fish_box_vars.X do
        table.insert(params.mie_fish_box.widget.slotpos, Vector3(80 * x - 346 * 2 + fish_box_vars.posX, 80 * y - 100 * 2 + fish_box_vars.posY, 0))
    end
end

params.mie_fish_box.itemtestfn = function(container, item, slot)
    -- 不要种子库了，储藏库！
    if true then
        if item:HasTag("_perishable_mone") then
            return true;
        end
        if isIcebox(container, item, slot) then
            return true;
        end
        if isSaltbox(container, item, slot) then
            return true;
        end
        return false;
    end

    -- 蔬菜、水果、种子、杂草
    if item.prefab == "berries"
            or (not item:HasTag("cookable"))
    then
        return false;
    end
    if item.prefab == "pineananas"
            or item.prefab == "firenettles"
            or item.prefab == "forgetmelots"
            or item.prefab == "tillweed"
            or item:HasTag("deployedfarmplant")
    then
        return true;
    end
    local p = cooking.ingredients[item.prefab];
    if not p then
        return false;
    end
    for _, v in ipairs({ "veggie", "fruit", "seed" }) do
        if p.tags[v] then
            return true;
        end
    end
    return false;
end

------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------

if config_data.mone_backpack_update then
    params.mone_backpack = {
        widget = {
            slotpos = {},
            animbank = "ui_piggyback_2x6",
            animbuild = "ui_piggyback_2x6",
            pos = Vector3(690, -120 + 15 - 1 --[[+ 62]], 0),
            side_align_tip = 160,
            buttoninfo = {
                text = "一键整理",
                position = Vector3(-125, -270, 0), -- 确定了，是第一象限！
                fn = function(inst, doer)
                    if inst.components.container ~= nil then
                        API.arrangeContainer(inst);
                    elseif inst.replica.container ~= nil and not inst.replica.container:IsBusy() then
                        SendRPCToServer(RPC.DoWidgetButtonAction, nil, inst, nil)
                    end
                end,
                validfn = function(inst)
                    return inst.replica.container ~= nil and not inst.replica.container:IsEmpty()
                end
            }
        },
        type = "mone_bag",
        itemtestfn = function(container, item, slot)
            if not TUNING.MONE_TUNING.GET_MOD_CONFIG_DATA.cane_gointo_mone_backpack then
                if item.prefab == "cane" then
                    return false;
                end
            end
            return item:HasTag("_equippable");
        end
    }
    for y = 0, 5 do
        table.insert(params.mone_backpack.widget.slotpos, Vector3(-162, -75 * y + 170, 0))
        table.insert(params.mone_backpack.widget.slotpos, Vector3(-162 + 75, -75 * y + 170, 0))
    end
end

--[[params.mie_watersource = {
    widget = {
        slotpos = {},
        animbank = "my_chest_ui_4x4",
        animbuild = "my_chest_ui_4x4",
        pos = Vector3(0, 200, 0),
        buttoninfo = {
            text = "一键整理",
            position = Vector3(0, -190, 0),
            fn = fn,
            validfn = validfn
        }
    },
    type = "chest",
    itemtestfn = function(container, item, slot)
        local recipes = CRAFTING_FILTERS.GARDENING.recipes;
        if recipes and type(recipes) == "table" then
            for _, v in ipairs(recipes) do
                if item.prefab == v then
                    return true;
                end
            end
        end
        if item:HasTag("hammer")
            or item:HasTag("fertilizerresearchable")
        then
            return true;
        end
        if item.prefab == "shovel"
                or item.prefab == "goldenshovel"
                or item.prefab == "hammer"
        then
            return true;
        end

        return false;
    end
}

for y = 2, -1, -1 do
    for x = -1, 2 do
        table.insert(params.mie_watersource.widget.slotpos, Vector3(80 * x - 40, 80 * y - 40, 0))
    end
end]]


--if CAPACITY then
--    params.mone_treasurechest = {
--        widget = {
--            slotpos = {},
--            animbank = "my_chest_ui_6x6",
--            animbuild = "my_chest_ui_6x6",
--            pos = Vector3(0, 200 + 20, 0),
--            side_align_tip = 160,
--            buttoninfo = {
--                text = "一键整理",
--                position = Vector3(75 * 0, -75 * 3 - 37.5 + 5 - 20, 0),
--                fn = fn,
--                validfn = validfn;
--            }
--        },
--        type = "chest",
--    }
--
--    for y = 2, -3, -1 do
--        for x = -3, 2 do
--            table.insert(params.mone_treasurechest.widget.slotpos, Vector3(75 * x + 37.5, 75 * y + 37.5, 0))
--        end
--    end
--
--    params.mone_dragonflychest = deepcopy(params.mone_treasurechest);
--    params.mone_icebox = deepcopy(params.mone_treasurechest);
--    params.mone_saltbox = deepcopy(params.mone_treasurechest);
--
--    function params.mone_icebox.itemtestfn(container, item, slot)
--        if item:HasTag("icebox_valid") then
--            return true
--        end
--
--        --Perishable
--        if not (item:HasTag("fresh") or item:HasTag("stale") or item:HasTag("spoiled")) then
--            return false
--        end
--
--        if item:HasTag("smallcreature") then
--            return false
--        end
--
--        --Edible
--        for k, v in pairs(FOODTYPE) do
--            if item:HasTag("edible_" .. v) then
--                return true
--            end
--        end
--
--        return false
--    end
--
--    function params.mone_saltbox.itemtestfn(container, item, slot)
--        return ((item:HasTag("fresh") or item:HasTag("stale") or item:HasTag("spoiled"))
--                and item:HasTag("cookable")
--                and not item:HasTag("deployable")
--                and not item:HasTag("smallcreature")
--                and item.replica.health == nil)
--                or item:HasTag("saltbox_valid")
--    end
--end

--[[if config_data.candybag_itemtestfn then
    if params.mone_candybag then
        local old_itemtestfn = params.mone_candybag.itemtestfn;
        params.mone_candybag.itemtestfn = function(container, item, slot)
            if old_itemtestfn(container, item, slot) then
                return true;
            end
            -- 补充
            local recipes = CRAFTING_FILTERS.REFINE.recipes;
            if recipes and type(recipes) == "table" then
                for _, v in ipairs(recipes) do
                    if item.prefab == v then
                        return true;
                    end
                end
            end
            if item.prefab == "nitre"
                    or item.prefab == "cutreeds"
                    or item.prefab == "marble"
            then
                return true;
            end

            return false;
        end
    end
end]]

------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------

for k, v in pairs(params) do
    containers.MAXITEMSLOTS = math.max(containers.MAXITEMSLOTS, v.widget.slotpos ~= nil and #v.widget.slotpos or 0)
end