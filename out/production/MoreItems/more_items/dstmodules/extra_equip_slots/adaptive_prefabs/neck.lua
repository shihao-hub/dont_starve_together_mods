---
--- @author zsh in 2023/3/20 8:53
---

---@type table
local hard_coded_data = {
    -- klei
    ["amulet"] = { "torso_amulets", "redamulet" };
    ["blueamulet"] = { "torso_amulets", "blueamulet" };
    ["purpleamulet"] = { "torso_amulets", "purpleamulet" };
    ["orangeamulet"] = { "torso_amulets", "orangeamulet" };
    ["greenamulet"] = { "torso_amulets", "greenamulet" };
    ["yellowamulet"] = { "torso_amulets", "yellowamulet" };

    -- 伊蕾娜
    ["brooch1"] = { "torso_amulets", "brooch1" };
    ["brooch2"] = { "torso_amulets", "brooch2" };
    ["brooch4"] = { "torso_amulets", "brooch4" };
    ["brooch5"] = { "torso_amulets", "brooch5" };
    ["brooch6"] = { "torso_amulets", "brooch6" };
    ["brooch7"] = { "torso_amulets", "brooch7" };
    ["brooch8"] = { "torso_amulets", "brooch8" };
    ["brooch9"] = { "torso_amulets", "brooch9" };
    ["moon_brooch"] = { "torso_amulets", "moon_brooch" };
    ["star_brooch"] = { "torso_amulets", "star_brooch" };

    -- 小穹
    ["sora2amulet"] = { "torso_amulets", "sora2amulet" };
    ["sorabowknot"] = { "torso_amulets", "sorabowknot" };

    -- 经济学
    ["luckamulet"] = { "torso_amulets", "luckamulet" };

    -- 千年狐
    ["wharang_amulet"] = { "torso_amulets", "wharang_amulet" };

    -- 富贵险中求
    ["ndnr_opalpreciousamulet"] = { "torso_amulets", "ndnr_opalpreciousamulet" };

    -- 光棱剑
    ["terraprisma"] = { "torso_amulets", "terraprisma" };

    -- 其他
}

-- 棋子
for _, p in ipairs({
    "pawn", "rook", "knight", "bishop", "muse", "formal", "hornucopia", "pipe", "deerclops", "bearger",
    "moosegoose", "dragonfly", "clayhound", "claywarg", "butterfly", "anchor", "moon", "carrat", "crabking",
    "malbatross", "toadstool", "stalker", "klaus", "beequeen", "antlion", "minotaur"
}) do
    hard_coded_data["chesspiece_" .. p] = { "swap_chesspiece_" .. p, "swap_body" };
    for _, m in ipairs({ "marble", "stone", "moonglass" }) do
        hard_coded_data["chesspiece_" .. p .. "_" .. m] = { "swap_chesspiece_" .. p .. "_" .. m, "swap_body" };
    end
end

-- 巨型作物
for name, def in pairs(require("prefabs/farm_plant_defs").PLANT_DEFS) do
    local build_symbol = { def.build or "farm_plant_" .. name, "swap_body" }
    hard_coded_data[name .. "_oversized"] = build_symbol
    hard_coded_data[name .. "_oversized_waxed"] = build_symbol
end


-- TEST
hard_coded_data = {};

local function isNeck(inst)
    if not (inst.components.equippable
            and (inst.components.equippable.equipslot == EQUIPSLOTS.BODY
            or inst.components.equippable.equipslot == EQUIPSLOTS.NECK))
    then
        return false;
    end
    for k, v in pairs(hard_coded_data) do
        if inst.prefab == k then
            return true;
        end
    end
    return inst.foleysound and inst.foleysound == "dontstarve/movement/foley/jewlery";
end

return {
    hard_coded_data = hard_coded_data;
    isNeck = isNeck;
}