---
--- @author zsh in 2023/5/20 19:43
---

local prefab_name = "me_pithpike";

local assets = {
    Asset("ANIM", "anim/spear_gungnir.zip"),
    Asset("ANIM", "anim/swap_spear_gungnir.zip"),
}

local prefabs = {
    "reticuleline",
    "reticulelineping",
    "spear_gungnir_lungefx",
    "me_weaponsparks_fx",
    "firehit",
}
------------

local tuning_values = ReForged.REFORGED_TUNING.PITHPIKE

--------------------------------------------------------------------------
-- Attack Functions
--------------------------------------------------------------------------
-- TODO targets glow yellow on hit for a few frames, does ours do that? this might apply to other attacks as well
local function OnAttack(inst, attacker, target)
    if not inst.components.weapon.isaltattacking then
        ReForged.COMMON_FNS.CreateFX("me_weaponsparks_fx", target, attacker)
    else
        ReForged.COMMON_FNS.CreateFX("me_forgespear_fx", target, attacker)
        ReForged.COMMON_FNS.EQUIPMENT.FlipTarget(attacker, target)
    end
end
--------------------------------------------------------------------------
-- Ability Functions
--------------------------------------------------------------------------
local function PyrePoker(inst, caster, pos)
    caster:PushEvent("combat_lunge", {
        targetpos = pos,
        weapon = inst
    })
end

local function OnLunge(inst, lunger)
    inst.components.rechargeable:StartRecharge()
    inst.components.aoespell:OnSpellCast(lunger)
end
--------------------------------------------------------------------------
-- Pristine Functions
--------------------------------------------------------------------------
local function PristineFN(inst)
    -- aoeweapon_lunge (from aoeweapon_lunge component) added to pristine state for optimization
    ReForged.COMMON_FNS.AddTags(inst, "sharp", "pointy", "aoeweapon_lunge")
end
--------------------------------------------------------------------------

local weapon_values = {
    name_override = "spear_gungnir",
    swap_strings = { "swap_spear_gungnir" },
    OnAttack = OnAttack,
    AOESpell = PyrePoker,
    pristine_fn = PristineFN,
}
------------

local function fn()
    local inst = ReForged.COMMON_FNS.EQUIPMENT.CommonWeaponFN("spear_gungnir", nil, weapon_values, tuning_values)
    ------------

    if not TheWorld.ismastersim then
        return inst
    end
    ------------

    ReForged.COMMON_FNS.EQUIPMENT.AOEWeaponLungeInit(inst, tuning_values.ALT_WIDTH, tuning_values.ALT_STIMULI, OnLunge)
    ------------

    inst:AddComponent("finiteuses")
    inst.components.finiteuses:SetMaxUses(TUNING.SPEAR_USES)
    inst.components.finiteuses:SetUses(TUNING.SPEAR_USES)

    inst.components.finiteuses:SetMaxUses(200)
    inst.components.finiteuses:SetUses(200)

    inst.components.finiteuses:SetOnFinished(inst.Remove)


    return inst
end

return ENV.ForgePrefab(prefab_name, fn, assets, prefabs, nil, tuning_values.ENTITY_TYPE, nil, "images/inventoryimages.xml", "spear_gungnir.tex", "swap_spear_gungnir", "common_hand")