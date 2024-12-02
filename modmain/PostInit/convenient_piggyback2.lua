---
--- @author zsh in 2023/7/10 14:23
---



local convenient_piggyback1 = TUNING.MONE_TUNING.GET_MOD_CONFIG_DATA.item_go_into_waterchest_inv_or_piggyback;
local convenient_piggyback2 = TUNING.MONE_TUNING.GET_MOD_CONFIG_DATA.direct_consumption;

local ContainersToFind = { "mone_piggyback", "mone_waterchest_inv" };

local function BothServerClient()
    return TheNet:GetIsServer() and not TheNet:IsDedicated();
end
-- 量子消耗：暂时仅开了独行长路的房主...不开独行长路的话，暂时不行，计划通过 Json 实现
if convenient_piggyback2 and (BothServerClient() or OneOfModEnabled("2657513551")) then
    -- 暂定为检测放在物品栏的所有相关容器
    env.AddComponentPostInit("inventory", function(self)
        local old_Has = self.Has;
        function self:Has(item, amount, checkallcontainers, ...)
            local _, num_found = old_Has(self, item, amount, checkallcontainers, ...);

            local containers = {};
            for _, v in pairs(self.itemslots) do
                if table.contains(ContainersToFind, v.prefab) then
                    if not v.components.container:IsOpen() then
                        table.insert(containers, v);
                    end
                end
            end
            if #containers > 0 then
                for _, v in ipairs(containers) do
                    local container = v.components.container;
                    if container and not container.excludefromcrafting then
                        local iscrafting = checkallcontainers;
                        local container_enough, container_found = container:Has(item, amount, iscrafting)
                        num_found = num_found + container_found
                    end
                end
            end
            return num_found >= amount, num_found;
        end

        local old_GetCraftingIngredient = self.GetCraftingIngredient;
        function self:GetCraftingIngredient(item, amount, ...)
            local crafting_items = old_GetCraftingIngredient(self, item, amount, ...);

            local total_num_found = 0;
            local containers = {};
            for _, v in pairs(self.itemslots) do
                if table.contains(ContainersToFind, v.prefab) then
                    if not v.components.container:IsOpen() then
                        table.insert(containers, v);
                    end
                end
            end
            if #containers > 0 then
                for _, container_inst in ipairs(containers) do
                    local container = container_inst.components.container;
                    if container and not container.excludefromcrafting then
                        for k, v in pairs(container:GetCraftingIngredient(item, amount - total_num_found, true)) do
                            crafting_items[k] = v
                            total_num_found = total_num_found + v
                        end
                    end
                    if total_num_found >= amount then
                        return crafting_items;
                    end
                end
            end
            return crafting_items;
        end

        -- 这里需要处理一下？啊，之前没处理，是没问题的。啊？这里加了之后会双倍消耗。。。
        --local old_RemoveItem = self.RemoveItem;
        --function self:RemoveItem(item, wholestack, ...)
        --    local res = { old_RemoveItem(self, item, wholestack, ...) };
        --
        --    local containers = {};
        --    for _, v in pairs(self.itemslots) do
        --        if table.contains(ContainersToFind, v.prefab) then
        --            if not v.components.container:IsOpen() then
        --                table.insert(containers, v);
        --            end
        --        end
        --    end
        --    if #containers > 0 then
        --        for _, v in ipairs(containers) do
        --            local container = v.components.container;
        --            if container and not container.excludefromcrafting then
        --                local container_item = container:RemoveItem(item, wholestack)
        --                if container_item then
        --                    return container_item;
        --                end
        --            end
        --        end
        --    end
        --
        --    return unpack(res, 1, table.maxn(res));
        --end
    end)
end

