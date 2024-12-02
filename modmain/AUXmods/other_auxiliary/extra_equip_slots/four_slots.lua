---
--- @author zsh in 2023/5/18 15:55
---

local config_data = TUNING.MONE_TUNING.GET_MOD_CONFIG_DATA;

if not config_data.extra_equip_slots then
    return ;
end
if null(EQUIPSLOTS) then
    return ;
end
if rawget(EQUIPSLOTS, "BACK") or rawget(EQUIPSLOTS, "NECK") then
    return ;
end
if TUNING.MX_SLOTS_ENABLED_TEST then
    return ;
end

TUNING.MORE_ITEMS_EXTRA_EQUIP_SLOTS_ENABLED = true;

TUNING.MORE_ITEMS_EXTRA_EQUIP_SLOTS = {};

-- 只添加一个额外的背包槽，其他一律不要动！
EQUIPSLOTS.BACK = "back";

local EQUIPSLOTS_CACHE = deepcopy(EQUIPSLOTS);

local ItemsCategory = Import("modmain/AUXmods/other_auxiliary/extra_equip_slots/files/items.lua");

local IsBody, IsBack, IsNeck = ItemsCategory.IsBody, ItemsCategory.IsBack, ItemsCategory.IsNeck;

---添加新的装备槽
local function add_extra_equip_slots()
    -- 直接修改文件，避免占用内存和其他奇怪的问题(比如实际需要使用的数据居然变成了脏数据)
    local InvBar = require("widgets/inventorybar");

    local old_AddEquipSlot = InvBar.AddEquipSlot;
    local old_Refresh = InvBar.Refresh;
    local old_Rebuild = InvBar.Rebuild;
    if not oneOfNull(3, old_AddEquipSlot, old_Refresh, old_Rebuild) then
        function InvBar:AddEquipSlot(...)
            old_AddEquipSlot(self, ...);
            if self.more_items_extra_equip_slots_flag == nil and #self.equipslotinfo == 3 then
                self.more_items_extra_equip_slots_flag = true;
                self:AddEquipSlot(EQUIPSLOTS_CACHE.BACK, "images/uiimages/back.xml", "back.tex", 2.1);
            end
        end

        local function RefreshReBuild(self)
            self.bg:SetScale(1.35, 1, 1);
            self.bgcover:SetScale(1.35, 1, 1);

            if self.inspectcontrol then
                local W = 68
                local SEP = 12
                local INTERSEP = 28
                local inventory = self.owner.replica.inventory
                local num_slots = inventory:GetNumSlots()
                local num_equip = #self.equipslotinfo
                local num_buttons = self.controller_build and 0 or 1
                local num_slotintersep = math.ceil(num_slots / 5)
                local num_equipintersep = num_buttons > 0 and 1 or 0
                local total_w = (num_slots + num_equip + num_buttons) * W + (num_slots + num_equip + num_buttons - num_slotintersep - num_equipintersep - 1) * SEP + (num_slotintersep + num_equipintersep) * INTERSEP
                self.inspectcontrol.icon:SetPosition(-4, 6)
                self.inspectcontrol:SetPosition((total_w - W) * .5 + 3, -6, 0)
            end
        end
        function InvBar:Refresh(...)
            old_Refresh(self, ...);
            RefreshReBuild(self);
        end

        function InvBar:Rebuild(...)
            old_Rebuild(self, ...);
            RefreshReBuild(self);
        end
    end
end
add_extra_equip_slots();

---无侵入修改，临时替换变量，和我的绝对吃不完系列实现方法类似。
local function EquipSlotsCover(old_fn)
    -- 如果传入的函数不存在/不是函数类型，则直接返回
    if not isFn(old_fn) then
        return old_fn;
    end
    return function(...)
        local body = EQUIPSLOTS.BODY;
        EQUIPSLOTS.BODY = EQUIPSLOTS.BACK or EQUIPSLOTS.BODY;
        local res = { old_fn(...) };
        EQUIPSLOTS.BODY = body;
        return unpack(res, 1, table.maxn(res));
    end
