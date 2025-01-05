---
--- @author zsh in 2023/1/21 0:06
---

local API = require("chang_mone.dsts.API");

local assets = {
    Asset("ANIM", "anim/seedpouch.zip"),
    Asset("ANIM", "anim/ui_krampusbag_2x8.zip"),
}

local prefabs = {
    "ash",
}

local function onequip(inst, owner)
    local skin_build = inst:GetSkinBuild()
    if skin_build ~= nil then
        owner:PushEvent("equipskinneditem", inst:GetSkinName())
        owner.AnimState:OverrideItemSkinSymbol("backpack", skin_build, "backpack", inst.GUID, "seedpouch")
        owner.AnimState:OverrideItemSkinSymbol("swap_body", skin_build, "swap_body", inst.GUID, "seedpouch")
    else
        owner.AnimState:OverrideSymbol("backpack", "seedpouch", "backpack")
        owner.AnimState:OverrideSymbol("swap_body", "seedpouch", "swap_body")
    end
    inst.components.container:Open(owner)
end

local function onunequip(inst, owner)
    owner.AnimState:ClearOverrideSymbol("backpack")
    owner.AnimState:ClearOverrideSymbol("swap_body")
    inst.components.container:Close(owner)
end

local function onequiptomodel(inst, owner)
    inst.components.container:Close(owner)
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.entity:AddMiniMapEntity()
    inst.MiniMapEntity:SetIcon("seedpouch.tex")

    inst.AnimState:SetBank("seedpouch")
    inst.AnimState:SetBuild("seedpouch")
    inst.AnimState:PlayAnimation("anim")

    inst.foleysound = "dontstarve/movement/foley/backpack"

    inst:AddTag("backpack")
    inst:AddTag("mone_seedpouch")
    inst:AddTag("waterproofer")

    local swap_data = { bank = "seedpouch", anim = "anim" }
    MakeInventoryFloatable(inst, "med", 0.125, 0.65, nil, nil, swap_data)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        local old_OnEntityReplicated = inst.OnEntityReplicated
        inst.OnEntityReplicated = function(inst)
            if old_OnEntityReplicated then
                old_OnEntityReplicated(inst)
            end
            if inst and inst.replica and inst.replica.container then
                inst.replica.container:WidgetSetup("mone_seedpouch");
            end
        end
        return inst
    end

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.cangoincontainer = false
    inst.components.inventoryitem:ChangeImageName("seedpouch");

    inst:AddComponent("equippable")
    inst.components.equippable.equipslot = EQUIPSLOTS.BODY
    inst.components.equippable:SetOnEquip(onequip)
    inst.components.equippable:SetOnUnequip(onunequip)
    inst.components.equippable:SetOnEquipToModel(onequiptomodel)
    --inst.components.equippable.walkspeedmult = 0.7

    inst:AddComponent("container")
    inst.components.container:WidgetSetup("mone_seedpouch")
    inst.components.container.skipclosesnd = true
    inst.components.container.skipopensnd = true
    --local old_onclosefn = inst.components.container.onclosefn;
    --inst.components.container.onclosefn = function(inst, data)
    --    if old_onclosefn then
    --        old_onclosefn(inst, data);
    --    end
    --
    --    API.arrangeContainer(inst);
    --end

    inst:AddComponent("preserver")
    inst.components.preserver:SetPerishRateMultiplier(0)

    inst:AddComponent("waterproofer")
    inst.components.waterproofer:SetEffectiveness(0.8)

    MakeHauntableLaunchAndDropFirstItem(inst)

    return inst
end

return Prefab("mone_seedpouch", fn, assets, prefabs)
