---
--- @author zsh in 2023/1/10 4:52
---

assert(getfenv(1) ~= _G, "ERROR: current environment is global environment.");

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

-- TEST
if isDebugSimple() then
    -- 3x5 的装备袋不太行...
    --config_data.mone_backpack_capacity = 3;
end


-- 一键整理
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

local function mod_rpc_handlers()
    -- 高级整理按钮
    AddModRPCHandler("more_items", "storage_button_fn", function(player, target)
        local playercontroller = player.components.playercontroller
        if playercontroller ~= nil and playercontroller:IsEnabled() and not player.sg:HasStateTag("busy") then
            local container = target ~= nil and target.components.container or nil
            if container ~= nil and container:IsOpenedBy(player) then
                local widget = container:GetWidget()
                local buttoninfo = widget ~= nil and widget.more_items_storage_buttoninfo or nil
                if buttoninfo ~= nil and (buttoninfo.validfn == nil or buttoninfo.validfn(target)) and buttoninfo.fn ~= nil then
                    buttoninfo.fn(target, player)
                end
            end
        end
    end)

    -- 关闭按钮：海上箱子和收纳袋
    AddModRPCHandler("more_items", "close_button_fn", function(player, target)
        local playercontroller = player.components.playercontroller
        if playercontroller ~= nil and playercontroller:IsEnabled() and not player.sg:HasStateTag("busy") then
            local container = target ~= nil and target.components.container or nil
            if container ~= nil and container:IsOpenedBy(player) then
                local widget = container:GetWidget()
                local buttoninfo = widget ~= nil and widget.more_items_piggyback_buttoninfo or nil
                if buttoninfo ~= nil and (buttoninfo.validfn == nil or buttoninfo.validfn(target)) and buttoninfo.fn ~= nil then
                    buttoninfo.fn(target, player)
                end
            end
        end
    end)

    -- 换装按钮
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
mod_rpc_handlers();

