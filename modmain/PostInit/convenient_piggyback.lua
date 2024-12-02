---
--- @author zsh in 2023/7/3 14:48
---


-- 以下部分功能失效？


local function old()
    local convenient_piggyback1 = TUNING.MONE_TUNING.GET_MOD_CONFIG_DATA.item_go_into_waterchest_inv_or_piggyback;
    local convenient_piggyback2 = TUNING.MONE_TUNING.GET_MOD_CONFIG_DATA.direct_consumption;

    -- 拾取入袋功能所需要的，用于发出声音：哎，咋说呢，垃圾功能，也不好删掉...
    AddClientModRPCHandler("more_items", "container_client_play_sound2", function(...)
        TheFocalPoint.SoundEmitter:PlaySound("dontstarve/HUD/collect_resource");
    end)

    --[[ 物品拾取入袋功能 ]]
    if convenient_piggyback1 then
        -- 处理开启洞穴后，没有声音的问题
        -- 容器未打开状态，压根没有触发 itemget 事件。。。
        --[[    for _, name in ipairs({ "mone_piggyback", "mone_waterchest_inv" }) do
                env.AddPrefabPostInit(name, function(inst)
                    if not TheWorld.ismastersim then
                        -- 是客户端部分
                        inst:ListenForEvent("itemget", function(inst, data)
                            TheFocalPoint.SoundEmitter:PlaySound("dontstarve/HUD/collect_resource");
                            print("inst.replica.container._isopen: " .. tostring(((inst.replica or {}).container or {})._isopen));
                            if inst:HasTag("INLIMBO")
                                    and not (inst.replica and inst.replica.container and inst.replica.container._isopen)
                            then
                                if TheNet:GetServerIsClientHosted() then
                                    if TheNet:GetIsServer() or TheNet:IsDedicated() then
                                        -- 不是专用服务器，是房主的饥荒进程
                                        TheFocalPoint.SoundEmitter:PlaySound("dontstarve/HUD/collect_resource");
                                    else
                                        -- 不是专用服务器且不是房主的饥荒进程，则什么都不做
                                    end
                                else
                                    -- 是专用服务器
                                    TheFocalPoint.SoundEmitter:PlaySound("dontstarve/HUD/collect_resource");
                                end
                            end
                        end)
                        return inst;
                    end
                end)
            end]]

        local function pickup_action_fn_part(act)
            -- 判个空
            if not (act.doer and act.target) then
                return ;
            end
            -- 执行相关内容
            if act.target.components.equippable ~= nil and not act.target.components.equippable:IsRestricted(act.doer) then
                local equip = act.doer.components.inventory:GetEquippedItem(act.target.components.equippable.equipslot)
                if equip ~= nil and not act.target.components.inventoryitem.cangoincontainer then
                    --special case for trying to carry two backpacks
                    if equip.components.inventoryitem ~= nil and equip.components.inventoryitem.cangoincontainer then
                        --act.doer.components.inventory:SelectActiveItemFromEquipSlot(act.target.components.equippable.equipslot)
                        act.doer.components.inventory:GiveItem(act.doer.components.inventory:Unequip(act.target.components.equippable.equipslot))
                    else
                        act.doer.components.inventory:DropItem(equip)
                    end
                    act.doer.components.inventory:Equip(act.target)
                    return true
                elseif act.doer:HasTag("player") then
                    if equip == nil or act.doer.components.inventory:GetNumSlots() <= 0 then
                        act.doer.components.inventory:Equip(act.target)
                        return true
                    elseif GetGameModeProperty("non_item_equips") then
                        act.doer.components.inventory:DropItem(equip)
                        act.doer.components.inventory:Equip(act.target)
                        return true
                    end
                end
            end
        end


        -- 在这里写！
        env.AddComponentPostInit("inventory", function(self)
            local old_GiveItem = self.GiveItem;
        end)

        env.AddPlayerPostInit(function(inst)
            if not TheWorld.ismastersim then
                return inst;
            end

            inst:ListenForEvent("onpickupitem", function(inst, data)
                --do
                --    -- TEST
                --    return;
                --end

                -- ACTIONS.PICKUP.fn act.doer:PushEvent("onpickupitem", { item = act.target }) 之后的部分函数
                --pickup_action_fn_part({ doer = inst, target = data.item }); -- 这个函数咋导致的不能直接装备物品？
                -- 检索物品栏的全部处于关闭状态的收纳袋和海上箱子
                local item = data and data.item;
                if item == nil then
                    return ;
                end

                local containers = {};

                local itemslots = inst.components.inventory.itemslots;

                for _, v in pairs(itemslots) do
                    if v and v.components.container then
                        if not v.components.container:IsOpen() then
                            if v.prefab == "mone_piggyback" or v.prefab == "mone_waterchest_inv" then
                                table.insert(containers, v);
                            end
                        end
                    end
                end

                for _, v in ipairs(containers) do
                    local container = v.components.container;
                    if container and container:Has(item.prefab, 1) then
                        local success;
                        if item and item:IsValid() then
                            item.mi_give_item = true;
                            success = container:GiveItem(item);

                            if TheNet:GetServerIsClientHosted() --[[不是专用服务器]] then
                                --print("Not dedicated server");
                                if TheNet:IsDedicated() --[[开洞的房主服务端进程]] then
                                    --print("Open the host server process");
                                    SendModRPCToClient(CLIENT_MOD_RPC["more_items"]["container_client_play_sound2"], inst.userid);
                                elseif TheNet:GetIsServer() --[[不开洞的房主饥荒过程]] then
                                    --print("Do not open the hole of the homeowner famine process");
                                else
                                    -- 这里还有什么进程呢？
                                    --print("What else is going on here?");
                                    SendModRPCToClient(CLIENT_MOD_RPC["more_items"]["container_client_play_sound2"], inst.userid);
                                end
                            else
                                -- 是专用服务器
                                --print("Is a dedicated server");
                                SendModRPCToClient(CLIENT_MOD_RPC["more_items"]["container_client_play_sound2"], inst.userid);
                            end

                            if item and item:IsValid() then
                                item.mi_give_item = nil;
                            end
                        else
                            print("item_valid: " .. tostring(item and item:IsValid()));
                        end
                        if not success then
                            print("success: " .. tostring(success));
                        end

                        -- 问题如下：不可堆叠的预制物之所以塞不进去不是塞不进去，而是只能堆满。。。
                        ---- 我看样子需要修改 container:GiveItem 函数了。

                        break ;
                    end
                end
            end);
        end)
    end

    --[[ 直接消耗容器里的材料制作物品 ]]
    if convenient_piggyback2 then
        env.AddComponentPostInit("inventory", function(self)
            -- 检索口袋里处于关闭状态的收纳袋和海上箱子
            local old_Has = self.Has;
            function self:Has(item, amount, checkallcontainers)
                local _, num_found = old_Has(self, item, amount, checkallcontainers);

                local containers = {};

                local itemslots = self.itemslots;

                for _, v in pairs(itemslots) do
                    if v.prefab == "mone_piggyback" or v.prefab == "mone_waterchest_inv" then
                        if not v.components.container:IsOpen() then
                            table.insert(containers, v);
                        end
                    end

                end
                for _, v in ipairs(containers) do
                    local container = v.components.container;
                    if container and not container.excludefromcrafting then
                        local iscrafting = checkallcontainers;
                        local container_enough, container_found = container:Has(item, amount, iscrafting)
                        num_found = num_found + container_found
                    end
                end
                return num_found >= amount, num_found;
            end

            local old_GetCraftingIngredient = self.GetCraftingIngredient;
            function self:GetCraftingIngredient(item, amount)
                local crafting_items = old_GetCraftingIngredient(self, item, amount);

                local total_num_found = 0;
                local containers = {};

                local itemslots = self.itemslots;

                for _, v in pairs(itemslots) do
                    if v.prefab == "mone_piggyback" or v.prefab == "mone_waterchest_inv" then
                        if not v.components.container:IsOpen() then
                            table.insert(containers, v);
                        end
                    end
                end
                for _, container_inst in ipairs(containers) do
                    local container = container_inst.components.container;
                    if container and not container.excludefromcrafting then
                        for k, v in pairs(container:GetCraftingIngredient(item, amount - total_num_found, true)) do
                            crafting_items[k] = v
                            total_num_found = total_num_found + v
                        end
                    end
                    if total_num_found >= amount then
                        return crafting_items
                    end
                end
                return crafting_items;
            end
        end);
    end
