---
--- @author zsh in 2023/3/20 8:51
---

-- 注意要通过 env.modimport 导入

if getmetatable(env) == nil then
    setmetatable(env, { __index = function(_, k)
        return rawget(GLOBAL, k);
    end });
end

local fns = {
    getTabLen = function(tab)
        assert(type(tab) == "table");
        local cnt = 0;
        for k, v in pairs(tab) do
            cnt = cnt + 1;
        end
        return cnt;
    end
};

local vars = {};

local SLOTS_NUMBER;

local W = 68
local SEP = 12
local YSEP = 8
local INTERSEP = 28

local CURSOR_STRING_DELAY = 10
local TIP_YFUDGE = 16
local HINT_UPDATE_INTERVAL = 2.0 -- once per second

local ap_back = require("mi_modules.extra_equip_slots.adaptive_prefabs.back");
local ap_body = require("mi_modules.extra_equip_slots.adaptive_prefabs.body");
local ap_neck = require("mi_modules.extra_equip_slots.adaptive_prefabs.neck");

local isBack = ap_back.isBack;
local isBody = ap_body.isBody;
local isNeck = ap_neck.isNeck;

if EQUIPSLOTS then
    EQUIPSLOTS.HANDS = "hands";
    EQUIPSLOTS.HEAD = "head";
    EQUIPSLOTS.BODY = "body";
    EQUIPSLOTS.BACK = "back";
    EQUIPSLOTS.NECK = "neck";
else
    EQUIPSLOTS = {
        HANDS = "hands",
        HEAD = "head",
        BODY = "body",
        BACK = "back",
        NECK = "neck",
        BEARD = "beard"
    }
end

SLOTS_NUMBER = fns.getTabLen(EQUIPSLOTS);
print("SLOTS_NUMBER: " .. SLOTS_NUMBER); -- TEST

if SLOTS_NUMBER > 5 or EQUIPSLOTS.BACK or EQUIPSLOTS.NECK then
    print("你开启了其他同类型模组，本模组自动失效。");
    return ;
end

-- IDS 不需要手动生成，equipslotutil.lua 中已经通过 EQUIPSLOTS 自动生成了。
--local EQUIPSLOT_NAMES = {};
--for k, v in pairs(EQUIPSLOTS) do
--    table.insert(EQUIPSLOT_NAMES, v)
--end
--EQUIPSLOT_IDS = table.invert(EQUIPSLOT_NAMES);

-- 图片资源导入
table.insert(env.Assets, Asset("IMAGE", "images/uiimages/back.tex"));
table.insert(env.Assets, Asset("ATLAS", "images/uiimages/back.xml"));
table.insert(env.Assets, Asset("IMAGE", "images/uiimages/neck.tex"));
table.insert(env.Assets, Asset("ATLAS", "images/uiimages/neck.xml"));


