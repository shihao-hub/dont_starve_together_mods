---
--- @author zsh in 2023/1/10 4:52
---

local config_data = TUNING.MONE_TUNING.GET_MOD_CONFIG_DATA;

local SCROLL = config_data.scroll_containers;

local NEW_BUTTON = true; -- 不明显，算了？emm，纠结

local API = require("chang_mone.dsts.API");
local TEXT = require("languages.mone.loc");

local cooking = require("cooking");

local emoji = {
    pigman = "󰀐",
    palm = "󰀮",
}

emoji.palm = "󰀘"; -- 战斗图标，先这样吧，懒得改了。

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

------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------
local mone_chests_boxs_capability = TUNING.MONE_TUNING.GET_MOD_CONFIG_DATA.mone_chests_boxs_capability;
-- 我去，有个坑，我应该加个 else 的，因为 mone_chests_boxs_capability 之前缓存的值是 bool 型...
if mone_chests_boxs_capability == 1 then
    params.mone_dragonflychest = {
        widget = {
            slotpos = {},
            animbank = "my_chest_ui_4x4",
            animbuild = "my_chest_ui_4x4",
            pos = Vector3(0, 200, 0),
            buttoninfo = {
                text = TEXT.TIDY,
                position = Vector3(0, -190, 0),
                fn = fn,
                validfn = validfn
            }
        },
        type = "chest",
    }

    for y = 2, -1, -1 do
        for x = -1, 2 do
            table.insert(params.mone_dragonflychest.widget.slotpos, Vector3(80 * x - 40, 80 * y - 40, 0))
        end
    end

    if SCROLL and false --[[ 也很难受，算了 ]] then
        params.mone_dragonflychest.widget.slotpos = {};
        params.mone_dragonflychest.widget.more_items_scroll = {
            num_visible_rows = 4,
            num_columns = 4,
            scroll_data = {
                widget_width = 75,
                widget_height = 75,
                scrollbar_offset = 10,
                scrollbar_height_offset = nil,
                pos = Vector3(-7, 0, 0),
            }
        };
        for y = 2, -1, -1 do
            for x = -1, 2 do
                table.insert(params.mone_dragonflychest.widget.slotpos, Vector3(80 * x - 40, 80 * y - 40, 0))
            end
        end
        for y = 2, -1, -1 do
            for x = -1, 2 do
                table.insert(params.mone_dragonflychest.widget.slotpos, Vector3(80 * x - 40, 80 * y - 40, 0))
            end
        end
    end
elseif mone_chests_boxs_capability == 2 then
    params.mone_dragonflychest = {
        widget = {
            slotpos = {},
            animbank = "my_chest_ui_5x5",
            animbuild = "my_chest_ui_5x5",
            pos = Vector3(0, 200, 0),
            buttoninfo = {
                text = TEXT.TIDY,
                position = Vector3(0, -75 * 3 + 10, 0),
                fn = fn,
                validfn = validfn
            }
        },
        type = "chest",
    }

    for y = 2, -2, -1 do
        for x = -2, 2 do
            table.insert(params.mone_dragonflychest.widget.slotpos, Vector3(75 * x, 75 * y, 0))
        end
    end
elseif mone_chests_boxs_capability == 3 then
    params.mone_dragonflychest = {
        widget = {
            slotpos = {},
            animbank = "my_chest_ui_6x6",
            animbuild = "my_chest_ui_6x6",
            pos = Vector3(0, 200 + 20, 0),
            side_align_tip = 160,
            buttoninfo = {
                text = TEXT.TIDY,
                position = Vector3(75 * 0, -75 * 3 - 37.5 + 5 - 20, 0),
                fn = fn,
                validfn = validfn;
            }
        },
        type = "chest",
    }

    for y = 2, -3, -1 do
        for x = -3, 2 do
            table.insert(params.mone_dragonflychest.widget.slotpos, Vector3(75 * x + 37.5, 75 * y + 37.5, 0))
        end
    end
else
    -- 保证安全性
    params.mone_dragonflychest = {
        widget = {
            slotpos = {},
            animbank = "my_chest_ui_4x4",
            animbuild = "my_chest_ui_4x4",
            pos = Vector3(0, 200, 0),
            buttoninfo = {
                text = TEXT.TIDY,
                position = Vector3(0, -190, 0),
                fn = fn,
                validfn = validfn
            }
        },
        type = "chest",
    }

    for y = 2, -1, -1 do
        for x = -1, 2 do
            table.insert(params.mone_dragonflychest.widget.slotpos, Vector3(80 * x - 40, 80 * y - 40, 0))
        end
    end
end

-- 修改！
params.mone_treasurechest = deepcopy(params.mone_dragonflychest);
params.mone_icebox = deepcopy(params.mone_dragonflychest);
params.mone_saltbox = deepcopy(params.mone_dragonflychest);

function params.mone_icebox.itemtestfn(container, item, slot)
    return isIcebox(container, item, slot);
end

function params.mone_saltbox.itemtestfn(container, item, slot)
    return isSaltbox(container, item, slot);
end

params.mone_waterchest = {
    widget = {
        slotpos = {},
        animbank = "big_box_ui_120",
        animbuild = "big_box_ui_120",
        pos = Vector3(0, 0 + 100, 0),
        buttoninfo = {
            text = TEXT.TIDY,
            position = Vector3(-5, 193, 0), --数字诡异因为背景图调的不好
            fn = fn,
            validfn = validfn
        }
    },
    type = "mone_waterchest",
    itemtestfn = function(container, item, slot)
        if item.prefab == "mone_waterchest_inv" then
            return false;
        end
        if item:HasTag("_container") then
            return false;
        end
        return true;
    end
}

local spacer = 30 --间距
local posX = nil --x
local posY = nil --y
for z = 0, 2 do
    for y = 7, 0, -1 do
        for x = 0, 4 do
            posX = 80 * x - 600 + 80 * 5 * z + spacer * z
            posY = 80 * y - 100

            if y > 3 then
                posY = posY + spacer
            end

            table.insert(params.mone_waterchest.widget.slotpos, Vector3(posX, posY, 0))
        end
    end
end

-- 修改！
params.mone_minotaurchest = deepcopy(params.mone_waterchest);

local GetNumSlots = 40
local my_storeroom_animbank = nil
local my_storeroom_animbuild = nil
local my_storeroom_X = nil
local my_storeroom_Y = nil
local my_storeroom_posX = nil
local my_storeroom_posY = nil
local my_storeroom_button_pos = nil

