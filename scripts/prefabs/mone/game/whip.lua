---
--- @author zsh in 2023/8/1 20:48
---

local assets = {
    Asset("ANIM", "anim/whip.zip"),
    Asset("ANIM", "anim/swap_whip.zip"),
}

local function onequip(inst, owner)
    local skin_build = inst:GetSkinBuild()
    if skin_build ~= nil then
        owner:PushEvent("equipskinneditem", inst:GetSkinName())
        owner.AnimState:OverrideItemSkinSymbol("swap_object", skin_build, "swap_whip", inst.GUID, "swap_whip")
        owner.AnimState:OverrideItemSkinSymbol("whipline", skin_build, "whipline", inst.GUID, "swap_whip")
    else
        owner.AnimState:OverrideSymbol("swap_object", "swap_whip", "swap_whip")
        owner.AnimState:OverrideSymbol("whipline", "swap_whip", "whipline")
    end
    owner.AnimState:Show("ARM_carry")
    owner.AnimState:Hide("ARM_normal")
end

local function onunequip(inst, owner)
    owner.AnimState:Hide("ARM_carry")
    owner.AnimState:Show("ARM_normal")
    local skin_build = inst:GetSkinBuild()
    if skin_build ~= nil then
        owner:PushEvent("unequipskinneditem", inst:GetSkinName())
    end
end

local CRACK_MUST_TAGS = { "_combat" }
local CRACK_CANT_TAGS = { "player", "epic", "shadow", "shadowminion", "shadowchesspiece" }
local function supercrack(inst)
    local owner = inst.components.inventoryitem and inst.components.inventoryitem:GetGrandOwner() or nil
    local x, y, z = inst.Transform:GetWorldPosition()
    local ents = TheSim:FindEntities(x, y, z, TUNING.WHIP_SUPERCRACK_RANGE, CRACK_MUST_TAGS, CRACK_CANT_TAGS)
    for i, v in ipairs(ents) do
        if v ~= owner and v.components.combat:HasTarget() then
            v.components.combat:DropTarget()
            if v.sg ~= nil and v.sg:HasState("hit")
                    and v.components.health ~= nil and not v.components.health:IsDead()
                    and not v.sg:HasStateTag("transform")
                    and not v.sg:HasStateTag("nointerrupt")
                    and not v.sg:HasStateTag("frozen")
            --and not v.sg:HasStateTag("attack")
            --and not v.sg:HasStateTag("busy")
            then

                if v.components.sleeper ~= nil then
                    v.components.sleeper:WakeUp()
                end
                v.sg:GoToState("hit")
            end
        end
    end
end

local function LossOfHatred(target)
    if target ~= nil and target:IsValid() then
        if target.components.combat and target.components.combat:HasTarget() then
            target.components.combat:DropTarget()
        end
    end
end

local function onattack(inst, attacker, target)
    if target ~= nil and target:IsValid() then
        local chance = (target:HasTag("epic") and TUNING.WHIP_SUPERCRACK_EPIC_CHANCE) or
                (target:HasTag("monster") and TUNING.WHIP_SUPERCRACK_MONSTER_CHANCE) or
                TUNING.WHIP_SUPERCRACK_CREATURE_CHANCE

        local snap = SpawnPrefab("impact")

        local x, y, z = inst.Transform:GetWorldPosition()
        local x1, y1, z1 = target.Transform:GetWorldPosition()
        local angle = -math.atan2(z1 - z, x1 - x)
        snap.Transform:SetPosition(x1, y1, z1)
        snap.Transform:SetRotation(angle * RADIANS)

        --impact sounds normally play through comabt component on the target
        --whip has additional impact sounds logic, which we'll just add here

        if math.random() < chance then
            snap.Transform:SetScale(3, 3, 3)
            if target.SoundEmitter ~= nil then
                target.SoundEmitter:PlaySound(inst.skin_sound_large or "dontstarve/common/whip_large")
            end
            inst:DoTaskInTime(0, supercrack)
        elseif target.SoundEmitter ~= nil then
            target.SoundEmitter:PlaySound(inst.skin_sound_small or "dontstarve/common/whip_small")
        end
    end

    -- NEW!
    LossOfHatred(target);
end

local function DropEquipments(inst)
    local targets = {
        pigman = true,
        bunnyman = true,
        monkey = true,
    }
    if inst.components.inventory and targets[inst.prefab] then
        inst.components.inventory:DropEquipped();
    end
    LossOfHatred(inst);
end