--[[ 添加新的装备槽并调整想要的位置 ]]
env.AddClassPostConstruct("widgets/inventorybar", function(self, ...)
    print("TEST-owner: " .. tostring((select(1, ...))));
    if TheNet:GetServerGameMode() == "quagmire" then
        return ;
    end
    -- 修改原有装备槽的图片？

    -- 添加新装备槽    (话说我需不需要修改 sortkey 呢？)
    self:AddEquipSlot(EQUIPSLOTS.BACK, "images/uiimages/back.xml", "back.tex");
    self:AddEquipSlot(EQUIPSLOTS.NECK, "images/uiimages/neck.xml", "neck.tex");

    local function Refresh(self)
        -- 根据格子数量缩放装备栏，更新物品栏背景长度
        --self.bg:SetScale(1.3 + (SLOTS_NUMBER - 4) * 0.05, 1, 1.25)
        --self.bgcover:SetScale(1.3 + (SLOTS_NUMBER - 4) * 0.05, 1, 1.25)

        self.bg:SetScale(1.35, 1, 1);
        self.bgcover:SetScale(1.35, 1, 1);
        if self.integrated_backpack then
            self.bg:SetPosition(self.bg:GetPosition() * .65);
            self.toprow:SetPosition(self.toprow:GetPosition() * 1.3);
            self.bottomrow:SetPosition(self.bottomrow:GetPosition() * .65);
        else
            self.bg:SetPosition(self.bg:GetPosition() * .8);
            self.toprow:SetPosition(self.toprow:GetPosition() * 1.1);
        end
        self:UpdatePosition()
    end

    local old_Refresh = self.Refresh;
    function self:Refresh()
        old_Refresh(self);
        Refresh(self);
    end

    local old_Rebuild = self.Rebuild;
    function self:Rebuild()
        old_Rebuild(self);

        -- 获取新的 total_w
        local inventory = self.owner.replica.inventory;
        local overflow = inventory:GetOverflowContainer();
        overflow = (overflow ~= nil and overflow:IsOpenedBy(self.owner)) and overflow or nil;
        local do_integrated_backpack = overflow ~= nil and self.integrated_backpack;
        local do_self_inspect = not (self.controller_build or GetGameModeProperty("no_avatar_popup"));

        -- See `widgets/inventorybar.lua` RebuildLayout 函数
        local y = overflow ~= nil and ((W + YSEP) / 2) or 0
        local eslot_order = {}

        local num_slots = inventory:GetNumSlots()
        local num_equip = #self.equipslotinfo;
        local num_buttons = do_self_inspect and 1 or 0;
        local num_slotintersep = math.ceil(num_slots / 5)
        local num_equipintersep = num_buttons > 0 and 1 or 0
        local total_w = (num_slots + num_equip + num_buttons) * W + (num_slots + num_equip + num_buttons - num_slotintersep - num_equipintersep - 1) * SEP + (num_slotintersep + num_equipintersep) * INTERSEP

        local x = (W - total_w) * .5 + num_slots * W + (num_slots - num_slotintersep) * SEP + num_slotintersep * INTERSEP

        -- 调整人物检查按钮位置
        if do_self_inspect then
            Refresh(self);
            self.inspectcontrol:SetPosition((total_w - W) * .5 + 3, -7, 0);
        end
    end
end);

-------------------------------------------------------------------------------------------------------------
--[[ 普通 ]]
-------------------------------------------------------------------------------------------------------------

--[[ 硬编码显示图层 ]]

---待完成。这个六格装备栏写得乱七八糟的。我还不如看那个相当复杂的 mod 的呢！
local function onequiporunequip(inst, data)
    if data.eslot
            and (data.eslot == GLOBAL.EQUIPSLOTS.BODY
            or data.eslot == GLOBAL.EQUIPSLOTS.BACK
            or data.eslot == GLOBAL.EQUIPSLOTS.NECK)
    then
        local inventory = inst.replica.inventory;

    end
end
env.AddComponentPostInit("inventory", function(self, inst)
    inst:ListenForEvent("equip", onequiporunequip);
    inst:ListenForEvent("unequip", onequiporunequip);
end)

-- 2023-03-20-17:26：不写了，花了一天研究源码。五格装备栏优秀的很多，而且我也没有需求。















-------------------------------------------------------------------------------------------------------------
--[[ 高级-函数式编程 ]]
-------------------------------------------------------------------------------------------------------------
do
    -- 以下部分代码暂时无效化，内容较为复杂，先从简单的写起！
    return ;
end
--[[ Hook 官方的 RegisterPrefabsImpl 函数 ]]
local ANIM_STATE = newproxy(true);

function fns.hasUpvalueFn(fn_reference, fn_name)
    local level = 1;
    for i = 1, math.huge do
        local name, value = debug.getupvalue(fn_reference, level);
        level = level + 1;
        if name == nil then
            return false;
        end
        if name and string.find(name, fn_name) then
            return true;
        end
    end
end

vars.ANIM_DATA = {
    body = "swap_body_tall";
    back = "swap_body";
    neck = "swap_body";
}

