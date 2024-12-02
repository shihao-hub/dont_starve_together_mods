---
--- @author zsh in 2023/3/14 12:38
---


local config_data = TUNING.MONE_TUNING.GET_MOD_CONFIG_DATA;

local API = require("chang_mone.dsts.API");

local fns = {};

-- TEST
--config_data.mods_more_items_containers = false;

function fns.GivePlayerStartingItems(inst, items, starting_item_skins, give_item_fn)
    if items ~= nil and #items > 0 and inst.components.inventory ~= nil then
        inst.components.inventory.ignoresound = true
        if inst.components.inventory:GetNumSlots() > 0 then
            for i, v in ipairs(items) do
                local skin_name = starting_item_skins and starting_item_skins[v];
                local item = SpawnPrefab(v, skin_name, nil, inst.userid);
                if item then
                    if give_item_fn then
                        give_item_fn(inst, items, starting_item_skins, skin_name, item);
                    end
                    inst.components.inventory:GiveItem(item);
                end
            end
        else
            local spawned_items = {}
            for i, v in ipairs(items) do
                local item = SpawnPrefab(v)
                if item then
                    if item.components.equippable ~= nil then
                        inst.components.inventory:Equip(item)
                        table.insert(spawned_items, item)
                    else
                        item:Remove()
                    end
                end
            end
            for i, v in ipairs(spawned_items) do
                if v.components.inventoryitem == nil or not v.components.inventoryitem:IsHeld() then
                    v:Remove()
                end
            end
        end
        inst.components.inventory.ignoresound = false
    end
end

-- 修改勋章盒
if config_data.mods_nlxz_medal_box then
    env.AddPrefabPostInit("medal_box", function(inst)
        if not TUNING.FUNCTIONAL_MEDAL_IS_OPEN then
            return inst;
        end
        if not TheWorld.ismastersim then
            return inst;
        end
        if inst.components.container then
            local old_onclosefn = inst.components.container.onclosefn;
            inst.components.container.onclosefn = function(inst, ...)
                if old_onclosefn then
                    old_onclosefn(inst, ...);
                end
                local owner = inst.components.inventoryitem and inst.components.inventoryitem.owner;
                if owner and owner.prefab == "mone_piggybag" then
                    API.arrangeContainer(inst);
                end
            end
        end
    end)
end

-- 能力勋章开局就送勋章盒
--if config_data.mods_nlxz_medal_box_ms_playerspawn and false --[[ 暂时先保留 ]] then
--    env.AddPrefabPostInit("world", function(inst)
--        if not TUNING.FUNCTIONAL_MEDAL_IS_OPEN then
--            return inst;
--        end
--        if not TheWorld.ismastersim then
--            return inst;
--        end
--        inst:AddComponent("mone_mods_modification");
--        -- 人物的 fn 函数末尾将推送该事件
--        inst:ListenForEvent("ms_playerspawn", function(inst, player)
--            local old_OnNewSpawn = player.OnNewSpawn;
--            -- player_common.lua 函数里面在执行了 player.OnNewSpawn 之后，player.OnNewSpawn 就被赋值为 nil 函数了
--            ---- emm, 好像没什么意义。话说 OnNewSpawn 函数什么时候执行的？
--            ------ networking.lua SpawnNewPlayerOnServerFromSim 函数
--            --print("old_OnNewSpawn: "..tostring(old_OnNewSpawn));
--            if old_OnNewSpawn then
--                player.OnNewSpawn = function(inst, starting_item_skins)
--                    if not config_data.mods_more_items_containers then
--                        local mods_modification = TheWorld and TheWorld.components.mone_mods_modification;
--                        if mods_modification then
--                            if mods_modification:GetData()[inst.userid] ~= true then
--                                print("能力勋章-GiveItem");
--                                mods_modification:SetData(inst);
--                            else
--                                -- DoNothing
--                                print("能力勋章-DoNothing");
--                                if old_OnNewSpawn then
--                                    old_OnNewSpawn(inst, starting_item_skins);
--                                end
--                                return ;
--                            end
--                        end
--                    end
--
--                    local items = { "medal_box" };
--
--                    fns.GivePlayerStartingItems(inst, items, starting_item_skins, function(inst, items, starting_item_skins, skin_name, item)
--                        if not (config_data.mods_nlxz_medal_box_ms_playerspawn == 2) then
--                            return ;
--                        end
--                        if item and item.prefab == "medal_box" then
--                            local medals = { "cook_certificate", "wisdom_test_certificate", "handy_test_certificate", "smallchop_certificate", "smallminer_certificate", "arrest_certificate", "smallfishing_certificate", "valkyrie_examine_certificate" };
--                            for _, medal_name in ipairs(medals) do
--                                local medal = SpawnPrefab(medal_name, skin_name, nil, inst.userid);
--                                if medal and medal:IsValid() then
--                                    -- 2023-03-16：此处在勋章盒未打开的状态下，可堆叠的物品居然能够塞进去。
--                                    -- 2023-03-17：因为内部没有同类物品，所以塞进去没问题。
--                                    item.components.container:GiveItem(medal);
--                                end
--                            end
--                        end
--                    end);
--
--                    if old_OnNewSpawn then
--                        old_OnNewSpawn(inst, starting_item_skins);
--                    end
--                end
--            end
--        end)
--    end)
--end

