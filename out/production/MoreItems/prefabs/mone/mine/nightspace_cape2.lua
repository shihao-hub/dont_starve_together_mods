---
--- @author zsh in 2023/1/10 2:11
---

local assets = {
    Asset("ANIM", "anim/ndnr_armor_vortex_cloak.zip"),
    Asset("IMAGE", "images/inventoryimages/ndnr_armorvortexcloak.tex"),
    Asset("ATLAS", "images/inventoryimages/ndnr_armorvortexcloak.xml"),
}

local prefabs = {}

local SHIELD_DURATION = 10 * FRAMES
local SHIELD_VARIATIONS = 3
local MAIN_SHIELD_CD = 1.2

local RESISTANCES = {
    "_combat",
    "explosive",
    "quakedebris",
    "caveindebris",
    "trapdamage",
}

for j = 0, 3, 3 do
    for i = 1, SHIELD_VARIATIONS do
        table.insert(prefabs, "shadow_shield" .. tostring(j + i))
    end
end

local function PickShield(inst)
    local t = GetTime()
    local flipoffset = math.random() < .5 and SHIELD_VARIATIONS or 0

    --variation 3 is the main shield
    local dt = t - inst.lastmainshield
    if dt >= MAIN_SHIELD_CD then
        inst.lastmainshield = t
        return flipoffset + 3
    end

    local rnd = math.random()
    if rnd < dt / MAIN_SHIELD_CD then
        inst.lastmainshield = t
        return flipoffset + 3
    end

    return flipoffset + (rnd < dt / (MAIN_SHIELD_CD * 2) + .5 and 2 or 1)
end

local function OnShieldOver(inst, OnResistDamage)
    inst.task = nil
    for i, v in ipairs(RESISTANCES) do
        inst.components.resistance:RemoveResistance(v)
    end
    inst.components.resistance:SetOnResistDamageFn(OnResistDamage)
end

local function OnResistDamage(inst)
    --, damage)
    local owner = inst.components.inventoryitem:GetGrandOwner() or inst
    local fx = SpawnPrefab("shadow_shield" .. tostring(PickShield(inst)))
    fx.entity:SetParent(owner.entity)

    if inst.task ~= nil then
        inst.task:Cancel()
    end
    inst.task = inst:DoTaskInTime(SHIELD_DURATION, OnShieldOver, OnResistDamage)
    inst.components.resistance:SetOnResistDamageFn(nil)

    inst.components.fueled:DoDelta(-TUNING.MED_FUEL)
    if inst.components.cooldown.onchargedfn ~= nil then
        inst.components.cooldown:StartCharging()
    end

    if inst.components.rechargeable then
        inst.components.rechargeable:StartRecharging()
    end
end

local function ShouldResistFn(inst)
    if not inst.components.equippable:IsEquipped() then
        return false
    end
    local owner = inst.components.inventoryitem.owner
    return owner ~= nil
            and not (owner.components.inventory ~= nil and
            owner.components.inventory:EquipHasTag("forcefield"))
end

local function OnChargedFn(inst)
    if inst.task ~= nil then
        inst.task:Cancel()
        inst.task = nil
        inst.components.resistance:SetOnResistDamageFn(OnResistDamage)
    end
    for i, v in ipairs(RESISTANCES) do
        inst.components.resistance:AddResistance(v)
    end
end

local function nofuel(inst)
    inst.components.cooldown.onchargedfn = nil
    inst.components.cooldown:FinishCharging()
end

local function CLIENT_PlayFuelSound(inst)
    local parent = inst.entity:GetParent()
    local container = parent ~= nil and (parent.replica.inventory or parent.replica.container) or nil
    if container ~= nil and container:IsOpenedBy(ThePlayer) then
        TheFocalPoint.SoundEmitter:PlaySound("dontstarve/common/nightmareAddFuel")
    end
end

local function SERVER_PlayFuelSound(inst)
    local owner = inst.components.inventoryitem.owner
    if owner == nil then
        inst.SoundEmitter:PlaySound("dontstarve/common/nightmareAddFuel")
    elseif inst.components.equippable:IsEquipped() and owner.SoundEmitter ~= nil then
        owner.SoundEmitter:PlaySound("dontstarve/common/nightmareAddFuel")
    else
        inst.playfuelsound:push()
        --Dedicated server does not need to trigger sfx
        if not TheNet:IsDedicated() then
            CLIENT_PlayFuelSound(inst)
        end
    end
end

local function ontakefuel(inst)
    if inst.components.equippable:IsEquipped() and
            not inst.components.fueled:IsEmpty() and
            inst.components.cooldown.onchargedfn == nil then
        inst.components.cooldown.onchargedfn = OnChargedFn
        inst.components.cooldown:StartCharging(TUNING.ARMOR_SKELETON_FIRST_COOLDOWN)
    end
    SERVER_PlayFuelSound(inst)
end

local function onequip(inst, owner)

    owner.AnimState:OverrideSymbol("swap_body", "ndnr_armor_vortex_cloak", "swap_body")

    inst.lastmainshield = 0
    if not inst.components.fueled:IsEmpty() then
        inst.components.cooldown.onchargedfn = OnChargedFn
        inst.components.cooldown:StartCharging(math.max(TUNING.ARMOR_SKELETON_FIRST_COOLDOWN, inst.components.cooldown:GetTimeToCharged()))
    end

    inst.mone_owner = owner;

    if inst.components.container then
        inst.components.container:Open(owner);
    end