if GetNumSlots == 20 then
    my_storeroom_animbank = "ui_chest_4x5"
    my_storeroom_animbuild = "ui_chest_4x5"
    my_storeroom_X = 4
    my_storeroom_Y = 3
    my_storeroom_posX = 90
    my_storeroom_posY = 130
    my_storeroom_button_pos = Vector3(80 * my_storeroom_X / 2 - 346 * 2 + my_storeroom_posX, 80 * 0 - 100 * 2 + my_storeroom_posY - 53, 0)
elseif GetNumSlots == 40 and true then
    my_storeroom_animbank = "ui_chest_5x8"
    my_storeroom_animbuild = "ui_chest_5x8"
    my_storeroom_X = 7
    my_storeroom_Y = 4
    my_storeroom_posX = 109
    my_storeroom_posY = 42
    my_storeroom_button_pos = Vector3(80 * my_storeroom_X / 2 - 346 * 2 + my_storeroom_posX, 80 * 0 - 100 * 2 + my_storeroom_posY - 53, 0)
elseif GetNumSlots == 60 and true then
    my_storeroom_animbank = "ui_chest_5x12"
    my_storeroom_animbuild = "ui_chest_5x12"
    my_storeroom_X = 11
    my_storeroom_Y = 4
    my_storeroom_posX = 98
    my_storeroom_posY = 42
    my_storeroom_button_pos = Vector3(80 * my_storeroom_X / 2 - 346 * 2 + my_storeroom_posX, 80 * 0 - 100 * 2 + my_storeroom_posY - 53, 0)
elseif GetNumSlots == 80 and true then
    my_storeroom_animbank = "ui_chest_5x16"
    my_storeroom_animbuild = "ui_chest_5x16"
    my_storeroom_X = 15
    my_storeroom_Y = 4
    my_storeroom_posX = 91
    my_storeroom_posY = 42
    my_storeroom_button_pos = Vector3(80 * my_storeroom_X / 2 - 346 * 2 + my_storeroom_posX, 80 * 0 - 100 * 2 + my_storeroom_posY - 53, 0)
end
--储藏室
params.mone_terrariumchest = {
    widget = {
        slotpos = {},
        animbank = my_storeroom_animbank,
        animbuild = my_storeroom_animbuild,
        pos = Vector3(360 - (GetNumSlots * 4.5), 150, 0),
        buttoninfo = {
            text = TEXT.TIDY,
            position = my_storeroom_button_pos,
            fn = fn,
            validfn = validfn
        }
    },
    type = "chest",
    itemtestfn = function(container, item, slot)
        if item.prefab == container.prefab or item:HasTag("_container") then
            return false;
        end
        return true;
    end
}
for y = my_storeroom_Y, 0, -1 do
    for x = 0, my_storeroom_X do
        table.insert(params.mone_terrariumchest.widget.slotpos, Vector3(80 * x - 346 * 2 + my_storeroom_posX, 80 * y - 100 * 2 + my_storeroom_posY, 0))
    end
end

-- 修改！
params.mone_piggyback = {
    widget = {
        slotpos = {},
        animbank = my_storeroom_animbank,
        animbuild = my_storeroom_animbuild,
        --pos = GetNumSlots ~= 40 and Vector3(360 - (GetNumSlots * 4.5), 150, 0)
        --        or Vector3(360 - (40 * 4.5) - 600 + 80, 150 + 200 - 50, 0),
        pos = Vector3(360 - (GetNumSlots * 4.5), 150, 0),
        buttoninfo = {
            text = TEXT.TIDY,
            position = my_storeroom_button_pos,
            fn = fn,
            validfn = validfn
        }
    },
    type = "mone_piggyback",
    itemtestfn = function(container, item, slot)
        if --[[item.prefab == container.inst.prefab or]] item:HasTag("_container") then
            return false;
        end
        return true;
    end
}
for y = my_storeroom_Y, 0, -1 do
    for x = 0, my_storeroom_X do
        table.insert(params.mone_piggyback.widget.slotpos, Vector3(80 * x - 346 * 2 + my_storeroom_posX, 80 * y - 100 * 2 + my_storeroom_posY, 0))
    end
end


