---
--- @author zsh in 2023/5/16 15:06
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

--if OneOfModEnabled("2890837039", "MX Slot") then
--    return ;
--end

--do
--    return;
--end

-- TEST
if TUNING.MX_SLOTS_ENABLED_TEST then
    return ;
end

-- TEST
--config_data.extra_equip_slots = 5;

-- 2023-05-17-01:00：
---- 我的服务器应该可能会长期使用四格，五格关于护符的问题，就留给小王者帮我测试吧！

-- 目前来说不是四格就是五格，四格应该更稳定，毕竟五格需要处理护符。
local FIVE_SLOTS = config_data.extra_equip_slots == 5;
local FOUR_SLOTS = config_data.extra_equip_slots == 4;

-- 2023-05-18：当前文件暂时是五格吧，我先去针对性地写一个完美的四格再说！
FIVE_SLOTS = true;
FOUR_SLOTS = false;

EQUIPSLOTS.BACK = "back";
EQUIPSLOTS.NECK = "neck";

if FOUR_SLOTS then
    --EQUIPSLOTS.NECK = EQUIPSLOTS.BODY; -- NECK 是 BODY 即可？呃，这会导致注册了相同的网络变量?...烦人...得改动更多了...
    EQUIPSLOTS.BACK = "back";
else
    EQUIPSLOTS.BACK = "back";
    EQUIPSLOTS.NECK = "neck";
end

-- 呃，有发现一个bug，开了永不妥协之后，五格情况下，背雕像，雕像不显示贴图？？？巨型作物是显示的...
---- 而且四格是正常的... 呃，关掉永不妥协之后，都是正常的？？？

local EQUIPSLOTS_CACHE = deepcopy(EQUIPSLOTS);

TUNING.MORE_ITEMS_EXTRA_EQUIP_SLOTS_ENABLED = true;

TUNING.MORE_ITEMS_EXTRA_EQUIP_SLOTS = {};

local ItemsCategory = Import("modmain/AUXmods/other_auxiliary/extra_equip_slots/files/items.lua");

local EXTRA_EQUIP_SLOTS_TAG = "more_items_extra_equip_slots_tag";

-- TEST
local AnimCoverFunctionalTest = true;

-- 2023-05-17：居然和永不妥协不兼容，因为我修改了 fn 函数，导致永不妥协没有找到对于的上值...呃...
---- 要么我单纯用 AddSimPostInit 试试？要么精确制导？(但是这两种方法，正面和反面，显然排除法是不够的，针对性修改才是正确的...)

