-- 处理一下客户端没声音的问题
-- 2023-03-07-10:49：不知道客机怎么获取 owner，暂时搁置。
--for _, v in ipairs({
--    "mone_storage_bag", "mone_piggybag","mone_tool_bag",
--    "mone_backpack", "mone_piggyback", "mone_candybag", "mone_icepack",
--    "mone_wathgrithr_box", "mone_wanda_box",
--    "mone_waterchest_inv",
--}) do
--
--    -- 怎么获取 owner?
--    -- 自己写个 NetVar？麻烦哦！
--    local function playSoundClient(inst, data)
--        local owner = inst.components.inventoryitem and inst.components.inventoryitem.owner;
--        if owner == nil then
--            return ;
--        end
--        if owner:HasTag("player") then
--            -- DoNothing
--            return ;
--        end
--        if owner.prefab == "mone_piggybag" then
--            TheFocalPoint.SoundEmitter:PlaySound("dontstarve/HUD/collect_resource");
--        end
--    end
--
--    local function playSoundServer(inst, data)
--        local owner = inst.components.inventoryitem and inst.components.inventoryitem.owner;
--        if owner == nil then
--            return ;
--        end
--        if owner:HasTag("player") then
--            -- DoNothing
--            return ;
--        end
--        if owner.prefab == "mone_piggybag" then
--            TheFocalPoint.SoundEmitter:PlaySound("dontstarve/HUD/collect_resource");
--        end
--    end
--    env.AddPrefabPostInit(v, function(inst)
--        if not TheWorld.ismastersim then
--            --inst:ListenForEvent("itemget", playSoundClient);
--            --inst:ListenForEvent("gotnewitem", playSoundClient);
--            return inst;
--        end
--        inst:ListenForEvent("itemget", playSoundServer);
--        inst:ListenForEvent("gotnewitem", playSoundServer);
--    end)
--end

local convenient_piggyback = TUNING.MONE_TUNING.GET_MOD_CONFIG_DATA.item_go_into_waterchest_inv_or_piggyback;

-- 暂时先不生效
if convenient_piggyback and false then
    -- 修改 ACTIONS.PICKUP 动作的执行函数
    if ACTIONS.PICKUP then
        local old_fn = ACTIONS.PICKUP.fn;
        ACTIONS.PICKUP.fn = function(act)
            local args = { old_fn(act) };
            if #args == 0 then
                return unpack(args);
            end
            -- 成功执行到此处的时候，Push 一个事件
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

--do
--    -- 此处？  -- 并不是
--    return;
--end

