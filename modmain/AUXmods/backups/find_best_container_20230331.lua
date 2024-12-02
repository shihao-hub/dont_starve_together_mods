---
--- @author zsh in 2023/1/19 3:22
---

local function GetLocalFn(fn, fn_name)
    local level = 1;
    local MAX_LEVEL = 20;
    for i = 1, math.huge do
        local name, value = debug.getupvalue(fn, level);
        if name and name == fn_name then
            if value and type(value) == "function" then
                return value, level;
            end
            break ;
        end
        level = level + 1;
        if level > MAX_LEVEL then
            break ;
        end
    end
end

-- 必须在调用 GetLocalFn 找到后，再调用该函数！
local function SetLocalFn(fn, up, value)
    debug.setupvalue(fn, up, value);
end

env.AddClassPostConstruct("widgets/invslot", function(self, inst)
    local old_TradeItem = self.TradeItem;
    local FindBestContainer, up = GetLocalFn(old_TradeItem, "FindBestContainer");

    if FindBestContainer and up then
        SetLocalFn(old_TradeItem, up, function(self, item, containers, exclude_containers)
            if item == nil or containers == nil then
                return
            end

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

                local mone_storage_bag, stewer, mone_backpack;
                local backpack;
                local mie_book_silviculture, structure;
                local mone_tool_bag;
                for c, bool in pairs(opencontainers) do
                    if c.prefab == "mone_storage_bag" then
                        mone_storage_bag = c;
                    elseif c:HasTag("stewer") then
                        stewer = c;
                    elseif c.prefab == "mone_backpack" then
                        mone_backpack = c;
                    elseif c:HasTag("backpack") then
                        backpack = c;
                    elseif c.prefab == "mone_tool_bag" then
                        mone_tool_bag = c;
                    elseif c.prefab == "mie_book_silviculture" then
                        mie_book_silviculture = c;
                    elseif c:HasTag("structure") then
                        structure = c;
                    end
                end

                -- Question:
                -- 如下情况：
                -- 设物品栏1，保鲜袋2，装备袋3，冰箱4，shift+左键do
                -- 1.没有其他容器开启的情况下（冰箱、锅、箱子），1do应该进入保鲜袋，但是却进入了装备袋。
                -- 2.装备袋里的比如手杖和火腿棒，切换的时候是不是不会调用Inventory GiveItem的，所以火腿棒没有进入保鲜袋
                -- 3.存在有时候装备取下来，居然不进入装备袋的情况。

                -- 1、2原因找到/已经解决，3不方便测试，暂不知道怎么找到问题所在。
                -- 感觉3是因为官方优化了体验，卸下自动回到之前的格子位置的感觉。不清楚，烦人。
                -- 还是说从手臂卸下来的时候并不会调用Inventory:GiveItem函数？
                -- 确实，优化了体验，在 Inventory:GiveItem 函数中，
                -- local eslot = self:IsItemEquipped(inst); if eslot then self:Unequip(eslot); end;

                --print(string.format("%s%s, %s%s",
                --        "stewer: ", tostring(stewer),
                --        "mone_storage_bag", tostring(mone_storage_bag)));

                if stewer and mone_storage_bag then
                    if exclude_containers and type(exclude_containers) == "table" then
                        exclude_containers[mone_storage_bag] = true;
                    end
                end

                -- 这是干啥的？
                --if mone_tool_bag and mone_backpack then
                --    if exclude_containers and type(exclude_containers) == "table" then
                --        exclude_containers[mone_backpack] = true;
                --    end
                --end

                -- 可以肯定的是，shift+左键确确实实调用的是此处的函数！

                --print(string.format("%s%s, %s%s",
                --        "mone_backpack: ", tostring(mone_backpack),
                --        "mone_storage_bag", tostring(mone_storage_bag)));

                -- 那我把装备袋排除掉是否会优先进入保鲜袋了呢？YES!!!但是我不太懂为什么非要这样？不应该直接就ok吗？
                -- 因为 containers 参数是pairs？随机的？然后装备袋和保鲜袋是随机的而已？

                -- 注意了哈，装备袋只能放 _equippable 的东西，所以这样很舒服的就能实现了！
                -- 要是装备带里还能放别的东西，那就非常不友好了！
                --print("", tostring(item.prevcontainer));
                -- 如果你是切换的时候让他自己进容器的话，item.prevcontainer是存在的
                -- 如果不是装备切换的话，item.prevcontainer不存在！记录一下，以后可能会用到！
                --if item.prevcontainer
                --        and item.prevcontainer.inst
                --        and item.prevcontainer.inst:IsValid()
                --        and item.prevcontainer.inst.prefab == "mone_storage_bag"
                --        and item.prevcontainer:IsOpenedBy(character) then
                --    -- DoNothing
                --end
                -- 这个的存在的副作用是：我从保鲜袋里shift出去的火腿棒也不会进入装备袋
                -- 需要解决吗？2023-02-16-15:44，似乎不必了！
                -- 背包未打开状态才会生效？话说我这是干嘛的？
                -- 2023-03-06-01:26：这不是多余吗。。。
                --if mone_storage_bag and mone_backpack and not backpack then
                --    if exclude_containers and type(exclude_containers) == "table" then
                --        exclude_containers[mone_backpack] = true;
                --    end
                --end

                -- mie_book_silviculture 和 建筑类容器同时打开的时候，物品先进入建筑类容器
                if mie_book_silviculture and structure then
                    if exclude_containers and type(exclude_containers) == "table" then
                        exclude_containers[mie_book_silviculture] = true;
                    end
                end

            end

            return FindBestContainer(self, item, containers, exclude_containers);
        end);
    end
end)