---
--- @author zsh in 2023/1/21 12:02
---

-- 修复不能直接消耗箱子里的材料制作物品的bug

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

-- 当时我是被迫这样写的，好像因为格子容量问题出现了故障。好像是和其他五格一起开的时候的故障，
if slotsnum > 6 then
    return ;
elseif slotsnum > 4 then
    return ;
else
    GLOBAL.EQUIPSLOTS = {
        HANDS = "hands",
        HEAD = "head",
        BODY = "body",
        BACK = "back",
        NECK = "neck"
    }

    GLOBAL.EQUIPSLOT_IDS = {}

    local num = 0;
    for _, v in pairs(GLOBAL.EQUIPSLOTS) do
        num = num + 1;
        GLOBAL.EQUIPSLOT_IDS[v] = num;
    end
end

print("MORE_ITEMS_EXTRA_EQUIP_SLOTS_ON");

-- 添加 ！
env.AddComponentPostInit("inventory", function(self, inst)
    local original_Equip = self.Equip
    self.Equip = function(self, item, old_to_active)
        if original_Equip(self, item, old_to_active) and item and item.components and item.components.equippable then
            local eslot = item.components.equippable.equipslot
            if self.equipslots[eslot] ~= item then
                if eslot == GLOBAL.EQUIPSLOTS.BACK and item.components.container ~= nil then
                    self.inst:PushEvent("setoverflow", { overflow = item })
                end
            end
            return true
        else
            return
        end
    end

    self.GetOverflowContainer = function()
        if self.ignoreoverflow then
            return
        end
        local item = self:GetEquippedItem(GLOBAL.EQUIPSLOTS.BACK)
        return item ~= nil and item.components.container or nil
    end
end)

env.AddGlobalClassPostConstruct("widgets/inventorybar", "Inv", function()
    local Inv_Refresh_base = Inv.Refresh or function() return "" end
    local Inv_Rebuild_base = Inv.Rebuild or function() return "" end

    function Inv:LoadExtraSlots(self)
        self.bg:SetScale(1.35,1,1.25)
        self.bgcover:SetScale(1.35,1,1.25)

        if self.addextraslots == nil then
            self.addextraslots = 1

            self:AddEquipSlot(GLOBAL.EQUIPSLOTS.BACK, "images/uiimages/back.xml", "back.tex")
            self:AddEquipSlot(GLOBAL.EQUIPSLOTS.NECK, "images/uiimages/neck.xml", "neck.tex")

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
    end

    function Inv:Refresh()
        Inv_Refresh_base(self)
        Inv:LoadExtraSlots(self)
    end

    function Inv:Rebuild()
        Inv_Rebuild_base(self)
        Inv:LoadExtraSlots(self)
    end
end)

env.AddPrefabPostInit("inventory_classified", function(inst)
    if not TheWorld.ismastersim then
        inst.GetOverflowContainer = function(inst)
            local item = inst.GetEquippedItem(inst, GLOBAL.EQUIPSLOTS.BACK)
            return item ~= nil and item.replica.container or nil
        end
    end
end)

env.AddStategraphPostInit("wilson", function(self)
    for key,value in pairs(self.states) do
        if value.name == 'amulet_rebirth' then
            local original_amulet_rebirth_onexit = self.states[key].onexit
            self.states[key].onexit = function(inst)
                local item = inst.components.inventory:GetEquippedItem(GLOBAL.EQUIPSLOTS.NECK)
                if item and item.prefab == "amulet" then
                    item = inst.components.inventory:RemoveItem(item)
                    if item then
                        item:Remove()
                        item.persists = false
                    end
                end
                original_amulet_rebirth_onexit(inst)
            end
        end
    end
end)