-- 此处代码应放在文件末尾，因为有 do return; end
if TUNING.MONE_TUNING.GET_MOD_CONFIG_DATA.item_go_into_waterchest_inv_or_piggyback then
    -- TEST: 不行的。。。
    -- 修改 ACTIONS.PICKUP 动作的执行函数
    --if ACTIONS.PICKUP then
    --    local old_fn = ACTIONS.PICKUP.fn;
    --    ACTIONS.PICKUP.fn = function(act)
    --        local args = { old_fn(act) };
    --        if #args == 0 then
    --            return unpack(args);
    --        end
    --        -- 成功执行到此处的时候，Push 一个事件
    --        act.doer:PushEvent("mone_onpickupitem", { item = act.target })
    --        return unpack(args);
    --    end
    --end

    -- 检索第一个收纳袋和海上箱子
    ---@deprecated
    local function onpickupitem(inst, data)
        local item = data and data.item;
        if item == nil then
            return ;
        end

        local piggyback_pocket, find_piggyback_pocket = nil, false;
        local water_chest_pocket, find_water_chest_pocket = nil, false;
        for _, v in ipairs(inst.components.inventory.itemslots) do
            if v and v.prefab == "mone_piggyback" and not find_piggyback_pocket then
                piggyback_pocket = v;
                find_piggyback_pocket = true;
            end
            if v and v.prefab == "mone_waterchest_inv" and not find_water_chest_pocket then
                water_chest_pocket = v;
                find_water_chest_pocket = true;
            end
            if find_piggyback_pocket and find_water_chest_pocket then
                break ;
            end
        end

        local piggyback_pocket_container = piggyback_pocket and piggyback_pocket.components.container;
        local water_chest_pocket_container = water_chest_pocket and water_chest_pocket.components.container;

        if piggyback_pocket_container and piggyback_pocket_container:Has(item.prefab, 1) then
            --local preopen = false;
            --if piggyback_pocket_container:IsOpen() then
            --    preopen = true;
            --end
            --piggyback_pocket_container:Open(inst); -- 打开容器不可堆叠的物品也进不去。这。。。
            piggyback_pocket_container:GiveItem(item);
            --if not preopen then
            --    piggyback_pocket_container:Close(inst);
            --end
        elseif water_chest_pocket_container and water_chest_pocket_container:Has(item.prefab, 1) then
            --local preopen = false;
            --if water_chest_pocket_container:IsOpen() then
            --    preopen = true;
            --end
            --water_chest_pocket_container:Open(inst);
            water_chest_pocket_container:GiveItem(item);
            --if not preopen then
            --    water_chest_pocket_container:Close(inst);
            --end
        end
    end

    -- 检索物品栏的全部处于关闭状态的收纳袋和海上箱子
    local function onpickupitem2(inst, data)
        local item = data and data.item;
        if item == nil then
            return ;
        end

        local containers = {};

        local itemslots = inst.components.inventory.itemslots;
        -- 补充，检索身上处在打开状态的猪猪袋
        --local piggybag;
        --for k, v in pairs(itemslots) do
        --    if v.prefab == "mone_piggybag" then
        --        if v.components.container:IsOpen() then
        --            piggybag = v;
        --            break ;
        --        end
        --    end
        --end
        --if piggybag then
        --    for k, v in pairs(piggybag.components.container:GetAllItems()) do
        --        table.insert(itemslots,v);
        --    end
        --end

        for _, v in pairs(itemslots) do
            if v and v.components.container then
                -- 限制成是关闭状态
                if not v.components.container:IsOpen() then
                    if v.prefab == "mone_piggyback" or v.prefab == "mone_waterchest_inv" then
                        table.insert(containers, v);
                    end
                end
            end
        end

        -- 换个写法，上面那个写法咋回事？检索出来成百上千的材料了，卡死。
        -- 2023-02-25-13:33 先算了，我要玩游戏！
        --local piggybag;
        --for k, v in pairs(itemslots) do
        --    if v.prefab == "mone_piggybag" then
        --        if v.components.container:IsOpen() then
        --            piggybag = v;
        --            break ;
        --        end
        --    end
        --end
        --if piggybag then
        --    for _, v in pairs(piggybag.components.container:GetAllItems()) do
        --        if v and v.components.container then
        --            -- 限制成是关闭状态
        --            if not v.components.container:IsOpen() then
        --                if v.prefab == "mone_piggyback" or v.prefab == "mone_waterchest_inv" then
        --                    table.insert(containers, v);
        --                end
        --            end
        --        end
        --    end
        --end



        for _, v in ipairs(containers) do
            local container = v.components.container;
            if container and container:Has(item.prefab, 1) then
                -- 1
                --v.mi_ignore_sound = true;
                --container:Open(inst);
                local success = container:GiveItem(item); --, nil, item.GetPosition and item:GetPosition()); 没用;
                -- 不行的
                --print("item:IsValid()? "..tostring(item:IsValid()));
                --if item:IsValid() then
                --    container:GiveItem(item); --, nil, item.GetPosition and item:GetPosition()); 没用
                --end
                -- 2023-03-06-00:06：为什么堆叠满的物品塞不进去？玩我呢？莫非是 onpickupitem 事件的问题？
                --container:Close();
                --v.mi_ignore_sound = nil;

                -- 2: classified 相关崩掉了！
                -- 和 inventoryitem_replica SetPickupPos 有关，所以说真的是 onpickupitem 事件的问题吗？
                -- 补充：记得处理一下客机塞进去没声音的bug
                -- 是不是功能2导致的整理卡顿？好像不是，看样子就是此处的功能了。。。吧，并不是。那就是功能2了，明天测试一下！
                --print("success: "..tostring(success));
                --if item then
                --    container:GiveItem(item);
                --end

                break ;
            end
        end
    end

    -- 只检索物品栏的全部处于关闭状态的容器，背包就算了，等会有个玩家塞一身的容器，这不得卡死？
    -- 至于处于打开状态的容器？算了吧！
    ---@deprecated
    local function onpickupitem_all(inst, data)
        local item = data and data.item;
        if item == nil then
            return ;
        end

        local containers = {};
        for _, v in pairs(inst.components.inventory.itemslots) do
            if v and v.components.container then
                -- 限制成是关闭状态
                if not v.components.container:IsOpen() then
                    table.insert(containers, v);
                end
            end
        end
        for _, v in ipairs(containers) do
            local container = v.components.container;
            if container and container:Has(item.prefab, 1) then
                container:GiveItem(item); -- 为什么堆叠满的物品塞不进去？
                break ;
            end
        end
    end

    env.AddPlayerPostInit(function(inst)
        if not TheWorld.ismastersim then
            return inst;
        end


        -- 只检索口袋里！mone_onpickupitem: 不行的
        inst:ListenForEvent("onpickupitem", function(inst, data)
            -- 加个延迟的坏处是主机会听到两次叮叮声，所以客机为什么直接塞听不懂声音呢？烦哦。
            --inst:DoTaskInTime(FRAMES, function(inst, data)
            --    onpickupitem(inst, data);
            --end, data)
            onpickupitem2(inst, data);
        end);


        --[[        -- 只检索口袋里！
                inst:ListenForEvent("onpickupitem", function(inst, data)
                    local item = data and data.item;
                    --print("item: " .. tostring(item));
                    if item == nil then
                        return ;
                    end
                    local water_chest_pocket;
                    for _, v in pairs(inst.components.inventory.itemslots) do
                        --print("", "", tostring(v.prefab));
                        if v and v.prefab == "mone_waterchest_inv" then
                            water_chest_pocket = v;
                            break ;
                        end
                    end
                    --print("water_chest_pocket: " .. tostring(water_chest_pocket));
                    if water_chest_pocket == nil then
                        return ;
                    end
                    local container = water_chest_pocket.components.container;
                    --print("container: " .. tostring(container));

                    -- 不可堆叠的物品在容器未打开的状态下，塞不进去。这可能是联机版的特有情况。哎，绝了。
                    if container and container:Has(item.prefab, 1) then
                        --print("item: " .. tostring(item));
                        --print("enter!");
                        -- 有 Has 在不用加延迟了，但是没 Has 需要加个延迟！！！不然不行！！！
                        -- 但是说实话，加了延迟会有点难受的！有Has在不用加延迟刚刚好！Nice
                        --water_chest_pocket:DoTaskInTime(FRAMES, function(water_chest_pocket, container)
                        --    container:GiveItem(item);
                        --end, container)
                        container:GiveItem(item);
                    end
                end);]]
    end)
