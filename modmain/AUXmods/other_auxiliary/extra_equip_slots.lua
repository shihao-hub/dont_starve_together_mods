---
--- @author zsh in 2023/1/21 12:02
---

if GLOBAL.EQUIPSLOTS == nil then
    return ;
end

-- 2023-03-22：按道理来说，我应该重制此处内容的。但是先算了，我没有需求。

local function getTabLen(t)
    local len = 0
    for _, _ in pairs(t) do
        len = len + 1;
    end
    return len;
end

local slotsnum = getTabLen(GLOBAL.EQUIPSLOTS);
local Inv = require "widgets/inventorybar";

TUNING.MONE_TUNING.EXTRA_EQUIP_SLOTS_ON_TAG = "mone_extra_equip_slot_on_tag";

-- 当时我是被迫这样写的，好像因为格子容量问题出现了故障。好像是和其他五格一起开的时候的故障，和 net、classified 有关
if GLOBAL.EQUIPSLOTS.BACK or GLOBAL.EQUIPSLOTS.NECK then
    return ;
else
    -- 兼容新版本威尔逊
    if GLOBAL.EQUIPSLOTS then
        GLOBAL.EQUIPSLOTS.HANDS = "hands";
        GLOBAL.EQUIPSLOTS.HEAD = "head";
        GLOBAL.EQUIPSLOTS.BODY = "body";
        GLOBAL.EQUIPSLOTS.BACK = "back";
        GLOBAL.EQUIPSLOTS.NECK = "neck";
    else
        GLOBAL.EQUIPSLOTS = {
            HANDS = "hands",
            HEAD = "head",
            BODY = "body",
            BACK = "back",
            NECK = "neck",
            BEARD = "beard"
        }
    end

    -- 2023-03-22：这里其实不用写吧
    GLOBAL.EQUIPSLOT_IDS = {}
    local num = 0;
    for _, v in pairs(GLOBAL.EQUIPSLOTS) do
        num = num + 1;
        GLOBAL.EQUIPSLOT_IDS[v] = num;
    end
end

print("MORE_ITEMS_EXTRA_EQUIP_SLOTS_ON");

-- 优先级低于能力勋章，然后能力勋章会报错 ?????? 我只能调低我自己的优先级了。 -- 已解决
-- 勋章优先级比我低的时候总是会导致格子溢出，为什么呢？ -- 未能解决

------------------------------------------------------------------------------------------------------------
--[[ 添加装备槽以及修改部分细节 ]]
------------------------------------------------------------------------------------------------------------
--local InvBar = require "widgets/inventorybar";
--if InvBar then
--    local old_AddEquipSlot = InvBar.AddEquipSlot;
--    if old_AddEquipSlot then
--        function InvBar:AddEquipSlot(...)
--            if old_AddEquipSlot == nil then
--                print("InvBar:AddEquipSlot: `old_AddEquipSlot == nil`");
--                return ;
--            end
--            old_AddEquipSlot(self, ...);
--            if self.extra_equip_slots_flag == nil and #self.equipslotinfo == 3 then
--                self.extra_equip_slots_flag = true;
--                self:AddEquipSlot(EQUIPSLOTS.BACK, "images/uiimages/back.xml", "back.tex", 2.1);
--                self:AddEquipSlot(EQUIPSLOTS.NECK, "images/uiimages/neck.xml", "neck.tex", 2.2);
--            end
--        end
--    end
--
--    local old_Rebuild = InvBar.Rebuild;
--    if old_Rebuild then
--        function InvBar:Rebuild(...)
--            if old_Rebuild == nil then
--                print("InvBar:Rebuild: `old_Rebuild == nil`");
--                return ;
--            end
--            old_Rebuild(self, ...);
--            self.bg:SetScale(1.35, 1, 1);
--            self.bgcover:SetScale(1.35, 1, 1);
--            if self.integrated_backpack then
--                self.bg:SetPosition(self.bg:GetPosition() * .65);
--                self.toprow:SetPosition(self.toprow:GetPosition() * 1.3);
--                self.bottomrow:SetPosition(self.bottomrow:GetPosition() * .65);
--            else
--                self.bg:SetPosition(self.bg:GetPosition() * .8);
--                self.toprow:SetPosition(self.toprow:GetPosition() * 1.1);
--            end
--            self:UpdatePosition();
--        end
--    end
--end

