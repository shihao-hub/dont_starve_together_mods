---
--- @author zsh in 2023/4/23 0:33
---

local fns = {};

-- 溺水物品不掉落
env.AddComponentPostInit("drownable", function(self)
    if not self.inst:HasTag("player") then
        return ;
    end
    local old_ShouldDropItems = self.ShouldDropItems;
    function self:ShouldDropItems(...)
        if self.inst:HasTag("player") then
            return false;
        end
        return old_ShouldDropItems and old_ShouldDropItems(self, ...);
    end
end)

-- 玩家死亡时物品不掉落：不是覆盖法！我去，写完发现，scripts/components/inventory.lua 里面有个 DisableDropOnDeath() 可以直接让死亡不掉落物品。刚好学习一下：实现功能可以从本源出发，获取这个函数然后直接移除监听，这不就行了。emm，不行，虽然移除了 ondeath 的监听，但是 inventory:DropEverything(true) 函数有很多地方直接调用的！
local function CanDrop(item)
    if item == nil or item.components.inventoryitem == nil then
        return ;
    end

    --if item:HasTag("irreplaceable")
    --        or item.components.inventoryitem.keepondrown
    --        or item.components.inventoryitem.keepondeath
    --        or item.components.container
    --        or item.components.inventory
    --then
    --    return false;
    --end

    return not item:HasTag("irreplaceable")
            and not item.components.inventoryitem.keepondrown
            and not item.components.inventoryitem.keepondeath
            and not item.components.container
            and not item.components.inventory;
end

local function ForcedDropItem(inventory, item, wholestack, randomdir, pos, ...)
    local self = inventory;
    if item == nil or item.components.inventoryitem == nil then
        return ;
    end
    item.dont_drop_everything_forced_drop = true;
    self:DropItem(item, wholestack, randomdir, pos, ...);
    item.dont_drop_everything_forced_drop = nil;
    return true;
end

function fns.IsDeadPlayer(inst)
    return inst and inst:IsValid()
            and (inst:HasTag("player") or inst:HasTag("playerghost"))
            and inst.components.health
            and (inst.components.health.currenthealth <= 0 or inst.dont_drop_everything_ondeath);
end

local FORCED_DROP_ITEMS = {
    "amulet"; -- 生命护符
    "reviver"; -- 告密的心
    "pocketwatch_revive"; -- 第二次机会表
    "ancient_amulet_red"; -- 永不妥协的唤灵护符
}
function fns.ForcedDropItems(inventory)
    local self = inventory;
    local overflow = self:GetOverflowContainer();
    local backpack = overflow and overflow.inst;

    -- 装备槽也需要掉落一个
    for k, v in pairs(self.equipslots) do
        if v and table.contains(FORCED_DROP_ITEMS, v.prefab) then
            ForcedDropItem(self, v, true, true);
            break ;
        end
    end

    -- 强制掉落物品栏和背包中的某些物品，暂定掉落一个
    local items = {};
    -- 物品栏
    for _, v in pairs(self.itemslots) do
        if v and v:IsValid() then
            table.insert(items, v);
        end
    end
    -- 背包
    if backpack and backpack.components.container and backpack.components.container.slots then
        for _, v in pairs(backpack.components.container.slots) do
            if v and v:IsValid() then
                table.insert(items, v);
            end
        end
    end
    -- 其他打开的容器，注意这个容器可能是 container/inventory。但是死亡之后执行到此处的时候，容器已经关闭了...
    --for container_inst in pairs(self.opencontainers) do
    --    local container = container_inst.components.container or container_inst.components.inventory;
    --    if container and container ~= overflow and not container.excludefromcrafting then
    --        local slots = container.slots or container.itemslots or {};
    --        for _, v in pairs(slots) do
    --            if v and v:IsValid() then
    --                table.insert(items, v);
    --            end
    --        end
    --    end
    --end
    -- 开始强制掉落部分物品
    local DROP_ITEMS = {};
    for _, name in ipairs(FORCED_DROP_ITEMS) do
        DROP_ITEMS[name] = 1;
    end
    for _, v in ipairs(items) do
        if v and v:IsValid() and v.prefab and v.components.inventoryitem
                and table.containskey(DROP_ITEMS, v.prefab)
                and DROP_ITEMS[v.prefab] and DROP_ITEMS[v.prefab] > 0 then
            --print("强制掉落：" .. v.prefab);
            DROP_ITEMS[v.prefab] = DROP_ITEMS[v.prefab] - 1;
            ForcedDropItem(self, v, true, true)
        end
    end
    -- 如果物品栏和背包已满，则有选择性地掉落一个物品。如果找不到，则随机掉落一个物品。
    local inventory_full, backpack_full;
    if self:IsFull() then
        inventory_full = true;
    end
    if backpack and backpack.components.container and backpack.components.container:IsFull() then
        backpack_full = true;
    end
    --print("backpack: " .. tostring(backpack) .. ", backpack_full: " .. tostring(backpack_full));
    --print("inventory_full: " .. tostring(inventory_full));
    if inventory_full and not backpack or inventory_full and backpack_full then
        --print("准备有选择性地掉落物品...");
        local all_items = {};
        -- 物品栏
        for _, v in pairs(self.itemslots) do
            if v and v:IsValid() then
                table.insert(all_items, v);
            end
        end
        -- 背包
        if backpack and backpack.components.container and backpack.components.container.slots then
            for _, v in pairs(backpack.components.container.slots) do
                if v and v:IsValid() then
                    table.insert(all_items, v);
                end
            end
        end
        -- 有选择性地掉落一个物品，以腾出一格空间
        local can_drop;
        for _, v in ipairs(all_items) do
            if CanDrop(v) then
                --print("有选择性地掉落: " .. v.prefab);
                if ForcedDropItem(self, v, true, true) then
                    can_drop = true;
                end
                break ;
            else
                --print("item: " .. tostring(v) .. " 不能掉落...");
            end
        end
        -- 找不到，则随机掉落一个物品
        if not can_drop and shuffleArray then
            shuffleArray(all_items);
            if all_items[1] then
                --print("洗牌算法:有选择性地掉落: " .. all_items[1].prefab);
                ForcedDropItem(self, all_items[1], true, true);
            end
        end
    end
