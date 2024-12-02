---
--- @author zsh in 2023/5/21 13:17
---

local Import = Import;
local _ReForged = ReForged;

---@class ReForged
---@field G ReForged_G
---@field COMMON_FNS COMMON_FNS
---@field REFORGED_TUNING REFORGED_TUNING
---@field ReForgedImport function
local ReForged = {}; -- 这个表的意义是：我想要的我 emmylua 插件知道这是张表...
ReForged = _ReForged; -- 再指回去...呃，我又要吐槽我自己一下了：我这结构到底怎么设计的啊。扩展性差、可读性差...


setmetatable(ReForged, {
    __index = getmetatable(getfenv(1)).__index;
});

ReForged.ReForged = ReForged; -- 指向自身

GLOBAL.ShiHao.ReForged = ReForged; -- 往我的全局表里存一下，因为我需要用到这个表

setfenv(1, ReForged);

local MODULE_ROOT = "modmain/AUXmods/more_equipments/modmain/reforged/";

function ReForgedImport(modulename)
    modulename = MODULE_ROOT .. "scripts/" .. modulename;
    return Import(modulename, ReForged);
end

---@type REFORGED_TUNING
REFORGED_TUNING = ReForgedImport("tuning");

---@type ReForged_G
G = ReForgedImport("global");

---@type COMMON_FNS
COMMON_FNS = ReForgedImport("common_functions");

---@type COMMON_FNS_EQUIPMENT
COMMON_FNS.EQUIPMENT = ReForgedImport("common_equipment_functions");

------------

-- 哎，打个补丁吧
if true then
    if EntityScript then
        local CollectActions = EntityScript.CollectActions;
        if CollectActions then
            local UpvalueUtil = require("chang_mone.dsts.UpvalueUtil");
            local COMPONENT_ACTIONS = UpvalueUtil.GetUpvalue(CollectActions, "COMPONENT_ACTIONS");
            if COMPONENT_ACTIONS and type(COMPONENT_ACTIONS) == "table" then
                local old_aoespell = COMPONENT_ACTIONS.POINT and COMPONENT_ACTIONS.POINT.aoespell;
                if old_aoespell and type(old_aoespell) == "function" then
                    COMPONENT_ACTIONS.POINT.aoespell = function(inst, doer, pos, actions, right, target, ...)
                        if right then
                            local inventory = doer.replica.inventory
                            if inventory ~= nil and inventory:GetActiveItem() ~= nil then
                                return
                            end
                            ------

                            -- 骑牛不允许有这个动作...呃，这个 componentactions.lua 文件轻易动行不行呢？
                            ---- 测试了开了洞穴问题不大，真麻烦。主客机，RPC了解一下。
                            local handitem = inventory and inventory:GetEquippedItem(EQUIPSLOTS.HANDS);
                            local rider = doer.replica.rider;
                            if handitem and handitem:HasTag("reforged_aoespell_item") and rider and rider:IsRiding() then
                                return false;
                            else
                                return old_aoespell(inst, doer, pos, actions, right, target, ...);
                            end
                        else
                            return old_aoespell(inst, doer, pos, actions, right, target, ...);
                        end
                    end
                end
            end
        end
    end
end


------------
-- Weapon --
------------
---2023-05-23：呃，要不不改这里咋样？太复杂的，再说吧。
---- 而且我发现全局搜索本体没调用 DoAltAttack 函数啊...在哪调用的？
---- 哦，在我的 reforged_aoeweapon_leap 组件里调用的...
do
    -- 简单写写，这样就行了！
    env.AddComponentPostInit("weapon", function(self)
        function self:ReForgedDoAttack(attacker, target_override, projectile, stimuli, instancemult, damage_override, damage_type)
            if attacker and attacker.components.combat then
                if target_override and type(target_override) == "table" and not target_override.prefab then
                    for _, ent in ipairs(target_override) do
                        -- 砍树挖矿：但是 target_override 排除了这些目标？呃，再说吧！没排除啊...
                        ---- 20230602：因为相关类需要添加个基类
                        --if ent ~= attacker and ent:IsValid()
                        --        and ent.components.workable
                        --        and self.inst.ReForgedIsWorkableAllowed
                        --        and self.inst:ReForgedIsWorkableAllowed(ent.components.workable:GetWorkAction(), ent) then
                        --    ent.components.workable:WorkedBy(attacker, 4);
                        --end

                        -- 造成伤害
                        if ent ~= attacker and attacker.components.combat:IsValidTarget(ent) and ent.components.health and not ent.components.health:IsDead() then
                            attacker.components.combat:DoAttack(ent, self.inst, projectile, stimuli, instancemult);
                            --attacker.components.combat:DoAttack(ent, self.inst, projectile, stimuli, instancemult, damage_override, true, nil, damage_type)
                        end
                    end
                else
                    if attacker.components.combat:IsValidTarget(target_override) then
                        attacker.components.combat:DoAttack(target_override, self.inst, projectile, stimuli, instancemult);
                        --attacker.components.combat:DoAttack(target_override, self.inst, projectile, stimuli, instancemult, damage_override, true, nil, damage_type)
                    end
                end
            end
        end
    end)

    return ;