-- 高级整理
local function storage_button()
    local vars, fns = {}, {};

    local DIST = 30;

    local function PickUpItems(inst)
        local x, y, z = inst.Transform:GetWorldPosition();
        if oneOfNull(3, x, y, z) then
            return ;
        end

        local MUST_TAGS = API.AutoSorter.PickObjectOnFloorOnClick_MUST_TAGS;
        local CANT_TAGS = API.AutoSorter.PickObjectOnFloorOnClick_CANT_TAGS;

        local ents = TheSim:FindEntities(x, y, z, DIST, MUST_TAGS, CANT_TAGS);

        ents = table.reverse(ents); -- 翻转一下，从最远的地方开始捡

        local valid_ents = {};
        local other_perishable_ents = {};

        local skull_chest_ents = inst.prefab == "mone_skull_chest" and {} or nil;

        -- 获得有效目标
        for _, v in ipairs(ents) do
            if isValid(v) and v.components.inventoryitem
                    and v.components.inventoryitem.canbepickedup
                    and v.components.inventoryitem.cangoincontainer
                    and not v.components.inventoryitem.canonlygoinpocket
                    and not v.components.inventoryitem:IsHeld()
                    and not v:HasTag("_container")
                    and not v:HasTag("unwrappable")
                    and not table.contains({
                "terrarium", "glommerflower", "chester_eyebone", "hutch_fishbowl", "beef_bell",
                "heatrock", "moonrockseed", "fruitflyfruit", "singingshell_octave3", "singingshell_octave4",
                "singingshell_octave5", "powcake", "farm_plow_item", "winter_food4",
                "mie_bundle_state1", "mie_bundle_state2",
            }, v.prefab) then
                if inst.components.container:Has(v.prefab, 1) then
                    if v.components.burnable then
                        if v.components.burnable:IsBurning() or v.components.burnable:IsSmoldering() then
                            -- DoNothing
                        else
                            table.insert(valid_ents, v);
                        end
                    else
                        table.insert(valid_ents, v);
                    end
                elseif inst.components.container:CanTakeItemInSlot(v) then
                    if v.components.perishable then
                        table.insert(other_perishable_ents, v);
                    end
                    if skull_chest_ents then
                        table.insert(skull_chest_ents, v);
                    end
                end
            end
        end

        -- 如果是可以保鲜的容器，容器内没有该物品、该物品能够塞进容器中、该物品有新鲜度
        if inst.components.preserver or inst:HasTag("fridge") or inst:HasTag("foodpreserver") then
            UnionSeq(valid_ents, other_perishable_ents);
        end

        if skull_chest_ents then
            UnionSeq(valid_ents, skull_chest_ents);
        end

        -- 处理有效目标
        if #valid_ents > 0 then
            local fx = SpawnPrefab("sand_puff");
            local scale = 1.4;
            fx.Transform:SetScale(scale, scale, scale);
            fx.Transform:SetPosition(x, y, z);
        end

        for _, v in ipairs(valid_ents) do
            local v_x, v_y, v_z = v.Transform:GetWorldPosition();
            if not oneOfNull(3, v_x, v_y, v_z) then
                SpawnPrefab("sand_puff").Transform:SetPosition(v_x, v_y, v_z);
                inst.components.container:GiveItem(v);
            end
        end
    end

    -- 将周围的某些容器中的同类物品转移至当前容器中。
    local function OneClickStorage(inst)
        if inst.one_click_storage_busy --[[避免频繁点击]] then
            return ;
        end

        inst.one_click_storage_busy = true;

        if inst.components.container:IsEmpty() --[[容器为空则部分执行]] then
            PickUpItems(inst); -- 捡起周围物品
            inst.one_click_storage_busy = nil;
            return ;
        end

        -- 如果容器已满而且都已经堆满
        ---- 否命题：容器未满 或者 容器尚未堆满(前提是容器已满)
        local function allFull(ent)
            if not ent.components.container:IsFull() then
                return false;
            else
                for _, v in ipairs(ent.components.container:GetAllItems()) do
                    if v.components.stackable and not v.components.stackable:IsFull() then
                        return false;
                    end
                end
            end
            return true;
        end

        if allFull(inst) then
            inst.one_click_storage_busy = nil;
            return ;
        end

        local x, y, z = inst.Transform:GetWorldPosition();
        if oneOfNull(3, x, y, z) then
            inst.one_click_storage_busy = nil;
            return ;
        end

        local items = inst.components.container:GetAllItems();

        local ents = TheSim:FindEntities(x, y, z, DIST, { "_container" }, { "INLIMBO", "NOCLICK", "FX", "DECOR" });

        ents = table.reverse(ents); -- 翻转一下，从最远的地方开始捡

        local valid_ents = {};


        -- 得到有效目标
        for _, v in ipairs(ents) do
            if isValid(v) and v ~= inst
                    and v.prefab and inst.prefab
                    and v.components.container and not v.components.container:IsEmpty() then
                if v.prefab == inst.prefab then
                    if inst.prefab == "mone_skull_chest" then
                        -- DoNothing
                    else
                        table.insert(valid_ents, v);
                    end
                else
                    local Vip = {
                        --["mone_treasurechest"] = { "treasurechest" };
                        --["mone_dragonflychest"] = { "dragonflychest" };
                        --["mone_icebox"] = { "icebox" };
                        --["mone_saltbox"] = { "saltbox", "icebox", "mone_icebox" };

                        --["treasurechest"] = { "mone_treasurechest" };
                        --["dragonflychest"] = { "mone_dragonflychest" };
                        --["icebox"] = { "mone_icebox" };
                        --["saltbox"] = { "mone_saltbox", "icebox", "mone_icebox" };

                        ["mone_treasurechest"] = { "treasurechest" };
                        ["mone_dragonflychest"] = { "dragonflychest" };
                        ["mone_icebox"] = { "icebox" };
                        ["mone_saltbox"] = { "saltbox" };

                        ["treasurechest"] = { "mone_treasurechest" };
                        ["dragonflychest"] = { "mone_dragonflychest" };
                        ["icebox"] = { "mone_icebox" };
                        ["saltbox"] = { "mone_saltbox" };

                        ["mone_skull_chest"] = {
                            "mone_treasurechest", "mone_dragonflychest", "mone_icebox", "mone_saltbox",
                            "treasurechest", "dragonflychest", "icebox", "saltbox",
                        };

                        ["mie_bear_skin_cabinet"] = {
                            "mone_treasurechest", "mone_dragonflychest", "mone_icebox", "mone_saltbox",
                            "treasurechest", "dragonflychest", "icebox", "saltbox",
                        };
                    }
                    if Vip[inst.prefab] and table.contains(Vip[inst.prefab], v.prefab) then
                        table.insert(valid_ents, v);
                    end
                end
            end
        end

        local success_fx;

        -- 处理有效目标
        for _, ent in ipairs(valid_ents) do
            if allFull(inst) then
                break ;
            end

            local target_items = ent.components.container:FindItems(function(item)
                for _, v in ipairs(items) do
                    if inst.prefab == "mone_skull_chest" then
                        if isValid(v) and inst.components.container:CanTakeItemInSlot(item) then
                            return true;
                        end
                    else
                        if isValid(v) and v.prefab == item.prefab and not item:HasTag("unwrappable") then
                            return true;
                        end
                    end
                end
            end)

            if #target_items > 0 then
                if success_fx == nil then
                    success_fx = true;
                end

                -- 找到了就生成特效，而不是被转移的生成特效...
                local v_x, v_y, v_z = ent.Transform:GetWorldPosition();
                if not oneOfNull(3, v_x, v_y, v_z) then
                    SpawnPrefab("sand_puff").Transform:SetPosition(v_x, v_y, v_z);
                end
            end

            -- 这里需要好好处理一下...
            -- 相关引用的处理需要使用官方的函数，不要自己随意处理...比如这里需要用到 RemoveItemBySlot 函数。
            for _, target in ipairs(target_items) do
                -- 2023-05-14-22:40：这里可以优化一下的，但是先算了。
                local slot;
                for k, v in pairs(ent.components.container.slots) do
                    if v == target then
                        slot = k;
                        break ;
                    end
                end
                if slot then
                    local item = ent.components.container:RemoveItemBySlot(slot);
                    item.prevslot = nil;
                    item.prevcontainer = nil;
                    if not inst.components.container:GiveItem(item) then
                        ent.components.container:GiveItem(item, slot);
                    end
                end
            end
        end

        if success_fx then
            local fx = SpawnPrefab("sand_puff");
            local scale = 1.4;
            fx.Transform:SetScale(scale, scale, scale);
            fx.Transform:SetPosition(x, y, z);
        end

        -- 捡起周围物品
        PickUpItems(inst);

        inst.one_click_storage_busy = nil;
    end

    function fns.storage_fn(inst, doer)
        if inst.components.container ~= nil then
            OneClickStorage(inst);
        elseif inst.replica.container ~= nil and not inst.replica.container:IsBusy() then
            SendModRPCToServer(MOD_RPC["more_items"]["storage_button_fn"], inst);
        end
    end

    function fns.storage_validfn(inst)
        --return inst.replica.container ~= nil and not inst.replica.container:IsEmpty();
        return true;
    end

    return {
        storage_fn = fns.storage_fn;
        storage_validfn = fns.storage_validfn;
    }
