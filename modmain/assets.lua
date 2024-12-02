---
--- @author zsh in 2023/4/5 0:18
---

env.Assets = {
    Asset("ANIM", "anim/my_ui_cookpot_1x1.zip"),

    Asset("ANIM", "anim/my_chest_ui_4x4.zip"),
    Asset("ANIM", "anim/my_chest_ui_5x5.zip"),
    Asset("ANIM", "anim/my_chest_ui_6x6.zip"),

    --Asset("ANIM", "anim/ui_revolvedmoonlight_4x3.zip"), -- 2023-08-01：Tried to add build [ui_revolvedmoonlight_4x3] from file [../mods/MoreItems/anim/ui_revolvedmoonlight_4x3.zip] but we've already added a build with that name!

    -- 动画做不好。。。关闭动画有问题，算了。肯定是因为要做动画，再说吧！
    --Asset("ANIM", "anim/changx_chest_4x4.zip"),
    --Asset("ANIM", "anim/changx_chest_5x5.zip"),
    --Asset("ANIM", "anim/changx_chest_5x10.zip"),

    Asset("ANIM", "anim/big_box_ui_120.zip"),

    Asset("ANIM", "anim/ui_bigbag_3x8.zip"),

    Asset("ANIM", "anim/ui_chest_4x5.zip"),
    Asset("ANIM", "anim/ui_chest_5x8.zip"),
    Asset("ANIM", "anim/ui_chest_5x12.zip"),
    Asset("ANIM", "anim/ui_chest_5x16.zip"),

    Asset("ANIM", "anim/mone_seedpouch.zip"),

    Asset("IMAGE", "images/inventoryimages/mone_minotaurchest.tex"),
    Asset("ATLAS", "images/inventoryimages/mone_minotaurchest.xml"),

    -- TEMP：看来我的 images 也得加个 mod 名用来区分了！！！
    Asset("IMAGE", "images/uiimages/back.tex"),
    Asset("ATLAS", "images/uiimages/back.xml"),
    Asset("IMAGE", "images/uiimages/neck.tex"),
    Asset("ATLAS", "images/uiimages/neck.xml"),

    Asset("IMAGE", "images/uiimages/krampus_sack_bg.tex"),
    Asset("ATLAS", "images/uiimages/krampus_sack_bg.xml"),

    Asset("IMAGE", "images/uiimages/fish_slot.tex"),
    Asset("ATLAS", "images/uiimages/fish_slot.xml"),

    Asset("IMAGE", "images/DLC/inventoryimages.tex"),
    Asset("ATLAS", "images/DLC/inventoryimages.xml"),
    Asset("IMAGE", "images/DLC/inventoryimages1.tex"),
    Asset("ATLAS", "images/DLC/inventoryimages1.xml"),
    Asset("IMAGE", "images/DLC/inventoryimages2.tex"),
    Asset("ATLAS", "images/DLC/inventoryimages2.xml"),
    Asset("IMAGE", "images/DLC/inventoryimages3.tex"),
    Asset("ATLAS", "images/DLC/inventoryimages3.xml"),

    Asset("IMAGE", "images/DLC0000/inventoryimages.tex"),
    Asset("ATLAS", "images/DLC0000/inventoryimages.xml"),

    Asset("IMAGE", "images/DLC0001/inventoryimages.tex"),
    Asset("ATLAS", "images/DLC0001/inventoryimages.xml"),

    Asset("IMAGE", "images/DLC0002/inventoryimages.tex"),
    Asset("ATLAS", "images/DLC0002/inventoryimages.xml"),

    Asset("IMAGE", "images/DLC0003/inventoryimages.tex"),
    Asset("ATLAS", "images/DLC0003/inventoryimages.xml"),
    Asset("IMAGE", "images/DLC0003/inventoryimages_2.tex"),
    Asset("ATLAS", "images/DLC0003/inventoryimages_2.xml"),
}