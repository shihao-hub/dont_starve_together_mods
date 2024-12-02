---
--- @author zsh in 2023/5/16 15:13
---

assert(getfenv(1) ~= _G, "ERROR: current environment is global environment.");

local function hasPercent(inst)
    return inst.components.finiteuses
            or inst.components.fueled
            or inst.components.armor;
end
------------------------------------------------------------------------------------------------------------
local BODYS = {}
-- 实现的时候先判定 IsBack/IsNeck，然后修改其他 equipslot，只要不是我判定的背包和护符，都是 Body 就行了！
local function IsBody(inst)
    local equipslot = inst.components.equippable and inst.components.equippable.equipslot;
    if null(equipslot) or equipslot ~= EQUIPSLOTS.BODY then
        return false;
    end
    return true;
end
------------------------------------------------------------------------------------------------------------
local BACKS = {
    -- 原版
    "backpack", "candybag", "icepack", "krampus_sack", "piggyback", "seedpouch", "spicepack",

};

local function IsBack(inst)
    local equipslot = inst.components.equippable and inst.components.equippable.equipslot;
    if null(equipslot) or equipslot ~= EQUIPSLOTS.BODY and equipslot ~= EQUIPSLOTS.BACK then
        return false;
    end
    -- 2023-05-17: 别动！被迫的！因为重物不在身体栏的话，需要处理一大堆东西，暂时先不管了。
    if inst:HasTag("heavy") then
        return false;
    end
    if table.contains(BACKS, inst.prefab) then
        return true;
    end
    return inst:HasTag("backpack")
            or (inst.components.container and not hasPercent(inst))
            or (inst.components.container and hasPercent(inst) and inst:HasTag("hide_percentage"));
end
------------------------------------------------------------------------------------------------------------
local NECKS = {
    -- 原版
    "amulet", "blueamulet", "purpleamulet", "orangeamulet", "greenamulet", "yellowamulet",
    -- 伊蕾娜
    "brooch1", "brooch2", "brooch4", "brooch5", "brooch6", "brooch7", "brooch8", "brooch9", "moon_brooch", "star_brooch",
    -- 小穹
    "sora2amulet", "sorabowknot",
    -- 经济学
    "luckamulet",
    -- 千年狐
    "wharang_amulet",
    -- 富贵险中求
    "ndnr_opalpreciousamulet",
    -- 光棱剑
    "terraprisma",
}

---- 原版的雕塑、棋子等
--for _, name_fragment in ipairs({
--    "pawn", "rook", "knight", "bishop", "muse", "formal", "hornucopia", "pipe", "deerclops", "bearger",
--    "moosegoose", "dragonfly", "clayhound", "claywarg", "butterfly", "anchor", "moon", "carrat", "crabking",
--    "malbatross", "toadstool", "stalker", "klaus", "beequeen", "antlion", "minotaur"
--}) do
--    table.insert(NECKS, "chesspiece_" .. name_fragment);
--    for _, name_fragment_fragment in ipairs({ "marble", "stone", "moonglass" }) do
--        table.insert(NECKS, "chesspiece_" .. name_fragment .. "_" .. name_fragment_fragment);
--    end
--end
--
---- 巨大作物
--for name, def in pairs(require("prefabs/farm_plant_defs").PLANT_DEFS) do
--    table.insert(NECKS, name .. "_oversized");
--    table.insert(NECKS, name .. "_oversized_waxed");
--end

local function IsNeck(inst)
    local equipslot = inst.components.equippable and inst.components.equippable.equipslot;
    if null(equipslot) or equipslot ~= EQUIPSLOTS.BODY and equipslot ~= EQUIPSLOTS.NECK then
        return false;
    end
    -- 2023-05-17: 别动！被迫的！因为重物不在身体栏的话，需要处理一大堆东西，暂时先不管了。
    if inst:HasTag("heavy") then
        return false;
    end
    if table.contains(NECKS, inst.prefab) then
        return true;
    end
    return inst.foleysound == "dontstarve/movement/foley/jewlery";
end
------------------------------------------------------------------------------------------------------------

return setmetatable({
    IsBody = IsBody;
    IsBack = IsBack;
    IsNeck = IsNeck;
    BODYS = BODYS;
    BACKS = BACKS;
    NECKS = NECKS;
}, { __call = function(t, ...)
    -- 呃，写着玩...
    local args = {};
    for k, v in pairs(t) do
        table.insert(args, v);
    end
    return unpack(args, 1, table.maxn(args));
end })