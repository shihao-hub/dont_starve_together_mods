---
--- @author zsh in 2023/5/22 16:38
---

local name = "spiralspear";

local prefab_name = "me_spiralspear";

local assets = {
    Asset("ANIM", "anim/spear_lance.zip"),
    Asset("ANIM", "anim/swap_spear_lance.zip"),
}

local prefabs = {
    "reticuleaoesmall",
    "reticuleaoesmallping",
    "reticuleaoesmallhostiletarget",

    "me_weaponsparks_fx",
    "me_forgespear_fx",

    "superjump_fx",

    --"splash_lavafx", -- 这个特效先不管，和露西斧有关的特效
}
------------

local CreateFX = ReForged.COMMON_FNS.CreateFX;
local MergeTable = ReForged.G.MergeTable;
local ApplyBuild = ReForged.COMMON_FNS.ApplyBuild;

local BasicEntityInit = ReForged.COMMON_FNS.EQUIPMENT.BasicEntityInit;

---------------------------
-- Directional Reticules --
---------------------------
local DirectionalReticuleInit = ReForged.COMMON_FNS.EQUIPMENT.DirectionalReticuleInit;
-------------------
-- AOE Reticules --
-------------------
local AOEReticuleInit = ReForged.COMMON_FNS.EQUIPMENT.AOEReticuleInit;
------------------------
-- AOESpell Functions --
------------------------
local AOESpellInit = ReForged.COMMON_FNS.EQUIPMENT.AOESpellInit;
----------------------------
-- Rechargeable Functions --
----------------------------
local RechargeableInit = ReForged.COMMON_FNS.EQUIPMENT.RechargeableInit;
----------------------
-- Weapon Functions --
----------------------
local WeaponInit = ReForged.COMMON_FNS.EQUIPMENT.WeaponInit;
------------------------
-- ItemType Functions --
------------------------
local ItemTypeInit = ReForged.COMMON_FNS.EQUIPMENT.ItemTypeInit;
-----------------------------
-- InventoryItem Functions --
-----------------------------
local InventoryItemInit = ReForged.COMMON_FNS.EQUIPMENT.InventoryItemInit;
--------------------------
-- Equippable Functions --
--------------------------
local EquippableInit = ReForged.COMMON_FNS.EQUIPMENT.EquippableInit;

------------------------
-- Weapon Prefab Init --
------------------------
--bank, build, anim, nameoverride, image_name, swap_strings, weapon_values, tuning_values
local function CommonWeaponFN(bank, build, weapon_values, tuning_values)
    local inst = BasicEntityInit(bank, build, weapon_values.anim, { pristine_fn = function(inst)
        MakeInventoryPhysics(inst);
        ------------

        -- 这个就先算了，不知道是干嘛的，是不是就是给预制物改名用的？
        --inst.nameoverride = weapon_values.name_override;
        ------------

        -- rechargeable (from rechargeable component) added to pristine state for optimization
        inst:AddTag("rechargeable");
        ------------

        if weapon_values.pristine_fn then
            weapon_values.pristine_fn(inst)
        end
    end });
    ------------

    local reticule = tuning_values.RET or {}
    if reticule.TYPE == "directional" then
        DirectionalReticuleInit(inst, reticule.LENGTH, reticule.PREFAB, reticule.PING_PREFAB, reticule.ALWAYS_VALID)
    elseif reticule.TYPE == "aoe" then
        AOEReticuleInit(inst, reticule.LENGTH, reticule.PREFAB, reticule.PING_PREFAB, reticule.VALID_COLOR, reticule.VALID_COLORS, reticule.INVALID_COLOR)
    end

    ------------

    if not TheWorld.ismastersim then
        return inst;
    end
    ------------

    AOESpellInit(inst, weapon_values.AOESpell, tuning_values.SPELL_TYPES)
    ------------

    RechargeableInit(inst, tuning_values)
    ------------

    WeaponInit(inst, weapon_values, tuning_values)
    ------------

    ItemTypeInit(inst, tuning_values.ITEM_TYPE)
    ------------

    inst:AddComponent("inspectable")
    ------------

    InventoryItemInit(inst, weapon_values.image_name or bank)
    ------------

    EquippableInit(inst, weapon_values.type or "hand", weapon_values.onequip_fn, weapon_values.onunequip_fn, unpack(weapon_values.swap_strings))
    ------------

    return inst;