end

---同时显示 背包和护甲/符
local function symbol_replace()
    local NewAnimState = newproxy(true);

    -- 已知蜗牛壳是 BODY，按道理来说已经被我从 swap_body_tall 改成了 swap_body，但是感觉有点不对劲
    ---- 不对劲之处在于这个函数的第三个参数：OverrideSymbol("swap_body_tall", "armor_slurtleshell", "swap_body_tall")
    ---- 但是就同时显示背包和护甲而言，已经差不多了...先这样吧！
    local SymbolMap = { ["back"] = "swap_body_tall"; ["body"] = "swap_body"; }

    local function AnimSymbolCover(old_fn, new_symbol, extra_fn, isunequip)
        if not isFn(old_fn) or not isStr(new_symbol) then
            return old_fn;
        end
        return function(inst, owner, ...)
            -- 只兼容玩家，避免莫名错误，比如假人等。
            if not owner or not owner:HasTag("player") then
                return old_fn(inst, owner, ...);
            end
            local old_AnimState = rawget(owner, "AnimState");
            local mt = getmetatable(NewAnimState);
            if oneOfNull(2, old_AnimState, mt) then
                return old_fn(inst, owner, ...);
            end
            mt.__index = function(t, k)
                -- 呃，t 是 userdata 类型的 ... 话说这个 t 里面一定都是函数吗？
                return function(_, old_symbol, ...)
                    return isStr(old_symbol) and string.find(old_symbol, "^swap_body")
                            and old_AnimState[k](old_AnimState, new_symbol, ...)
                            or old_AnimState[k](old_AnimState, old_symbol, ...);
                end
            end

            -- 无侵入修改，临时替换变量
            rawset(owner, "AnimState", NewAnimState);
            old_fn(inst, owner, ...);
            rawset(owner, "AnimState", old_AnimState);

            -- 卸下背包的时候按道理调用的是：ClearOverrideSymbol("swap_body_tall") 吧，为什么 swap_body 也被清理掉了
            if inst.components.equippable.equipslot == EQUIPSLOTS_CACHE.BACK then
                local inventory = owner.components.inventory;
                local body = inventory and inventory:Unequip(EQUIPSLOTS_CACHE.BODY);
                if body then
                    inventory:GiveItem(body);
                    inventory:Equip(body);
                end
            end

            if isFn(extra_fn) then
                extra_fn(inst, owner, new_symbol, ...);
            end
        end
    end

    ---留作备份，这样实现其实很危险，毕竟修改了原函数的内存地址，容易和其他模组冲突
    local function prefab_fn_cover1()
        local function PrefabFnCover(old_fn)
            if not isFn(old_fn) then
                return old_fn;
            end

            local function HeavyPrefabsFn(inst, owner, symbol)
                -- 由于我只添加了一个新的背包栏，所以根本不需要额外处理。
            end

            local function modify(inst, slot)
                local equippable = inst.components.equippable;

                equippable.onequipfn = AnimSymbolCover(equippable.onequipfn, SymbolMap[slot]);
                equippable.onunequipfn = AnimSymbolCover(equippable.onunequipfn, SymbolMap[slot], HeavyPrefabsFn, true);

                equippable.equipslot = slot;
            end

            return function(...)
                local inst = old_fn(...);
                if not TheWorld.ismastersim then
                    return inst;
                end
                -- 修改装备
                if inst.components.equippable then
                    if IsBack(inst) then
                        modify(inst, EQUIPSLOTS_CACHE.BACK or EQUIPSLOTS_CACHE.BODY);
                    elseif IsBody(inst) then
                        modify(inst, EQUIPSLOTS_CACHE.BODY);
                    end
                end
                return inst;
            end
        end

        -- 直接修改 RegisterPrefabsImpl 函数。呃，怎么说呢，其实这种方式有好也有坏...
        ---- 出问题了再说吧，不得不说，AddXXXPostInit 这种方式其实挺不错的...
        local old_RegisterPrefabsImpl = GLOBAL.RegisterPrefabsImpl;
        GLOBAL.RegisterPrefabsImpl = function(prefab, ...)
            local old_fn = prefab.fn;
            if old_fn then
                local function FindUpvalue(fn, key)
                    local level = 1;
                    while true do
                        local name, value = debug.getupvalue(fn, level);
                        level = level + 1;
                        if name == nil then
                            return ;
                        end
                        if string.find(name, key) then
                            return true;
                        end
                    end
                end
                if FindUpvalue(old_fn, "equip") or FindUpvalue(old_fn, "onfinishseamlessplayerswap") then
                    prefab.fn = PrefabFnCover(old_fn);
                end
            end
            return old_RegisterPrefabsImpl(prefab, ...);
        end
    end
    --prefab_fn_cover1();

    local function prefab_fn_cover2()
        local function modify(inst, slot)
            local equippable = inst.components.equippable;

            equippable.onequipfn = AnimSymbolCover(equippable.onequipfn, SymbolMap[slot]);
            equippable.onunequipfn = AnimSymbolCover(equippable.onunequipfn, SymbolMap[slot]);

            equippable.equipslot = slot;
        end

        env.AddPrefabPostInitAny(function(inst)
            if not TheWorld.ismastersim then
                return inst;
            end
            if null(inst.components.equippable) then
                return inst;
            end
            if IsBack(inst) then
                modify(inst, EQUIPSLOTS_CACHE.BACK or EQUIPSLOTS_CACHE.BODY);
            elseif IsBody(inst) then
                modify(inst, EQUIPSLOTS_CACHE.BODY);
            end
        end)
    end
    prefab_fn_cover2();