-- 拾取入袋：2023-07-10-14:00：优化了一下，好了很多
if convenient_piggyback1 then
    local function ClientPlaySoundPreLoad()
        local rpc_namespace = "more_items";
        local rpc_name = "container_client_play_sound2";
        AddClientModRPCHandler(rpc_namespace, rpc_name, function(...)
            local pickupsound = (select(1, ...));
            local player = ThePlayer;

            local data = { item = { pickupsound = pickupsound } };

            if TheNet:GetServerIsClientHosted() --[[不是专用服务器]] then
                if TheNet:IsDedicated() --[[开洞的房主服务端进程]] then
                    NonGeneralFns.PlaySoundOnGotNewItem(player, data);
                elseif TheNet:GetIsServer() --[[不开洞的房主饥荒过程]] then
                    -- DoNothing
                else
                    NonGeneralFns.PlaySoundOnGotNewItem(player, data);
                end
            else
                --[[是专用服务器]]
                NonGeneralFns.PlaySoundOnGotNewItem(player, data);
            end
        end)
    end
    ClientPlaySoundPreLoad();

    local function ClientPlaySound(inst, ...)
        if not isValid(inst) then
            return ;
        end
        SendModRPCToClient(CLIENT_MOD_RPC["more_items"]["container_client_play_sound2"], inst.userid, ...);
    end

    -- 特别地...
    local function ContainerCanAcceptCount(container_inst, item, maxcount)
        local inst = container_inst;
        local container = inst.components.container;

        if not isValid(inst) or null(container) then
            return ;
        end

        local stacksize = math.max(maxcount or 0, item.components.stackable ~= nil and item.components.stackable.stacksize or 1)
        if stacksize <= 0 then
            return 0
        end

        local acceptcount = 0

        local self = container;
        --check for empty space in the container
        for k = 1, self.numslots do
            local v = self.slots[k]
            if v ~= nil then
                if v.prefab == item.prefab and v.skinname == item.skinname and v.components.stackable ~= nil then
                    acceptcount = acceptcount + v.components.stackable:RoomLeft()
                    if acceptcount >= stacksize then
                        return stacksize
                    end
                end
            elseif self:CanTakeItemInSlot(item, k) then
                if self.acceptsstacks or stacksize <= 1 then
                    return stacksize
                end
                acceptcount = acceptcount + 1
                if acceptcount >= stacksize then
                    return stacksize
                end
            end
        end

        -- 如果容器内塞不下，返回 0
        return 0
    end

    local function InventoryCanAcceptCount(self, item, maxcount)
        local stacksize = math.max(maxcount or 0, item.components.stackable ~= nil and item.components.stackable.stacksize or 1)
        if stacksize <= 0 then
            return 0
        end

        local acceptcount = 0

        --check for empty space in the container
        for k = 1, self.maxslots do
            local v = self.itemslots[k]
            -- 只检索非空物品栏，空的物品栏忽略
            if v ~= nil then
                if v.prefab == item.prefab and v.skinname == item.skinname and v.components.stackable ~= nil then
                    acceptcount = acceptcount + v.components.stackable:RoomLeft()
                    if acceptcount >= stacksize then
                        return stacksize
                    end
                end
            end
        end

        if not (item.components.inventoryitem ~= nil and item.components.inventoryitem.canonlygoinpocket) then
            --check for empty space in our backpack
            local overflow = self:GetOverflowContainer()
            if overflow ~= nil then
                for k = 1, overflow.numslots do
                    local v = overflow.slots[k]
                    -- 这里也同理，背包中空的格子也忽略
                    if v ~= nil then
                        if v.prefab == item.prefab and v.skinname == item.skinname and v.components.stackable ~= nil then
                            acceptcount = acceptcount + v.components.stackable:RoomLeft()
                            if acceptcount >= stacksize then
                                return stacksize
                            end
                        end
                    end
                end
            end
        end

        if item.components.stackable ~= nil then
            --check for equip stacks that aren't full
            for k, v in pairs(self.equipslots) do
                if v.prefab == item.prefab and v.skinname == item.skinname and v.components.equippable.equipstack and v.components.stackable ~= nil then
                    acceptcount = acceptcount + v.components.stackable:RoomLeft()
                    if acceptcount >= stacksize then
                        return stacksize
                    end
                end
            end
        end

        -- 如果已有的格子塞不下，返回 0
        return 0
    end

    local function InventoryCanAcceptCount2(self, item, maxcount)
        local stacksize = math.max(maxcount or 0, item.components.stackable ~= nil and item.components.stackable.stacksize or 1)
        if stacksize <= 0 then
            return 0
        end

        local acceptcount = 0

        --check for empty space in the container
        for k = 1, self.maxslots do
            local v = self.itemslots[k]
            if v ~= nil then
                if v.prefab == item.prefab and v.skinname == item.skinname and v.components.stackable ~= nil then
                    acceptcount = acceptcount + v.components.stackable:RoomLeft()
                    if acceptcount >= stacksize then
                        return stacksize
                    end
                end
            elseif self:CanTakeItemInSlot(item, k) then
                if self.acceptsstacks or stacksize <= 1 then
                    return stacksize
                end
                acceptcount = acceptcount + 1
                if acceptcount >= stacksize then
                    return stacksize
                end
            end
        end

        if not (item.components.inventoryitem ~= nil and item.components.inventoryitem.canonlygoinpocket) then
            --check for empty space in our backpack
            local overflow = self:GetOverflowContainer()
            if overflow ~= nil then
                for k = 1, overflow.numslots do
                    local v = overflow.slots[k]
                    if v ~= nil then
                        if v.prefab == item.prefab and v.skinname == item.skinname and v.components.stackable ~= nil then
                            acceptcount = acceptcount + v.components.stackable:RoomLeft()
                            if acceptcount >= stacksize then
                                return stacksize
                            end
                        end
                    elseif overflow:CanTakeItemInSlot(item, k) then
                        if overflow.acceptsstacks or stacksize <= 1 then
                            return stacksize
                        end
                        acceptcount = acceptcount + 1
                        if acceptcount >= stacksize then
                            return stacksize
                        end
                    end
                end
            end
        end

        if item.components.stackable ~= nil then
            --check for equip stacks that aren't full
            for k, v in pairs(self.equipslots) do
                if v.prefab == item.prefab and v.skinname == item.skinname and v.components.equippable.equipstack and v.components.stackable ~= nil then
                    acceptcount = acceptcount + v.components.stackable:RoomLeft()
                    if acceptcount >= stacksize then
                        return stacksize
                    end
                end
            end
        end

        -- 如果已有的格子塞不下或压根没格子了，返回 0
        return 0
    end

    local function OnPickupItem(inst, data)
        -- 检索物品栏的全部处于关闭状态的那些容器
        local item = data and data.item;
        if item == nil or not isValid(item) then
            return ;
        end

        local containers = {};

        local itemslots = inst.components.inventory.itemslots;

        for _, v in pairs(itemslots) do
            if v and v.components.container then
                -- 只搜索未被打开的那些容器
                if not v.components.container:IsOpen() then
                    if table.contains(ContainersToFind, v.prefab) then
                        table.insert(containers, v);
                    end
                end
            end
        end

        if #containers <= 0 then
            return ;
        end

        for _, v in ipairs(containers) do
            local container = v.components.container;

            if isValid(item) and item.components.stackable and container and container:Has(item.prefab, 1) then
                -- 判断一下身上能不能放得下
                if not (InventoryCanAcceptCount(inst.components.inventory, item, 1) > 0) then
                    if container:GiveItem(item) then
                        ClientPlaySound(inst, item.pickupsound);
                    end
                    -- 看了一下 stackable 的 Put 代码才知道需要在此处再执行一次...
                    -- 呃，但是立刻执行的话，为什么明明判断了有效性调用 GiveItem 时 item 却是无效的？
                    --if isValid(item) then
                    --    if container:GiveItem(item) then
                    --        ClientPlaySound(inst, item.pickupsound);
                    --    end
                    --end

                    inst:DoTaskInTime(0, function()
                        if isValid(item) and item:IsInLimbo()
                                and isValid(inst)
                                and container
                                and isValid(container.inst)
                                and container:Has(item.prefab, 1)
                                and ContainerCanAcceptCount(container.inst, item, 1) > 0 then
                            -- 呃，这个 ContainerCanAcceptCount 应该不需要调用
                            local item_owner = item.components.inventoryitem.owner;
                            if item_owner then
                                if item_owner == inst then
                                    item = inst.components.inventory:RemoveItem(item, true);
                                elseif item_owner:HasTag("_container") then
                                    item = item_owner.components.container:RemoveItem(item, true);
                                end
                            end

                            -- 第二次塞的时候不要发出声音
                            local old_ignoresound = container.ignoresound;
                            if not old_ignoresound then
                                container.ignoresound = true;
                            end
                            if container:GiveItem(item, nil, container.inst:GetPosition()) then
                                --ClientPlaySound(inst, item.pickupsound);
                                if not old_ignoresound then
                                    container.ignoresound = false;
                                end
                            end
                        end
                    end)
                end
                break ;
            end
        end
    end

    env.AddPlayerPostInit(function(inst)
        if not TheWorld.ismastersim then
            return inst;
        end
        inst:ListenForEvent("onpickupitem", OnPickupItem);
    end)
end
