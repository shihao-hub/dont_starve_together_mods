---
--- @author zsh in 2023/3/1 8:31
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

local containers = require("containers");
local params = containers.params;

local cooking = require("cooking");

local config_data = TUNING.MIE_TUNING.MOD_CONFIG_DATA;

------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------

-- 谷仓
params.mie_new_granary = {
    widget = {
        slotpos = {},
        animbank = "ui_zx_5x10",
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
    itemtestfn = function(container, item, slot)
        -- 蔬菜、水果、种子、部分杂草
        if table.contains({
            "pineananas","firenettles","forgetmelots","tillweed",
        }, item.prefab) then
            return true;
        end

        if table.contains({
            "berries","",
        }, item.prefab) then
            return false;
        end

        -- 呃，爆米花鱼和曼德拉草要排除

        if not item:HasTag("cookable") then
            return false;
        end
        if item:HasTag("deployedfarmplant") then
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
}

for y = 4, 0, -1 do
    for x = 0, 9 do
        local offsetX = x <= 4 and -20 or 10
        table.insert(params.mie_new_granary.widget.slotpos, Vector3(80 * (x - 5) + 40 + offsetX, 80 * (y - 3) + 80, 0))
    end
end

params.mie_granary_meats = {
    widget = {
        slotpos = {},
        animbank = "ui_zx_5x10",
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
        pos = Vector3(0, 220, 0),
        side_align_tip = 160,
        buttoninfo = {
            text = "一键整理",
            position = Vector3(0, -200 - 10 - 20, 0),
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