-- 旧版本：应该是不如上面的，但是不至于背景过长，占屏幕空间。
local function RefreshSomething(self)
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

    -- 此处导致纵向过长
    --if self.integrated_backpack then
    --    self.bg:SetPosition(self.bg:GetPosition() * .65);
    --    self.toprow:SetPosition(self.toprow:GetPosition() * 1.3);
    --    self.bottomrow:SetPosition(self.bottomrow:GetPosition() * .65);
    --else
    --    self.bg:SetPosition(self.bg:GetPosition() * .8);
    --    self.toprow:SetPosition(self.toprow:GetPosition() * 1.1);
    --end
    --self:UpdatePosition();
end

env.AddClassPostConstruct("widgets/inventorybar", function(self, owner)
    self:AddEquipSlot(GLOBAL.EQUIPSLOTS.BACK, "images/uiimages/back.xml", "back.tex", 2.1);
    self:AddEquipSlot(GLOBAL.EQUIPSLOTS.NECK, "images/uiimages/neck.xml", "neck.tex", 2.2);

    local old_Refresh = self.Refresh;
    function self:Refresh()
        if old_Refresh == nil then
            return ;
        end
        old_Refresh(self);
        RefreshSomething(self);
    end

    local old_Rebuild = self.Rebuild;
    function self:Rebuild()
        if old_Rebuild == nil then
            return ;
        end
        old_Rebuild(self);
        RefreshSomething(self);
    end
end)

------------------------------------------------------------------------------------------------------------
--[[ 此处需要优化的！ ]]
------------------------------------------------------------------------------------------------------------
env.AddComponentPostInit("inventory", function(self)
    local old_Equip = self.Equip
    self.Equip = function(self, item, old_to_active)
        if old_Equip and old_Equip(self, item, old_to_active) then
            if item and item.components and item.components.equippable and item.components.container then
                local eslot = item.components.equippable.equipslot;
                if self.equipslots[eslot] ~= item and item.components.equippable.equipslot == GLOBAL.EQUIPSLOTS.BACK then
                    self.inst:PushEvent("setoverflow", { overflow = item })
                end
                self.heavylifting = item:HasTag("heavy")
            end
            return true
        end
    end

    local old_GetOverflowContainer = self.GetOverflowContainer
    self.GetOverflowContainer = function(self)
        local item;
        if GLOBAL.EQUIPSLOTS.BACK then
            item = self:GetEquippedItem(GLOBAL.EQUIPSLOTS.BACK)
        end
        if item and not item:HasTag(TUNING.MONE_TUNING.EXTRA_EQUIP_SLOTS_ON_TAG) then
            if self.ignoreoverflow then
                return
            end
            return (item ~= nil and item.components.container ~= nil and item.components.container.canbeopened) and item.components.container or nil
        end
        if old_GetOverflowContainer then
            return old_GetOverflowContainer(self)
        end
    end
end)

env.AddPrefabPostInit("inventory_classified", function(inst)
    if not TheWorld.ismastersim then
        local old_GetOverflowContainer = inst.GetOverflowContainer
        inst.GetOverflowContainer = function(inst)
            local item;
            if GLOBAL.EQUIPSLOTS.BACK then
                item = inst.GetEquippedItem(inst, GLOBAL.EQUIPSLOTS.BACK)
            end
            if item and not item:HasTag(TUNING.MONE_TUNING.EXTRA_EQUIP_SLOTS_ON_TAG) then
                if inst.ignoreoverflow then
                    return
                end
                return item ~= nil and item.replica.container or nil
            end
            if old_GetOverflowContainer then
                return old_GetOverflowContainer(inst)
            end
        end
        return inst
    end
end)

