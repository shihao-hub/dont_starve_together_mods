---
--- @author zsh in 2023/1/19 3:22
---

-- 2023-02-16-00:17：新版本已经写好了，此处就先用老版本吧！我先测试测试！

local function GetLocalFn(fn, fn_name)
    local level = 1;
    local MAX_LEVEL = 20;
    for i = 1, math.huge do
        local name, value = debug.getupvalue(fn, level);
        if name and name == fn_name then
            if value and type(value) == "function" then
                return value;
            end
            break ;
        end
        level = level + 1;
        if level > MAX_LEVEL then
            break ;
        end
    end
end

env.AddClassPostConstruct("widgets/invslot", function(self, inst)
    local old_TradeItem = self.TradeItem; -- Lua 只有表传的是引用，但是我这样好像没什么问题
    --print("old_TradeItem: " .. tostring(old_TradeItem)); -- 这两个函数地址确实是同一个啊！
    --print("self.TradeItem: " .. tostring(self.TradeItem));
    local FindBestContainer = GetLocalFn(old_TradeItem, "FindBestContainer");
    if not FindBestContainer then
        --print("FindBestContainer == nil");
        return ''
    end
    --print("FindBestContainer get!");
    -- 但是函数并不是引用，我没法覆盖这个函数呀！
    -- 算了，覆盖法吧！

    function self:TradeItem(stack_mod)
        --if old_TradeItem then
        --    old_TradeItem(self, stack_mod);
        --end

        local slot_number = self.num
        local character = ThePlayer
        local inventory = character and character.replica.inventory or nil
        local container = self.container
        local container_item = container and container:GetItemInSlot(slot_number) or nil

        if character ~= nil and inventory ~= nil and container_item ~= nil then
            local opencontainers = inventory:GetOpenContainers()
            if next(opencontainers) == nil then
                return
            end

            local overflow = inventory:GetOverflowContainer()
            local backpack = nil
            if overflow ~= nil and overflow:IsOpenedBy(character) then
                backpack = overflow.inst
                overflow = backpack.replica.container
                if overflow == nil then
                    backpack = nil
                end
            else
                overflow = nil
            end

            -- chang
            local mone_storage_bag, stewer;
            for con, bool in pairs(opencontainers) do
                --print(tostring(con), tostring(bool));
                if con.prefab == "mone_storage_bag" then
                    mone_storage_bag = con;
                elseif con:HasTag("stewer") then
                    stewer = con;
                end
            end

            --find our destination container
            local dest_inst = nil
            if container == inventory then
                local playercontainers = backpack ~= nil and { [backpack] = true } or nil
                -- chang
                if stewer then
                    if playercontainers and mone_storage_bag then
                        playercontainers[mone_storage_bag] = true;
                    end
                end

                dest_inst = FindBestContainer(self, container_item, opencontainers, playercontainers)
                        or FindBestContainer(self, container_item, playercontainers)
            elseif container == overflow then
                local exclude_containers = { [backpack] = true };
                -- chang
                if stewer then
                    if mone_storage_bag then
                        exclude_containers[mone_storage_bag] = true;
                    end
                end

                dest_inst = FindBestContainer(self, container_item, opencontainers, exclude_containers)
                        or (inventory:IsOpenedBy(character)
                        and FindBestContainer(self, container_item, { [character] = true })
                        or nil)
            else
                local exclude_containers = { [container.inst] = true }
                -- chang
                if stewer then
                    if mone_storage_bag then
                        exclude_containers[mone_storage_bag] = true;
                    end
                end

                if backpack ~= nil then
                    exclude_containers[backpack] = true
                end
                dest_inst = FindBestContainer(self, container_item, opencontainers, exclude_containers) or
                        (inventory:IsOpenedBy(character) and character or backpack)
            end

            --if a destination container/inv is found...
            if dest_inst ~= nil then
                if stack_mod and
                        container_item.replica.stackable ~= nil and
                        container_item.replica.stackable:IsStack() then
                    container:MoveItemFromHalfOfSlot(slot_number, dest_inst)
                else
                    container:MoveItemFromAllOfSlot(slot_number, dest_inst)
                end
                TheFocalPoint.SoundEmitter:PlaySound("dontstarve/HUD/click_object")
            else
                TheFocalPoint.SoundEmitter:PlaySound("dontstarve/HUD/click_negative")
            end
        end
    end
end)