end

--local function ondeath(inst, data)
--    local self = inst.components.inventory;
--    if self == nil then
--        return ;
--    end
--    local overflow = self:GetOverflowContainer();
--    local backpack = overflow and overflow.inst;
--    local items = {};
--
--    -- `player_common_extensions.lua`
--    -- inst:ListenForEvent("death", ex_fns.OnPlayerDeath) 已经关闭了所有容器。PS：调用的是 inventory 的 Hide 函数。
--    for container_inst in pairs(self.opencontainers) do
--        local container = container_inst.components.container or container_inst.components.inventory;
--        if container and container ~= overflow and not container.excludefromcrafting then
--            local slots = container.slots or container.itemslots or {};
--            for _, v in pairs(slots) do
--                if v and v:IsValid() then
--                    table.insert(items, v);
--                end
--            end
--        end
--    end
--    local DROP_ITEMS = {};
--    for _, name in ipairs(FORCED_DROP_ITEMS) do
--        DROP_ITEMS[name] = 1;
--    end
--    for _, v in ipairs(items) do
--        if v and v:IsValid() and v.prefab and v.components.inventoryitem
--                and table.containskey(DROP_ITEMS, v.prefab)
--                and DROP_ITEMS[v.prefab] and DROP_ITEMS[v.prefab] > 0 then
--            DROP_ITEMS[v.prefab] = DROP_ITEMS[v.prefab] - 1;
--            ForcedDropItem(self, v, true, true)
--        end
--    end
--end

--env.AddPlayerPostInit(function(inst)
--    if not TheWorld.ismastersim then
--        return inst;
--    end
--    inst:ListenForEvent("death", ondeath);
--end)

env.AddComponentPostInit("inventory", function(self)
    if not self.inst:HasTag("player") then
        return ;
    end
    local old_DropItem = self.DropItem;
    function self:DropItem(item, wholestack, randomdir, pos, ...)
        if item == nil or item.components.inventoryitem == nil or old_DropItem == nil then
            return ;
        end

        local owner = item.components.inventoryitem and item.components.inventoryitem:GetGrandOwner();

        -- 修bug：如果物品在鼠标格子上，此时人物死亡，物品直接无了，具体代码在哪里懒得找，就这样处理吧。
        if owner and owner:HasTag("player") and owner.components.inventory:GetActiveItem() == item then
            return old_DropItem(self, item, wholestack, randomdir, pos, ...);
        end

        -- 主体内容
        if fns.IsDeadPlayer(owner) and not item.dont_drop_everything_forced_drop then
            return ;
        end
        --if fns.IsDeadPlayer(owner) and item.dont_drop_everything_forced_drop then
        --    print("玩家：" .. tostring(owner.prefab) .. " 已经死亡，强制掉落：" .. tostring(item.prefab) .. " ");
        --end
        return old_DropItem(self, item, wholestack, randomdir, pos, ...);
    end

    local old_DropEverything = self.DropEverything;
    function self:DropEverything(ondeath, keepequip, ...)
        self.inst.dont_drop_everything_ondeath = ondeath;
        if old_DropEverything then
            old_DropEverything(self, ondeath, keepequip, ...);
        end
        if fns.IsDeadPlayer(self.inst) then
            fns.ForcedDropItems(self);
        end
        self.inst.dont_drop_everything_ondeath = nil;
    end
end)
