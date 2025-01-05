---
--- @author zsh in 2023/3/20 8:53
---

local hard_coded_data = {
    -- klei
    ["backpack"] = { "swap_backpack", "swap_body" };
    ["candybag"] = { "candybag", "swap_body" };
    ["icepack"] = { "swap_icepack", "swap_body" };
    ["krampus_sack"] = { "swap_krampus_sack", "swap_body" };
    ["piggyback"] = { "swap_piggyback", "swap_body" };
    ["seedpouch"] = { "seedpouch", "swap_body" };
    ["spicepack"] = { "swap_chefpack", "swap_body" };


    -- 其他
}

-- TEST
hard_coded_data = {};

local function hasPercent(inst)
    return inst.components.finiteuses
            or inst.components.fueled
            or inst.components.armor;
end

---判断是否是背包的目的是将 equipslot: EQUIPSLOTS.BODY 改为 equipslot: EQUIPSLOTS.BACK
local function isBack(inst)
    if not (inst.components.equippable
            and (inst.components.equippable.equipslot == EQUIPSLOTS.BODY
            or inst.components.equippable.equipslot == EQUIPSLOTS.BACK))
    then
        return false;
    end
    for k, v in pairs(hard_coded_data) do
        if inst.prefab == k then
            return true;
        end
    end
    return inst:HasTag("backpack")
            or (inst.components.container and not hasPercent(inst))
            or (inst.components.container and hasPercent(inst) and inst:HasTag("hide_percentage"));
end

return {
    hard_coded_data = hard_coded_data;
    isBack = isBack;
}