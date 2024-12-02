---
--- @author zsh in 2023/4/24 14:42
---

local API = require("chang_mone.dsts.API");
local TEXT = require("languages.mone.loc");

local config_data = TUNING.MONE_TUNING.GET_MOD_CONFIG_DATA;

local containers = require("containers");
local params = containers.params;

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

if params.wateringcan == nil and config_data.wateringcan then
    params.wateringcan = {
        more_items_tag = true;
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
end

if params.premiumwateringcan == nil and config_data.premiumwateringcan then
    -- 不舒服，hand_inv 让格子有点小。
    params.premiumwateringcan = {
        more_items_tag = true;
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
end

for k, v in pairs(params) do
    containers.MAXITEMSLOTS = math.max(containers.MAXITEMSLOTS, v.widget.slotpos ~= nil and #v.widget.slotpos or 0)
end