end

local function onunequip(inst, owner)
    owner.AnimState:ClearOverrideSymbol("swap_body")
    inst.components.cooldown.onchargedfn = nil
    if inst.task ~= nil then
        inst.task:Cancel()
        inst.task = nil
        inst.components.resistance:SetOnResistDamageFn(OnResistDamage)
    end
    for i, v in ipairs(RESISTANCES) do
        inst.components.resistance:RemoveResistance(v)
    end

    local skin_build = inst:GetSkinBuild()
    if skin_build ~= nil then
        owner:PushEvent("unequipskinneditem", inst:GetSkinName())
    end

    if inst.components.container then
        inst.components.container:Close(owner);
    end
end

local function onequiptomodel(inst, owner, from_ground)
    inst.components.cooldown.onchargedfn = nil

    if inst.task ~= nil then
        inst.task:Cancel()
        inst.task = nil
        inst.components.resistance:SetOnResistDamageFn(OnResistDamage)
    end

    for i, v in ipairs(RESISTANCES) do
        inst.components.resistance:RemoveResistance(v)
    end
end

local function GetShadowLevel(inst)
    return not inst.components.fueled:IsEmpty() and TUNING.ARMOR_SKELETON_SHADOW_LEVEL or 0
end

local function ondropped(inst)
    if inst.components.container then
        inst.components.container:Close()
    end
end

local fns = {};


local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()
    inst.entity:AddSoundEmitter()

    MakeInventoryPhysics(inst)

    inst.entity:AddMiniMapEntity()
    inst.MiniMapEntity:SetIcon("ndnr_armorvortexcloak.tex")

    inst.AnimState:SetBank("ndnr_armor_vortex_cloak")
    inst.AnimState:SetBuild("ndnr_armor_vortex_cloak")
    inst.AnimState:PlayAnimation("anim")

    inst:AddTag("fossil")

    inst:AddTag("mone_nightspace_cape")
    inst:AddTag("backpack")

    --shadowlevel (from shadowlevel component) added to pristine state for optimization
    inst:AddTag("shadowlevel")

    inst.playfuelsound = net_event(inst.GUID, "armorskeleton.playfuelsound")

    MakeInventoryFloatable(inst);

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        --delayed because we don't want any old events
        inst:DoTaskInTime(0, inst.ListenForEvent, "armorskeleton.playfuelsound", CLIENT_PlayFuelSound)

        local old_OnEntityReplicated = inst.OnEntityReplicated
        inst.OnEntityReplicated = function(inst)
            if old_OnEntityReplicated then
                old_OnEntityReplicated(inst)
            end
            if inst and inst.replica and inst.replica.container then
                inst.replica.container:WidgetSetup("mone_nightspace_cape");
            end
        end
        return inst
    end

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.cangoincontainer = false;
    inst.components.inventoryitem.imagename = "ndnr_armorvortexcloak";
    inst.components.inventoryitem.atlasname = "images/inventoryimages/ndnr_armorvortexcloak.xml";
    inst.components.inventoryitem:SetOnDroppedFn(ondropped);

    inst:AddComponent("container")
    inst.components.container:WidgetSetup("mone_nightspace_cape");
    inst.components.container.skipclosesnd = true;
    inst.components.container.skipopensnd = true;

    inst:AddComponent("fueled")
    inst.components.fueled.fueltype = FUELTYPE.NIGHTMARE
    inst.components.fueled:InitializeFuelLevel(4 * TUNING.LARGE_FUEL)
    inst.components.fueled:SetDepletedFn(nofuel)
    inst.components.fueled:SetTakeFuelFn(ontakefuel)
    inst.components.fueled.accepting = true

    inst:AddComponent("equippable")
    inst.components.equippable.equipslot = EQUIPSLOTS.BODY
    inst.components.equippable:SetOnEquip(onequip)
    inst.components.equippable:SetOnUnequip(onunequip)
    inst.components.equippable:SetOnEquipToModel(onequiptomodel)

    inst:AddComponent("resistance")
    inst.components.resistance:SetShouldResistFn(ShouldResistFn)
    inst.components.resistance:SetOnResistDamageFn(OnResistDamage)

    inst:AddComponent("cooldown")
    inst.components.cooldown.cooldown_duration = TUNING.ARMOR_SKELETON_COOLDOWN

    inst:AddTag("rechargeable"); -- emm，全靠这个标签
    inst:AddComponent("mone_rechargeable");
    inst.components.rechargeable = inst.components.mone_rechargeable;
    inst.components.rechargeable:SetRechargeTime(TUNING.ARMOR_SKELETON_COOLDOWN);
    inst:RegisterComponentActions("rechargeable");

    inst:AddComponent("shadowlevel")
    inst.components.shadowlevel:SetDefaultLevel(TUNING.ARMOR_SKELETON_SHADOW_LEVEL)
    inst.components.shadowlevel:SetLevelFn(GetShadowLevel)

    MakeHauntableLaunch(inst)

    inst.task = nil;
    inst.lastmainshield = 0;

    return inst
end

return Prefab("mone_nightspace_cape", fn, assets, prefabs)
