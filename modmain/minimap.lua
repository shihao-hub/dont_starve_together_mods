---
--- @author zsh in 2023/2/10 15:52
---

local minimap = {
    "images/minimapimages/icemaker.xml",
    "images/minimapimages/tall_pre.xml",
    "images/minimapimages/zx_granary_meat.xml",
    "images/minimapimages/zx_granary_veggie.xml",
    "images/minimapimages/water_bucket.xml",
    "images/minimapimages/tap_minimapicons.xml",

    "images/inventoryimages/tap_buildingimages.xml",

    "images/inventoryimages/self_use/map_icons/myth_granary.xml",
    "images/inventoryimages/self_use/map_icons/myth_well.xml",
    "images/inventoryimages/self_use/map_icons/myth_yjp.xml",
    "images/inventoryimages/self_use/map_icons/myth_cash_tree_ground.xml",

    -- 这样不好！
    "images/inventoryimages1.xml",
}

for _, v in ipairs(minimap) do
    AddMinimapAtlas(v);
    table.insert(Assets, Asset("ATLAS", v));
end