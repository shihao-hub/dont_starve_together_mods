---
--- @author zsh in 2023/2/13 10:30
---

-- 应用造林学
-- 完全重写，只是使用了贴图罢了
-- 阅读时减少 20%(TMP) 的理智
-- 阅读时执行逻辑：首先找到所有树根，然后铲除。接着检索周围所有预制物，塞到里面。塞不下了就停止。

local assets = {
    Asset("ANIM", "anim/books.zip"),
    --Asset("SOUND", "sound/common.fsb"),
}

local assets_fx = {
    Asset("ANIM", "anim/fx_books.zip"),
}

local MIE_SILVICULTURE_MUST_TAGS = { "_inventoryitem" }
local MIE_SILVICULTURE_CANT_TAGS = { "FX", "INLIMBO", "NOCLICK" }
local MIE_SILVICULTURE_ONEOF_TAGS = {}

local book_defs = {
    {
        name = "mie_book_silviculture",
        uses = TUNING.BOOK_USES_LARGE,
        read_sanity = -TUNING.SANITY_LARGE,
        peruse_sanity = -TUNING.SANITY_LARGE,
        fx_under = "roots",
        layer_sound = { frame = 17, sound = "wickerbottom_rework/book_spells/silviculture" },
        fn = function(inst, reader)

        end,
        perusefn = function(inst, reader)
            if reader.peruse_silviculture then
                reader.peruse_silviculture(reader)
            end
            reader.components.talker:Say(GetString(reader, "ANNOUNCE_READ_BOOK", "BOOK_SILVICULTURE"))
            return true
        end,
    },
}

local function MakeBook(def)
    local prefabs
    if def.deps ~= nil then
        prefabs = {}
        for i, v in ipairs(def.deps) do
            table.insert(prefabs, v)
        end
    end
    if def.fx ~= nil then
        prefabs = prefabs or {}
        table.insert(prefabs, def.fx)
    end
    if def.fxmount ~= nil then
        prefabs = prefabs or {}
        table.insert(prefabs, def.fxmount)
    end
    if def.fx_over ~= nil then
        prefabs = prefabs or {}
        local fx_over_prefab = "fx_" .. def.fx_over .. "_over_book"
        table.insert(prefabs, fx_over_prefab)
        table.insert(prefabs, fx_over_prefab .. "_mount")
    end
    if def.fx_under ~= nil then
        prefabs = prefabs or {}
        local fx_under_prefab = "fx_" .. def.fx_under .. "_under_book"
        table.insert(prefabs, fx_under_prefab)
        table.insert(prefabs, fx_under_prefab .. "_mount")
    end

    local function fn()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddNetwork()

        MakeInventoryPhysics(inst)

        inst.AnimState:SetBank("books")
        inst.AnimState:SetBuild("books")
        inst.AnimState:PlayAnimation(def.name)

        MakeInventoryFloatable(inst, "med", nil, 0.75)

        inst:AddTag("book")
        inst:AddTag("bookcabinet_item")
        inst:AddTag(def.name)

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end

        -----------------------------------

        inst.def = def
        inst.swap_build = "swap_books"
        inst.swap_prefix = def.name

        inst:AddComponent("inspectable")
        inst:AddComponent("book")
        inst.components.book:SetOnRead(def.fn)
        inst.components.book:SetOnPeruse(def.perusefn)
        inst.components.book:SetReadSanity(def.read_sanity)
        inst.components.book:SetPeruseSanity(def.peruse_sanity)
        inst.components.book:SetFx(def.fx, def.fxmount)

        inst:AddComponent("inventoryitem")

        inst:AddComponent("finiteuses")
        inst.components.finiteuses:SetMaxUses(def.uses)
        inst.components.finiteuses:SetUses(def.uses)
        inst.components.finiteuses:SetOnFinished(inst.Remove)

        inst:AddComponent("fuel")
        inst.components.fuel.fuelvalue = TUNING.MED_FUEL

        MakeSmallBurnable(inst, TUNING.MED_BURNTIME)
        MakeSmallPropagator(inst)

        --MakeHauntableLaunchOrChangePrefab(inst, TUNING.HAUNT_CHANCE_OFTEN, TUNING.HAUNT_CHANCE_OCCASIONAL, nil, nil, morphlist)
        MakeHauntableLaunch(inst)

        return inst
    end

    return Prefab(def.name, fn, assets, prefabs)
end

local function MakeFX(name, anim, ismount)
    if ismount then
        name = name .. "_mount"
        anim = anim .. "_mount"
    end

    local function fn()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddFollower()
        inst.entity:AddNetwork()

        inst:AddTag("FX")

        if ismount then
            inst.Transform:SetSixFaced() --match mounted player
        else
            inst.Transform:SetFourFaced() --match player
        end

        inst.AnimState:SetBank("fx_books")
        inst.AnimState:SetBuild("fx_books")
        inst.AnimState:PlayAnimation(anim)

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end

        inst:ListenForEvent("animover", inst.Remove)
        inst.persists = false

        return inst
    end

    return Prefab(name, fn, assets_fx)
end

local ret = {}
for i, v in ipairs(book_defs) do
    table.insert(ret, MakeBook(v))

    -- NOTE: 目前使用的原版内容，故该部分先保留
    if v.fx_over ~= nil then
        v.fx_over_prefab = "fx_" .. v.fx_over .. "_over_book"
        table.insert(ret, MakeFX(v.fx_over_prefab, v.fx_over, false))
        table.insert(ret, MakeFX(v.fx_over_prefab, v.fx_over, true))
    end
    if v.fx_under ~= nil then
        v.fx_under_prefab = "fx_" .. v.fx_under .. "_under_book"
        table.insert(ret, MakeFX(v.fx_under_prefab, v.fx_under, false))
        table.insert(ret, MakeFX(v.fx_under_prefab, v.fx_under, true))
    end
end
book_defs = nil -- klei 写这个的目的是不是想要快一点把这个表清理掉？
return unpack(ret)



