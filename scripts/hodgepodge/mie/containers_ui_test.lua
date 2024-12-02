---
--- @author zsh in 2023/2/5 14:17
---

local API = require("chang_mone.dsts.API");

local SetPosAccordingToScreenResolution;

if API.SetPosAccordingToScreenResolution then
    SetPosAccordingToScreenResolution = function(x, y, z)
        return API.SetPosAccordingToScreenResolution(x, y, z, env);
    end
else
    SetPosAccordingToScreenResolution = function(x, y, z)
        local width, height = TheSim:GetScreenSize();
        if env and not API.isDebug(env) then
            width, height = 1980, 1080;
        end
        local RESOLUTION_X, RESOLUTION_Y = 1980, 1080; -- 我的屏幕分辨率
        local ratio_x, ratio_y = width / RESOLUTION_X, height / RESOLUTION_Y;
        return Vector3(ratio_x * x, ratio_y * y, z);
    end
end

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
        pos = SetPosAccordingToScreenResolution(0, 200, 0),
        side_align_tip = 160
    },
    type = "chest",
    itemtestfn = function(container, item, slot)
        local exclude_prefabs = {

        }
        for _, v in ipairs(exclude_prefabs) do
            if v == item.prefab then
                return false;
            end
        end

        local exclude_tags = {
            "irreplaceable", "_container"
        }
        for _, v in ipairs(exclude_tags) do
            if item:HasTag(v) then
                return false;
            end
        end

        return true;
    end
}

params.mie_bear_skin_cabinet = {
    widget = {
        slotpos = {},
        animbank = "ui_chest_3x3",
        animbuild = "ui_chest_3x3",
        pos = SetPosAccordingToScreenResolution(0, 200, 0),
        side_align_tip = 160,
        buttoninfo = {
            text = "一键整理",
            position = SetPosAccordingToScreenResolution(0, -140, 0),
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
end

params.mie_sand_pit = {
    widget = {
        slotpos = {},
        --[[        animbank = "ui_largechest_5x5",
                animbuild = "ui_largechest_5x5",]]
        animbank = "my_chest_ui_5x5",
        animbuild = "my_chest_ui_5x5",
        pos = SetPosAccordingToScreenResolution(0, 200, 0),
        buttoninfo = {
            text = "一键捡起",
            position = SetPosAccordingToScreenResolution(0, -75 * 3 + 10, 0),
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
        --pos = SetPosAccordingToScreenResolution(0, 220, 0),
        pos = SetPosAccordingToScreenResolution(220, 220, 0),
        side_align_tip = 160,
        buttoninfo = {
            text = "一键整理",
            position = SetPosAccordingToScreenResolution(-125 + 90 + 30 + 1 + 2, -270 + 80 + 10 + 1 + 2, 0),
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
        pos = SetPosAccordingToScreenResolution(220, 220, 0),
        side_align_tip = 160,
        buttoninfo = {
            text = "一键整理",
            position = SetPosAccordingToScreenResolution(-125 + 90 + 30 + 1 + 2, -270 + 80 + 10 + 1 + 2, 0),
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

------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------

if config_data.mone_backpack_update then
    params.mone_backpack = {
        widget = {
            slotpos = {},
            animbank = "ui_piggyback_2x6",
            animbuild = "ui_piggyback_2x6",
            pos = SetPosAccordingToScreenResolution(690, -120 + 15 - 1 --[[+ 62]], 0),
            side_align_tip = 160,
            buttoninfo = {
                text = "一键整理",
                position = SetPosAccordingToScreenResolution(-125, -270, 0), -- 确定了，是第一象限！
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

if CAPACITY then
    params.mone_treasurechest = {
        widget = {
            slotpos = {},
            animbank = "my_chest_ui_6x6",
            animbuild = "my_chest_ui_6x6",
            pos = SetPosAccordingToScreenResolution(0, 200 + 20, 0),
            side_align_tip = 160,
            buttoninfo = {
                text = "一键整理",
                position = SetPosAccordingToScreenResolution(75 * 0, -75 * 3 - 37.5 + 5 - 20, 0),
                fn = fn,
                validfn = validfn;
            }
        },
        type = "chest",
    }

    for y = 2, -3, -1 do
        for x = -3, 2 do
            table.insert(params.mone_treasurechest.widget.slotpos, Vector3(75 * x + 37.5, 75 * y + 37.5, 0))
        end
    end

    params.mone_dragonflychest = deepcopy(params.mone_treasurechest);
    params.mone_icebox = deepcopy(params.mone_treasurechest);
    params.mone_saltbox = deepcopy(params.mone_treasurechest);

    function params.mone_icebox.itemtestfn(container, item, slot)
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

    function params.mone_saltbox.itemtestfn(container, item, slot)
        return ((item:HasTag("fresh") or item:HasTag("stale") or item:HasTag("spoiled"))
                and item:HasTag("cookable")
                and not item:HasTag("deployable")
                and not item:HasTag("smallcreature")
                and item.replica.health == nil)
                or item:HasTag("saltbox_valid")
    end
end

------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------

-- TODO: 目前可以存放的东西太多了！需要限制一下！
params.mie_granary_meats = {
    widget = {
        slotpos = {},
        animbank = "ui_zx_5x10",
        animbuild = "ui_zx_5x10",
        pos = SetPosAccordingToScreenResolution(0, 220, 0),
        side_align_tip = 160,
        buttoninfo = {
            text = "一键整理",
            position = SetPosAccordingToScreenResolution(0, -200 - 20 - 10, 0),
            fn = fn,
            validfn = validfn
        }
    },
    type = "chest",
    itemtestfn = function(container, item, slot)
        local p = cooking.ingredients[item.prefab];
        if not p then
            return false;
        end
        for _, v in ipairs({ "meat", "fish", "egg", "dairy", "fat" }) do
            if p.tags[v] then
                return true;
            end
        end
        return false;
    end
}

for y = 4, 0, -1 do
    for x = 0, 9 do
        local offsetX = x <= 4 and -20 or 10
        table.insert(params.mie_granary_meats.widget.slotpos, Vector3(80 * (x - 5) + 40 + offsetX, 80 * (y - 3) + 80, 0))
    end
end

params.mie_granary_greens = {
    widget = {
        slotpos = {},
        animbank = "ui_zx_5x10",
        animbuild = "ui_zx_5x10",
        pos = SetPosAccordingToScreenResolution(0, 220, 0),
        side_align_tip = 160,
        buttoninfo = {
            text = "一键整理",
            position = SetPosAccordingToScreenResolution(0, -200 - 10 - 20, 0),
            fn = fn,
            validfn = validfn
        }
    },
    type = "chest",
    itemtestfn = function(container, item, slot)
        if item:HasTag("deployedfarmplant") then
            return true;
        end
        local p = cooking.ingredients[item.prefab];
        if not p then
            return false;
        end
        for _, v in ipairs({ "veggie", "fruit", "seed", "sweetener", "decoration" }) do
            if p.tags[v] then
                return true;
            end
        end
        return false;
    end
}

for y = 4, 0, -1 do
    for x = 0, 9 do
        local offsetX = x <= 4 and -20 or 10
        table.insert(params.mie_granary_greens.widget.slotpos, Vector3(80 * (x - 5) + 40 + offsetX, 80 * (y - 3) + 80, 0))
    end
end

------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------

for k, v in pairs(params) do
    containers.MAXITEMSLOTS = math.max(containers.MAXITEMSLOTS, v.widget.slotpos ~= nil and #v.widget.slotpos or 0)
end