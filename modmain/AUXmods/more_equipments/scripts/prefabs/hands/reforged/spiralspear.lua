---
--- @author zsh in 2023/5/22 16:38
---

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
    local jump_fx = ReForged.COMMON_FNS.CreateFX("superjump_fx", nil, leaper)
    jump_fx:SetTarget(inst)
    inst.components.rechargeable:StartRecharge()
    inst.components.aoespell:OnSpellCast(leaper)
end

--------------------------------------------------------------------------
-- Attack Functions
--------------------------------------------------------------------------
local function OnAttack(inst, attacker, target)
    if not inst.components.weapon.isaltattacking then
        ReForged.COMMON_FNS.CreateFX("me_weaponsparks_fx", target, attacker)
    else
        ReForged.COMMON_FNS.CreateFX("me_forgespear_fx", target, attacker)
    end
end
--------------------------------------------------------------------------
-- Pristine Functions
--------------------------------------------------------------------------
local function PristineFN(inst)
    --aoeweapon_leap (from aoeweapon_leap component) added to pristine state for optimization
    ReForged.COMMON_FNS.AddTags(inst, "sharp", "pointy", "superjump", "aoeweapon_leap")
end
------------

local weapon_values = {
    name_override = "spear_lance",
    swap_strings = { "swap_spear_lance" },
    OnAttack = OnAttack,
    AOESpell = SkyLunge,
    pristine_fn = PristineFN,
}

local tuning_values = ReForged.REFORGED_TUNING.SPIRALSPEAR;

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

    ReForged.COMMON_FNS.EQUIPMENT.AOEWeaponLeapInit(inst, tuning_values.ALT_STIMULI, OnLeap);
    ------------

    inst:AddComponent("reforged_multithruster");
    ------------

    inst:AddComponent("finiteuses")
    inst.components.finiteuses:SetMaxUses(TUNING.SPEAR_USES)
    inst.components.finiteuses:SetUses(TUNING.SPEAR_USES)

    inst.components.finiteuses:SetMaxUses(200)
    inst.components.finiteuses:SetUses(200)

    inst.components.finiteuses:SetOnFinished(inst.Remove)

    return inst;
end

return ENV.ForgePrefab(prefab_name, fn, assets, prefabs, nil, tuning_values.ENTITY_TYPE, nil, "images/inventoryimages.xml", "spear_lance.tex", "swap_spear_lance", "common_hand")