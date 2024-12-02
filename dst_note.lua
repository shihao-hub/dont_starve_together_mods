
-- 添加物品栏图片
inst.components.inventoryitem.imagename = "seasack"
inst.components.inventoryitem.atlasname = "images/DLC0003/inventoryimages.xml"

inst.components.equippable.onequipfn = fn
inst.components.equippable.onunequipfn = fn

if not TheWorld.ismastersim then
    return inst
end