local function TimeoutRepel(inst, creatures, task)
    if task ~= nil then
        task:Cancel();
    end

    for i, v in ipairs(creatures) do
        if v.speed ~= nil then
            v.inst.Physics:ClearMotorVelOverride()
            v.inst.Physics:Stop()
            DropEquipments(inst);
        end
    end
end

local function UpdateRepel(inst, x, z, creatures)
    local REPEL_RADIUS = 1.5
    local REPEL_RADIUS_SQ = REPEL_RADIUS * REPEL_RADIUS

    for i = #creatures, 1, -1 do
        local v = creatures[i]
        
        if not (inst:IsValid() and v.inst:IsValid() and v.inst.entity:IsVisible()) then
            table.remove(creatures, i);
            return;
        end
        
        if v.speed == nil then
            local distsq = v.inst:GetDistanceSqToPoint(x, 0, z)
            if distsq > REPEL_RADIUS_SQ then
                if distsq > 0 then
                    v.inst:ForceFacePoint(x, 0, z)
                end
                v.speed = 15 * (0.5 * distsq / 16)--25 * k
                v.inst.Physics:SetMotorVelOverride(v.speed, 0, 0)
            end
        else
            local distsq = v.inst:GetDistanceSqToPoint(x, 0, z)
            if distsq < REPEL_RADIUS_SQ then
                v.inst.Physics:ClearMotorVelOverride()
                v.inst.Physics:Stop()
                table.remove(creatures, i)
            else
                local x1, y1, z1 = v.inst.Transform:GetWorldPosition()
                if x1 ~= x or z1 ~= z then
                    v.inst:ForceFacePoint(x, 0, z)
                end
                DropEquipments(v.inst)
                v.inst.Physics:SetMotorVelOverride(v.speed, 0, 0)
            end
        end
    end
end


local function SpellMainFn(inst, doer, target)
    local creatures = {};
    if target.Physics ~= nil then
        table.insert(creatures, { inst = target })
    end
    local x, y, z = doer.Transform:GetWorldPosition()
    if #creatures > 0 then
        doer:DoTaskInTime(10 * FRAMES, TimeoutRepel, creatures, doer:DoPeriodicTask(0, UpdateRepel, nil, x, z, creatures))
    end
end

local function spellfn(inst, doer, target)
    if inst.components.rechargeable.recharging then
        return ;
    end

    inst.components.rechargeable:StartRecharging();

    if target:HasTag("trapsprung") and target.components.trap then
        target.components.trap:Harvest(doer);
    elseif doer.components.inventory and target.components.inventoryitem and target.components.inventoryitem.canbepickedup then
        doer:PushEvent("onpickupitem", { item = target });
        doer.components.inventory:GiveItem(target, nil, target:GetPosition());
    elseif target.components.health and not target.components.health:IsDead() and target.components.locomotor then
        SpellMainFn(inst, doer, target);
    end
end

local function onrechargingfn(inst)
    inst.components.mone_whip_spell.canspell = false
end

local function onstoprechargfn(inst)
    inst.components.mone_whip_spell.canspell = true
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("whip")
    inst.AnimState:SetBuild("whip")
    inst.AnimState:PlayAnimation("idle")

    inst:AddTag("whip")

    --weapon (from weapon component) added to pristine state for optimization
    inst:AddTag("weapon")

    -- NEW
    inst:AddTag("rechargeable")

    MakeInventoryFloatable(inst, "med", nil, 0.9)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("weapon")
    --inst.components.weapon:SetDamage(0) -- TUNING.WHIP_DAMAGE
    --inst.components.weapon:SetRange(2) -- TUNING.WHIP_RANGE
    inst.components.weapon:SetDamage(TUNING.WHIP_DAMAGE)
    inst.components.weapon:SetRange(TUNING.WHIP_RANGE)
    inst.components.weapon:SetOnAttack(onattack)

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "whip";
    inst.components.inventoryitem.atlasname = "images/inventoryimages.xml";

    inst:AddComponent("equippable")
    inst.components.equippable:SetOnEquip(onequip)
    inst.components.equippable:SetOnUnequip(onunequip)

    -- NEW
    inst:AddComponent("mone_whip_spell")
    inst.components.mone_whip_spell:SetSpellFn(spellfn)

    -- NEW
    inst:AddComponent("mone_rechargeable")
    inst.components.rechargeable = inst.components.mone_rechargeable
    inst.components.rechargeable:SetRechargeTime(10)
    inst.components.rechargeable.rechargingfn = onrechargingfn
    inst.components.rechargeable.stoprechargfn = onstoprechargfn
    inst:RegisterComponentActions("rechargeable")

    MakeHauntableLaunch(inst)

    return inst
end

return Prefab("mone_whip", fn, assets)