local function isHeavy(inst, owner, symbol)
    return symbol == "swap_body"
            and inst:HasTag("heavy")
            and owner.sg ~= nil and owner.sg.statemem.heavy and owner.sg:GoToState("idle");
end

-- FIXME: 此处不完整，写了一半。接下来部分暂时没看懂，因为表在 C 层，我需要进游戏打印一下内容才行！
local function AnimCover(fn, symbol, extra_fn)
    return function(inst, owner, ...)
        local old_AnimState = rawget(owner, "AnimState");

        local mt = getmetatable(ANIM_STATE);
        mt.__index = function(t, k)
            print("k: " .. tostring(k));
            --if type(rawget(t, k)) ~= "function" then
            --    return rawget(t, k);
            --end
            return function(_, paramX, ...)
                return paramX and type(paramX) == "string" and string.find(str, "body")
                        and old_AnimState[k](old_AnimState, symbol, ...)
                        or old_AnimState[k](old_AnimState, paramX, ...);
            end
        end
        rawset(owner, "AnimState", mt);

        fn(inst, owner, ...);

        rawset(owner, "AnimState", old_AnimState);

        if extra_fn and type(extra_fn) == "function" then
            extra_fn(inst, owner, symbol, ...);
        end
    end
end

function fns.ModifyInst(inst, eslot)
    local equippable = inst.components.equippable;
    equippable.equipslot = eslot;
    equippable.onequipfn = AnimCover(equippable.onequipfn, vars.ANIM_DATA[eslot], nil);
    equippable.onunequipfn = AnimCover(equippable.onunequipfn, vars.ANIM_DATA[eslot], isHeavy);
    return inst;
end

-- FIXME
local function EventCover(fn, ...)
    return function(...)
        local old_BODY = EQUIPSLOTS.BODY;
        EQUIPSLOTS.BODY = EQUIPSLOTS.BACK or EQUIPSLOTS.BODY; --???
        local result = fn(...);
        EQUIPSLOTS.BODY = old_BODY;
        return result;
    end
end

---??? 记得去看一下事件里面的内容！
function fns.ModifyPlayerEvent(inst)
    if inst.sg and inst.sg.sg then
        local events = inst.sg.sg.events;
        local old_equip = events.equip and events.equip.fn;
        local old_unequip = events.unequip and events.unequip.fn;
        if old_equip and old_unequip then
            events.equip.fn = EventCover(old_equip);
            events.unequip.fn = EventCover(old_unequip);
        end
    end
    return inst;
end

-- 2023-03-20-16:00：此处部分尚未测试，好复杂。
local old_RegisterPrefabsImpl = RegisterPrefabsImpl;
RegisterPrefabsImpl = function(prefab, ...)
    -- See `prefabs.lua`
    local old_fn = prefab.fn;
    if old_fn then
        -- 注意，此时的预制物并没有生成，此处只是个原型。所以那如果没有这种上值应该怎么办呢？比如我习惯性 fns
        if fns.hasUpvalueFn(old_fn, "equip") then
            prefab.fn = function(fn, ...)
                return function(...)
                    local inst = fn(...);
                    return isBody(inst) and fns.ModifyInst(inst, EQUIPSLOTS.BODY)
                            or isBack(inst) and fns.ModifyInst(inst, EQUIPSLOTS.BODY)
                            or isNeck(inst) and fns.ModifyInst(inst, EQUIPSLOTS.BODY)
                            or inst;
                end
            end
        else
            print("no pattern`equip` function.");
        end
        if fns.hasUpvalueFn(old_fn, "onfinishseamlessplayerswap") then
            prefab.fn = function(fn, ...)
                return function(...)
                    local inst = fn(...);
                    return inst:HasTag("player") and fns.ModifyPlayerEvent(inst) or inst;
                end
            end
        end
    end
    return old_RegisterPrefabsImpl(prefab, ...);
end

--[[ HookEquipInv??? ]]

--[[ 修改人物的 OnRespawnFromGhost 函数 ]]