end

local StorageButton = storage_button();

local storage_fn = StorageButton.storage_fn;
local storage_validfn = StorageButton.storage_validfn;

-- 给扩展包提供的
if API.StorageButton == nil then
    API.StorageButton = StorageButton;
end

-- 其他
local icebox_itemtestfn = params.icebox and params.icebox.itemtestfn;
local saltbox_itemtestfn = params.saltbox and params.saltbox.itemtestfn;

local function isIcebox(container, item, slot, ...)
    if isFn(icebox_itemtestfn) then
        return icebox_itemtestfn(container, item, slot, ...);
    end

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

local function isSaltbox(container, item, slot, ...)
    if isFn(saltbox_itemtestfn) then
        return saltbox_itemtestfn(container, item, slot, ...);
    end

    return ((item:HasTag("fresh") or item:HasTag("stale") or item:HasTag("spoiled"))
            and item:HasTag("cookable")
            and not item:HasTag("deployable")
            and not item:HasTag("smallcreature")
            and item.replica.health == nil)
            or item:HasTag("saltbox_valid")
end

------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------
local DoFns = setmetatable({}, {
    __newindex = function(t, k, v)
        if type(v) ~= "function" then
            return ;
        end
        rawset(t, k, v);
    end
})

-- 升级版·箱子、升级版·龙鳞宝箱、升级版·冰箱、升级版·盐盒
-- 三种容量：4x4 5x5 6x6
function DoFns.chests()
    local mone_chests_boxs_capability = TUNING.MONE_TUNING.GET_MOD_CONFIG_DATA.mone_chests_boxs_capability;
    -- 我去，有个坑，我应该加个 else 的，因为 mone_chests_boxs_capability 之前缓存的值是 bool 型...

    local common_chest;
    local condition = mone_chests_boxs_capability;
    local switch = {
        [1] = function()
            common_chest = {
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
                    },
                    more_items_storage_buttoninfo = {
                        text = "高级整理",
                        position = Vector3(0, 185, 0),
                        fn = storage_fn,
                        validfn = storage_validfn
                    };
                },
                type = "chest",
            }

            for y = 2, -1, -1 do
                for x = -1, 2 do
                    table.insert(common_chest.widget.slotpos, Vector3(80 * x - 40, 80 * y - 40, 0))
                end
            end

            -- 滚动条容器测试了一下，不太行，感觉翻页式的应该还行
            if SCROLL and false --[[ 也很难受，算了 ]] then
                common_chest.widget.slotpos = {};
                common_chest.widget.more_items_scroll = {
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
                        table.insert(common_chest.widget.slotpos, Vector3(80 * x - 40, 80 * y - 40, 0))
                    end
                end
                for y = 2, -1, -1 do
                    for x = -1, 2 do
                        table.insert(common_chest.widget.slotpos, Vector3(80 * x - 40, 80 * y - 40, 0))
                    end
                end
            end
        end,
        [2] = function()
            common_chest = {
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
                    },
                    more_items_storage_buttoninfo = {
                        text = "高级整理",
                        position = Vector3(0, 211, 0),
                        fn = storage_fn,
                        validfn = storage_validfn
                    };
                },
                type = "chest",
            }

            for y = 2, -2, -1 do
                for x = -2, 2 do
                    table.insert(common_chest.widget.slotpos, Vector3(75 * x, 75 * y, 0))
                end
            end
        end,
        [3] = function()
            common_chest = {
                widget = {
                    slotpos = {},
                    animbank = "my_chest_ui_6x6",
                    animbuild = "my_chest_ui_6x6",
                    pos = Vector3(0, 200 + 20, 0),
                    side_align_tip = 160,
                    buttoninfo = {
                        text = TEXT.TIDY,
                        position = Vector3(75 * 0, -75 * 3 - 37.5 + 5 - 20 + 20, 0),
                        fn = fn,
                        validfn = validfn;
                    },
                    more_items_storage_buttoninfo = {
                        text = "高级整理",
                        position = Vector3(0, -(-75 * 3 - 37.5 + 5 - 20 + 20) - 4 + 1, 0),
                        fn = storage_fn,
                        validfn = storage_validfn
                    };
                },
                type = "chest",
            }

            for y = 2, -3, -1 do
                for x = -3, 2 do
                    table.insert(common_chest.widget.slotpos, Vector3(75 * x + 37.5, 75 * y + 37.5, 0))
                end
            end
        end,
        ["default"] = function()
            common_chest = {
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
                    table.insert(common_chest.widget.slotpos, Vector3(80 * x - 40, 80 * y - 40, 0))
                end
            end
        end
    }
    if switch[condition] then
        switch[condition]();
    elseif switch["default"] then
        switch["default"]();
    end

    params.mone_treasurechest = deepcopy(common_chest);
    params.mone_dragonflychest = deepcopy(common_chest);
    params.mone_icebox = deepcopy(common_chest);
    params.mone_saltbox = deepcopy(common_chest);

    function params.mone_icebox.itemtestfn(container, item, slot)
        return isIcebox(container, item, slot);
    end

    function params.mone_saltbox.itemtestfn(container, item, slot)
        return isSaltbox(container, item, slot);
    end
