---
--- @author zsh in 2023/4/23 14:39
---

-- 溺水或者死亡的时候，该物品不掉落 + 猴子不会偷

local KEEP_ON_ITEMS = {
    "mone_storage_bag", "mone_piggybag", "mone_tool_bag",
    "mone_backpack", "mone_candybag", "mone_icepack", "mone_piggyback",
    "mone_waterchest_inv",
    "mone_wathgrithr_box", "mone_wanda_box",

    "mie_book_silviculture", "mie_book_horticulture",

    "mone_seasack", "mone_nightspace_cape",
    "mone_seedpouch",

    "mone_brainjelly", "mone_bathat",

    "mone_pheromonestone", "mone_pheromonestone2",

    "mie_bundle_state1", "mie_bundle_state2",
}

for _, name in ipairs(KEEP_ON_ITEMS) do
    env.AddPrefabPostInit(name, function(inst)
        if not TheWorld.ismastersim then
            return inst;
        end
        if inst.components.inventoryitem == nil then
            return inst;
        end
        inst:AddTag("nosteal");
        inst.components.inventoryitem.keepondrown = true;
        inst.components.inventoryitem.keepondeath = true;
    end)
end

local KEEP_ON_ITEMS_TAGS = {
    "mie_inf_food", "mie_inf_roughage","mi_nfs_food_tag"
}

env.AddPrefabPostInitAny(function(inst)
    if not TheWorld.ismastersim then
        return inst;
    end
    if inst.components.inventoryitem == nil then
        return inst;
    end
    for _, tag in ipairs(KEEP_ON_ITEMS_TAGS) do
        if inst:HasTag(tag) then
            inst:AddTag("nosteal");
            inst.components.inventoryitem.keepondrown = true;
            inst.components.inventoryitem.keepondeath = true;
            break ;
        end
    end
end)