------------------------------------------------------------------------------------------------------------
--[[ 此处也需要优化的！同时还需要完善！ ]]
------------------------------------------------------------------------------------------------------------
--关于生命护符
env.AddStategraphPostInit("wilson", function(self)
    for k, v in pairs(self.states) do
        if v and v.name == "amulet_rebirth" then
            local old_onexit = self.states[k].onexit

            -- 2023-02-13-11:08：并没有 onexit 函数，只有 onenter
            -- 而且按照这个函数内容，似乎真正执行的话问题很大啊！
            -- TODO: 先放在这里吧！等有空学了 brain 和 sg 再说！

            self.states[k].onexit = function(inst)
                local item;
                if GLOBAL.EQUIPSLOTS.NECK then
                    item = inst.components.inventory:GetEquippedItem(GLOBAL.EQUIPSLOTS.NECK)
                end
                if item and item.prefab and item.prefab == "amulet" then
                    item = inst.components.inventory:RemoveItem(item)
                    if item then
                        item:Remove()
                        item.persists = false
                    end
                end
                if old_onexit then
                    old_onexit(inst)
                end
            end
        end
    end
end)

-- 2023-03-22：兼容永不妥协？但是我没需求啊。。。

------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------
local ees_data = require("definitions.mone.ees_data");

local function isBackpack(inst)
    if not (inst.components.equippable
            and (inst.components.equippable.equipslot == EQUIPSLOTS.BODY
            or inst.components.equippable.equipslot == EQUIPSLOTS.BACK))
    then
        return false;
    end
    for k, v in pairs(ees_data.backpacks) do
        if inst.prefab == k then
            return true;
        end
    end
    return inst:HasTag("backpack")
            or (inst.components.container and not ees_data.fns.hasPercent(inst))
            or (inst.components.container and ees_data.fns.hasPercent(inst) and inst:HasTag("hide_percentage"));
end

local function isAmulet(inst)
    if not (inst.components.equippable
            and (inst.components.equippable.equipslot == EQUIPSLOTS.BODY
            or inst.components.equippable.equipslot == EQUIPSLOTS.NECK))
    then
        return false;
    end
    for _, v in ipairs(ees_data.amulets) do
        if inst.prefab == v then
            return true;
        end
    end
    return inst.foleysound and inst.foleysound == "dontstarve/movement/foley/jewlery";
end

-- armor 其实和 body 差不多，其实没什么判断的必要。
---- 反正不是 BACK 和 NECK，统统保持原样！
local function isBody(inst)
    if not (inst.components.equippable
            and inst.components.equippable.equipslot == EQUIPSLOTS.BODY)
    then
        return false;
    end
    for _, v in ipairs(ees_data.armors) do
        if inst.prefab == v then
            return true;
        end
    end
end

env.AddPrefabPostInitAny(function(inst)
    if not TheWorld.ismastersim then
        return inst;
    end
    if inst.components.equippable == nil then
        return inst;
    end
    -- 2023-04-09：我反过来了。应该修改了再添加标签的。。。
    inst:AddTag(TUNING.MONE_TUNING.EXTRA_EQUIP_SLOTS_ON_TAG);
    if isBackpack(inst) then
        inst.components.equippable.equipslot = GLOBAL.EQUIPSLOTS.BACK or GLOBAL.EQUIPSLOTS.BODY;
        inst:RemoveTag(TUNING.MONE_TUNING.EXTRA_EQUIP_SLOTS_ON_TAG);
    elseif isAmulet(inst) then
        inst.components.equippable.equipslot = GLOBAL.EQUIPSLOTS.NECK or GLOBAL.EQUIPSLOTS.BODY;
        inst:RemoveTag(TUNING.MONE_TUNING.EXTRA_EQUIP_SLOTS_ON_TAG);
    elseif isBody(inst) then
        inst.components.equippable.equipslot = GLOBAL.EQUIPSLOTS.BODY;
        inst:RemoveTag(TUNING.MONE_TUNING.EXTRA_EQUIP_SLOTS_ON_TAG);
    else
        -- DoNothing
    end
end)