end

-- 杂物箱
function DoFns.skull_chest()
    local function pre_excluded(container, item, slot)
        return item:HasTag("_equippable")
                or table.contains({

        }, item.prefab);
    end

    local function included(container, item, slot)
        return item:HasTag("skull_chest_itemtestfn")
                or item:HasTag("sketch")
                or item:HasTag("wintersfeastfood")

                or string.find(item.prefab, "^dug_")
                or string.find(item.prefab, "^turf_")
                or string.find(item.prefab, "^deer_antler")
                or string.find(item.prefab, "^feather_")
                --or string.find(item.prefab, "^trinket_")

                or table.contains({
            "", -- 树枝类，
            "", -- 草类
            "", -- 燧石类
            "", -- 硝石类
            "log", "boards", "charcoal", "pinecone", -- 木头类
            --"rocks","cutstone", -- 石头类
            --"goldnugget", -- 金块类

            -- 其他
            "ash", "sketch", "cookingrecipecard", "lavae_egg", "glommerwings",
            "pig_token", "blueprint",
            --"stinger",
            --"coontail",
        }, item.prefab);
    end

    params.mone_skull_chest = {
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
            },
            more_items_storage_buttoninfo = {
                text = "快捷收纳",
                position = Vector3(0, 211, 0),
                fn = storage_fn,
                validfn = storage_validfn
            };
        },
        type = "chest",
        itemtestfn = function(container, item, slot)
            if item.prefab == container.inst.prefab then
                return false;
            end
            if pre_excluded(container, item, slot) then
                return false;
            end
            if included(container, item, slot) then
                return true;
            end
            return false;
        end
    }

    for y = 2, -2, -1 do
        for x = -2, 2 do
            table.insert(params.mone_skull_chest.widget.slotpos, Vector3(75 * x, 75 * y, 0))
        end
    end

    local common_chest = {
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
            },
            more_items_storage_buttoninfo = {
                text = "快捷收纳",
                position = Vector3(0, 185, 0),
                fn = storage_fn,
                validfn = storage_validfn
            };
        },
        type = "chest",
        itemtestfn = function(container, item, slot)
            if item.prefab == container.inst.prefab then
                return false;
            end
            if pre_excluded(container, item, slot) then
                return false;
            end
            if included(container, item, slot) then
                return true;
            end
            return false;
        end
    }

    for y = 2, -1, -1 do
        for x = -1, 2 do
            table.insert(common_chest.widget.slotpos, Vector3(80 * x - 40, 80 * y - 40, 0))
        end
    end

    --params.mone_skull_chest = deepcopy(common_chest);
end

-- 海上箱子：120格
function DoFns.waterchest()
    local button_pos = Vector3(-5, 193, 0);

    params.mone_waterchest = {
        widget = {
            slotpos = {},
            animbank = "big_box_ui_120",
            animbuild = "big_box_ui_120",
            pos = Vector3(0, 0 + 100, 0),
            buttoninfo = {
                text = "整理",
                position = button_pos + Vector3(-75, 0, 0), --数字诡异因为背景图调的不好
                fn = fn,
                validfn = validfn
            },
            more_items_waterchest_buttoninfo = {
                text = "关闭",
                position = button_pos + Vector3(75, 0, 0),
                fn = function(inst, doer)
                    if inst.components.container ~= nil then
                        if inst.components.container:IsOpen() then
                            inst.components.container:Close(doer);
                        end
                    elseif inst.replica.container ~= nil and not inst.replica.container:IsBusy() then
                        SendModRPCToServer(MOD_RPC["more_items"]["close_button_fn"], inst);
                    end
                end,
                validfn = function(inst)
                    return true;
                end;
            }
        },
        type = "mone_waterchest",
        itemtestfn = function(container, item, slot)
            if container.inst.prefab == item.prefab then
                return false;
            end
            --if item.prefab == "mone_waterchest_inv" then
            --    return false;
            --end
            --if item:HasTag("_container") then
            --    return false;
            --end
            return true;
        end
    }
    local spacer = 30; -- 间距
    local posX; -- x
    local posY; -- y
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
end