end


--\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
--以下部分暂时无效化\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
--\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
env.AddComponentPostInit("weapon", function(self)
    self.hasaltattack = false
    self.isaltattacking = false
    self.altattackrange = nil
    self.althitrange = nil
    self.altdamage = nil
    self.altdamagecalc = nil
    self.altcondition = nil
    self.altprojectile = nil
    self._projectile = nil
    --ZARKLORD: FIDOOOP YOU LITERALY POOPED OUR CODEBASE!!?!?!?! --"poop" -- Just in case. It'll be overided in SetProjectile
    --Fid: It was Cunning Fox actually... @n@
    --Fox: No u
    --Fid: Ok it was probably Chris
    self.damagetype = nil
    self.altdamagetype = nil
    self._damagetype = nil
    self.launch_pos_override_fn = nil
    self.sync_projectile = nil
    self.hit_weight = nil
    self.hit_weight_fn = nil

    function self:SetDamageType(damagetype)
        self.damagetype = damagetype
        self._damagetype = damagetype
    end

    function self:SetStimuli(stimuli)
        self.stimuli = stimuli
    end

    --Trying to fix invisible poj after using the AltAtk
    function self:SetProjectile(projectile)
        self.projectile = projectile
        self._projectile = projectile
    end

    function self:GetLaunchPositionOverride(attacker)
        return self.launch_pos_override_fn and self.launch_pos_override_fn(self.inst, attacker)
    end

    function self:SetLaunchPositionOverride(pos)
        self.launch_pos_override_fn = pos
    end

    function self:SyncProjectile(val)
        self.sync_projectile = val
    end

    function self:GetHitWeight()
        return self.hit_weight_fn and self.hit_weight_fn(self.inst) or self.hit_weight
    end

    function self:SetHitWeight(val)
        self.hit_weight = val
    end

    function self:SetHitWeightFN(fn)
        self.hit_weight_fn = fn
    end

    function self:SetAltAttack(damage, range, proj, damagetype, damagecalcfn, conditionfn)
        --Used to give weapons a 2nd attack
        self.hasaltattack = true
        self.altdamage = damage ~= nil and damage or self.damage
        if range ~= nil then
            self.altattackrange = (type(range) == "table" and range[1] or type(range) ~= "table" and range) or self.attackrange
            self.althitrange = type(range) == "table" and range[2] or self.altattackrange
        else
            --Uhmmmm.......... Is this healthy?
            self.altattackrange = 20
            self.althitrange = 20
        end
        self.base_alt_attack_range = self.altattackrange
        self.base_alt_hit_range = self.althitrange
        self.altprojectile = proj --Not required, only uses projectile and complexprojectile. An aimedprojectile alt needs to be used through something like aoespell
        self.altdamagetype = damagetype ~= nil and damagetype or self.damagetype --Used incase an alt attack is a different damagetype than the main attack
        self.altdamagecalc = damagecalcfn --Used for when the damage could turn out as a different value under a specific circumstance like with infernal staff (Will default to self.altdamage)
        self.altcondition = conditionfn --Used for telling the weapon when it should alt attack

        if self.altdamagecalc then
            local _olddamagecalc = self.altdamagecalc
            self.altdamagecalc = function(weapon, attacker, target)
                local dmg = _olddamagecalc(weapon, attacker, target)
                return dmg ~= nil and dmg or self.altdamage
            end
        end

        if self.inst.replica.inventoryitem then
            self.inst.replica.inventoryitem:SetAltAttackRange(self.altattackrange)
        end
    end

    function self:UpdateAltAttackRange(attack_range, hit_range, owner)
        local owner = owner or self.inst.components.inventoryitem and self.inst.components.inventoryitem.owner
        self.base_alt_attack_range = attack_range or self.base_alt_attack_range or 0
        self.base_alt_hit_range = hit_range or self.base_alt_hit_range or 0
        if owner and owner.components.scaler then
            local scale = owner.components.scaler.scale
            self.altattackrange = self.base_alt_attack_range * scale
            self.althitrange = self.base_alt_hit_range * scale
        else
            self.altattackrange = self.base_alt_attack_range
            self.althitrange = self.base_alt_hit_range
        end
        if self.inst.replica.inventoryitem then
            self.inst.replica.inventoryitem:SetAltAttackRange(self.altattackrange)
        end
    end

    function self:SetIsAltAttacking(alt, no_netvar)
        self.isaltattacking = alt
        if self.inst.replica.inventoryitem then
            --and not no_netvar then
            self.inst.replica.inventoryitem:SetIsAltAttacking(alt)
        end
        --*intense grumbling*
        if alt then
            self.projectile = self.altprojectile
            self.damagetype = self.altdamagetype
        else
            self.projectile = self._projectile
            self.damagetype = self._damagetype
        end
    end

    function self:HasAltAttack()
        return self.hasaltattack
    end

    function self:CanAltAttack()
        if self:HasAltAttack() and self.isaltattacking then
            return self.altcondition ~= nil and self.altcondition(self.inst) or true
        end
    end

    local _oldCanRangedAttack = self.CanRangedAttack
    function self:CanRangedAttack()
        return self:CanAltAttack() and self.altprojectile or _oldCanRangedAttack(self)
    end

    function self:DoAltAttack(attacker, target_override, projectile, stimuli, instancemult, damage_override, damage_type)
        --Used to force an alt attack out for situations where the alt system is handled seperately like with aoespell
        self:SetIsAltAttacking(true, true)
        --Set setalt to true if the alt is a single attack or AOE attack.
        --If the alt hits rapidly though, leave it false and control SetIsAltAttacking before and after the rapid attacks all trigger (This way we avoid rapidly pushing a netbool)
        if attacker and attacker.components.combat and self:CanAltAttack() then
            if target_override and type(target_override) == "table" and not target_override.prefab then
                --You can pass a table of collected entities through the target_override argument to do an AOE attack
                for _, ent in ipairs(target_override) do
                    if ent ~= attacker and attacker.components.combat:IsValidTarget(ent) and ent.components.health and not ent.components.health:IsDead() then
                        --I'm deciding not to push this event since mob collection occurs before this function runs and
                        --I don't want 2 events pushed for every attack
                        --attacker:PushEvent("onareaattackother", { target = ent, weapon = self.inst, stimuli = stimuli }) --
                        --DoAttack(target, weapon, projectile, stimuli, instancemult, damage_override, is_alt, is_special, damage_type)
                        attacker.components.combat:DoAttack(ent, self.inst, projectile, stimuli, instancemult, damage_override, true, nil, damage_type)
                    end
                    --attacker:PushEvent("alt_attack_complete", {})
                end
            else
                if attacker.components.combat:IsValidTarget(target_override) then
                    attacker.components.combat:DoAttack(target_override, self.inst, projectile, stimuli, instancemult, damage_override, true, nil, damage_type)
                end
            end
        end
        attacker:PushEvent("alt_attack_complete", { weapon = self.inst })
        self:SetIsAltAttacking(false, true)
    end

    -- Basically default function with the added damage parameter so that projectile damage is set on throw and not impact.
    function self:LaunchProjectile(attacker, target, damage)
        if self.projectile then
            if self.onprojectilelaunch then
                self.onprojectilelaunch(self.inst, attacker, target, damage)
            end

            local proj = _G.SpawnPrefab(self.projectile)
            if proj then
                if proj.components.projectile then
                    proj.Transform:SetPosition(attacker.Transform:GetWorldPosition())
                    proj.components.projectile:Throw(self.inst, target, attacker, damage)
                    if self.inst.projectiledelay then
                        proj.components.projectile:DelayVisibility(self.inst.projectiledelay)
                    end
                elseif proj.components.complexprojectile then
                    proj.Transform:SetPosition(attacker.Transform:GetWorldPosition())
                    proj.components.complexprojectile:Launch(target:GetPosition(), attacker, self.inst, damage)
                end
                if self.onprojectilelaunched then
                    self.onprojectilelaunched(self.inst, attacker, target, proj)
                end
            end
        end
    end
end)