end
symbol_replace();

---修改相关联的一些组件和预制物
local function hook_associated_content()

    -- 修改服务端的 GetOverflowContainer 函数
    HookComponent("inventory", function(self)
        local old_GetOverflowContainer = self.GetOverflowContainer;
        self.GetOverflowContainer = EquipSlotsCover(old_GetOverflowContainer);
    end)

    -- 修改客户端的 GetOverflowContainer 函数
    env.AddSimPostInit(function()
        local Prefabs = GLOBAL.Prefabs;
        local inventory_classified = Prefabs and Prefabs["inventory_classified"];
        local inventory_classified_fn = inventory_classified and inventory_classified.fn;
        if oneOfNull(2, inventory_classified, inventory_classified_fn) then
            return ;
        end
        inventory_classified.fn = function(...)
            local inst = inventory_classified_fn(...);
            if not TheWorld.ismastersim then
                local old_GetOverflowContainer = inst.GetOverflowContainer
                inst.GetOverflowContainer = EquipSlotsCover(old_GetOverflowContainer);
                return inst;
            end
            return inst;
        end
    end)
end
hook_associated_content();

local function optimization()
    -- 人物复活时的优化...呃，开了死亡不掉落的优化。。。
    local player_common_extensions = require "prefabs/player_common_extensions";
    if player_common_extensions then
        local old_OnRespawnFromGhost = player_common_extensions.OnRespawnFromGhost;
        if old_OnRespawnFromGhost then
            player_common_extensions.OnRespawnFromGhost = function(inst, from, ...)
                local res = {};
                if old_OnRespawnFromGhost then
                    res = { old_OnRespawnFromGhost(inst, from, ...) }
                end

                -- 显示头部物品的贴图：注意同样不够太完美，因为有些人物的图层不止这些...
                inst:DoTaskInTime(120 * FRAMES, function(inst)
                    inst.AnimState:Show("HAT");
                end);

                -- 重新装备一下背包
                local inventory = inst.components.inventory;
                for k, _ in pairs(inventory.equipslots) do
                    if k == EQUIPSLOTS_CACHE.BACK then
                        local item = inventory:Unequip(k);
                        inventory:GiveItem(item);
                        inventory:Equip(item);
                        break ;
                    end
                end

                return unpack(res, 1, table.maxn(res));
            end
        end
    end
end
optimization();
