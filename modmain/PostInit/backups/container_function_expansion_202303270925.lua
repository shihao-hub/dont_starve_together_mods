local convenient_piggyback1 = TUNING.MONE_TUNING.GET_MOD_CONFIG_DATA.item_go_into_waterchest_inv_or_piggyback;
local convenient_piggyback2 = TUNING.MONE_TUNING.GET_MOD_CONFIG_DATA.direct_consumption;

-- 暂时先不生效
if convenient_piggyback1 and false then
    -- 修改 ACTIONS.PICKUP 动作的执行函数
    if ACTIONS.PICKUP then
        local old_fn = ACTIONS.PICKUP.fn;
        ACTIONS.PICKUP.fn = function(act)
            local args = { old_fn(act) };
            if #args == 0 then
                return unpack(args);
            end
            -- 成功执行到此处的时候，Push 一个事件
            ---- 不行，这样有点慢，已经在身上的预制物直接塞进未打开的容器问题很大。
            act.doer:PushEvent("mone_onpickupitem", { item = act.target })
            return unpack(args);
        end
    end

    local function isSpecifiedContainer(inst)
        for _, v in ipairs({
            "mone_piggyback", "mone_waterchest_inv"
        }) do
            if inst and inst.prefab == v then
                return true;
            end
        end
    end

    -- 只检索口袋
    local function findPocketContainers(player)
        local containers = {};
        -- 检索口袋
        for _, v in ipairs(player.components.inventory:FindItems(isSpecifiedContainer)) do
            table.insert(containers, v);
        end
        return containers;
    end

    -- 检索口袋、背包、猪猪袋
    local function findAllContainers(player)
        local mone_piggybag = player.components.inventory:FindItem(function(item)
            local container = item.components.container;
            if item.prefab == "mone_piggybag" and container and container:IsOpen() then
                return true;
            end
        end)
        local containers = {};
        -- 检索口袋
        for _, v in ipairs(player.components.inventory:FindItems(isSpecifiedContainer)) do
            table.insert(containers, v);
        end
        -- 检索背包 GetOverflowContainer 得到的是 container 组件
        local overflow = player.components.inventory:GetOverflowContainer();
        if overflow then
            for _, v in ipairs(overflow:FindItems(isSpecifiedContainer)) do
                table.insert(containers, v);
            end
        end
        -- 检索猪猪袋
        if mone_piggybag then
            for _, v in ipairs(mone_piggybag.components.container:FindItems(isSpecifiedContainer)) do
                table.insert(containers, v);
            end
        end

        return containers;
    end

    --[[ 捡起的物品尝试塞到某容器中 ]]

end