----------------------------
-- Inventory Item Replica --
----------------------------
---2023-05-23：这里要处理一下，目前算是摆设，因为我判空了，但是实际上 isaltattacking 是不存在的...
env.AddClassPostConstruct("components/inventoryitem_replica", function(self)
    self.can_altattack_fn = function()
        return true
    end

    function self:SetIsAltAttacking(alt)
        if self.classified and self.classified.isaltattacking then
            self.classified.isaltattacking:set(alt)
        end
    end

    function self:SetAltAttackRange(range)
        if self.classified and self.classified.isaltattacking then
            self.classified.altattackrange:set(range or self:AttackRange())
        end
    end

    function self:AltAttackRange()
        if self.inst.components.weapon then
            return self.inst.components.weapon.altattackrange
        elseif self.classified ~= nil and self.classified.altattackrange then
            return math.max(0, self.classified.altattackrange:value())
        else
            return self:AttackRange()
        end
    end

    function self:SetAltAttackCheck(fn)
        if fn and type(fn) == "function" then
            self.can_altattack_fn = fn
        end
    end

    function self:CanAltAttack()
        if self.classified and self.classified.isaltattacking and self.classified.isaltattacking:value() then
            return self.inst.components.weapon and self.components.weapon:CanAltAttack() or self.can_altattack_fn(self.inst)
        end
    end

    local _oldAttackRange = self.AttackRange
    function self:AttackRange()
        return self:CanAltAttack() and self:AltAttackRange() or _oldAttackRange(self)
    end
end)

