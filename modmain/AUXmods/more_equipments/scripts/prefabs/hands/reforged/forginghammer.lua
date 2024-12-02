---
--- @author zsh in 2023/5/20 19:43
---

local prefab_name = "me_forginghammer";


local assets = {
    Asset("ANIM", "anim/hammer_mjolnir.zip"),
    Asset("ANIM", "anim/swap_hammer_mjolnir.zip"),
}

local prefabs = {
    "me_forginghammer_crackle_fx",
    "me_forgeelectricute_fx",

    "reticuleaoe",
    "reticuleaoeping",
    "reticuleaoehostiletarget",
    "me_weaponsparks_fx",
}

local tuning_values = ReForged.REFORGED_TUNING.FORGINGHAMMER;

--------------------------------------------------------------------------
-- Ability Functions
--------------------------------------------------------------------------
local function AnvilStrike(inst, caster, pos)
    caster:PushEvent("combat_leap", {targetpos = pos, weapon = inst})
end

local function OnLeap(inst, leaper, starting_pos, target_pos)
    ReForged.COMMON_FNS.CreateFX("me_forginghammer_crackle_fx", leaper)
    inst.components.rechargeable:StartRecharge()
    inst.components.aoespell:OnSpellCast(leaper)
end
--------------------------------------------------------------------------
-- Attack Functions
--------------------------------------------------------------------------
local function OnAttack(inst, attacker, target)
    if not inst.components.weapon.isaltattacking then
        ReForged.COMMON_FNS.CreateFX("me_weaponsparks_fx", target, attacker)
        ReForged.COMMON_FNS.EQUIPMENT.ApplyArmorBreak(attacker, target)
    else
        ReForged.COMMON_FNS.CreateFX("me_forge_electrocute_fx", target, attacker)
    end
end
--------------------------------------------------------------------------
-- Pristine Functions
--------------------------------------------------------------------------
local function PristineFN(inst)
    -- aoeweapon_leap (from aoeweapon_leap component) added to pristine state for optimization
    ReForged.COMMON_FNS.AddTags(inst, "hammer", "aoeweapon_leap")
end
--------------------------------------------------------------------------
local weapon_values = {
    name_override = "hammer_mjolnir",
    swap_strings  = {"swap_hammer_mjolnir"},
    OnAttack      = OnAttack,
    AOESpell      = AnvilStrike,
    pristine_fn   = PristineFN,
}
------------

local function fn()
    local inst = ReForged.COMMON_FNS.EQUIPMENT.CommonWeaponFN("hammer_mjolnir", nil, weapon_values, tuning_values)
    ------------

    if not TheWorld.ismastersim then
        return inst
    end
    ------------

    ReForged.COMMON_FNS.EQUIPMENT.AOEWeaponLeapInit(inst, tuning_values.ALT_STIMULI, OnLeap)
    ------------


    inst.ReForgedIsWorkableAllowed = function(inst, action, target)
        return action == ACTIONS.CHOP or action == ACTIONS.DIG and target:HasTag("stump") or action == ACTIONS.MINE;
    end

    --inst.components.aoeweapon_leap:SetRange(12); -- 为什么没用...范围还是那么小...

    inst:AddComponent("finiteuses")
    inst.components.finiteuses:SetMaxUses(TUNING.SPEAR_USES)
    inst.components.finiteuses:SetUses(TUNING.SPEAR_USES)

    inst.components.finiteuses:SetMaxUses(200)
    inst.components.finiteuses:SetUses(200)

    inst.components.finiteuses:SetOnFinished(inst.Remove)

    return inst
end


return ENV.ForgePrefab(prefab_name, fn, assets, prefabs, nil, tuning_values.ENTITY_TYPE, nil, "images/inventoryimages.xml", "hammer_mjolnir.tex", "swap_hammer_mjolnir", "common_hand");