-- 修改！进阶雪球发射器
params.mone_firesuppressor = {
    widget = {
        slotpos = {},
        animbank = "my_chest_ui_5x5",
        animbuild = "my_chest_ui_5x5",
        pos = Vector3(0, 200, 0),
        buttoninfo = {
            text = TEXT.PICK,
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
    itemtestfn = function(container, item, slot)
        if item:HasTag("_container") then
            return false;
        end
        return true;
    end
}

for y = 2, -2, -1 do
    for x = -2, 2 do
        table.insert(params.mone_firesuppressor.widget.slotpos, Vector3(75 * x, 75 * y, 0))
    end
end

params.mone_chiminea = {
    widget = {
        slotpos = {},
        animbank = "ui_chest_3x3",
        animbuild = "ui_chest_3x3",
        pos = Vector3(0, 200, 0),
        side_align_tip = 160,
        buttoninfo = {
            text = TEXT.DELETE,
            position = Vector3(0, -140, 0),
            fn = function(inst, doer)
                if inst.components.container then
                    --local age_in_days = inst.components.age and inst.components.age:GetDisplayAgeInDays();
                    --local visitorAge = 20;
                    --if age_in_days and age_in_days < visitorAge then
                    --    if doer.components.talker then
                    --        local msg = "我只存活了：" .. tostring(age_in_days) .. "天，不足 " .. tostring(visitorAge) .. " 天，因此我无法销毁物品！";
                    --        doer.components.talker:Say(msg);
                    --    end
                    --    return ;
                    --end
                    if inst.components.container then
                        -- 这个 RemoveAllItems 不调用 Remove 的话会出问题的！
                        for _, v in pairs(inst.components.container:RemoveAllItems()) do
                            if v and v:IsValid() then
                                if v.prefab then
                                    print(v.prefab .. " Remove()")
                                end
                                -- 永远吃不完系列补丁：忽略吧，没用了。
                                if v:HasTag("mie_inf_food") then
                                    v.mie_remove = true;
                                end
                                v:Remove();
                            end
                        end
                        inst.SoundEmitter:PlaySound("dontstarve/common/fireOut")
                    end
                elseif inst.replica.container and not inst.replica.container:IsBusy() then
                    SendRPCToServer(RPC.DoWidgetButtonAction, nil, inst, nil)
                end
            end,
            validfn = function(inst)
                return inst.replica.container ~= nil and not inst.replica.container:IsEmpty()
            end
        }
    },
    type = "chest",
    itemtestfn = function(container, item, slot)
        return not (item:HasTag("irreplaceable") or item:HasTag("_container") or item:HasTag("bundle") or item:HasTag("nobundling"))
    end
}
for y = 2, 0, -1 do
    for x = 0, 2 do
        table.insert(params.mone_chiminea.widget.slotpos, Vector3(80 * x - 80 * 2 + 80, 80 * y - 80 * 2 + 80, 0))
    end
end

local function hat_slot()
    return { image = "wardrobe_hat_slot.tex", atlas = "images/uiimages/wardrobe_hat_slot.xml" };
end

local function chest_slot()
    return { image = "wardrobe_chest_slot.tex", atlas = "images/uiimages/wardrobe_chest_slot.xml" };
end

local function tool_slot()
    return { image = "wardrobe_tool_slot.tex", atlas = "images/uiimages/wardrobe_tool_slot.xml" };
end

params.mone_wardrobe = {
    widget = {
        slotpos = {},
        animbank = "my_chest_ui_6x6",
        animbuild = "my_chest_ui_6x6",
        pos = Vector3(0, 200, 0),
        side_align_tip = 160,
        slotbg = TUNING.MONE_TUNING.GET_MOD_CONFIG_DATA.wardrobe_background and {
            --hat_slot(); hat_slot(); hat_slot(); hat_slot(); hat_slot(); hat_slot();
            --chest_slot(); chest_slot(); chest_slot(); chest_slot(); chest_slot(); chest_slot();
            --tool_slot(); tool_slot(); tool_slot(); tool_slot(); tool_slot(); tool_slot();
            --hat_slot(); hat_slot(); hat_slot(); hat_slot(); hat_slot(); hat_slot();
            --chest_slot(); chest_slot(); chest_slot(); chest_slot(); chest_slot(); chest_slot();
            --tool_slot(); tool_slot(); tool_slot(); tool_slot(); tool_slot(); tool_slot();
            { image = "wardrobe_hat_slot.tex", atlas = "images/uiimages/wardrobe_hat_slot.xml" },
            { image = "wardrobe_chest_slot.tex", atlas = "images/uiimages/wardrobe_chest_slot.xml" },
            { image = "wardrobe_tool_slot.tex", atlas = "images/uiimages/wardrobe_tool_slot.xml" },
            { image = "wardrobe_hat_slot.tex", atlas = "images/uiimages/wardrobe_hat_slot.xml" },
            { image = "wardrobe_chest_slot.tex", atlas = "images/uiimages/wardrobe_chest_slot.xml" },
            { image = "wardrobe_tool_slot.tex", atlas = "images/uiimages/wardrobe_tool_slot.xml" },
            { image = "wardrobe_hat_slot.tex", atlas = "images/uiimages/wardrobe_hat_slot.xml" },
            { image = "wardrobe_chest_slot.tex", atlas = "images/uiimages/wardrobe_chest_slot.xml" },
            { image = "wardrobe_tool_slot.tex", atlas = "images/uiimages/wardrobe_tool_slot.xml" },
            { image = "wardrobe_hat_slot.tex", atlas = "images/uiimages/wardrobe_hat_slot.xml" },
            { image = "wardrobe_chest_slot.tex", atlas = "images/uiimages/wardrobe_chest_slot.xml" },
            { image = "wardrobe_tool_slot.tex", atlas = "images/uiimages/wardrobe_tool_slot.xml" },
            { image = "wardrobe_hat_slot.tex", atlas = "images/uiimages/wardrobe_hat_slot.xml" },
            { image = "wardrobe_chest_slot.tex", atlas = "images/uiimages/wardrobe_chest_slot.xml" },
            { image = "wardrobe_tool_slot.tex", atlas = "images/uiimages/wardrobe_tool_slot.xml" },
            { image = "wardrobe_hat_slot.tex", atlas = "images/uiimages/wardrobe_hat_slot.xml" },
            { image = "wardrobe_chest_slot.tex", atlas = "images/uiimages/wardrobe_chest_slot.xml" },
            { image = "wardrobe_tool_slot.tex", atlas = "images/uiimages/wardrobe_tool_slot.xml" },
            { image = "wardrobe_hat_slot.tex", atlas = "images/uiimages/wardrobe_hat_slot.xml" },
            { image = "wardrobe_chest_slot.tex", atlas = "images/uiimages/wardrobe_chest_slot.xml" },
            { image = "wardrobe_tool_slot.tex", atlas = "images/uiimages/wardrobe_tool_slot.xml" },
            { image = "wardrobe_hat_slot.tex", atlas = "images/uiimages/wardrobe_hat_slot.xml" },
            { image = "wardrobe_chest_slot.tex", atlas = "images/uiimages/wardrobe_chest_slot.xml" },
            { image = "wardrobe_tool_slot.tex", atlas = "images/uiimages/wardrobe_tool_slot.xml" },
            { image = "wardrobe_hat_slot.tex", atlas = "images/uiimages/wardrobe_hat_slot.xml" },
            { image = "wardrobe_chest_slot.tex", atlas = "images/uiimages/wardrobe_chest_slot.xml" },
            { image = "wardrobe_tool_slot.tex", atlas = "images/uiimages/wardrobe_tool_slot.xml" },
            { image = "wardrobe_hat_slot.tex", atlas = "images/uiimages/wardrobe_hat_slot.xml" },
            { image = "wardrobe_chest_slot.tex", atlas = "images/uiimages/wardrobe_chest_slot.xml" },
            { image = "wardrobe_tool_slot.tex", atlas = "images/uiimages/wardrobe_tool_slot.xml" },
            { image = "wardrobe_hat_slot.tex", atlas = "images/uiimages/wardrobe_hat_slot.xml" },
            { image = "wardrobe_chest_slot.tex", atlas = "images/uiimages/wardrobe_chest_slot.xml" },
            { image = "wardrobe_tool_slot.tex", atlas = "images/uiimages/wardrobe_tool_slot.xml" },
            { image = "wardrobe_hat_slot.tex", atlas = "images/uiimages/wardrobe_hat_slot.xml" },
            { image = "wardrobe_chest_slot.tex", atlas = "images/uiimages/wardrobe_chest_slot.xml" },
            { image = "wardrobe_tool_slot.tex", atlas = "images/uiimages/wardrobe_tool_slot.xml" }
        } or {},
        buttoninfo = {
            text = TEXT.TIDY,
            position = Vector3(75 * 0, -75 * 3 - 37.5 + 5, 0),
            fn = fn,
            validfn = validfn;
        },
        more_items_wardrobe_buttoninfo = {
            text = "换装",
            position = Vector3(0, 255, 0),
            fn = function(inst, doer)
                if inst.components.container ~= nil then
                    local prefab_skins = rawget(PREFAB_SKINS, doer.prefab) or {};
                    for _, skin in pairs(prefab_skins) do
                        local skindata = GetSkinData(skin)
                        if (skindata == nil) or (type(skindata) == "table" and skindata.skins == nil) then
                            doer.components.talker:Say("抱歉，由于目前获取不到模组人物的皮肤数据，所以模组人物无法在此处换皮肤！");
                            return ;
                        end
                    end
                    BufferedAction(doer, inst, ACTIONS.CHANGEIN):Do();
                elseif inst.replica.container ~= nil and not inst.replica.container:IsBusy() then
                    SendModRPCToServer(MOD_RPC["more_items"]["wardrobe_reskin"], inst);
                end
            end,
            validfn = function(inst)
                return true;
            end;
        }
    },
    type = "chest",
    itemtestfn = function(container, item, slot)
        return item:HasTag("_equippable")
                or item:HasTag("reloaditem_ammo")
                or item:HasTag("tool")
                or item:HasTag("trap")
                or item:HasTag("book")
                or item:HasTag("weapon")
                or (item.prefab == "razor" or item.prefab == "beef_bell")
                --or item:HasTag("heatrock")
                or (item:HasTag("pocketwatch") or item.prefab == "pocketwatch_dismantler")
                or item:HasTag("toolbox_item")
                or item.prefab == "sewing_tape"
                or item.prefab == "sewing_kit"
                or item:HasTag("fan")
                or string.match(item.prefab, "wx78module_") ~= nil;
    end
}

if params.mone_wardrobe.widget.more_items_wardrobe_buttoninfo then
    AddModRPCHandler("more_items", "wardrobe_reskin", function(player, inst)
        if inst.components.container ~= nil then
            local prefab_skins = rawget(PREFAB_SKINS, player.prefab) or {};
            for _, skin in pairs(prefab_skins) do
                local skindata = GetSkinData(skin)
                if (skindata == nil) or (type(skindata) == "table" and skindata.skins == nil) then
                    player.components.talker:Say("抱歉，由于目前获取不到模组人物的皮肤数据，所以模组人物无法在此处换皮肤！");
                    return ;
                end
            end
            BufferedAction(player, inst, ACTIONS.CHANGEIN):Do();
        end
    end);
end

for y = 2, -3, -1 do
    for x = -3, 2 do
        table.insert(params.mone_wardrobe.widget.slotpos, Vector3(75 * x + 37.5, 75 * y + 37.5, 0))
    end
end

params.mone_backpack = {
    widget = {
        slotpos = {},
        animbank = "ui_backpack_2x4",
        animbuild = "ui_backpack_2x4",
        pos = Vector3(689, -71, 0),
        side_align_tip = 160,
        buttoninfo = {
            text = TEXT.TIDY,
            position = Vector3(-125, -173, 0),
            fn = fn,
            validfn = validfn;
        },
    },
    type = "mone_backpack",
    itemtestfn = function(container, item, slot)
        if not TUNING.MONE_TUNING.GET_MOD_CONFIG_DATA.cane_gointo_mone_backpack then
            if item.prefab == "cane" then
                return false;
            end
        end
        if item.prefab == "foliageath"
                or item.prefab == "foliageath_together" -- 棱镜的青枝绿叶
        --or item.prefab == "razor"
        --or item.prefab == "beef_bell"
        then
            return true;
        end
        return item:HasTag("_equippable");
    end
}

if NEW_BUTTON then
    params.mone_backpack.widget.buttoninfo = nil;
    params.mone_backpack.widget.more_items_buttoninfo = {
        text = emoji.palm,
        --text_position = Vector3(0, 0, 0), -- 猪头
        text_position = Vector3(0, 1, 0), -- 手掌
        position = Vector3(-121, -170, 0),
        fn = fn,
        validfn = validfn,
    }
end

for y = 0, 3 do
    table.insert(params.mone_backpack.widget.slotpos, Vector3(-162, -75 * y + 114, 0))
    table.insert(params.mone_backpack.widget.slotpos, Vector3(-162 + 75, -75 * y + 114, 0))
end

-- TEST
--config_data.mone_backpack_capacity = 2;

if config_data.mone_backpack_capacity == 2 then
    params.mone_backpack.widget.slotpos = {};
    params.mone_backpack.widget.animbank = "ui_chester_shadow_3x4";
    params.mone_backpack.widget.animbuild = "ui_chester_shadow_3x4";
    params.mone_backpack.widget.pos = Vector3(587, -74, 0);

    if params.mone_backpack.widget.buttoninfo then
        params.mone_backpack.widget.buttoninfo.position = Vector3(-1, -177, 0);
    elseif params.mone_backpack.widget.more_items_buttoninfo then
        params.mone_backpack.widget.more_items_buttoninfo.position = Vector3(1, -177, 0);
    end

    for y = 2.5, -0.5, -1 do
        for x = 0, 2 do
            table.insert(params.mone_backpack.widget.slotpos, Vector3(75 * x - 75 * 2 + 75, 75 * y - 75 * 2 + 75, 0))
        end
    end
end

params.mone_tool_bag = {
    widget = {
        slotpos = {},
        animbank = "ui_backpack_2x4",
        animbuild = "ui_backpack_2x4",
        pos = Vector3(552, -72, 0),
        side_align_tip = 160,
        buttoninfo = {
            text = TEXT.TIDY,
            position = Vector3(-125, -176, 0),
            fn = fn,
            validfn = validfn,
        },
    },
    type = "mone_tool_bag_mone_icepack",
    itemtestfn = function(container, item, slot)
        if item:HasTag("tool_bag_notag") then
            return false;
        end
        if item:HasTag("tool")
                or item:HasTag("wateringcan")
        then
            return true;
        end
        if item.prefab == "farm_hoe"
                or item.prefab == "golden_farm_hoe"
                or item.prefab == "pitchfork"
                or item.prefab == "goldenpitchfork"
                or item.prefab == "onemanband"
                or item.prefab == "sewing_kit"
                or item.prefab == "sewing_tape"
                or item.prefab == "torch"
                or item.prefab == "fishingrod"
                or item.prefab == "oar"
                or item.prefab == "oar_driftwood"
                or item.prefab == "reskin_tool"
                or item.prefab == "malbatross_beak"
                or item.prefab == "portabletent_item"
                or item.prefab == "lighter"
                or item.prefab == "umbrella"
                or item.prefab == "razor"
                or item.prefab == "beef_bell"
                or item.prefab == "brush"
                or item.prefab == "saddlehorn"
                or string.find(item.prefab, "saddle_")
        --or item.prefab == "plantregistryhat"
        --or item.prefab == "nutrientsgoggleshat"
        then
            return true;
        end
        return false;
    end
}

if NEW_BUTTON then
    params.mone_tool_bag.widget.buttoninfo = nil;
    params.mone_tool_bag.widget.more_items_buttoninfo = {
        text = emoji.palm,
        text_position = Vector3(0, 1, 0),
        position = Vector3(-121, -172, 0),
        fn = fn,
        validfn = validfn,
    }
end

for y = 0, 3 do
    table.insert(params.mone_tool_bag.widget.slotpos, Vector3(-162, -75 * y + 114, 0))
    table.insert(params.mone_tool_bag.widget.slotpos, Vector3(-162 + 75, -75 * y + 114, 0))
end

-- TEST
--config_data.mone_tool_bag_capacity = 2;

if config_data.mone_tool_bag_capacity == 2 then
    params.mone_tool_bag.widget.slotpos = {};
    params.mone_tool_bag.widget.animbank = "ui_chester_shadow_3x4";
    params.mone_tool_bag.widget.animbuild = "ui_chester_shadow_3x4";
    params.mone_tool_bag.widget.pos = Vector3(399, -74, 0);

    if params.mone_tool_bag.widget.buttoninfo then
        params.mone_tool_bag.widget.buttoninfo.position = Vector3(-2, -177, 0);
    elseif params.mone_tool_bag.widget.more_items_buttoninfo then
        params.mone_tool_bag.widget.more_items_buttoninfo.position = Vector3(1, -177, 0);
    end

    for y = 2.5, -0.5, -1 do
        for x = 0, 2 do
            table.insert(params.mone_tool_bag.widget.slotpos, Vector3(75 * x - 75 * 2 + 75, 75 * y - 75 * 2 + 75, 0))
        end
    end
end

params.mone_icepack = {
    widget = {
        slotpos = {},
        animbank = "ui_backpack_2x4",
        animbuild = "ui_backpack_2x4",
        pos = Vector3(552, -72, 0),
        side_align_tip = 160,
        buttoninfo = {
            text = TEXT.TIDY,
            position = Vector3(-125, -176, 0),
            fn = fn,
            validfn = validfn,
        },
    },
    type = "mone_tool_bag_mone_icepack",
    itemtestfn = function(container, item, slot)
        return item:HasTag("_perishable_mone");
    end
}

if NEW_BUTTON then
    params.mone_icepack.widget.buttoninfo = nil;
    params.mone_icepack.widget.more_items_buttoninfo = {
        text = emoji.palm,
        text_position = Vector3(0, 1, 0),
        position = Vector3(-121, -172, 0),
        fn = fn,
        validfn = validfn,
    }
end

for y = 0, 3 do
    table.insert(params.mone_icepack.widget.slotpos, Vector3(-162, -75 * y + 114, 0))
    table.insert(params.mone_icepack.widget.slotpos, Vector3(-162 + 75, -75 * y + 114, 0))
end

-- TEST
--config_data.mone_icepack_capacity = 2;

if config_data.mone_icepack_capacity == 2 then
    params.mone_icepack.widget.slotpos = {};
    params.mone_icepack.widget.animbank = "ui_chester_shadow_3x4";
    params.mone_icepack.widget.animbuild = "ui_chester_shadow_3x4";
    params.mone_icepack.widget.pos = Vector3(399, -74, 0);

    if params.mone_icepack.widget.buttoninfo then
        params.mone_icepack.widget.buttoninfo.position = Vector3(-2, -177, 0);
    elseif params.mone_icepack.widget.more_items_buttoninfo then
        params.mone_icepack.widget.more_items_buttoninfo.position = Vector3(1, -177, 0);
    end

    for y = 2.5, -0.5, -1 do
        for x = 0, 2 do
            table.insert(params.mone_icepack.widget.slotpos, Vector3(75 * x - 75 * 2 + 75, 75 * y - 75 * 2 + 75, 0))
        end
    end
end

params.mone_piggybag = {
    widget = {
        slotpos = {},
        animbank = "ui_chest_3x3",
        animbuild = "ui_chest_3x3",
        pos = Vector3(625, -360, 0)
    },
    type = "mone_piggybag",
    itemtestfn = function(container, item, slot)
        if item.prefab == "mone_piggybag"
                or item:HasTag("mone_piggybag_notag")
        then
            return false;
        end
        if item:HasTag("mone_piggybag_itemtesttag")
                or item:HasTag("_container")
        then
            return true;
        end
        return false;
    end
}

-- TEST
--if env and API.isDebug(env) then
--    params.mone_piggybag.widget.pos = Vector3(0, 0, 0);
--    params.mone_piggybag.issidewidget = true;
--end

if env and API.isDebug(env) then
    local old_itemtestfn = params.mone_piggybag.itemtestfn;
    params.mone_piggybag.itemtestfn = function(container, item, slot)
        if item:HasTag("_container") and item:HasTag("_equippable") then
            return false;
        end
        return old_itemtestfn(container, item, slot);
    end
end

for y = 2, 0, -1 do
    for x = 0, 2 do
        table.insert(params.mone_piggybag.widget.slotpos, Vector3(80 * x - 80 * 2 + 80, 80 * y - 80 * 2 + 80, 0))
    end
end

params.mone_wathgrithr_box = {
    widget = {
        slotpos = {},
        animbank = "ui_backpack_2x4",
        animbuild = "ui_backpack_2x4",
        pos = Vector3(275 + 100 + 150 + 150 + 5 + 2 - 30 - 60 - 40, -60 - 10 + 3 + 3 - 5 - 3, 0),
        side_align_tip = 160,
        buttoninfo = {
            text = TEXT.TIDY,
            position = Vector3(-125, -174, 0), -- 确定了，是第一象限！
            fn = fn,
            validfn = validfn
        },
    },
    type = "mone_character_box",
    itemtestfn = function(container, item, slot)
        return item:HasTag("battlesong");
    end
}

if NEW_BUTTON then
    params.mone_wathgrithr_box.widget.buttoninfo = nil;
    params.mone_wathgrithr_box.widget.more_items_buttoninfo = {
        text = emoji.palm,
        text_position = Vector3(0, 1, 0),
        position = Vector3(-121, -172, 0),
        fn = fn,
        validfn = validfn,
    }
end

for y = 0, 3 do
    table.insert(params.mone_wathgrithr_box.widget.slotpos, Vector3(-162, -75 * y + 114, 0))
    table.insert(params.mone_wathgrithr_box.widget.slotpos, Vector3(-162 + 75, -75 * y + 114, 0))
end

--params.mone_wanda_box = deepcopy(params.mone_wathgrithr_box);
params.mone_wanda_box = {
    widget = {
        slotpos = {},
        animbank = "ui_backpack_2x4",
        animbuild = "ui_backpack_2x4",
        pos = Vector3(552, -72, 0),
        side_align_tip = 160,
        buttoninfo = {
            text = TEXT.TIDY,
            position = Vector3(-125, -176, 0),
            fn = fn,
            validfn = validfn;
        },
    },
    type = "mone_character_box",
    itemtestfn = function(container, item, slot)
        return item:HasTag("mone_wanda_box_itemtestfn");
    end
}

if NEW_BUTTON then
    params.mone_wanda_box.widget.buttoninfo = nil;
    params.mone_wanda_box.widget.more_items_buttoninfo = {
        text = emoji.palm,
        text_position = Vector3(0, 1, 0),
        position = Vector3(-121, -172, 0),
        fn = fn,
        validfn = validfn,
    }
end

for y = 0, 3 do
    table.insert(params.mone_wanda_box.widget.slotpos, Vector3(-162, -75 * y + 114, 0))
    table.insert(params.mone_wanda_box.widget.slotpos, Vector3(-162 + 75, -75 * y + 114, 0))
end

params.mone_candybag = {
    widget = {
        slotpos = {},
        animbank = "ui_tacklecontainer_3x2",
        animbuild = "ui_tacklecontainer_3x2",
        pos = Vector3(0 + 800 - 200 + 90 - 10, 200 - 90 + 10 - 5, 0),
        side_align_tip = 160,
        more_items_buttoninfo = {
            text = emoji.palm,
            text_position = Vector3(0, 1, 0),
            position = Vector3(0, 105, 0), -- 上
            --position = Vector3(0, -107, 0), -- 下
            fn = fn,
            validfn = validfn,
        }
    },
    type = "mone_candybag",
    itemtestfn = function(container, item, slot)
        return table.contains({ "cutgrass", "twigs", "flint", "rocks", "goldnugget", "log", }, item.prefab);
    end
}

for y = 1, 0, -1 do
    for x = 0, 2 do
        table.insert(params.mone_candybag.widget.slotpos, Vector3(80 * x - 80 * 2 + 80, 80 * y - 80 * 2 + 120, 0))
    end
end

if config_data.candybag_itemtestfn then
    --AddModRPCHandler("more_items_debug", "test1", function(player, ...)
    --    local message = (select(1));
    --    print(tostring(message));
    --end);

    local COUNT = 0;
    local materials = {};
    local old_itemtestfn = params.mone_candybag.itemtestfn;
    params.mone_candybag.itemtestfn = function(container, item, slot)
        if old_itemtestfn(container, item, slot) then
            return true;
        end
        -- 排除的物品
        if item:HasTag("_perishable_mone")
                or not item:HasTag("_stackable_mone")
                or item:HasTag("_equippable_mone")
        then
            return false;
        end
        -- 精炼栏
        local recipes = CRAFTING_FILTERS.REFINE.recipes;
        if recipes and type(recipes) == "table" then
            for _, v in ipairs(recipes) do
                if item.prefab == v then
                    return true;
                end
            end
        end
        -- 制作精炼栏物品所需的材料
        if COUNT == 0 then
            COUNT = 1;
            if recipes and type(recipes) == "table" then
                for _, rename in ipairs(recipes) do
                    local recipe = GetValidRecipe(tostring(rename));
                    if recipe then
                        local ingredients = recipe.ingredients or {};
                        for k, ingredient in pairs(ingredients) do
                            if ingredient and ingredient.is_a and ingredient:is_a(Ingredient) then
                                local ingredienttype = ingredient.type;
                                if ingredienttype and not (ingredienttype == CHARACTER_INGREDIENT.HEALTH or ingredienttype == CHARACTER_INGREDIENT.SANITY) then
                                    materials[tostring(ingredienttype)] = true;
                                end
                            end
                        end
                    end
                end
            end
        end
        -- 注意，有点多了。。。阿哲？
        -- 为什么还有怪物肉？

        -- print materials
        --local cnt1, cnt2 = 0, 0;
        --local msg = {};
        --for k, v in pairs(materials) do
        --    cnt1 = cnt1 + 1;
        --    if v and v == true then
        --        cnt2 = cnt2 + 1;
        --        table.insert(msg, k);
        --    end
        --end
        --print(string.format("------cnt1: %s, cnt2: %s", tostring(cnt1), tostring(cnt2)));
        ----print("{ " .. table.concat(msg, ",") .. " }");
        --SendModRPCToServer(MOD_RPC["more_items_debug"]["test1"], "{ " .. table.concat(msg, ",") .. " }");

        for k, v in pairs(materials) do
            if v and v == true then
                if item.prefab == k then
                    return true;
                end
            end
        end

        -- 仍需精确添加的物品?
        if item.prefab == "nitre"
                or item.prefab == "cutreeds"
                or item.prefab == "marble"
        then
            return true;
        end

        return false;
    end
end

if SCROLL and config_data.sc_candybag then
    params.mone_candybag.widget.slotpos = {};
    --params.mone_candybag.widget.buttoninfo = {
    --    text = TEXT.TIDY,
    --    position = Vector3(0, -100 - 5 - 2, 0),
    --    fn = fn,
    --    validfn = validfn;
    --}
    params.mone_candybag.widget.more_items_scroll = {
        num_visible_rows = 2,
        num_columns = 3,
        scroll_data = {
            widget_width = 71,
            widget_height = 71,
            scrollbar_offset = 13,
            scrollbar_height_offset = -43, -- 负数
            pos = Vector3(-7, 0, 0)
        }
    };
    for y = 1, 0, -1 do
        for x = 0, 2 do
            table.insert(params.mone_candybag.widget.slotpos, Vector3(80 * x - 80 * 2 + 80, 80 * y - 80 * 2 + 120, 0))
        end
    end
    for y = 1, 0, -1 do
        for x = 0, 2 do
            table.insert(params.mone_candybag.widget.slotpos, Vector3(80 * x - 80 * 2 + 80, 80 * y - 80 * 2 + 120, 0))
        end
    end

    if not config_data.candybag_itemtestfn then
        local old_itemtestfn = params.mone_candybag.itemtestfn;
        params.mone_candybag.itemtestfn = function(container, item, slot)
            return table.contains({ "rope", "cutstone", "boards", "marble", "nitre", "nightmarefuel", }, item.prefab) or old_itemtestfn(container, item, slot);
        end
    end
end

params.mone_seedpouch = {
    widget = {
        slotpos = {},
        animbank = "ui_krampusbag_2x8",
        animbuild = "ui_krampusbag_2x8",
        pos = Vector3(-5, -130, 0),
    },
    issidewidget = true,
    type = "pack",
    openlimit = 1,
    itemtestfn = function(container, item, slot)
        return item:HasTag("deployedfarmplant");
    end
}

for y = 0, 6 do
    table.insert(params.mone_seedpouch.widget.slotpos, Vector3(-162, -75 * y + 240, 0))
    table.insert(params.mone_seedpouch.widget.slotpos, Vector3(-162 + 75, -75 * y + 240, 0))
end

params.mone_relic_2 = {
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

params.mone_storage_bag = {
    widget = {
        slotpos = {
            Vector3(-37.5, 32 + 4, 0),
            Vector3(37.5, 32 + 4, 0),
            Vector3(-37.5, -(32 + 4), 0),
            Vector3(37.5, -(32 + 4), 0)
        },
        animbank = "ui_chest_2x2",
        animbuild = "ui_chest_2x2",
        pos = Vector3(106, 85, 0), --头盔位置
        -- pos = Vector3(156, 85, 0),
        side_align_tip = 160
    },
    type = "hand_inv",
    itemtestfn = function(container, item, slot)
        if item.prefab == "heatrock"
                or item.prefab == "ice"
        then
            return false;
        end
        return isIcebox(container, item, slot) or isSaltbox(container, item, slot);
    end
}

params.mone_nightspace_cape = {
    widget = {
        slotpos = {},
        animbank = "ui_krampusbag_2x8",
        animbuild = "ui_bigbag_3x8",
        pos = Vector3(-180 + 150 + 5 + 5, -150 + 10, 0),
    },
    issidewidget = true,
    type = "pack",
    openlimit = 1
}

for y = 0, 7 do
    table.insert(params.mone_nightspace_cape.widget.slotpos, Vector3(-131 - 75, -75 * y + 264, 0))
    table.insert(params.mone_nightspace_cape.widget.slotpos, Vector3(-131, -75 * y + 264, 0))
    table.insert(params.mone_nightspace_cape.widget.slotpos, Vector3(-131 + 75, -75 * y + 264, 0))
end

if SCROLL and config_data.sc_nightspace_cape then
    -- 覆盖！
    params.mone_nightspace_cape = {
        widget = {
            slotpos = {},
            animbank = "ui_krampusbag_2x8",
            animbuild = "ui_krampusbag_2x8",
            --pos = Vector3(-5, -120, 0),
            pos = Vector3(-5, -130, 0),
        },
        issidewidget = true,
        type = "pack",
        openlimit = 1,
    }

    params.mone_nightspace_cape.widget.more_items_scroll = {
        num_visible_rows = 7,
        num_columns = 2,
        scroll_data = {
            widget_width = 71,
            widget_height = 71,
            scrollbar_offset = 10,
            scrollbar_height_offset = nil,
            pos = Vector3(-127, -17 + 34, 0),
        }
    };

    for y = 0, 6 do
        table.insert(params.mone_nightspace_cape.widget.slotpos, Vector3(-162, -75 * y + 240, 0))
        table.insert(params.mone_nightspace_cape.widget.slotpos, Vector3(-162 + 75, -75 * y + 240, 0))
    end
    for y = 0, 6 do
        table.insert(params.mone_nightspace_cape.widget.slotpos, Vector3(-162, -75 * y + 240, 0))
        table.insert(params.mone_nightspace_cape.widget.slotpos, Vector3(-162 + 75, -75 * y + 240, 0))
    end

end

params.mone_fish_box = {
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
}

for y = 4, 0, -1 do
    for x = 0, 9 do
        local offsetX = x <= 4 and -20 or 10
        table.insert(params.mone_fish_box.widget.slotpos, Vector3(80 * (x - 5) + 40 + offsetX, 80 * (y - 3) + 80, 0))
    end
end

params.mone_seasack = {
    widget = {
        slotpos = {},
        animbank = "ui_krampusbag_2x8",
        animbuild = "ui_krampusbag_2x8",
        --pos = Vector3(-5, -120, 0),
        pos = Vector3(-5, -130, 0),
    },
    issidewidget = true,
    type = "pack",
    openlimit = 1,
}

for y = 0, 6 do
    table.insert(params.mone_seasack.widget.slotpos, Vector3(-162, -75 * y + 240, 0))
    table.insert(params.mone_seasack.widget.slotpos, Vector3(-162 + 75, -75 * y + 240, 0))
end

if SCROLL and config_data.sc_seasack then
    -- 2x4
    params.mone_seasack = {
        widget = {
            slotpos = {},
            animbank = "ui_backpack_2x4",
            animbuild = "ui_backpack_2x4",
            --pos = Vector3(-5, -70, 0),
            pos = Vector3(-5, -80, 0),
        },
        issidewidget = true,
        type = "pack",
        openlimit = 1,
    }

    for y = 0, 3 do
        table.insert(params.mone_seasack.widget.slotpos, Vector3(-162, -75 * y + 114, 0))
        table.insert(params.mone_seasack.widget.slotpos, Vector3(-162 + 75, -75 * y + 114, 0))
    end

    -- 修改
    params.mone_seasack.widget.slotpos = {};
    params.mone_seasack.widget.more_items_scroll = {
        num_visible_rows = 4,
        num_columns = 2,
        scroll_data = {
            widget_width = 71,
            widget_height = 71,
            scrollbar_offset = 10,
            scrollbar_height_offset = nil,
            pos = Vector3(-127, -17 + 10 + 3, 0),
        }
    };
    for y = 0, 3 do
        table.insert(params.mone_seasack.widget.slotpos, Vector3(-162, -75 * y + 114, 0))
        table.insert(params.mone_seasack.widget.slotpos, Vector3(-162 + 75, -75 * y + 114, 0))
    end
    for y = 0, 3 do
        table.insert(params.mone_seasack.widget.slotpos, Vector3(-162, -75 * y + 114, 0))
        table.insert(params.mone_seasack.widget.slotpos, Vector3(-162 + 75, -75 * y + 114, 0))
    end
end

------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------
-- 背包添加一键整理按钮
if config_data.backpack_arrange_button then
    local PITCH_OF_MY_BUTTON = true; -- 修改后的按钮
    for _, v in ipairs({
        params.backpack, params.spicepack, params.krampus_sack, params.piggyback, params.seedpouch, params.icepack,
        params.mone_seasack, params.mone_seedpouch, params.mone_nightspace_cape
    }) do
        if v and type(v) == "table"
                and v.widget and v.widget.buttoninfo == nil
                and v.widget.slotpos
                and (#v.widget.slotpos == 6
                or #v.widget.slotpos == 8
                or #v.widget.slotpos == 12
                or #v.widget.slotpos == 14
                or (#v.widget.slotpos == 16 and SCROLL)
                or (#v.widget.slotpos == 28 and SCROLL)) then
            if PITCH_OF_MY_BUTTON --[[只进入此处，另一个域是备份用的]] then
                local position = Vector3(0, 0, 0);
                local text = emoji.palm; -- 猪头
                local text_position = Vector3(0, 1, 0);
                if #v.widget.slotpos == 6 then
                    position = Vector3(-123, 140, 0); -- 上
                    --position = Vector3(-123, -140, 0); -- 下
                elseif #v.widget.slotpos == 8 then
                    position = Vector3(-123, 174, 0); -- 上
                    --position = Vector3(-123, -172, 0); -- 下
                elseif #v.widget.slotpos == 12 then
                    position = Vector3(-123, 236, 0); -- 上
                    --position = Vector3(-123, -262, 0); -- 下
                elseif #v.widget.slotpos == 14 then
                    position = Vector3(-123, 300, 0); -- 上
                    --position = Vector3(-123, -275, 0); -- 下
                elseif #v.widget.slotpos == 16 and SCROLL then
                    position = Vector3(-123, 174, 0); -- 上 8
                    --position = Vector3(-123, -174, 0); -- 下 8
                elseif #v.widget.slotpos == 28 and SCROLL then
                    position = Vector3(-123, 300, 0); -- 上 14
                    --position = Vector3(-123, -300, 0); -- 下 14
                end
                v.widget.more_items_buttoninfo = {
                    text = text,
                    text_position = text_position,
                    position = position,
                    fn = fn,
                    validfn = validfn;
                };
                v.widget.more_items_backpack_arrange_button_tag = true;
            else
                local position = Vector3(0, 0, 0);
                if #v.widget.slotpos == 6 then
                    position = Vector3(-123, -143, 0);
                elseif #v.widget.slotpos == 8 then
                    position = Vector3(-123, -173, 0);
                elseif #v.widget.slotpos == 12 then
                    position = Vector3(-123, -268, 0);
                elseif #v.widget.slotpos == 14 then
                    position = Vector3(-123, -278, 0);
                elseif #v.widget.slotpos == 16 and SCROLL then
                    position = Vector3(-123, -173, 0);
                elseif #v.widget.slotpos == 28 and SCROLL then
                    position = Vector3(-123, -278, 0);
                end
                v.widget.buttoninfo = {
                    text = TEXT.TIDY,
                    position = position,
                    fn = fn,
                    validfn = validfn;
                };
                v.widget.more_items_backpack_arrange_button_tag = true;
            end
        end
    end
end

-- emm, 添加了新按钮之后，官方的 RPC 失效了，在此处修改掉吧！
---- 2023-03-31-15:30：我自己 Send Add 不就行了吗。我为什么非要用官方的？
TUNING.MONE_TUNING.NEW_BUTTON_NEW = true;
if TUNING.MONE_TUNING.NEW_BUTTON_NEW then
    for k, v in pairs(params) do
        if v and v.widget and v.widget.buttoninfo == nil and v.widget.more_items_buttoninfo then
            v.widget.buttoninfo = v.widget.more_items_buttoninfo;
        end
    end
end

-- 注意此处只修改原版的几种背包，因为这样毕竟方便判定。
if SCROLL and config_data.sc_klei_backpack and false --[[暂时先取消了]] then
    for _, v in ipairs({
        params.backpack, params.spicepack, params.krampus_sack, params.piggyback,
        params.seedpouch, params.icepack,
    }) do
        if v and type(v) == "table"
                and v.widget and v.widget.buttoninfo == nil
                and v.widget.slotpos
                and (#v.widget.slotpos == 12
                or #v.widget.slotpos == 14) then
            -- 给背包添加滚动条

            -- 适配一下我的功能：背包添加一键整理按钮
            if config_data.backpack_arrange_button then
                if v and type(v) == "table"
                        and v.widget
                        and v.widget.more_items_buttoninfo
                        and v.widget.more_items_backpack_arrange_button_tag then
                    v.widget.more_items_buttoninfo.position = Vector3(-123, 174, 0);
                end
            end
        end
    end
end


-- 官方容器添加整理按钮：普通箱子、龙鳞宝箱、冰箱、盐盒
if config_data.klei_chests_arrangement_button then
    for _, v in ipairs({ params.treasurechest, params.dragonflychest, params.icebox, params.saltbox }) do
        if v and type(v) == "table"
                and v.widget and v.widget.buttoninfo == nil
                and v.widget.slotpos
                and (#v.widget.slotpos == 9 or #v.widget.slotpos == 12) then
            local position = Vector3(0, 0, 0);
            if #v.widget.slotpos == 9 then
                position = Vector3(0, -140, 0);
            elseif #v.widget.slotpos == 12 then
                position = Vector3(-1, -177, 0);
            end
            v.widget.buttoninfo = {
                text = TEXT.TIDY,
                position = position,
                fn = fn,
                validfn = validfn;
            }
        end
    end
end
------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------

params.mone_dragonflyfurnace = {
    widget = {
        slotpos = {},
        animbank = "ui_chest_3x3",
        animbuild = "ui_chest_3x3",
        pos = Vector3(0, 200, 0),
        side_align_tip = 160,
        buttoninfo = {
            text = TEXT.TIDY,
            position = Vector3(0, -140, 0),
            fn = fn,
            validfn = validfn
        }
    },
    type = "chest",
    itemtestfn = function(container, item, slot)
        return item:HasTag("heatrock");
    end
}

for y = 2, 0, -1 do
    for x = 0, 2 do
        table.insert(params.mone_dragonflyfurnace.widget.slotpos, Vector3(80 * x - 80 * 2 + 80, 80 * y - 80 * 2 + 80, 0))
    end
end

params.mone_moondial = {
    widget = {
        slotpos = {},
        animbank = "ui_chest_3x3",
        animbuild = "ui_chest_3x3",
        pos = Vector3(0, 200, 0),
        side_align_tip = 160,
        buttoninfo = {
            text = TEXT.TIDY,
            position = Vector3(0, -140, 0),
            fn = fn,
            validfn = validfn
        }
    },
    type = "chest",
    itemtestfn = function(container, item, slot)
        return item:HasTag("heatrock");
    end
}

for y = 2, 0, -1 do
    for x = 0, 2 do
        table.insert(params.mone_moondial.widget.slotpos, Vector3(80 * x - 80 * 2 + 80, 80 * y - 80 * 2 + 80, 0))
    end
end




------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------
-- 必须加这个，保证 MAXITEMSLOTS 足够大，而且请不要用 inst.replica.container:WidgetSetup(nil, widgetsetup); 的写法，问题太多！
for k, v in pairs(params) do
    containers.MAXITEMSLOTS = math.max(containers.MAXITEMSLOTS, v.widget.slotpos ~= nil and #v.widget.slotpos or 0)
end




