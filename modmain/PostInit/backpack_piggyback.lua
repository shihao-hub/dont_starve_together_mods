---
--- @author zsh in 2023/1/14 1:07
---

-- from klei
local fns = {} -- a table to store local functions in so that we don't hit the 60 upvalues limit

if TUNING.MONE_TUNING.GET_MOD_CONFIG_DATA.mone_backpack_auto then
    --------------------------------------------------------------------------
    --Equipment Breaking Events
    --------------------------------------------------------------------------
    --local function findSpecItem(inst)
    --    if not inst.components.inventory then
    --        return ;
    --    end
    --    local opencontainers = inst.components.inventory.opencontainers;
    --    local mone_backpack;
    --    for p, _ in pairs(opencontainers) do
    --        if p and p.prefab == "mone_backpack" then
    --            mone_backpack = p;
    --            break ;
    --        end
    --    end
    --    return mone_backpack;
    --end
    --
    --function fns.OnItemRanOut(inst, data)
    --    local mone_backpack = findSpecItem(inst);
    --    if inst.components.inventory:GetEquippedItem(data.equipslot) == nil then
    --        local sameTool = inst.components.inventory:FindItem(function(item)
    --            return item.prefab == data.prefab and
    --                    item.components.equippable ~= nil and
    --                    item.components.equippable.equipslot == data.equipslot
    --        end)
    --        --print("fns.OnItemRanOut--sameTool: " .. tostring(sameTool));
    --        if sameTool ~= nil then
    --            inst.components.inventory:Equip(sameTool);
    --        elseif mone_backpack then
    --            sameTool = mone_backpack.components.container:FindItem(function(item)
    --                return item.prefab == data.prefab and
    --                        item.components.equippable ~= nil and
    --                        item.components.equippable.equipslot == data.equipslot;
    --            end)
    --            inst.components.inventory:Equip(sameTool);
    --        end
    --    end
    --end
    --
    --function fns.OnUmbrellaRanOut(inst, data)
    --    local mone_backpack = findSpecItem(inst);
    --    if inst.components.inventory:GetEquippedItem(data.equipslot) == nil then
    --        local sameTool = inst.components.inventory:FindItem(function(item)
    --            return item:HasTag("umbrella") and
    --                    item.components.equippable ~= nil and
    --                    item.components.equippable.equipslot == data.equipslot
    --        end)
    --        --print("fns.OnUmbrellaRanOut--sameTool: " .. tostring(sameTool));
    --        if sameTool then
    --            inst.components.inventory:Equip(sameTool);
    --        elseif mone_backpack then
    --            sameTool = mone_backpack.components.container:FindItem(function(item)
    --                return item:HasTag("umbrella") and
    --                        item.components.equippable ~= nil and
    --                        item.components.equippable.equipslot == data.equipslot
    --            end)
    --            inst.components.inventory:Equip(sameTool);
    --        end
    --    end
    --end
    --
    --function fns.ArmorBroke(inst, data)
    --    local mone_backpack = findSpecItem(inst);
    --    if data.armor ~= nil then
    --        local sameArmor = inst.components.inventory:FindItem(function(item)
    --            return item.prefab == data.armor.prefab
    --        end)
    --        --print("fns.ArmorBroke--sameArmor: " .. tostring(sameArmor));
    --        if sameArmor ~= nil then
    --            -- sameArmor 在 inventory 里找到后，为什么调用此处的函数无效呢？ -- 因为执行了两次事件，一次官方的一次我的。。
    --            --print("进入了！");
    --            inst.components.inventory:Equip(sameArmor)
    --        elseif mone_backpack then
    --            sameArmor = mone_backpack.components.container:FindItem(function(item)
    --                return item.prefab == data.armor.prefab;
    --            end)
    --            inst.components.inventory:Equip(sameArmor);
    --        end
    --    end
    --end

    ---话说为什么没有武器的监听？
    ---2023-03-07-20:42：反正我这是服务器模组，我自己推送一个事件呗！！！
    ---2023-03-14-09:38：通过 getlocal 获取 MakeCharacter 的 local 变量 fn，修改 fn 即可！
    ---???不对。。。获取不到的。。。但是可以 hook MakeCharacter 然后 尾部执行？额，算了再说吧！
    ---@param type string @ 1:OnItemRanOut 2:OnUmbrellaRanOut 3:ArmorBroke 4:WeaponBroke?
    local function findSpecItem(inst, data, type)
        if not inst.components.inventory then
            return ;
        end
        local opencontainers = inst.components.inventory.opencontainers;
        local containers = {};
        for p, _ in pairs(opencontainers) do
            if p and (p.prefab == "mone_tool_bag" or p.prefab == "mone_backpack" or p.prefab == "mone_piggybag") then
                table.insert(containers, p);
            end
        end

        local item;
        for _, con in ipairs(containers) do
            if item == nil then
                if type == 1 then
                    item = con.components.container:FindItem(function(item)
                        return item.prefab == data.prefab and
                                item.components.equippable ~= nil and
                                item.components.equippable.equipslot == data.equipslot
                    end);
                elseif type == 2 then
                    item = con.components.container:FindItem(function(item)
                        return item:HasTag("umbrella") and
                                item.components.equippable ~= nil and
                                item.components.equippable.equipslot == data.equipslot
                    end)
                elseif type == 3 then
                    item = con.components.container:FindItem(function(item)
                        return item.prefab == data.armor.prefab
                    end)
                end
            else
                break ;
            end
        end

        return item;
    end

    function fns.OnItemRanOut(inst, data)
        if inst.components.inventory:GetEquippedItem(data.equipslot) == nil then
            local sameTool = inst.components.inventory:FindItem(function(item)
                return item.prefab == data.prefab and
                        item.components.equippable ~= nil and
                        item.components.equippable.equipslot == data.equipslot
            end)
            --print("fns.OnItemRanOut--sameTool: " .. tostring(sameTool));
            if sameTool ~= nil then
                inst.components.inventory:Equip(sameTool);
            else
                sameTool = findSpecItem(inst, data, 1);
                if sameTool then
                    inst.components.inventory:Equip(sameTool);
                end
            end
        end
    end

    function fns.OnUmbrellaRanOut(inst, data)
        if inst.components.inventory:GetEquippedItem(data.equipslot) == nil then
            local sameTool = inst.components.inventory:FindItem(function(item)
                return item:HasTag("umbrella") and
                        item.components.equippable ~= nil and
                        item.components.equippable.equipslot == data.equipslot
            end)
            --print("fns.OnUmbrellaRanOut--sameTool: " .. tostring(sameTool));
            if sameTool then
                inst.components.inventory:Equip(sameTool);
            else
                sameTool = findSpecItem(inst, data, 2);
                if sameTool then
                    inst.components.inventory:Equip(sameTool);
                end
            end
        end
    end

    function fns.ArmorBroke(inst, data)
        if data.armor ~= nil then
            local sameArmor = inst.components.inventory:FindItem(function(item)
                return item.prefab == data.armor.prefab
            end)
            --print("fns.ArmorBroke--sameArmor: " .. tostring(sameArmor));
            if sameArmor ~= nil then
                -- sameArmor 在 inventory 里找到后，为什么调用此处的函数无效呢？
                -- 因为执行了两次事件，一次官方的一次我的。。
                --print("进入了！");
                inst.components.inventory:Equip(sameArmor)
            else
                sameArmor = findSpecItem(inst, data, 3);
                if sameArmor then
                    inst.components.inventory:Equip(sameArmor);
                end
            end
        end
    end

    local function RegisterMasterEventListeners(inst)
        inst:ListenForEvent("itemranout", fns.OnItemRanOut)
        inst:ListenForEvent("umbrellaranout", fns.OnUmbrellaRanOut)
        inst:ListenForEvent("armorbroke", fns.ArmorBroke)
    end

    env.AddPlayerPostInit(function(inst)
        if not TheWorld.ismastersim then
            return inst;
        end
        --RegisterMasterEventListeners(inst);

        -- 官方的监听事件在表中第一个呗？那把第一个换成我的呗？
        inst:DoTaskInTime(0, function(inst)
            -- 不建议这样写，但是暂时先能跑就行。
            -- FIXME: 这个行为非常的危险！！！目前是因为官方确确实实第一个监听是这个内容，所以可以这样写！
            -- 用 upvaluehelper 应该可以处理，以后再说吧！(2023-02-05)
            if inst.event_listeners then
                if inst.event_listeners["itemranout"] and inst.event_listeners["itemranout"][inst] and inst.event_listeners["itemranout"][inst][1] then
                    inst.event_listeners["itemranout"][inst][1] = fns.OnItemRanOut;
                end
                if inst.event_listeners["umbrellaranout"] and inst.event_listeners["umbrellaranout"][inst] and inst.event_listeners["umbrellaranout"][inst][1] then
                    inst.event_listeners["umbrellaranout"][inst][1] = fns.OnUmbrellaRanOut;
                end
                if inst.event_listeners["armorbroke"] and inst.event_listeners["armorbroke"][inst] and inst.event_listeners["armorbroke"][inst][1] then
                    inst.event_listeners["armorbroke"][inst][1] = fns.ArmorBroke;
                end
            end
        end)

    end)

    -- 模组，写得相当好的客户端模组。显然是可以适配成不止 HANDS 还可以有 BODY、HEAD
    -- 2023-02-10-17:10 但是我是真不想写客户端模组，还是写改变游戏内容的东西有趣。
    -- 抽空好好学一下该部分吧！不然到时候报错了我咋修？
    do
        -- 自动换新武器

        local _G = GLOBAL
        local EQUIPSLOTS = _G.EQUIPSLOTS
        local ACTIONS = _G.ACTIONS
        local SendRPCToServer = _G.SendRPCToServer
        local RPC = _G.RPC
        local TheInput = _G.TheInput
        local GetTime = _G.GetTime
        local ThePlayer

        local equiptask
        local eventlisteninglist = {}

        local disable = false

        local function InGame()
            return ThePlayer and ThePlayer.HUD and not ThePlayer.HUD:HasInputFocus()
        end

        local function Say(text)
            if not (ThePlayer and ThePlayer.components.talker) then
                return
            end
            ThePlayer.components.talker:Say(text)
        end

        local function DoEquip(inst, item)
            if ThePlayer.replica.inventory:GetEquippedItem(EQUIPSLOTS.HANDS) then
                if equiptask then
                    equiptask:Cancel()
                    equiptask = nil
                end
            else
                local inventory = ThePlayer.components.inventory
                local playercontroller = ThePlayer.components.playercontroller
                local equip_actioncode = ACTIONS.EQUIP.code
                if inventory then
                    local playercontroller_deploy_mode = deploy_mode
                    playercontroller:ClearControlMods()
                    playercontroller.deploy_mode = false
                    inventory:ControllerUseItemOnSelfFromInvTile(item, equip_actioncode)
                    playercontroller.deploy_mode = playercontroller_deploy_mode
                else
                    SendRPCToServer(RPC.ControllerUseItemOnSelfFromInvTile, equip_actioncode, item)
                end
            end
        end

        local last_item
        local function OnItemRemoved()

            if disable or equiptask then
                return
            end

            local inventory = ThePlayer.replica.inventory

            if inventory and not inventory:GetEquippedItem(EQUIPSLOTS.HANDS) then

                local function TryToEquipNewItem(items)

                    if type(items) ~= "table" then
                        return
                    end

                    for slot, item in pairs(items) do
                        if item.prefab == last_item.prefab then
                            DoEquip(nil, item)
                            equiptask = ThePlayer:DoPeriodicTask(0, DoEquip, nil, item)
                            return true
                        end
                    end

                end

                local open_containers = inventory:GetOpenContainers()
                local active_item = inventory:GetActiveItem()
                if active_item then
                    TryToEquipNewItem({ active_item })
                elseif not TryToEquipNewItem(inventory:GetItems()) then
                    if open_containers then
                        for container, v in pairs(open_containers) do
                            if container and container.replica and container.replica.container then
                                if TryToEquipNewItem(container.replica.container:GetItems()) then
                                    return
                                end
                            end
                        end
                    end
                end
            end
        end

        local function RegistItemOnRemoveFn(item)
            if not item then
                return
            end
            last_item = item
            if ThePlayer.components.playercontroller.ismastersim then
                item:ListenForEvent("percentusedchange", function(inst, data)
                    if data and
                            data.percent ~= nil and
                            data.percent <= 0 and
                            inst.components.rechargeable == nil and
                            inst.components.inventoryitem ~= nil and
                            inst.components.inventoryitem.owner == ThePlayer
                    then
                        ThePlayer:DoTaskInTime(0, function()
                            OnItemRemoved()
                        end)
                    end
                end)
                return
            end

            if not eventlisteninglist[item] then
                item:ListenForEvent("onremove", function(inst)
                    if inst:HasTag("INLIMBO") and not inst:HasTag("projectile") then
                        OnItemRemoved()
                    end
                    item:RemoveEventCallback("onremove", OnItemRemoved)
                end)
                eventlisteninglist[item] = true
            end
        end

        AddClassPostConstruct("components/inventory_replica", function(self, inst)
            inst:DoTaskInTime(0, function(inst)
                if inst ~= _G.ThePlayer then
                    return
                end
                ThePlayer = _G.ThePlayer
                RegistItemOnRemoveFn(self:GetEquippedItem(EQUIPSLOTS.HANDS))
            end)
        end)

        AddComponentPostInit("playercontroller", function(self, inst)
            if inst ~= _G.ThePlayer then
                return
            end
            ThePlayer = _G.ThePlayer

            ThePlayer:ListenForEvent('equip', function(inst, data)
                if not (data and data.eslot == EQUIPSLOTS.HANDS) then
                    return
                end
                local item = data and data.item
                RegistItemOnRemoveFn(item)
            end)

            ThePlayer:ListenForEvent('unequip', function(inst, data)
                if not (data and data.eslot == EQUIPSLOTS.HANDS) then
                    return
                end
                if last_item then
                    if last_item:HasTag("blowdart") then
                        if self.ismastersim then
                            last_item:DoTaskInTime(0, function(inst)
                                if inst:HasTag("NOCLICK") then
                                    OnItemRemoved()
                                end
                            end)
                        elseif last_item:HasTag("NOCLICK") then
                            OnItemRemoved()
                        end
                    end
                    last_item:RemoveEventCallback("onremove", OnItemRemoved)
                    eventlisteninglist[last_item] = nil
                end
            end)

        end)
    end

end