-- Also scales the ents physics properties when used.
env.AddComponentPostInit("scaler", function(self)
    if true then
        return ; -- 暂时先不要这个，有空去看一下这是啥再说。
    end

    self.base_scale = 1
    self.damage_mult = 1
    self.current_scale = 1
    -- Physics Parameters
    self.base_rad = nil
    self.current_rad = nil
    self.current_height = nil
    self.base_mass = nil
    self.current_mass = nil
    self.base_shadow = nil
    self.current_shadow = nil
    self.source = nil

    -- Controls the rate at which these increase based on the given scale. Default is 1 to 1 with the scalar.
    self.rad_rate = 1
    self.height_rate = 1
    self.mass_rate = 1
    self.shadow_rate = 1
    self.inst.replica.scaler:SetScale(1)

    self.ApplyScale = function(self)
        local mults, adds, flats = self:GetScalerBuffs()
        self.scale = mults * adds -- + flats -- Not supporting flats for now
        self.inst.replica.scaler:SetScale(self.scale)
        self.current_scale = self.base_scale * self.scale
        self.inst.Transform:SetScale(self.current_scale, self.current_scale, self.current_scale)

        if self.base_rad then
            self.current_rad = self.base_rad * self.scale * self.rad_rate
            self.current_height = (self.base_height or 2) * self.scale * self.height_rate
            local pos = self.inst:GetPosition()
            self.inst.Physics:SetCapsule(self.current_rad, self.current_height)
            self.inst.Transform:SetPosition(pos:Get())
        end

        if self.base_mass then
            self.current_mass = self.base_mass * self.scale * self.mass_rate
            self.inst.Physics:SetMass(self.current_mass)
        end

        if self.base_shadow then
            self.current_shadow = { self.base_shadow[1] * self.scale * self.shadow_rate, self.base_shadow[2] * self.scale * self.shadow_rate }
            self.inst.DynamicShadow:SetSize(unpack(self.current_shadow))
        end

        if self.inst.components.combat then
            self.inst.components.combat:UpdateRange()
            local weapon = self.inst.components.combat:GetWeapon()
            if weapon then
                weapon.components.weapon:UpdateAltAttackRange(nil, nil, self.inst)
            end
        end

        if self.OnApplyScale then
            self.OnApplyScale(self.inst, self.current_scale, self.scale)
        end
    end

    self.GetScalerBuffs = function(self)
        local source = self.source
        local mults, adds, flats = self:GetSourceBuffs()
        if self.inst.components.buffable then
            local scaler_mults, scaler_adds, scaler_flats = self.inst.components.buffable:GetStatBuffs({ "scaler" })
            mults = mults * scaler_mults
            adds = adds + scaler_adds - 1 -- Offset for the sources scaler buff
            flats = flats + scaler_flats
        end
        return mults, adds, flats
    end

    self.GetSourceBuffs = function(self, checking_source)
        local source = self.source
        local mults = 1
        local adds = 1
        local flats = 0
        if source then
            -- Retrieve the sources source
            if source.components.scaler and source.components.scaler.source then
                return source.components.scaler:GetSourceBuffs()
                -- Return the sources current scaler buffs
            elseif source.components.buffable then
                return source.components.buffable:GetStatBuffs({ "scaler" })
            end
        end
        return mults, adds, flats
    end

    -- force_update is true by default
    self.SetSource = function(self, source, force_update)
        self.source = source
        if force_update == nil or force_update then
            self:ApplyScale()
        end
    end
    self.SetBaseScale = function(self, scale)
        self.base_scale = scale or self.base_scale
    end
    self.SetBaseRadius = function(self, radius)
        self.base_rad = radius or self.base_rad
    end
    self.SetBaseHeight = function(self, height)
        self.base_height = height or self.base_height
    end
    self.SetBaseMass = function(self, mass)
        self.base_mass = mass or self.base_mass
    end
    self.SetBaseShadow = function(self, shadow)
        self.base_shadow = shadow or self.base_shadow
    end
    self.SetRadiusRate = function(self, rate)
        self.rad_rate = rate or self.rad_rate
    end
    self.SetHeightRate = function(self, rate)
        self.height_rate = rate or self.height_rate
    end
    self.SetMassRate = function(self, rate)
        self.mass_rate = rate or self.mass_rate
    end
    self.SetShadowRate = function(self, rate)
        self.shadow_rate = rate or self.shadow_rate
    end
end)