end
old();


-- 2023-07-03：好不容易打开了开了洞穴的世界，刚刚打开收纳袋就闪退底层崩溃了，不知道是不是这里的问题
-- 备忘：此处代码极大概率有问题。（但是不应该呀，我就改动了 AddClientModRPCHandler 函数内容...）
-- 果然，我就不该写这个功能，要开洞穴太慢了，太浪费时间了。。。
local function new()
    local convenient_piggyback1 = TUNING.MONE_TUNING.GET_MOD_CONFIG_DATA.item_go_into_waterchest_inv_or_piggyback;
    local convenient_piggyback2 = TUNING.MONE_TUNING.GET_MOD_CONFIG_DATA.direct_consumption;

    if convenient_piggyback1 or convenient_piggyback2 then
        AddClientModRPCHandler("more_items", "container_client_play_sound2", function(...)
            local item = (select(1, ...));
            local player = ThePlayer;
            if player and item and type(item) == "table" then
                local sound = item and item.pickupsound or "DEFAULT_FALLBACK"
                TheFocalPoint.SoundEmitter:PlaySound(player._PICKUPSOUNDS[sound])
            end
        end)
    end

    -- 物品拾取入袋功能
    if convenient_piggyback1 then
        env.AddPlayerPostInit(function(inst)
            if not TheWorld.ismastersim then
                return inst;
            end

            inst:ListenForEvent("onpickupitem", function(inst, data)
                local item = data and data.item;
                if item == nil then
                    return ;
                end

                local containers = {};

                local itemslots = inst.components.inventory.itemslots;

                for _, v in pairs(itemslots) do
                    if v and v.components.container then
                        if not v.components.container:IsOpen() then
                            if v.prefab == "mone_piggyback" or v.prefab == "mone_waterchest_inv" then
                                table.insert(containers, v);
                            end
                        end
                    end
                end

                for _, v in ipairs(containers) do
                    local container = v.components.container;
                    if container and container:Has(item.prefab, 1) then
                        local success;
                        if item and item:IsValid() then
                            item.mi_give_item = true;

                            if TheNet:GetServerIsClientHosted() --[[不是专用服务器]] then
                                if TheNet:IsDedicated() --[[开洞的房主服务端进程]] then
                                    SendModRPCToClient(CLIENT_MOD_RPC["more_items"]["container_client_play_sound2"], inst.userid, item);
                                elseif TheNet:GetIsServer() --[[不开洞的房主饥荒过程]] then
                                    -- DoNothing
                                else
                                    SendModRPCToClient(CLIENT_MOD_RPC["more_items"]["container_client_play_sound2"], inst.userid, item);
                                end
                            else
                                --[[是专用服务器]]
                                SendModRPCToClient(CLIENT_MOD_RPC["more_items"]["container_client_play_sound2"], inst.userid, item);
                            end

                            success = container:GiveItem(item);

                            if item and item:IsValid() then
                                item.mi_give_item = nil;
                            end
                        else
                            print("item_valid: " .. tostring(item and item:IsValid()));
                        end
                        if not success then
                            print("success: " .. tostring(success));
                        end
                        break ;
                    end
                end
            end);
        end)
    end

    -- 直接消耗容器里的材料制作物品：开了洞穴不怎么有效...
    if convenient_piggyback2 then
        env.AddComponentPostInit("inventory", function(self)
            -- 检索口袋里处于关闭状态的收纳袋和海上箱子
            local old_Has = self.Has;
            function self:Has(item, amount, checkallcontainers)
                local _, num_found = old_Has(self, item, amount, checkallcontainers);

                local containers = {};

                local itemslots = self.itemslots;

                for _, v in pairs(itemslots) do
                    if v.prefab == "mone_piggyback" or v.prefab == "mone_waterchest_inv" then
                        if not v.components.container:IsOpen() then
                            table.insert(containers, v);
                        end
                    end

                end
                for _, v in ipairs(containers) do
                    local container = v.components.container;
                    if container and not container.excludefromcrafting then
                        local iscrafting = checkallcontainers;
                        local container_enough, container_found = container:Has(item, amount, iscrafting)
                        num_found = num_found + container_found
                    end
                end
                return num_found >= amount, num_found;
            end

            local old_GetCraftingIngredient = self.GetCraftingIngredient;
            function self:GetCraftingIngredient(item, amount)
                local crafting_items = old_GetCraftingIngredient(self, item, amount);

                local total_num_found = 0;
                local containers = {};

                local itemslots = self.itemslots;

                for _, v in pairs(itemslots) do
                    if v.prefab == "mone_piggyback" or v.prefab == "mone_waterchest_inv" then
                        if not v.components.container:IsOpen() then
                            table.insert(containers, v);
                        end
                    end
                end
                for _, container_inst in ipairs(containers) do
                    local container = container_inst.components.container;
                    if container and not container.excludefromcrafting then
                        for k, v in pairs(container:GetCraftingIngredient(item, amount - total_num_found, true)) do
                            crafting_items[k] = v
                            total_num_found = total_num_found + v
                        end
                    end
                    if total_num_found >= amount then
                        return crafting_items
                    end
                end
                return crafting_items;
            end
        end);
    end
end
--new();