--[[ 物品拾取入袋功能 ]]
if convenient_piggyback1 then

    local TEST = false;
    env.AddComponentPostInit("container", function(self)
        if not TEST then
            return ;
        end

        function self:GiveItem(item, slot, src_pos, drop_on_fail)
            if item == nil then
                return false
            elseif item.components.inventoryitem ~= nil and self:CanTakeItemInSlot(item, slot) then
                if slot == nil then
                    slot = self:GetSpecificSlotForItem(item)
                end
                -- chang: 一般情况，slot 应该都是 nil

                --try to burn off stacks if we're just dumping it in there
                if item.components.stackable ~= nil and self.acceptsstacks then
                    --Added this for when we want to dump a stack back into a
                    --specific spot (e.g. moving half a stack failed, so we
                    --need to dump the leftovers back into the original stack)
                    if slot ~= nil and slot <= self.numslots then
                        local other_item = self.slots[slot]
                        if other_item ~= nil and other_item.prefab == item.prefab and other_item.skinname == item.skinname and not other_item.components.stackable:IsFull() then
                            if self.inst.components.inventoryitem ~= nil and self.inst.components.inventoryitem.owner ~= nil then
                                self.inst.components.inventoryitem.owner:PushEvent("gotnewitem", { item = item, slot = slot })
                            end

                            item = other_item.components.stackable:Put(item, src_pos)
                            if item == nil then
                                return true
                            end

                            slot = self:GetSpecificSlotForItem(item)
                        end
                    end

                    -- chang: slot == nil，先把里面有的，依次堆满。服了。这为什么不对啊。
                    if slot == nil then
                        for k = 1, self.numslots do
                            local other_item = self.slots[k]
                            -- chang: 如果遍历到同名预制物，皮肤也一致，而且还没有堆叠满，就能进入该 if 域
                            if other_item and other_item.prefab == item.prefab and other_item.skinname == item.skinname and not other_item.components.stackable:IsFull() then
                                print(string.format("   [%s]-other_item: %s", tostring(k), tostring(other_item)));
                                if self.inst.components.inventoryitem ~= nil and self.inst.components.inventoryitem.owner ~= nil then
                                    self.inst.components.inventoryitem.owner:PushEvent("gotnewitem", { item = item, slot = k })
                                end

                                item = other_item.components.stackable:Put(item, src_pos)
                                if item == nil then
                                    return true
                                end
                            end
                        end

                        --if item and item:IsValid() and item.mi_give_item then
                        --    local find_slot;
                        --    if slot ~= nil and slot <= self.numslots and not self.slots[slot] then
                        --        find_slot = slot
                        --    elseif not self.usespecificslotsforitems and self.numslots > 0 then
                        --        for i = 1, self.numslots do
                        --            if not self.slots[i] then
                        --                find_slot = i
                        --                break
                        --            end
                        --        end
                        --    end
                        --    if find_slot then
                        --
                        --    end
                        --end
                    end
                end

                if item and item:IsValid() then
                    print("item.prefab: " .. tostring(item.prefab) .. ", number: "
                            .. tostring(item.components.stackable and item.components.stackable:StackSize() or 1));
                end

                local in_slot = nil
                if slot ~= nil and slot <= self.numslots and not self.slots[slot] then
                    in_slot = slot
                elseif not self.usespecificslotsforitems and self.numslots > 0 then
                    -- chang: 遍历找到第一个空洞，in_slot 就等于那个空洞的序号
                    for i = 1, self.numslots do
                        if not self.slots[i] then
                            in_slot = i
                            break
                        end
                    end
                end

                print("in_slot: " .. tostring(in_slot));

                -- chang: acceptsstacks 默认为 true
                if in_slot then
                    --weird case where we are trying to force a stack into a non-stacking container. this should probably have been handled earlier, but this is a failsafe
                    if not self.acceptsstacks and item.components.stackable and item.components.stackable:StackSize() > 1 then
                        print("----1");
                        item = item.components.stackable:Get()
                        self.slots[in_slot] = item
                        item.components.inventoryitem:OnPutInInventory(self.inst)
                        self.inst:PushEvent("itemget", { slot = in_slot, item = item, src_pos = src_pos, })
                        return false
                    end
                    print("----2");
                    -- 问题出现在这里！！！

                    self.slots[in_slot] = item
                    item.components.inventoryitem:OnPutInInventory(self.inst)
                    self.inst:PushEvent("itemget", { slot = in_slot, item = item, src_pos = src_pos })

                    if not self.ignoresound and self.inst.components.inventoryitem ~= nil and self.inst.components.inventoryitem.owner ~= nil then
                        self.inst.components.inventoryitem.owner:PushEvent("gotnewitem", { item = item, slot = in_slot })
                    end

                    return true
                end
            end

            --default to true if nil
            if drop_on_fail ~= false then
                --@V2C NOTE: not supported when using container_proxy
                item.Transform:SetPosition(self.inst.Transform:GetWorldPosition())
                if item.components.inventoryitem ~= nil then
                    item.components.inventoryitem:OnDropped(true)
                end
            end
            return false
        end
    end)


    -- 检索物品栏的全部处于关闭状态的收纳袋和海上箱子
    local function onpickupitem2(inst, data)
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
                    if item and item:IsValid() then
                        item.mi_give_item = nil;
                    end
                else
                    print("item_valid: " .. tostring(item and item:IsValid()));
                end
                -- 问题如下：不可堆叠的预制物之所以塞不进去不是塞不进去，而是只能堆满。。。
                ---- 我看样子需要修改 container:GiveItem 函数了。

                if not success then
                    print("success: " .. tostring(success));
                end
                break ;
            end
        end
    end

    env.AddPlayerPostInit(function(inst)
        if not TheWorld.ismastersim then
            return inst;
        end

        inst:ListenForEvent("onpickupitem", function(inst, data)
            onpickupitem2(inst, data);
        end);
    end)
end

--[[ 直接消耗容器里的材料制作物品 ]]
if convenient_piggyback2 then

    -- 检索口袋里全部处于关闭状态的容器（打开状态的容器官方已经实现）
    -- 但是有个问题，这个函数会类似刷帧的方式执行。。。
    local function direct_consumption_all(self)
        local old_Has = self.Has;
        function self:Has(item, amount, checkallcontainers)
            local _, num_found = old_Has(self, item, amount, checkallcontainers);

            local containers = {};
            for _, v in ipairs(self.itemslots) do
                if v and v.components.container then
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
            for _, v in ipairs(self.itemslots) do
                if v and v.components.container then
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
    end

    -- 检索口袋里处于关闭状态的收纳袋和海上箱子
    local function direct_consumption(self)
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
    end

    env.AddComponentPostInit("inventory", direct_consumption);
end