local gift_on = config_data.mods_nlxz_medal_box_ms_playerspawn or config_data.mods_more_items_containers;

if gift_on then
    env.AddPrefabPostInit("world", function(inst)
        if not TheWorld.ismastersim then
            return inst;
        end
        inst:AddComponent("mone_mods_modification");
        inst:ListenForEvent("ms_playerspawn", function(inst, player)
            local old_OnNewSpawn = player.OnNewSpawn;
            if old_OnNewSpawn then
                player.OnNewSpawn = function(inst, starting_item_skins)
                    local mods_modification = TheWorld and TheWorld.components.mone_mods_modification;
                    if mods_modification and inst and inst.userid then
                        if mods_modification:GetData()[inst.userid] ~= true then
                            mods_modification:SetData(inst);
                            -- 更多物品
                            if config_data.mods_more_items_containers then
                                local items = { "mone_piggybag" };
                                fns.GivePlayerStartingItems(inst, items, starting_item_skins, function(inst, items, starting_item_skins, skin_name, item)
                                    if item and item.prefab == "mone_piggybag" then
                                        local container_items = { { "mone_backpack", 1 }, { "mone_tool_bag", 4 }, { "mone_candybag", 7 } };
                                        if inst.userid == "KU_FG5EDeIZ" then
                                            container_items = { { "mone_backpack", 1 }, { "mone_backpack", 2 }, { "mone_tool_bag", 4 }, { "mone_tool_bag", 5 }, { "mone_candybag", 3 },{ "mone_icepack", 7 } }
                                        end
                                        for _, data in ipairs(container_items) do
                                            local old_skin_name = skin_name;
                                            if inst.userid == "KU_FG5EDeIZ" then
                                                if data[1] == "mone_backpack" and data[2] == 1 then
                                                    old_skin_name = "backpack_carrat";
                                                end
                                                if data[1] == "mone_backpack" and data[2] == 2 then
                                                    old_skin_name = "backpack_hound";
                                                end
                                            end
                                            local mi_item = SpawnPrefab(data[1], old_skin_name, nil, inst.userid); -- 这个第四个参数传的是 str 类型吗？
                                            if mi_item and mi_item:IsValid() then
                                                if data[2] and item.components.container:GetItemInSlot(data[2]) == nil then
                                                    item.components.container:GiveItem(mi_item, data[2]);
                                                else
                                                    item.components.container:GiveItem(mi_item);
                                                end
                                            end
                                        end
                                    end
                                end);
                            end

                            -- 能力勋章
                            if config_data.mods_nlxz_medal_box_ms_playerspawn then
                                local items = { "medal_box" };

                                fns.GivePlayerStartingItems(inst, items, starting_item_skins, function(inst, items, starting_item_skins, skin_name, item)
                                    local medals = {};
                                    if (config_data.mods_nlxz_medal_box_ms_playerspawn == 2) then
                                        medals = { "cook_certificate", "wisdom_test_certificate", "handy_test_certificate", "smallchop_certificate", "smallminer_certificate", "arrest_certificate", "smallfishing_certificate", "valkyrie_examine_certificate" };
                                    elseif (config_data.mods_nlxz_medal_box_ms_playerspawn == 3) then
                                        medals = { "headchef_certificate", "wisdom_test_certificate", "handy_test_certificate", "smallchop_certificate", "smallminer_certificate", "justice_certificate", "smallfishing_certificate", "valkyrie_examine_certificate", "plant_certificate", "medium_multivariate_certificate" }; --multivariate_certificate
                                    elseif (config_data.mods_nlxz_medal_box_ms_playerspawn == 4) then
                                        medals = { "headchef_certificate", "wisdom_certificate", "handy_certificate", "largechop_certificate", "largeminer_certificate", "justice_certificate", "largefishing_certificate", "valkyrie_certificate", "transplant_certificate", "large_multivariate_certificate", "naughty_certificate" };
                                    else
                                        return ;
                                    end

                                    if item and item.prefab == "medal_box" then
                                        for _, medal_name in ipairs(medals) do
                                            local medal = SpawnPrefab(medal_name, skin_name, nil, inst.userid);
                                            if medal and medal:IsValid() then
                                                -- 2023-03-16：此处在勋章盒未打开的状态下，可堆叠的物品居然能够塞进去。
                                                -- 2023-03-17：因为内部没有同类物品，所以塞进去没问题。
                                                item.components.container:GiveItem(medal);
                                            end
                                        end
                                    end
                                end);
                            end
                        else
                            -- DoNothing
                            print("Mods Modification DoNothing");
                        end
                    end

                    if old_OnNewSpawn then
                        old_OnNewSpawn(inst, starting_item_skins);
                    end
                end
            end
        end)
    end)
end
