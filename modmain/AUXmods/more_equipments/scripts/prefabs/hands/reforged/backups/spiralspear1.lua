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

-- 临时函数：呃，还需要涉及 AddReplicableComponent("scaler") 相关组件...
local function CreateFX(prefab, target, source, opts)
    local opts = opts or {}
    local fx = SpawnPrefab(prefab)
    local source = source or target

    -- chang: 为什么不判空呢？
    if fx == nil then
        return ;
    end

    if source and source.components.scaler then
        if not fx.components.scaler then
            fx:AddComponent("scaler")
        end
        fx.components.scaler:SetBaseScale(opts.scale)
        fx.components.scaler:SetSource(source)
    end

    if opts.position then
        fx.Transform:SetPosition(opts.position:Get())
    end

    if opts.OnSpawn then
        opts.OnSpawn(fx)
    end

    if fx.OnSpawn then
        fx:OnSpawn({ target = target, source = source or target })
    end

    return fx
end

------------
local function MergeTable(tbl_1, tbl_2, override_values)
    for i, j in pairs(tbl_2) do
        if override_values or not tbl_1[i] then
            tbl_1[i] = j ~= "nil" and j
        end
    end
end

local function ApplyMultiBuild(inst, symbols, build, alt)
    if symbols and build then
        for pt = 1, #symbols do
            --print(pt)
            for i, v in ipairs(symbols[pt]) do
                inst.AnimState:OverrideSymbol(v, alt and build or build .. "_pt" .. pt, v)
            end
        end
    end
end

local function ApplyBuild(inst, build)
    if build and type(build) == "table" then
        inst.AnimState:SetBuild(build.base)
        ApplyMultiBuild(inst, build.symbols, build.name)
    else
        inst.AnimState:SetBuild(build)
    end
end

local function BasicEntityInit(bank, build, anim, opts)
    local options = {
        anim = anim or "idle",
        anim_loop = true,
        noanim = false,
        --pristine_fn = nil,
    }
    MergeTable(options, opts or {}, true)
    ------------

    local inst = CreateEntity();
    ------------

    inst.entity:AddTransform()
    ------------

    if bank ~= nil then
        inst.entity:AddAnimState()
        inst.AnimState:SetBank(bank)
        ApplyBuild(inst, build or bank)
        if not options.noanim then
            inst.AnimState:PlayAnimation(options.anim, options.anim_loop)
        end
    end
    ------------

    inst.entity:AddNetwork()
    ------------

    if options.pristine_fn then
        options.pristine_fn(inst)
    end
    ------------

    inst.entity:SetPristine()
    ------------

    return inst;
end

---------------------------
-- Directional Reticules --
---------------------------
local function DirectionalReticuleTargetFn(length)
    return function()
        return Vector3(ThePlayer.entity:LocalToWorldSpace(length * (ThePlayer.replica.scaler and ThePlayer.replica.scaler:GetScale() or 1), 0, 0))
    end
end

local function ReticuleMouseTargetFn(length)
    return function(inst, mousepos)
        if mousepos ~= nil then
            local x, y, z = inst.Transform:GetWorldPosition()
            local dx = mousepos.x - x
            local dz = mousepos.z - z
            local l = dx * dx + dz * dz
            if l <= 0 then
                return inst.components.reticule.targetpos
            end
            l = length / math.sqrt(l) * (ThePlayer.replica.scaler and ThePlayer.replica.scaler:GetScale() or 1)
            return Vector3(x + dx * l, 0, z + dz * l)
        end
    end
end

local function ReticuleUpdatePositionFn(inst, pos, reticule, ease, smoothing, dt)
    local x, y, z = inst.Transform:GetWorldPosition()
    reticule.Transform:SetPosition(x, 0, z)
    local rot = -math.atan2(pos.z - z, pos.x - x) / DEGREES
    if ease and dt ~= nil then
        local rot0 = reticule.Transform:GetRotation()
        local drot = rot - rot0
        rot = Lerp((drot > 180 and rot0 + 360) or (drot < -180 and rot0 - 360) or rot0, rot, dt * smoothing)
    end
    reticule.Transform:SetRotation(rot)
end

local function DirectionalReticuleInit(inst, length, reticule_prefab, ping_prefab, always_valid)
    inst:AddComponent("aoetargeting")
    inst.components.aoetargeting:SetAlwaysValid(always_valid == nil or always_valid)
    inst.components.aoetargeting.reticule.reticuleprefab = reticule_prefab or "reticulelong"
    inst.components.aoetargeting.reticule.pingprefab = ping_prefab or "reticulelongping"
    inst.components.aoetargeting.reticule.targetfn = DirectionalReticuleTargetFn(length) -- TODO or default of 6.5?
    inst.components.aoetargeting.reticule.mousetargetfn = ReticuleMouseTargetFn(length) -- TODO or default of 6.5?
    inst.components.aoetargeting.reticule.updatepositionfn = ReticuleUpdatePositionFn
    inst.components.aoetargeting.reticule.validcolour = { 1, .75, 0, 1 }
    inst.components.aoetargeting.reticule.invalidcolour = { .5, 0, 0, 1 }
    inst.components.aoetargeting.reticule.ease = true
    inst.components.aoetargeting.reticule.mouseenabled = true
