---
--- @author zsh in 2023/5/3 15:55
---


if TUNING.AUTOMATIC_STACKING_ENABLED then
    return ;
end
------------

local function HasOneOfTag(inst, tags)
    if not isTab(tags) or not isValid(inst) then
        return false;
    end
    if #tags > 0 then
        for _, tag in ipairs(tags) do
            if inst.HasTag and inst:HasTag(tag) then
                return true;
            end
        end
    end
    return false;
end

HookComponent("stackable", function(self)
    local old_Get = self.Get;
    function self:Get(...)
        assert(old_Get ~= nil, "HookComponent: stackable: Get: `old_Get == nil`");

        local instance = old_Get(self, ...);

        -- 通过 Get 函数生成的预制物都不需要执行这个 DoTaskInTime 函数
        if instance and instance.more_items_automatic_stacking then
            instance.more_items_automatic_stacking:Cancel();
            instance.more_items_automatic_stacking = nil;
        end

        return instance;
    end
end)

local EXCLUDE_TAGS = { "INLIMBO", "NOCLICK", "FX", "smallcreature", "heavy", "trap", "NET_workable" };

local function IsExcludedPrefabs(inst, is_excluded_fn)
    if not isValid(inst) then
        return true;
    end
    if HasOneOfTag(inst, EXCLUDE_TAGS) then
        return true;
    end
    if inst:IsInLimbo() then
        return true; --V2C: faster than checking tag, but only valid on mastersim
    end
    if null(inst.components.inventoryitem) or null(inst.components.stackable) then
        return true;
    end
    if is_excluded_fn and is_excluded_fn(inst) then
        return true;
    end
    return false;
end

local function ReplaceOnSave(old_fn)
    return function(inst, data)
        if old_fn then
            old_fn(inst, data);
        end
    end
end

local function ReplaceOnLoad(old_fn)
    return function(inst, data)
        if old_fn then
            old_fn(inst, data);
        end
        -- 保证重载游戏的时候不会堆叠
        if inst.more_items_automatic_stacking then
            inst.more_items_automatic_stacking:Cancel();
            inst.more_items_automatic_stacking = nil;
        end
    end
end

local MAX_DIST = 3 * 4;

env.AddPrefabPostInitAny(function(inst)
    if not TheWorld.ismastersim then
        return inst;
    end

    -- 默认排除的一些目标
    if IsExcludedPrefabs(inst) then
        return inst;
    end

    --inst.OnSave = ReplaceOnSave(inst.OnSave);
    inst.OnLoad = ReplaceOnLoad(inst.OnLoad);

    inst.more_items_automatic_stacking = inst:DoTaskInTime(0.5, function(inst)
        local MORE_EXCLUDE_TAGS = {
            "penguin_egg",
            "lootpump_oncatch",
            "lootpump_onflight"
        }

        -- 默认排除的一些目标
        if IsExcludedPrefabs(inst, function(inst)
            -- 延迟堆叠的时候排除一些额外目标
            return HasOneOfTag(inst, MORE_EXCLUDE_TAGS)
                    or inst.components.stackable:IsFull()
                    or inst.components.inventoryitem:GetGrandOwner() ~= nil;
        end) then
            return ;
        end

        local x, y, z = inst.Transform:GetWorldPosition();

        -- 某个坐标为空就不执行
        if null(x) or null(y) or null(z) then
            return ;
        end

        local MUST_TAGS = { "_stackable" };
        local CANT_TAGS = deepcopy(EXCLUDE_TAGS);
        for _, tag in ipairs(MORE_EXCLUDE_TAGS) do
            table.insert(CANT_TAGS, tag);
        end

        local ents = TheSim:FindEntities(x, y, z, MAX_DIST, MUST_TAGS, CANT_TAGS);

        if #ents > 0 then
            for _, item in ipairs(ents) do
                if isValid(item) and not item.components.stackable:IsFull() then
                    if item ~= inst and item.prefab == inst.prefab and item.skinname == inst.skinname then
                        SpawnPrefab("sand_puff").Transform:SetPosition(item.Transform:GetWorldPosition())
                        if isValid(inst) then
                            inst.components.stackable:Put(item);
                        end
                    end
                end
            end
        end
    end)
end)