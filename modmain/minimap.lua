---
--- @author zsh in 2023/1/9 2:19
---


local minimap = {
    "images/minimapimages/ndnr_armorvortexcloak.xml",
    "images/minimapimages/mone_piggybag.xml",
    "images/minimapimages/garlic_bat.xml",
    "images/minimapimages/mone_wathgrithr_box.xml",
    "images/minimapimages/mone_wanda_box.xml",

    "images/inventoryimages/mandrake_backpack.xml",
    -- DLC0002
    "images/DLC0002/inventoryimages.xml",
    -- DLC0003
    "images/DLC0003/inventoryimages.xml",

    "images/modules/architect_pack/tap_minimapicons.xml",
    "images/modules/architect_pack/tap_buildingimages.xml",

    -- TEMP：这样不太好，之后在prefabs里直接用Asset("MINIMAP_IMAGE","picture_name")，但是这个图片记得导入！
    "images/inventoryimages.xml",
    "images/inventoryimages2.xml",

    "images/DLC/inventoryimages.xml",
}

for _, v in ipairs(minimap) do
    env.AddMinimapAtlas(v);
    table.insert(env.Assets, Asset("ATLAS", v));
end