local backpacks = {}
local amulets = {
    -- 原版护符
    "amulet", "blueamulet", "purpleamulet", "orangeamulet", "greenamulet", "yellowamulet",
    -- 兼容其他模组（该部分由 4/5/6格装备栏（适配mod版）模组整理，模组编号：2798599672）
    "brooch1", --伊蕾雅
    "brooch2",
    "brooch3",
    "brooch4",
    "brooch5",
    "brooch6",
    "brooch7",
    "brooch8",
    "brooch9",
    "moon_brooch",
    "star_brooch",
    "sora2amulet", --小穹
    "sorabowknot",
    "luckamulet", --经济学
    "wharang_amulet", --千年狐
    "ndnr_opalpreciousamulet", --富贵险中求
    "terraprisma", -- 光棱剑
    "aria_seaamulet", -- 艾丽娅
    "kemomimi_new_xianglian", -- 小狐狸
    "kemomimi_bell",
    "kemomimi_utr_xl",
    "philosopherstone", -- 托托莉
    "ov_amulet1", -- 和平鸽
    "ov_amulet2",
    "ov_bag2",
    "klaus_amulet", -- 永不妥协
    "ancient_amulet_red_demoneye",
    "oculet",
    "ancient_amulet_red",
    "jinshudaikou", -- 泰拉物品
    "zaishengshouhuan",
    "ruchongweijin"
}
local armors = {
    "armor_bramble", -- Bramble Husk
    "armordragonfly", -- Scalemail
    "armorgrass", -- Grass Suit
    "armormarble", -- Marble Suit
    "armorruins", -- Thulecite Suit
    "armor_sanity", -- Night Armour
    "armorskeleton", -- Bone Armor
    "armorwood", -- Log Suit
    "armor_medal_obsidian", -- 能力勋章
    "armor_blue_crystal", -- 能力勋章
    "golden_armor_mk", -- 神话书说
    "yangjian_armor", -- 神话书说
    "nz_damask", -- 神话书说
    "armorsiving", -- 神话书说
    "myth_iron_battlegear", -- 神话书说
    "xe_bag", -- 璇儿
    "icearmor", -- 玉子yuki
    "yuanzi_armor_lv1", -- 乃木園子
    "yuanzi_armor_lv2", -- 乃木園子
    "monvfu", -- 伊蕾娜
    "red_fairyskirt", -- 伊蕾娜
    "bule_fairyskirt", -- 伊蕾娜
    "sora2armor", -- 小穹
    "soraclothes", -- 小穹
    "purgatory_armor", -- 艾露莎
    "wharang_amulet_sack", -- 千年狐
    "ndnr_armorobsidian", -- 富贵
    "changchunjz", -- 战舰少女-长春的舰装
    "veneto_jz", -- 战舰少女-维内托的舰装
    "veneto_jzyf", -- 战舰少女-豪华意式舰装
    "fubuki_jz", -- 战舰少女-吹雪的舰装
    "uniform_firemoths", -- 希儿-逐火之蛾制服
    "lijie_jz", --战舰少女补给包-黎塞留的舰装
    "jianzhuang", --战舰少女补给包-欧根的舰装
    "fbk_jz", --战舰少女补给包-吹雪的舰装
    "lex_jz", --战舰少女补给包-列克星敦的舰装
    "yukikaze_jz", --战舰少女补给包-火炮鱼雷并联舰装
    "kahiro_dress", --kahiro学院袍
    "bf_nightmarearmor", --恶魔花护甲
    "bf_rosearmor", --玫瑰护甲
    "aria_armor_red", --艾丽娅·克莉丝塔露（RE）
    "aria_armor_blue", --艾丽娅·克莉丝塔露（RE）
    "aria_armor_green", --艾丽娅·克莉丝塔露（RE）
    "aria_armor_purple", --艾丽娅·克莉丝塔露（RE）
    "armorlimestone", --海难石灰岩套装
    "armorcactus", --海难仙人掌护甲
    "armorobsidian", --海难黑曜石护甲
    "armorseashell", --海难海套贝壳
    "suozi", --更多武器
    "bingxin", --更多武器
    "zhenfen", --更多武器
    "huomu", --更多武器
    "landun", --更多武器
    "riyan", --更多武器
    "kj", --更多武器
    "banjia", --更多武器
    "kemomiminewyifu", --小狐狸
    "featheredtunic", --熔炉
    "forge_woodarmor", --熔炉
    "jaggedarmor", --熔炉
    "silkenarmor", --熔炉
    "splintmail", --熔炉
    "steadfastarmor", --熔炉
    "armor_hpextraheavy", --熔炉
    "armor_hpdamager", --熔炉
    "armor_hprecharger", --熔炉
    "armor_hppetmastery", --熔炉
    "reedtunic", --熔炉
    "ov_armor", --和平鸽
    "armor_glassmail", --不妥协
    "feather_frock_fancy", --不妥协
    "feather_frock", --不妥协
    "xianrenzhangjia", --泰拉物品
    "nanguahujia", --泰拉物品
    "jinjia", --泰拉物品
    "seele_twinsdress", --希儿


    -- Armors: from the mod "More Armor" (<https://steamcommunity.com/sharedfiles/filedetails/?id=1153998909>)
    "armor_bone", -- Bone Suit
    "armor_stone", -- Stone Suit
}

-- 应该可以兼容其他模组
local function isBackpack(inst)
    if inst:HasTag("backpack") and inst:HasTag("_equippable") and inst:HasTag("_container")
            and not (inst.components.weapon)
    --and not (inst.components.fueled)
    --and not (inst.components.finiteuses)
    --and not (inst.components.perishable)
    then
        if inst.components.armor and not inst:HasTag("hide_percentage") then
            return false;
        end
        return true;
    end
    for _, v in ipairs(backpacks) do
        if inst.prefab == v then
            return true;
        end
    end
end

-- 只能精确兼容一下
local function isAmulet(inst)
    for _, v in ipairs(amulets) do
        if inst.prefab == v then
            return true;
        end
    end
end

local function isArmor(inst)
    for _, v in ipairs(armors) do
        if inst.prefab == v then
            return true;
        end
    end
end

env.AddPrefabPostInitAny(function(inst)
    if not TheWorld.ismastersim then
        return inst;
    end
    if isArmor(inst) then
        inst.components.equippable.equipslot = GLOBAL.EQUIPSLOTS.BODY;
    end
    if isBackpack(inst) then
        inst.components.equippable.equipslot = GLOBAL.EQUIPSLOTS.BACK or GLOBAL.EQUIPSLOTS.BODY;
    end
    if isAmulet(inst) then
        inst.components.equippable.equipslot = GLOBAL.EQUIPSLOTS.NECK or GLOBAL.EQUIPSLOTS.BODY;
    end
end)