-- 收纳袋：40格
function DoFns.piggyback()
    local GetNumSlots = 40 -- 固定 40！
    local animbank, animbuild, X, Y, posX, posY, button_pos;

    local condition = GetNumSlots;
    local switch = {
        [20] = function()
            animbank = "ui_chest_4x5"
            animbuild = "ui_chest_4x5"
            X = 4
            Y = 3
            posX = 90
            posY = 130
            button_pos = Vector3(80 * X / 2 - 346 * 2 + posX, 80 * 0 - 100 * 2 + posY - 53, 0)
        end,
        [40] = function()
            animbank = "ui_chest_5x8"
            animbuild = "ui_chest_5x8"
            X = 7
            Y = 4
            posX = 109
            posY = 42
            button_pos = Vector3(80 * X / 2 - 346 * 2 + posX, 80 * 0 - 100 * 2 + posY - 53, 0)
        end,
        [60] = function()
            animbank = "ui_chest_5x12"
            animbuild = "ui_chest_5x12"
            X = 11
            Y = 4
            posX = 98
            posY = 42
            button_pos = Vector3(80 * X / 2 - 346 * 2 + posX, 80 * 0 - 100 * 2 + posY - 53, 0)
        end,
        [80] = function()
            animbank = "ui_chest_5x16"
            animbuild = "ui_chest_5x16"
            X = 15
            Y = 4
            posX = 91
            posY = 42
            button_pos = Vector3(80 * X / 2 - 346 * 2 + posX, 80 * 0 - 100 * 2 + posY - 53, 0)
        end
    }
    if switch[condition] then
        switch[condition]();
    elseif switch["default"] then
        switch["default"]();
    end

    params.mone_piggyback = {
        widget = {
            slotpos = {},
            animbank = animbank,
            animbuild = animbuild,
            pos = Vector3(360 - (GetNumSlots * 4.5), 150, 0),
            buttoninfo = {
                text = TEXT.TIDY,
                position = button_pos,
                fn = fn,
                validfn = validfn
            },
            more_items_piggyback_buttoninfo = {
                text = "关闭",
                position = button_pos + Vector3(0, 423 + 1, 0),
                fn = function(inst, doer)
                    if inst.components.container ~= nil then
                        if inst.components.container:IsOpen() then
                            inst.components.container:Close(doer);
                        end
                    elseif inst.replica.container ~= nil and not inst.replica.container:IsBusy() then
                        SendModRPCToServer(MOD_RPC["more_items"]["close_button_fn"], inst);
                    end
                end,
                validfn = function(inst)
                    return true;
                end;
            }
        },
        type = "mone_piggyback",
        itemtestfn = function(container, item, slot)
            if container.inst.prefab == item.prefab then
                return false;
            end
            --if table.contains({ "mie_book_silviculture", "mie_book_horticulture" }, item.prefab) then
            --    return true;
            --end
            --if item:HasTag("_container") then
            --    return false;
            --end
            return true;
        end
    }

    for y = Y, 0, -1 do
        for x = 0, X do
            table.insert(params.mone_piggyback.widget.slotpos, Vector3(80 * x - 346 * 2 + posX, 80 * y - 100 * 2 + posY, 0))
        end
    end

    -- 2023-06-18-NEW: 格子从上到下排列
    --if isDebug() then
    --    params.mone_piggyback.widget.slotpos = {};
    --    for x = 0, X do
    --        for y = Y, 0, -1 do
    --            table.insert(params.mone_piggyback.widget.slotpos, Vector3(80 * x - 346 * 2 + posX, 80 * y - 100 * 2 + posY, 0))
    --        end
    --    end
    --end
end

-- 升级版·雪球发射器
function DoFns.firesuppressor()
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
end