end

-------------------
-- AOE Reticules --
-------------------
local function AOEReticuleTargetFn(radius)
    return function()
        local player = ThePlayer
        local ground = TheWorld.Map
        local pos = Vector3()
        --Cast range is 8, leave room for error
        --4 is the aoe range
        for r = radius, 0, -.25 do
            pos.x, pos.y, pos.z = player.entity:LocalToWorldSpace(r, 0, 0)
            if ground:IsPassableAtPoint(pos:Get()) and not ground:IsGroundTargetBlocked(pos) then
                return pos
            end
        end
        return pos
    end
end

local function AOEReticuleInit(inst, radius, reticule_prefab, ping_prefab, valid_color, valid_colors, invalid_color)
    inst:AddComponent("aoetargeting")
    inst.components.aoetargeting.targetprefab = ping_prefab or "reticuleaoehostiletarget"
    inst.components.aoetargeting.reticule.reticuleprefab = reticule_prefab or "reticuleaoe"
    inst.components.aoetargeting.reticule.pingprefab = reticule_prefab and reticule_prefab .. "ping" or "reticuleaoeping"
    inst.components.aoetargeting.reticule.targetfn = AOEReticuleTargetFn(radius) -- TODO or default of 7?
    inst.components.aoetargeting.reticule.validcolour = valid_color or { 1, .75, 0, 1 } -- TODO tuning?
    inst.components.aoetargeting.reticule.validcolours = valid_colors or {} -- TODO tuning?
    inst.components.aoetargeting.reticule.invalidcolour = invalid_color or { .5, 0, 0, 1 } -- TODO tuning?
    inst.components.aoetargeting.reticule.ease = true
    inst.components.aoetargeting.reticule.mouseenabled = true
end

------------------------
-- AOESpell Functions --
------------------------
local function AOESpellInit(inst, aoe_spell_fn, spell_types)
    inst:AddComponent("reforged_aoespell")
    inst.components.aoespell = inst.components.reforged_aoespell;
    inst:RegisterComponentActions("aoespell");

    inst.components.aoespell:SetAOESpell(aoe_spell_fn)
    if spell_types then
        inst.components.aoespell:SetSpellTypes(spell_types)
    end
end

----------------------------
-- Rechargeable Functions --
----------------------------
local function RechargeableInit(inst, tuning_values)
    inst:AddComponent("reforged_rechargeable");
    inst.components.rechargeable = inst.components.reforged_rechargeable;
    inst:RegisterComponentActions("rechargeable");

    local is_timer = tuning_values.COOLDOWN_TIMER == nil or tuning_values.COOLDOWN_TIMER
    inst.components.rechargeable:SetIsTimer(is_timer)
    if tuning_values.COOLDOWN then
        if is_timer then
            inst.components.rechargeable:SetRechargeTime(tuning_values.COOLDOWN)
        else
            inst.components.rechargeable:SetMaxRecharge(tuning_values.COOLDOWN)
        end
    end

end

----------------------
-- Weapon Functions --
----------------------
local function WeaponInit(inst, weapon_values, tuning_values)
    inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(tuning_values.DAMAGE)
    inst.components.weapon:SetOnAttack(weapon_values.OnAttack)
    inst.components.weapon:SetRange(tuning_values.ATTACK_RANGE, tuning_values.HIT_RANGE)
    inst.components.weapon:SetProjectile(weapon_values.projectile)
    inst.components.weapon:SetOnProjectileLaunch(weapon_values.projectile_fn)
    inst.components.weapon:SetDamageType(tuning_values.DAMAGE_TYPE)
    inst.components.weapon:SetStimuli(tuning_values.STIMULI)
    inst.components.weapon:SetHitWeight(weapon_values.hit_weight)
    inst.components.weapon:SetHitWeightFN(weapon_values.HitWeightFN)
    if tuning_values.ALT_DAMAGE then
        -- TODO if a weapon has an alt attack it must have ALT_DAMAGE, right?
        inst.components.weapon:SetAltAttack(tuning_values.ALT_DAMAGE, tuning_values.ALT_RADIUS or tuning_values.ALT_RANGE or { tuning_values.ALT_ATTACK_RANGE or tuning_values.ATTACK_RANGE, tuning_values.ALT_HIT_RANGE or tuning_values.HIT_RANGE }, nil, tuning_values.DAMAGE_TYPE, weapon_values.CalcAltDamage) -- TODO ALT_DAMAGE defaulted to DAMAGE if the same (need to change check if yes)?, ALT ranges defaulted to regular attack range, do these cause issues? should they always be set in tuning even if they are the same? range is hacky, fix
    end