end

-- 直接消耗容器里的材料制作物品
if TUNING.MONE_TUNING.GET_MOD_CONFIG_DATA.direct_consumption then
    -- 检索口袋里处于关闭状态的收纳袋和海上箱子
    local function direct_consumption(self)
        local old_Has = self.Has;
        function self:Has(item, amount, checkallcontainers)
            local _, num_found = old_Has(self, item, amount, checkallcontainers);

            local containers = {};

            local itemslots = self.itemslots;
            -- 补充，检索身上处在打开状态的猪猪袋
            --local piggybag;
            --for k, v in pairs(itemslots) do
            --    if v.prefab == "mone_piggybag" then
            --        if v.components.container:IsOpen() then
            --            piggybag = v;
            --            break ;
            --        end
            --    end
            --end
            --if piggybag then
            --    for k, v in pairs(piggybag.components.container:GetAllItems()) do
            --        table.insert(itemslots,v);
            --    end
            --end

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
            -- 补充，检索身上处在打开状态的猪猪袋
            --local piggybag;
            --for k, v in pairs(itemslots) do
            --    if v.prefab == "mone_piggybag" then
            --        if v.components.container:IsOpen() then
            --            piggybag = v;
            --            break ;
            --        end
            --    end
            --end
            --if piggybag then
            --    for k, v in pairs(piggybag.components.container:GetAllItems()) do
            --        table.insert(itemslots,v);
            --    end
            --end

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

    -- 检索口袋里全部处于关闭状态的容器（打开状态的容器官方已经实现）
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

    env.AddComponentPostInit("inventory", direct_consumption);

    do
        -- 以下代码暂时无效
        -- 2023-02-25-12:32
        -- 先放弃了。开有洞穴的世界实在太花时间了。根本不方便测试。吐血。浪费时间。
        return ;
    end

    local function myHasClient(self, prefab, amount, iscrafting, data)
        local enough, count = data.enough, data.count;

        local containers = {};
        for _, v in pairs(self:GetItems()) do
            if v.prefab == "mone_piggyback" or v.prefab == "mone_waterchest_inv" then
                if not v.replica.container:IsOpenedBy(ThePlayer) then
                    table.insert(containers, v);
                end
            end
        end

        -- TEST
        if #containers > 0 then
            for _, v in ipairs(containers) do
                print("", tostring(v.prefab));
            end
        end

        for _, v in ipairs(containers) do
            local container = v.replica and v.replica.container;
            if container and not container.excludefromcrafting then
                local container_enough, container_found = container:Has(prefab, amount, iscrafting)
                count = count + container_found
            end
        end

        return count >= amount, count;
    end

    env.AddClassPostConstruct("components/inventory_replica", function(self)
        local old_Has = self.Has;
        function self:Has(prefab, amount, checkallcontainers)
            local res, count = old_Has(self, prefab, amount, checkallcontainers);

            if prefab == "pigskin" then
                if self.classified ~= nil then
                    -- DoNothing
                else
                    -- self.classified 容器关闭状态下为 nil？
                    print("self.classified == nil, inventory_replica.inst: " .. tostring(self.inst));
                    -- DoSomething
                    res, count = myHasClient(self, prefab, amount, checkallcontainers, { enough = res, count = count });
                end
            end

            return res, count;
        end
    end)

    env.AddClassPostConstruct("components/container_replica", function(self)
        local old_Has = self.Has;
        function self:Has(prefab, amount, iscrafting)
            local res, count = old_Has(self, prefab, amount, iscrafting);

            if self.classified ~= nil then

            else
                print("self.classified == nil, container_replica.inst: " .. tostring(self.inst));
                -- DoSomething

            end

            return res, count;
        end

    end)

    do
        -- 以下代码无效
        return ;
    end
    env.AddClassPostConstruct("components/container_replica", function(self)
        local old_Has = self.Has;
        function self:Has(prefab, amount, iscrafting)
            --print("self.classified: "..tostring(self.classified));
            --print("self.opener: "..tostring(self.opener));
            --if self.classified == nil and self.inst.container_classified ~= nil then
            --    self.classified = self.inst.container_classified
            --    self.inst.container_classified.OnRemoveEntity = nil
            --    self.inst.container_classified = nil
            --    self:AttachClassified(self.classified)
            --end
            --if self.opener == nil and self.inst.container_opener ~= nil then
            --    self.opener = self.inst.container_opener
            --    self.inst.container_opener.OnRemoveEntity = nil
            --    self.inst.container_opener = nil
            --    self:AttachOpener(self.opener)
            --end
            local res, count = old_Has(self, prefab, amount, iscrafting);
            --if self.classified ~= nil then
            --    -- 默认是需要不为 nil 的，就是因为这个才无法获取数据的！错。。。self.classified 是和容器绑定了，打开容器后该预制物才会出现。
            --    if self.opener == nil then
            --        res, count = self.classified:Has(prefab, amount, iscrafting);
            --    end
            --end
            if prefab == "pigskin" then
                print("**********************");
                print("self.classified: " .. tostring(self.classified)
                        .. ", self.opener: " .. tostring(self.opener)
                        .. ", enough, count: " .. tostring(res) .. ", " .. tostring(count)
                );
                if self.classified then
                    print("self.classified._parent: " .. tostring(self.classified._parent));
                end
                print("container_replica.inst: " .. tostring(self.inst));
                print("**********************");
            end

            return res, count;
        end
    end)

    do
        -- 联机版不打开容器客机获取不到里面的数据
        return ;
    end
    env.AddClassPostConstruct("components/inventory_replica", function(self)
        --local old__ctor = self._ctor;
        --self._ctor = function(self, inst, ...)
        --    if old__ctor then
        --        old__ctor(self, inst, ...);
        --    end
        --    print("self.classified: "..tostring(self.classified));
        --    if self.classified then
        --        local old_classified_Has = self.classified.Has;
        --        function self.classified:Has(prefab, amount, checkallcontainers)
        --            local _, count = old_classified_Has(self, prefab, amount, checkallcontainers);
        --
        --            local containers = {};
        --            print("self:GetItems(): " .. tostring(self:GetItems()));
        --            for _, v in ipairs(self:GetItems()) do
        --                if v.prefab == "mone_piggyback" or v.prefab == "mone_waterchest_inv" then
        --                    print("", "", tostring(v))
        --                    table.insert(containers, v);
        --                    --if not (v.replica and v.replica.container and v.replica.container:IsOpenedBy(ThePlayer)) then
        --                    --    table.insert(containers, v);
        --                    --end
        --                end
        --            end
        --            --print("#containers: " .. tostring(#containers));
        --            for _, v in ipairs(containers) do
        --                local container = v.replica and v.replica.container;
        --                --print("container: " .. tostring(container));
        --                if container and not container.excludefromcrafting then
        --                    local iscrafting = checkallcontainers;
        --                    local container_enough, container_found = container:Has(prefab, amount, iscrafting)
        --                    count = count + container_found
        --                end
        --            end
        --            return count >= amount, count;
        --        end
        --    end
        --end

        local old_Has = self.Has;
        local function Count(item)
            return item.replica.stackable ~= nil and item.replica.stackable:StackSize() or 1
        end
        local function GetEquippedItem(inst, eslot)
            if inst._equipspreview ~= nil then
                return inst._equipspreview[eslot]
            end
            return inst._equips[eslot] ~= nil and inst._equips[eslot]:value() or nil
        end
        local function GetOverflowContainer(inst)
            if inst.ignoreoverflow then
                return
            end
            local item = GetEquippedItem(inst, EQUIPSLOTS.BODY)
            return item ~= nil and item.replica.container or nil
        end
        function self:Has(prefab, amount, checkallcontainers)
            -- print 测试！
            --print("self.inst.components.inventory: " .. tostring(self.inst.components.inventory)); -- nil
            --print("self.classified: " .. tostring(self.classified)); -- table

            if self.inst.components.inventory ~= nil then
                return self.inst.components.inventory:Has(prefab, amount, checkallcontainers)
            elseif self.classified ~= nil then
                if prefab ~= "pigskin" then
                    return self.classified:Has(prefab, amount, checkallcontainers)
                end


                --return self.classified:Has(prefab, amount, checkallcontainers)
                --V2C: this is the current assumption, so make it explicit
                local iscrafting = checkallcontainers

                local inst = self.classified;

                local count = inst._activeitem ~= nil and
                        inst._activeitem.prefab == prefab and
                        not (iscrafting and inst._activeitem:HasTag("nocrafting")) and
                        Count(inst._activeitem) or 0

                if inst._itemspreview ~= nil then
                    for i, v in ipairs(inst._items) do
                        local item = inst._itemspreview[i]
                        if item ~= nil and item.prefab == prefab and not (iscrafting and item:HasTag("nocrafting")) then
                            count = count + Count(item)
                        end
                    end
                else
                    for i, v in ipairs(inst._items) do
                        local item = v:value()
                        if item ~= nil and item ~= inst._activeitem and item.prefab == prefab and not (iscrafting and item:HasTag("nocrafting")) then
                            count = count + Count(item)
                        end
                    end
                end

                local overflow = GetOverflowContainer(inst)
                if overflow ~= nil then
                    local overflowhas, overflowcount = overflow:Has(prefab, amount, iscrafting)
                    count = count + overflowcount
                end

                if checkallcontainers then
                    local inventory_replica = inst and inst._parent and inst._parent.replica.inventory
                    local containers = inventory_replica and inventory_replica:GetOpenContainers()

                    if containers then
                        for container_inst in pairs(containers) do
                            local container = container_inst.replica.container or container_inst.replica.inventory
                            if container and container ~= overflow and not container.excludefromcrafting then
                                local containerhas, containercount = container:Has(prefab, amount, iscrafting)
                                print("containercount: " .. tostring(containercount));
                                count = count + containercount
                            end
                        end
                    end
                end

                -- chang
                local containers = {};
                --print("self:GetItems(): "..tostring(self:GetItems()));
                for _, v in pairs(self:GetItems()) do
                    --print("", "v.prefab: ", tostring(v.prefab))
                    if v.prefab == "mone_piggyback" or v.prefab == "mone_waterchest_inv" then
                        --print("", "", tostring(v))
                        table.insert(containers, v);
                        --if not (v.replica and v.replica.container and v.replica.container:IsOpenedBy(ThePlayer)) then
                        --    table.insert(containers, v);
                        --end
                    end
                end
                --print("#containers: " .. tostring(#containers));
                for _, v in ipairs(containers) do
                    local container = v.replica and v.replica.container;
                    --print("container: " .. tostring(container));
                    if container and not container.excludefromcrafting then
                        --print("---1");
                        local container_enough, container_found = container:Has(prefab, amount, iscrafting)
                        print("container_found: " .. tostring(container_found));
                        count = count + container_found
                    end
                end
                --print("count: "..tostring(count));
                return count >= amount, count
            else
                return amount <= 0, 0
            end
        end
    end)

    --[[    env.AddComponentPostInit("inventory_replica", function(self)
            if not TheWorld.ismastersim then
                print("客机");
                local old_Has = self.classified.Has;
                self.classified.Has = function(inst, prefab, amount, checkallcontainers)
                    print("old_Has: " .. tostring(old_Has));
                    if not old_Has then
                        -- DoNothing
                        return ;
                    end
                    --local inventory_replica = inst and inst._parent and inst._parent.replica.inventory;
                    --local self = inventory_replica;
                    --if not self then
                    --    print("??? inventory_replica == nil");
                    --    return old_Has(inst, prefab, amount, checkallcontainers);
                    --end
                    local _, count = old_Has(inst, prefab, amount, checkallcontainers);

                    local containers = {};
                    for _, v in ipairs(self:GetItems()) do
                        if v.prefab == "mone_piggyback" or v.prefab == "mone_waterchest_inv" then
                            if not (v.replica and v.replica.container and v.replica.container._isopen) then
                                table.insert(containers, v);
                            end
                        end
                    end
                    print("#containers: " .. tostring(#containers));
                    for _, v in ipairs(containers) do
                        local container = v.replica and v.replica.container;
                        print("container: " .. tostring(container));
                        if container and not container.excludefromcrafting then
                            local iscrafting = checkallcontainers;
                            local container_enough, container_found = container:Has(prefab, amount, iscrafting)
                            count = count + container_found
                        end
                    end
                    return count >= amount, count;
                end
            else
                print("主机");


            end
        end);]]

    -- 客机代码也要修改，好烦。。。
    --[[env.AddPrefabPostInit("inventory_classified", function(inst)
        if not TheWorld.ismastersim then
            local old_Has = inst.Has;
            inst.Has = function(inst, prefab, amount, checkallcontainers)
                print("old_Has: " .. tostring(old_Has));
                if not old_Has then
                    -- DoNothing
                    return ;
                end
                local _, count = old_Has(inst, prefab, amount, checkallcontainers);

                local inventory_replica = inst and inst._parent and inst._parent.replica.inventory;
                local itemslots = inventory_replica:GetItems();

                local containers = {};
                for _, v in ipairs(inst:GetItems()) do
                    if v.prefab == "mone_piggyback" or v.prefab == "mone_waterchest_inv" then
                        if not (v.replica and v.replica.container and v.replica.container:IsOpenedBy(ThePlayer)) then
                            table.insert(containers, v);
                        end
                    end
                end
                print("#containers: " .. tostring(#containers));
                for _, v in ipairs(containers) do
                    local container = v.replica and v.replica.container;
                    print("container: " .. tostring(container));
                    if container and not container.excludefromcrafting then
                        local iscrafting = checkallcontainers;
                        local container_enough, container_found = container:Has(prefab, amount, iscrafting)
                        count = count + container_found
                    end
                end
                return count >= amount, count;
            end

            return inst;
        end
    end)]]
end