end
------------





--------------------------------------------------------------------------
-- Ability Functions
--------------------------------------------------------------------------
local function SkyLunge(inst, caster, pos)
    caster:PushEvent("combat_superjump", {
        targetpos = pos,
        weapon = inst
    })
end

local function OnLeap(inst, leaper)
    local jump_fx = CreateFX("superjump_fx", nil, leaper)
    jump_fx:SetTarget(inst)
    inst.components.rechargeable:StartRecharge()
    inst.components.aoespell:OnSpellCast(leaper)
end

--------------------------------------------------------------------------
-- Attack Functions
--------------------------------------------------------------------------
local function OnAttack(inst, attacker, target)
    if not inst.components.weapon.isaltattacking then
        CreateFX("me_weaponsparks_fx", target, attacker)
    else
        CreateFX("me_forgespear_fx", target, attacker)
    end
end
--------------------------------------------------------------------------
-- Pristine Functions
--------------------------------------------------------------------------
local function AddTags(inst, ...)
    for _, tag in pairs({ ... }) do
        inst:AddTag(tag)
    end
end

local function PristineFN(inst)
    --aoeweapon_leap (from aoeweapon_leap component) added to pristine state for optimization
    AddTags(inst, "sharp", "pointy", "superjump", "aoeweapon_leap")
end
------------

local weapon_values = {
    name_override = "spear_lance",
    swap_strings = { "swap_spear_lance" },
    OnAttack = OnAttack,
    AOESpell = SkyLunge,
    pristine_fn = PristineFN,
}

local tuning_values = {
    DAMAGE = 34, -- 30
    ALT_DAMAGE = 75,
    ALT_RANGE = 16,
    ALT_RADIUS = 2.05, -- TODO change to 2 and test
    ALT_STIMULI = "explosive",
    COOLDOWN = 0, -- 12
    DAMAGE_TYPE = 1, -- Physical
    ITEM_TYPE = "melees",
    ENTITY_TYPE = "WEAPONS",
    WEIGHT = 3,
    RET = {
        DATA = { "aoesmallhostiletarget", 1 },
        PREFAB = "reticuleaoesmall",
        PING_PREFAB = "reticuleaoesmallping",
        TYPE = "aoe",
        LENGTH = 5,
    },
}
------------

local function AOEWeaponLeapInit(inst, stimuli, on_leap_fn)
    inst:AddComponent("reforged_aoeweapon_leap")
    inst.components.aoeweapon_leap = inst.components.reforged_aoeweapon_leap;

    inst.components.aoeweapon_leap:SetStimuli(stimuli)
    inst.components.aoeweapon_leap:SetOnLeapFn(on_leap_fn)
end
------------

local function Expansion(inst)
    inst:AddComponent("finiteuses")
    inst.components.finiteuses:SetMaxUses(TUNING.SPEAR_USES)
    inst.components.finiteuses:SetUses(TUNING.SPEAR_USES)

    inst.components.finiteuses:SetOnFinished(inst.Remove)
end
------------

local function fn()
    local inst = ReForged.COMMON_FNS.EQUIPMENT.CommonWeaponFN("spear_lance", nil, weapon_values, tuning_values);
    ------------

    inst.components.aoetargeting:SetRange(tuning_values.ALT_RANGE);
    ------------

    if not TheWorld.ismastersim then
        return inst;
    end
    ------------

    AOEWeaponLeapInit(inst, tuning_values.ALT_STIMULI, OnLeap);
    ------------

    inst:AddComponent("reforged_multithruster");
    ------------

    Expansion(inst);
    ------------

    return inst;
end

return ENV.ForgePrefab(prefab_name, fn, assets, prefabs, nil, tuning_values.ENTITY_TYPE, nil, "images/inventoryimages.xml", "spear_lance.tex", "swap_spear_lance", "common_hand")