end

------------------------
-- ItemType Functions --
------------------------
local function ItemTypeInit(inst, type)
    inst:AddComponent("reforged_itemtype")
    inst.components.reforged_itemtype:SetType(type);
    inst:RegisterComponentActions("itemtype");
end

-----------------------------
-- InventoryItem Functions --
-----------------------------
--This is a function that should be used to return to the ground, since a lot of basegame functions don't account for blocked areas (aka crowdstands)
local function ReturnToGround(inst)
    local pos = inst:GetPosition()
    local result_offset
    local distance = 0
    local step = 0.5
    while result_offset == nil do
        result_offset = FindValidPositionByFan(distance, distance, distance, function(offset)
            local test_point = pos + offset
            return not TheWorld.Map:IsGroundTargetBlocked(test_point) and TheWorld.Map:IsPassableAtPoint(test_point:Get()) and TheWorld.Map:IsValidTileAtPoint(test_point:Get())
        end)
        distance = distance + step
    end

    local target_pos = result_offset and pos + result_offset or _G.TheWorld.multiplayerportal and _G.TheWorld.multiplayerportal:GetPosition()

    -- Spawn fx depending on where the entity was last at.
    local fx = SpawnPrefab("splash_lavafx") -- TODO have different fx based on where it's teleporting from?

    -- chang: splash_lavafx 特效未导入，需要处理
    if fx then
        fx.Transform:SetPosition(pos:Get())
    end

    if inst.components.inventoryitem then
        inst.components.inventoryitem:DoDropPhysics(target_pos.x, 10, target_pos.z, false, false)
    else
        inst.Physics:Teleport(target_pos.x, 0, target_pos.z)
    end
end

-- TODO need to find our where momentum is handled and when it's not moving trigger this
local function InventoryItemInit(inst, image_name)
    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = image_name
    -- If an item goes out of bounds force it to return to the closest inbound location.
    inst:ListenForEvent("on_landed", function(inst)
        local pos = inst:GetPosition()
        if not TheWorld.Map:IsPassableAtPoint(pos:Get()) or TheWorld.Map:IsGroundTargetBlocked(pos) then
            -- or not TheWorld.Map:IsValidTileAtPoint(pos:Get()) then -- TheWorld.Map:IsGroundTargetBlocked(pos) or
            ReturnToGround(inst)
        end
        -- TODO remove this when bandaid is no longer needed
        inst:DoTaskInTime(5, function()
            if not TheWorld.Map:IsPassableAtPoint(pos:Get()) or TheWorld.Map:IsGroundTargetBlocked(pos) then
                ReturnToGround(inst)
            end
        end)
    end)
end

--------------------------
-- Equippable Functions --
--------------------------
local function CheckSwapStrings(swap_strings)
    if #swap_strings < 3 then
        -- use first string for the 3rd string
        table.insert(swap_strings, swap_strings[1])
    end
    return swap_strings
end

local function OnBlockedArmor(inst)
    local armor = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.BODY)
    if armor then
        inst.SoundEmitter:PlaySound(armor.hitsound)
    end
end