local function postinit()
    local priority = env.modinfo and env.modinfo.priority;

    --[[ 添加新的装备槽 ]]
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
                    if FOUR_SLOTS then
                        self:AddEquipSlot(EQUIPSLOTS_CACHE.BACK, "images/uiimages/back.xml", "back.tex", 2.1);
                    else
                        self:AddEquipSlot(EQUIPSLOTS_CACHE.BACK, "images/uiimages/back.xml", "back.tex", 2.1);
                        self:AddEquipSlot(EQUIPSLOTS_CACHE.NECK, "images/uiimages/neck.xml", "neck.tex", 2.2);
                    end
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

    --- 无侵入修改，临时替换变量，和我的绝对吃不完系列实现方法类似。
    local function EquipSlotsCover(old_fn)
        if null(old_fn) then
            return ;
        end
        return function(...)
            local body = EQUIPSLOTS.BODY;
            EQUIPSLOTS.BODY = EQUIPSLOTS.BACK or EQUIPSLOTS.BODY;
            local res = { old_fn(...) };
            EQUIPSLOTS.BODY = body;
            return unpack(res, 1, table.maxn(res));
        end
    end

    --[[ 修改物品的默认装备槽和贴图显示 ]]
    local IsBody, IsBack, IsNeck = ItemsCategory.IsBody, ItemsCategory.IsBack, ItemsCategory.IsNeck;

    -- 此处暂时先这样：之前的实现方法
    if not AnimCoverFunctionalTest then
        env.AddPrefabPostInitAny(function(inst)
            if not TheWorld.ismastersim then
                return inst;
            end
            if null(inst.components.equippable) then
                return inst;
            end

            if IsNeck(inst) then
                if FOUR_SLOTS then
                    -- DoNothing
                else
                    inst.components.equippable.equipslot = EQUIPSLOTS.NECK or EQUIPSLOTS.BODY;
                end
            elseif IsBack(inst) then
                inst.components.equippable.equipslot = EQUIPSLOTS.BACK or EQUIPSLOTS.BODY;
            elseif IsBody(inst) then
                -- DoNothing
            else
                -- DoNothing
            end
        end)
    end

    if AnimCoverFunctionalTest then
        local ProxyAnimState = newproxy(true);
        local AnimMap = { ["back"] = "swap_body_tall"; ["body"] = "swap_body"; ["neck"] = "swap_body"; }

        local function AnimCover(old_fn, symbol, extra_fn, isunequip)
            --assert(old_fn ~= nil, "AnimCover: `old_fn == nil`");
            if null(old_fn) or null(symbol) then
                return ;
            end
            return function(inst, owner, ...)
                if not owner or not owner:HasTag("player") then
                    return old_fn(inst, owner, ...);
                end
                local old_AnimState = rawget(owner, "AnimState");
                local mt = getmetatable(ProxyAnimState);
                if oneOfNull(2, old_AnimState, mt) then
                    return old_fn(inst, owner, ...);
                end
                mt.__index = function(t, k)
                    -- 呃，t 是 userdata 类型的 ... 话说这个 t 里面一定都是函数吗？
                    --local value = rawget(t, k);
                    --if not isFn(value) then
                    --    return value;
                    --end
                    return function(_, old_symbol, ...)
                        return isStr(old_symbol) and string.find(old_symbol, "body")
                                and old_AnimState[k](old_AnimState, symbol, ...)
                                or old_AnimState[k](old_AnimState, old_symbol, ...);
                    end
                end

                -- 无侵入修改，临时替换变量
                rawset(owner, "AnimState", ProxyAnimState);
                old_fn(inst, owner, ...);
                rawset(owner, "AnimState", old_AnimState);

                -- 测试一下：但是背重物的时候咋办呢...算了，重物设置在身体栏刚刚好！
                ---- 2023-05-16: 只能说，这是凑活用的办法，而且我下面注释掉的部分还不能执行，因为会相互调用...堆栈溢出...
                if true then
                    local inventory = owner.components.inventory;
                    if inst.components.equippable.equipslot == EQUIPSLOTS_CACHE.BACK then
                        local body = inventory and inventory:Unequip(EQUIPSLOTS_CACHE.BODY);
                        if body then
                            inventory:GiveItem(body);
                            inventory:Equip(body);
                        else
                            if FOUR_SLOTS then
                                -- DoNothing
                            else
                                local neck = inventory and inventory:Unequip(EQUIPSLOTS_CACHE.NECK);
                                if neck then
                                    inventory:GiveItem(neck);
                                    inventory:Equip(neck);
                                end
                            end
                        end
                    end
                    if isunequip then
                        if FOUR_SLOTS then
                            -- DoNothing
                        else
                            if inst.components.equippable.equipslot == EQUIPSLOTS_CACHE.NECK then
                                local body = inventory and inventory:Unequip(EQUIPSLOTS_CACHE.BODY);
                                if body then
                                    inventory:GiveItem(body);
                                    inventory:Equip(body);
                                end
                                --elseif inst.components.equippable.equipslot == EQUIPSLOTS_CACHE.BODY then
                                --    local neck = inventory and inventory:Unequip(EQUIPSLOTS_CACHE.NECK);
                                --    if neck then
                                --        inventory:GiveItem(neck);
                                --        inventory:Equip(neck);
                            end
                        end
                    end
                end

                if isFn(extra_fn) then
                    extra_fn(inst, owner, symbol, ...);
                end
            end
        end

        -- TEST
        --local function HeavySpecialFnTest(inst, owner, symbol)
        --    return symbol == "swap_body"
        --            and inst:HasTag("heavy")
        --            and owner.sg ~= nil
        --            and owner.sg.statemem.heavy;
        --end
        --local function HeavySpecialFn(inst, owner, symbol)
        --    if inst:HasTag("heavy") then
        --        print("", tostring(inst));
        --        print("", "heavy: " .. tostring(HeavySpecialFnTest(inst, owner, symbol)))
        --        print("", "heavy symbol: " .. tostring(symbol));
        --    else
        --        print("", tostring(HeavySpecialFnTest(inst, owner, symbol)))
        --        print("", "symbol: " .. tostring(symbol));
        --    end
        --    return symbol == "swap_body"
        --            and inst:HasTag("heavy")
        --            and owner.sg ~= nil
        --            and owner.sg.statemem.heavy
        --            and owner.sg:GoToState("idle");
        --end

        local function PrefabFnCover(old_fn)
            if null(old_fn) then
                return ;
            end
            -- 卸下重物之后需要是正常动画，但是不对劲啊，几乎没执行...
            local function HeavySpecialFn(inst, owner, symbol)
                --local pr_data = {
                --    symbol, inst:HasTag("heavy"), owner.sg, owner.sg and owner.sg.statemem.heavy
                --}
                --printSafe(unpack(pr_data,1,table.maxn(pr_data)));
                return symbol == "swap_body"
                        and inst:HasTag("heavy")
                        and owner.sg ~= nil
                        and owner.sg.statemem.heavy
                        and owner.sg:GoToState("idle");
            end

            local function modify(inst, slot)
                local equippable = inst.components.equippable;

                equippable.onequipfn = AnimCover(equippable.onequipfn, AnimMap[slot]);
                equippable.onunequipfn = AnimCover(equippable.onunequipfn, AnimMap[slot], HeavySpecialFn, true);

                equippable.equipslot = slot;
            end
            return function(...)
                local inst = old_fn(...);
                if not TheWorld.ismastersim then
                    return inst;
                end
                -- 修改玩家
                if inst:HasTag("player") and inst.sg and inst.sg.sg and inst.sg.sg.events then
                    local old_events = inst.sg.sg.events;
                    old_events.equip.fn = EquipSlotsCover(old_events.equip.fn);
                    old_events.unequip.fn = EquipSlotsCover(old_events.unequip.fn);
                end

                -- 修改装备
                if inst.components.equippable then
                    if IsNeck(inst) then
                        if FOUR_SLOTS then
                            -- DoNothing
                        else
                            modify(inst, EQUIPSLOTS_CACHE.NECK or EQUIPSLOTS_CACHE.BODY);
                        end
                    elseif IsBack(inst) then
                        modify(inst, EQUIPSLOTS_CACHE.BACK or EQUIPSLOTS_CACHE.BODY);
                    elseif IsBody(inst) then
                        modify(inst, EQUIPSLOTS_CACHE.BODY);
                    end
                end
                return inst;
            end
        end

        -- 不用 AddSimPostInit 了，直接修改 RegisterPrefabsImpl 函数
        ---- 呃，压根就没有执行我修改后的 RegisterPrefabsImpl 函数... ?
        ------ 噢，好吧...赋值的时候需要加个 GLOBAL.RegisterPrefabsImpl，因为我只修改了 env 原表的 __index
        local old_RegisterPrefabsImpl = RegisterPrefabsImpl;
        GLOBAL.RegisterPrefabsImpl = function(prefab, ...)
            local old_fn = prefab.fn;
            --prefab.fn = PrefabFnCover(old_fn);

            -- 换一种方式，增强兼容性，毕竟我修改了全体预制物函数在内存中的地址(应该是这个原因)，这个非常危险啊......
            ---- 怎么发现的：永不妥协在搜索克眼的上值的时候没有找到对应的值...然后 assert 了！
            if old_fn then
                local function FindUpvalue(fn, key)
                    local level = 1;
                    while true do
                        local name, value = debug.getupvalue(fn, level);
                        level = level + 1;
                        if name == nil then
                            return ;
                        end
                        if (string.find(name, key)) then
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

    -- 暂未处理！不要改成 true，改成 true 的话，应该需要开洞穴测试一下 inventory_classified！
    ---- 2023-05-17：处理了！开洞穴也测试过了！没啥问题，本地和远程都打印了，都可以正常获取到背包！
    local modify_inventory_classified = true;

    --[[ 修改相关联的一些组件或预制物 ]]
    local function hook_associated_content()
        -- inventory
        HookComponent("inventory", function(self)
            local old_Equip = self.Equip;
            self.Equip = EquipSlotsCover(old_Equip);
            --local Equip_Cover = self.Equip;
            --function self:Equip(item, ...)
            --    if item == nil or item.components.equippable == nil or not item:IsValid() or item.components.equippable:IsRestricted(self.inst) or (self.noheavylifting and item:HasTag("heavy")) then
            --        return
            --    end
            --    -----
            --
            --    if item:HasTag("heavy") and item.components.equippable.equipslot == EQUIPSLOTS_CACHE.BODY then
            --        return old_Equip(self, item, ...);
            --    end
            --    return Equip_Cover(self, item, ...);
            --end

            local old_Unequip = self.Unequip;
            self.Unequip = EquipSlotsCover(old_Unequip);
            --local Unequip_Cover = self.Unequip;
            --function self:Unequip(equipslot, ...)
            --    if equipslot == EQUIPSLOTS_CACHE.BODY then
            --        local body = self.equipslots[equipslot];
            --        if body and body:HasTag("heavy") then
            --            return old_Unequip(self, equipslot, ...);
            --        end
            --    end
            --
            --    -- 这是打补丁，处理未知错误(所谓未知错误是懒得去找到原因或者很难找到原因，此处算是平替方案)
            --    if equipslot == EQUIPSLOTS_CACHE.BACK then
            --        local body = self.equipslots[EQUIPSLOTS_CACHE.BODY];
            --        local back = self.equipslots[equipslot];
            --        if body and body:HasTag("heavy") and back then
            --            return old_Unequip(self, equipslot, ...);
            --        end
            --    end
            --    -- 这也是打补丁，处理未知错误(所谓未知错误是懒得去找到原因或者很难找到原因，此处算是平替方案)
            --    if FIVE_SLOTS then
            --        -- 此处没啥问题，但是 Equip 哪里需要处理一下了...
            --        ---- 2023-05-17-00:00：终止于此，因为我发现...背雕像的时候装备护符或者护甲会出现两种问题
            --        ---- 草，不管了！反正雕像几乎用不到，暂时就先不管了！因为屁事一大堆...烦死了。就是因为 BACK 不是 BODY
            --        ---- 但是似乎可以修改 GetEquippedItem 啊，获取 body 都返回获取 back？呃，这又导致其他问题了吧？
            --        ------ 但是其实也不失是个思路，因为可以加判定啊！
            --    end
            --
            --    return Unequip_Cover(self, equipslot, ...);
            --end

            -- 不知道不修改 inventory_classified 的 GetOverflowContainer 会不会有问题...
            ---- 2023-05-17：显然是有问题的，目前已经修改了，而且开洞穴测试过了！完全正常！
            if modify_inventory_classified then
                self.GetOverflowContainer = EquipSlotsCover(self.GetOverflowContainer);
                --self.TakeActiveItemFromEquipSlot = EquipSlotsCover(self.TakeActiveItemFromEquipSlot);
            else
                -- 可能是稳定版本：2890837039，似乎必须要这样写，因为需要兼容 2428854303、439115156。好像是导致卸下重物的时候动画未执行 idle？
                ---- 呃，我感觉不对，而且此处的 picker 不知道是干嘛的...
                ------ 还有就是，这绝对不对！我是添加的 BACK 槽，BACK 槽是背包！！！
                local old_GetEquippedItem = self.GetEquippedItem;
                function self:GetEquippedItem(slot, ...)
                    if slot == EQUIPSLOTS_CACHE.BODY then
                        local caller = debug.getinfo(2);
                        if caller.name == "GetOverflowContainer" then
                            local overflow = old_GetEquippedItem(self, EQUIPSLOTS_CACHE.BACK);
                            if (overflow ~= nil and overflow.components.container ~= nil and overflow.components.container.canbeopened) and overflow.components.container then
                                return overflow;
                            end
                        end

                        -- 这里应该是为了兼容 The Architect Pack 和 Musha，但是我懒得开这两个模组测试，照搬吧！
                        local picker = debug.getinfo(ACTIONS.PICKUP.fn);
                        if caller.name == "TakeActiveItemFromEquipSlot"
                                or caller.linedefined == 499
                                or caller.linedefined == 604
                                or caller.func == picker.func
                                or caller.name == nil and picker.name == nil and old_GetEquippedItem(self, EQUIPSLOTS_CACHE.BODY) == nil
                        then
                            return old_GetEquippedItem(self, EQUIPSLOTS_CACHE.BODY);
                        end

                        return old_GetEquippedItem(self, EQUIPSLOTS_CACHE.BACK);
                    end
                    return old_GetEquippedItem(self, slot, ...);
                end
            end

            -- 由于我添加了新的装备栏，而假人(sewing_mannequin)的 OnActivate 函数只写了前三个栏，所以此处我不需要修改。
            --self.SwapEquipment = EquipSlotsCover(self.SwapEquipment);
        end)

        -- inventory_classified: 需要改吗？
        if modify_inventory_classified then
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

        -- playeractionpicker：兼容一些动作，算是优化性内容吧！
        HookComponent("playeractionpicker", function(self)
            local old_GetRightClickActions = self.GetRightClickActions;
            self.GetRightClickActions = EquipSlotsCover(old_GetRightClickActions);
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
                    local res = { old_OnRespawnFromGhost(inst, from, ...) };

                    -- ??????
                    --if from and from.source and from.source.prefab == "amulet" then
                    --    from.source.components.finiteuses:Use(2);
                    --end

                    -- 显示头部物品的贴图
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
end
postinit();