-- 垃圾焚化炉
function DoFns.chiminea()
    --params.mone_chiminea = {
    --    widget = {
    --        slotpos = {},
    --        animbank = "ui_chest_3x3",
    --        animbuild = "ui_chest_3x3",
    --        pos = Vector3(0, 200, 0),
    --        side_align_tip = 160,
    --        buttoninfo = {
    --            text = TEXT.DELETE,
    --            position = Vector3(0, -140, 0),
    --            fn = function(inst, doer)
    --                if inst.components.container then
    --                    --local age_in_days = inst.components.age and inst.components.age:GetDisplayAgeInDays();
    --                    --local visitorAge = 20;
    --                    --if age_in_days and age_in_days < visitorAge then
    --                    --    if doer.components.talker then
    --                    --        local msg = "我只存活了：" .. tostring(age_in_days) .. "天，不足 " .. tostring(visitorAge) .. " 天，因此我无法销毁物品！";
    --                    --        doer.components.talker:Say(msg);
    --                    --    end
    --                    --    return ;
    --                    --end
    --                    for _, v in pairs(inst.components.container:RemoveAllItems()) do
    --                        if isValid(v) then
    --                            print(tostring(v.prefab) .. " Remove");
    --                            v:Remove();
    --                        end
    --                    end
    --                    inst.SoundEmitter:PlaySound("dontstarve/common/fireOut")
    --                elseif inst.replica.container and not inst.replica.container:IsBusy() then
    --                    SendRPCToServer(RPC.DoWidgetButtonAction, nil, inst, nil)
    --                end
    --            end,
    --            validfn = function(inst)
    --                return inst.replica.container ~= nil and not inst.replica.container:IsEmpty()
    --            end
    --        }
    --    },
    --    type = "chest",
    --    itemtestfn = function(container, item, slot)
    --        return not (item:HasTag("irreplaceable") or item:HasTag("_container") or item:HasTag("bundle") or item:HasTag("nobundling"))
    --    end
    --}
    --for y = 2, 0, -1 do
    --    for x = 0, 2 do
    --        table.insert(params.mone_chiminea.widget.slotpos, Vector3(80 * x - 80 * 2 + 80, 80 * y - 80 * 2 + 80, 0))
    --    end
    --end

    local common_chest = {
        widget = {
            slotpos = {},
            animbank = "my_chest_ui_5x5",
            animbuild = "my_chest_ui_5x5",
            pos = Vector3(0, 200, 0),
            buttoninfo = {
                text = TEXT.DELETE,
                position = Vector3(0, -75 * 3 + 10, 0),
                fn = function(inst, doer)
                    if inst.components.container then
                        for _, v in pairs(inst.components.container:RemoveAllItems()) do
                            if isValid(v) then
                                print(tostring(v.prefab) .. " Remove");
                                v:Remove();
                            end
                        end
                        inst.SoundEmitter:PlaySound("dontstarve/common/fireOut")
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

    for y = 2, -2, -1 do
        for x = -2, 2 do
            table.insert(common_chest.widget.slotpos, Vector3(75 * x, 75 * y, 0))
        end
    end

    params.mone_chiminea = deepcopy(common_chest);
end

-- 你的装备柜
function DoFns.wardrobe()
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
                hat_slot(); chest_slot(); tool_slot(); hat_slot(); chest_slot(); tool_slot();
                hat_slot(); chest_slot(); tool_slot(); hat_slot(); chest_slot(); tool_slot();
                hat_slot(); chest_slot(); tool_slot(); hat_slot(); chest_slot(); tool_slot();
                hat_slot(); chest_slot(); tool_slot(); hat_slot(); chest_slot(); tool_slot();
                hat_slot(); chest_slot(); tool_slot(); hat_slot(); chest_slot(); tool_slot();
                hat_slot(); chest_slot(); tool_slot(); hat_slot(); chest_slot(); tool_slot();
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

    for y = 2, -3, -1 do
        for x = -3, 2 do
            table.insert(params.mone_wardrobe.widget.slotpos, Vector3(75 * x + 37.5, 75 * y + 37.5, 0))
        end
    end

    -- NEW
    --if isDebug() then
    --    params.mone_wardrobe.widget.slotpos = {};
    --    for x = -3, 2 do
    --        for y = 2, -3, -1 do
    --            table.insert(params.mone_wardrobe.widget.slotpos, Vector3(75 * x + 37.5, 75 * y + 37.5, 0))
    --        end
    --    end
    --    if #params.mone_wardrobe.widget.slotbg > 0 then
    --        params.mone_wardrobe.widget.slotbg = {
    --            hat_slot(); hat_slot(); hat_slot(); hat_slot(); hat_slot(); hat_slot();
    --            chest_slot(); chest_slot(); chest_slot(); chest_slot(); chest_slot(); chest_slot();
    --            tool_slot(); tool_slot(); tool_slot(); tool_slot(); tool_slot(); tool_slot();
    --            hat_slot(); hat_slot(); hat_slot(); hat_slot(); hat_slot(); hat_slot();
    --            chest_slot(); chest_slot(); chest_slot(); chest_slot(); chest_slot(); chest_slot();
    --            tool_slot(); tool_slot(); tool_slot(); tool_slot(); tool_slot(); tool_slot();
    --        }
    --    end
    --end

end

-- 装备袋
function DoFns.backpack()
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
                    or item.prefab == "foliageath_mylove"
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

    if config_data.mone_backpack_capacity == 2 then
        params.mone_backpack.widget.slotpos = {};
        params.mone_backpack.widget.animbank = "ui_chester_shadow_3x4";
        params.mone_backpack.widget.animbuild = "ui_chester_shadow_3x4";
        params.mone_backpack.widget.pos = Vector3(587, -74, 0);

        if params.mone_backpack.widget.buttoninfo then
            -- 此处不会执行的
            params.mone_backpack.widget.buttoninfo.position = Vector3(-1, -177, 0);
        elseif params.mone_backpack.widget.more_items_buttoninfo then
            params.mone_backpack.widget.more_items_buttoninfo.position = Vector3(1, -177, 0);
        end

        for y = 2.5, -0.5, -1 do
            for x = 0, 2 do
                table.insert(params.mone_backpack.widget.slotpos, Vector3(75 * x - 75 * 2 + 75, 75 * y - 75 * 2 + 75, 0))
            end
        end
    elseif config_data.mone_backpack_capacity == 3 then
        params.mone_backpack.widget.slotpos = {};
        params.mone_backpack.widget.animbank = "ui_tacklecontainer_3x5";
        params.mone_backpack.widget.animbuild = "ui_tacklecontainer_3x5";
        params.mone_backpack.widget.pos = Vector3(587, -74 + 60 - 3, 0);

        if params.mone_backpack.widget.more_items_buttoninfo then
            params.mone_backpack.widget.more_items_buttoninfo.position = Vector3(1, -177 - 130 - 50, 0);
        end

        for y = 1, -3, -1 do
            for x = 0, 2 do
                table.insert(params.mone_backpack.widget.slotpos, Vector3(80 * x - 80 * 2 + 80, 80 * y - 45, 0))
            end
        end
    end
end

-- 小书架
function DoFns.bookstation()
    params.mone_bookstation = {
        widget = {
            slotpos = {},
            animbank = "ui_bookstation_4x5",
            animbuild = "ui_bookstation_4x5",
            pos = Vector3(0, 280, 0) + Vector3(370, 0, 0),
            side_align_tip = 160,
        },
        type = "chest_mone_bookstation",
    }

    for y = 0, 4 do
        table.insert(params.mone_bookstation.widget.slotpos, Vector3(-114, (-77 * y) + 37 - (y * 2), 0))
        table.insert(params.mone_bookstation.widget.slotpos, Vector3(-114 + 75, (-77 * y) + 37 - (y * 2), 0))
        table.insert(params.mone_bookstation.widget.slotpos, Vector3(-114 + 150, (-77 * y) + 37 - (y * 2), 0))
        table.insert(params.mone_bookstation.widget.slotpos, Vector3(-114 + 225, (-77 * y) + 37 - (y * 2), 0))
    end

    function params.mone_bookstation.itemtestfn(container, item, slot)
        return item:HasTag("bookcabinet_item");
    end
end

-- 工具袋
function DoFns.tool_bag()
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
        type = "mone_tool_bag",
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
                    or item.prefab == "oceanfishingrod"
                    or item.prefab == "portableboat_item"
                    --or item.prefab == "yellowamulet"
                    or item.prefab == "voidcloth_umbrella"
                    or string.find(item.prefab, "saddle_")
                    or string.find(item.prefab, "_fishingnet")
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
end

-- 食物袋
function DoFns.icepack()
    params.mone_icepack = {
        widget = {
            slotpos = {},
            animbank = "ui_backpack_2x4",
            animbuild = "ui_backpack_2x4",
            pos = Vector3(-300 + 40 + 80, 200 - 40 - 220, 0), --Vector3(552, -72, 0),
            side_align_tip = 160,
            buttoninfo = {
                text = TEXT.TIDY,
                position = Vector3(-125, -176, 0),
                fn = fn,
                validfn = validfn,
            },
        },
        type = "mone_icepack",
        itemtestfn = function(container, item, slot)
            return item:HasTag("_perishable_mone") or item:HasTag("non_preparedfood");
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

    if config_data.mone_icepack_capacity == 2 then
        params.mone_icepack.widget.slotpos = {};
        params.mone_icepack.widget.animbank = "ui_chester_shadow_3x4";
        params.mone_icepack.widget.animbuild = "ui_chester_shadow_3x4";
        params.mone_icepack.widget.pos = Vector3(-300 + 40 + 80, 200 - 40 - 220, 0); -- Vector3(399, -74, 0);

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
end

-- 猪猪袋
function DoFns.piggybag()
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
end

-- 女武神的歌谣盒
function DoFns.wathgrithr_box()
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
end

-- 旺达的钟表盒
function DoFns.wanda_box()
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
end

-- 材料袋
function DoFns.candybag()
    local capacity = config_data.mone_candybag_capacity;

    capacity = 1; -- 算了

    if capacity == 1 then
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
    elseif capacity == 2 then
        params.mone_candybag = {
            widget = {
                slotpos = {},
                animbank = "ui_chest_3x3",
                animbuild = "ui_revolvedmoonlight_4x3",
                pos = Vector3(0 + 800 - 200 + 90 - 10, 200 - 90 + 10 - 5 + 20, 0),
                side_align_tip = 160,
                more_items_buttoninfo = {
                    text = emoji.palm,
                    text_position = Vector3(0, 1, 0),
                    position = Vector3(-2, 130, 0),
                    fn = fn,
                    validfn = validfn,
                }
            },
            type = "mone_candybag",
            itemtestfn = function(container, item, slot)
                return table.contains({ "cutgrass", "twigs", "flint", "rocks", "goldnugget", "log", }, item.prefab);
            end
        }
        for y = 0, 2 do
            table.insert(params.mone_candybag.widget.slotpos, Vector3(-122, (-77 * y) + 80 - (y * 2), 0))
            table.insert(params.mone_candybag.widget.slotpos, Vector3(-122 + 75, (-77 * y) + 80 - (y * 2), 0))
            table.insert(params.mone_candybag.widget.slotpos, Vector3(-122 + 150, (-77 * y) + 80 - (y * 2), 0))
            table.insert(params.mone_candybag.widget.slotpos, Vector3(-122 + 225, (-77 * y) + 80 - (y * 2), 0))
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
end

-- 妈妈放心种子袋
function DoFns.seedpouch()
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
end

-- 保鲜袋
function DoFns.storage_bag()
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
end

-- 暗夜空间斗篷
function DoFns.nightspace_cape()
    local capacity = config_data.mone_nightspace_cape_capacity;

    if capacity == 1 then
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
    elseif capacity == 2 then
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

        for y = 0, 6 do
            table.insert(params.mone_nightspace_cape.widget.slotpos, Vector3(-162, -75 * y + 240, 0))
            table.insert(params.mone_nightspace_cape.widget.slotpos, Vector3(-162 + 75, -75 * y + 240, 0))
        end
    end
end

-- 海上背包
function DoFns.seasack()
    if config_data.mone_seasack_capacity_increase then
        params.mone_seasack = {
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
            table.insert(params.mone_seasack.widget.slotpos, Vector3(-131 - 75, -75 * y + 264, 0))
            table.insert(params.mone_seasack.widget.slotpos, Vector3(-131, -75 * y + 264, 0))
            table.insert(params.mone_seasack.widget.slotpos, Vector3(-131 + 75, -75 * y + 264, 0))
        end
        return ;
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
end

-- 杂物箱
--function DoFns.moondial()
--
--end

-- 升级版·龙鳞火炉
function DoFns.dragonflyfurnace()
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
end

-- 升级版·月晷
function DoFns.moondial()
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
end

for _, do_fn in pairs(DoFns) do
    do_fn();
end

------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------
-- 官方背包和我的背包添加一键整理按钮：more_items_buttoninfo
local function backpack_arrange_button()
    local PITCH_OF_MY_BUTTON = true; -- 修改后的按钮
    for i, v in ipairs({
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

if config_data.backpack_arrange_button then
    backpack_arrange_button();
end


-- 官方容器添加按钮：普通箱子、龙鳞宝箱、冰箱、盐盒
local function klei_chests_arrangement_button()
    for _, v in ipairs({ params.treasurechest, params.dragonflychest, params.icebox, params.saltbox }) do
        if v and type(v) == "table"
                and v.widget and v.widget.buttoninfo == nil
                and v.widget.slotpos
                and (#v.widget.slotpos == 9 or #v.widget.slotpos == 12) then
            -- 添加整理按钮
            if config_data.klei_chests_arrangement_button then
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

            -- 添加高级整理按钮
            if config_data.klei_chests_storage_button then
                local position = Vector3(0, 0, 0);
                if #v.widget.slotpos == 9 then
                    position = Vector3(0, 143, 0);
                elseif #v.widget.slotpos == 12 then
                    position = Vector3(-1, 177, 0);
                end
                v.widget.more_items_storage_buttoninfo = {
                    text = "高级整理",
                    position = position,
                    fn = storage_fn,
                    validfn = storage_validfn;
                }
            end
        end
    end
end

klei_chests_arrangement_button();

-- 一些补丁
local patches = setmetatable({}, {
    __newindex = function(t, k, v)
        if type(v) ~= "function" then
            return ;
        end
        rawset(t, k, v);
    end
});

-- emm, 添加了新按钮之后，官方的 RPC 失效了，在此处修改掉吧！PS：2023-03-31-15:30：我自己 Send Add 不就行了吗。我为什么非要用官方的？
---- 2023-05-08：这还得放后面执行，不然背包添加按钮失效了。我咋写的我忘了，先在这里记录一下吧。
patches[1] = function()
    TUNING.MONE_TUNING.NEW_BUTTON_NEW = true;
    if TUNING.MONE_TUNING.NEW_BUTTON_NEW then
        for k, v in pairs(params) do
            if v and v.widget and v.widget.buttoninfo == nil and v.widget.more_items_buttoninfo then
                v.widget.buttoninfo = v.widget.more_items_buttoninfo;
            end
        end
    end
end

-- 修改装备袋容量为 3x5，这种情况下，装备袋 itemtestfn = 装备袋 itemtestfn + 工具袋 itemtestfn
patches[2] = function()
    if config_data.mone_backpack_capacity == 3 and params.mone_backpack and params.mone_tool_bag then
        local old_fn1, old_fn2 = params.mone_backpack.itemtestfn, params.mone_tool_bag.itemtestfn;
        params.mone_backpack.itemtestfn = function(...)
            return old_fn1(...) or old_fn2(...);
        end
    end
end

-- 无效？
--patches[3] = function()
--    if not isDebug() then
--        return ;
--    end
--    local medal_box = params.medal_box;
--    if medal_box then
--        medal_box.issidewidget = nil;
--        medal_box.widget.pos = medal_box.widget.pos + Vector3(0, 0, 0);
--    end
--end

for _, do_fn in pairs(patches) do
    do_fn();
end

-- 打个补丁，兼容一下老麦
local function compatible_with_maxwell()
    local CONTAINERS = {
        -- 装备袋
        ["mone_backpack"] = function(t)
            t.widget.pos = Vector3(-250, 0, 0)
        end,
        -- 材料袋
        ["mone_candybag"] = function(t)
            t.widget.pos = Vector3(-250, 210, 0)
        end,
        -- 工具袋
        ["mone_tool_bag"] = function(t)
            t.widget.pos = Vector3(-450, -250, 0)
        end,
        -- 食物袋
        ["mone_icepack"] = function(t)
            t.widget.pos = Vector3(-250, -250, 0)
        end,
        -- 猪猪袋
        ["mone_piggybag"] = function(t)
            t.widget.pos = Vector3(-450, -18, 0)
        end,
    }
    for k, _fn in pairs(CONTAINERS) do
        if params[k] then
            params[k].issidewidget = true
            _fn(params[k])
        end
    end
end

if config_data.compatible_with_maxwell then
    compatible_with_maxwell()
end

------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------
for k, v in pairs(params) do
    containers.MAXITEMSLOTS = math.max(containers.MAXITEMSLOTS, v.widget.slotpos ~= nil and #v.widget.slotpos or 0)
end