local onequip_fns = {
    body = function(onequip_fn, ...)
        local swap_strings = CheckSwapStrings({ ... })
        return function(inst, owner)
            owner.AnimState:OverrideSymbol(unpack(swap_strings))
            inst:ListenForEvent("blocked", OnBlockedArmor, owner)

            -- Apply Max Health Increase
            if inst.max_hp then
                -- TODO should this be in all equip fns regardless of type?
                owner.components.health:AddHealthBuff(inst.prefab, inst.max_hp, "flat")
            end

            -- Apply Pet Levels
            if inst.pet_level_up then
                -- TODO should this be in all equip fns regardless of type?
                owner.current_pet_level = (owner.current_pet_level or 1) + inst.pet_level_up
                if owner.components.leader and owner.components.leader.followers then
                    for pet, _ in pairs(owner.components.leader.followers) do
                        pet:PushEvent("updatepetmastery", { level = inst.pet_level_up }) -- TODO could add levels of mastery instead where each pet has their own level scaling
                    end
                end
            end

            if onequip_fn then
                onequip_fn(inst, owner)
            end
        end
    end,
    book = function(onequip_fn, ...)
        local swap_strings = CheckSwapStrings({ ... })
        return function(inst, owner)
            owner.AnimState:ClearOverrideSymbol("swap_object")
            owner.AnimState:OverrideSymbol(unpack(swap_strings))
            if onequip_fn then
                onequip_fn(inst, owner)
            end
        end
    end,
    fist = function(onequip_fn, ...)
        local swap_strings = CheckSwapStrings({ ... })
        return function(inst, owner)
            owner.AnimState:ClearOverrideSymbol("swap_object")
            owner.AnimState:OverrideSymbol(unpack(swap_strings))
            owner.AnimState:Hide("ARM_carry")
            owner.AnimState:Show("ARM_normal")
            if onequip_fn then
                onequip_fn(inst, owner)
            end
        end
    end,
    hand = function(onequip_fn, ...)
        -- Weapon
        local swap_strings = CheckSwapStrings({ ... })
        return function(inst, owner)
            owner.AnimState:OverrideSymbol("swap_object", unpack(swap_strings))
            owner.AnimState:Show("ARM_carry")
            owner.AnimState:Hide("ARM_normal")
            if onequip_fn then
                onequip_fn(inst, owner)
            end
        end
    end,
    head = function(onequip_fn, ...)
        -- Helm
        local swap_strings = CheckSwapStrings({ ... })
        return function(inst, owner)
            owner.AnimState:OverrideSymbol(unpack(swap_strings))
            owner.AnimState:Show("HAT")
            if inst.cover_head then
                owner.AnimState:Show("HAIR_HAT")
                owner.AnimState:Show("HEAD_HAT")
                owner.AnimState:Hide("HAIR_NOHAT")
                owner.AnimState:Hide("HAIR")
                owner.AnimState:Hide("HEAD")
            end
            if onequip_fn then
                onequip_fn(inst, owner)
            end
        end
    end,
}
local onunequip_fns = {
    body = function(onunequip_fn)
        return function(inst, owner)
            owner.AnimState:ClearOverrideSymbol("swap_body")
            inst:RemoveEventCallback("blocked", OnBlockedArmor, owner)

            -- Remove Max Health Increase
            if inst.max_hp then
                owner.components.health:RemoveHealthBuff(inst.prefab, "flat")
            end

            -- Remove Pet Levels
            if inst.pet_level_up then
                owner.current_pet_level = (owner.current_pet_level or 1) - inst.pet_level_up
                if owner.components.leader and owner.components.leader.followers then
                    for pet, _ in pairs(owner.components.leader.followers) do
                        pet:PushEvent("updatepetmastery", { level = -inst.pet_level_up })
                    end
                end
            end

            if onunequip_fn then
                onunequip_fn(inst, owner)
            end
        end
    end,
    fist = function(onunequip_fn)
        return function(inst, owner)
            owner.AnimState:Hide("ARM_carry")
            owner.AnimState:Show("ARM_normal")
            owner.AnimState:OverrideSymbol("hand", owner.prefab, "hand")
            owner.AnimState:ClearOverrideSymbol("hand")
            owner.components.skinner:SetClothing(owner.components.skinner.clothing.hand)
            owner.components.skinner:SetClothing(owner.components.skinner.clothing.body) --because some skins alter the hands
            if onunequip_fn then
                onunequip_fn(inst, owner)
            end
        end
    end,
    hand = function(onunequip_fn)
        return function(inst, owner)
            owner.AnimState:Hide("ARM_carry")
            owner.AnimState:Show("ARM_normal")
            if onunequip_fn then
                onunequip_fn(inst, owner)
            end
        end
    end,
    head = function(onunequip_fn)
        -- Helm
        return function(inst, owner)
            owner.AnimState:ClearOverrideSymbol("swap_hat")
            owner.AnimState:Hide("HAT")
            if inst.cover_head then
                owner.AnimState:Hide("HAIR_HAT")
                owner.AnimState:Hide("HEAD_HAT")
                owner.AnimState:Show("HAIR_NOHAT")
                owner.AnimState:Show("HAIR")
                owner.AnimState:Show("HEAD")
            end
            if onunequip_fn then
                onunequip_fn(inst, owner)
            end
        end
    end,
}

local function EquippableInit(inst, type, onequip_fn, onunequip_fn, symbol_1, symbol_2, symbol_3)
    -- TODO different name for symbol?
    inst:AddComponent("equippable")
    inst.components.equippable:SetOnEquip(onequip_fns[type] and onequip_fns[type](onequip_fn, symbol_1, symbol_2 or symbol_1, symbol_3) or onequip_fn)
    inst.components.equippable:SetOnUnequip(onunequip_fns[type] and onunequip_fns[type](onunequip_fn) or onunequip_fn)
end

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
    for _,tag in pairs({...}) do
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
    COOLDOWN = 4, -- 12
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
    local inst = CommonWeaponFN("spear_lance", nil, weapon_values, tuning_values);
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