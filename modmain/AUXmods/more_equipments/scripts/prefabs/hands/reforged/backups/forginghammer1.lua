---
--- @author zsh in 2023/5/20 19:43
---

local prefab_name = "me_forginghammer"; -- 这里的名字是我的物品名

local assets = { Asset("ANIM", "anim/hammer_mjolnir.zip"), Asset("ANIM", "anim/swap_hammer_mjolnir.zip") };
local deps = { "me_forginghammer_crackle_fx", "me_forgeelectricute_fx", "me_weaponsparks_fx", "reticuleaoe", "reticuleaoeping", "reticuleaoehostiletarget", };

local function ReticuleTargetFn()
    local player = ThePlayer
    local ground = TheWorld.Map
    local pos = Vector3()
    --Cast range is 8, leave room for error
    --4 is the aoe range
    for r = 7, 0, -.25 do
        pos.x, pos.y, pos.z = player.entity:LocalToWorldSpace(r, 0, 0)
        if ground:IsPassableAtPoint(pos:Get()) and not ground:IsGroundTargetBlocked(pos) then
            return pos
        end
    end
    return pos
end

local function spellfn(inst, doer, pos)
    doer:PushEvent("combat_leap", { targetpos = pos, weapon = inst });
end

local function onleap(inst, ...)
    SpawnPrefab("me_forginghammer_crackle_fx"):SetTarget(inst)
    inst.components.rechargeable:Discharge(10)
end

-- TODO：需要理解
local function onattack(inst, attacker, target)
    if not inst.components.weapon.isaltattacking and target and target:IsValid() then
        SpawnPrefab("me_weaponsparks_fx"):SetPosition(attacker, target)
    else
        SpawnPrefab("me_forgeelectricute_fx"):SetTarget(target, true)
    end
end

local function onequipfn(inst, owner, ...)
    owner.AnimState:OverrideSymbol("swap_object", "swap_hammer_mjolnir", "swap_hammer_mjolnir")
    owner.AnimState:Show("ARM_carry")
    owner.AnimState:Hide("ARM_normal")
end

local function onunequipfn(inst, owner, ...)
    owner.AnimState:Hide("ARM_carry")
    owner.AnimState:Show("ARM_normal")
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("hammer_mjolnir")
    inst.AnimState:SetBuild("hammer_mjolnir")
    inst.AnimState:PlayAnimation("idle")

    inst:AddTag("aoeweapon_leap")
    inst:AddTag("hammer")

    inst:AddComponent("aoetargeting")
    inst.components.aoetargeting.reticule.reticuleprefab = "reticuleaoe"
    inst.components.aoetargeting.reticule.pingprefab = "reticuleaoeping"
    inst.components.aoetargeting.reticule.targetfn = ReticuleTargetFn;
    inst.components.aoetargeting.reticule.validcolour = { 1, .75, 0, 1 }
    inst.components.aoetargeting.reticule.invalidcolour = { .5, 0, 0, 1 }
    inst.components.aoetargeting.reticule.ease = true;
    inst.components.aoetargeting.reticule.mouseenabled = true;

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.IsWorkableAllowed = function(inst, u, target)
        return u == ACTIONS.CHOP or u == ACTIONS.DIG and target:HasTag("stump") or u == ACTIONS.MINE
    end;

    inst:AddComponent("inspectable")

    inst:AddComponent("aoespell")
    inst.components.aoespell:SetSpellFn(spellfn)

    -- TODO：需要理解
    inst:AddComponent("me_aoeweapon_leap")
    inst.components.me_aoeweapon_leap:SetStimuli("electric")
    inst.components.me_aoeweapon_leap:SetOnLeapFn(onleap)

    -- TODO：需要理解
    inst:AddComponent("me_reticule_spawner")
    inst.components.reticule_spawner:Setup(unpack({ "aoehostiletarget", 0.9 }))

    inst:AddComponent("rechargeable")
    inst.components.rechargeable:SetChargeTime(10)
    inst.components.rechargeable:SetOnDischargedFn(function(inst)
        inst.components.aoetargeting:SetEnabled(false)
    end)
    inst.components.rechargeable:SetOnChargedFn(function(inst)
        inst.components.aoetargeting:SetEnabled(true)
    end)

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "hammer_mjolnir";
    inst.components.inventoryitem.atalsname = "images/inventoryimages.xml";

    inst:AddComponent("equippable")
    inst.components.equippable.equipslot = EQUIPSLOTS.HANDS;
    inst.components.equippable:SetOnEquip(onequipfn)
    inst.components.equippable:SetOnUnequip(onunequipfn)

    inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(34)
    inst.components.weapon:SetOnAttack(onattack)

    -- TODO：需要理解
    --inst.components.weapon:SetDamageType(DAMAGETYPES.PHYSICAL)
    --inst.components.weapon:SetAltAttack(TUNING.THE_FORGE_ITEM_PACK.FORGINGHAMMER.ALT_DAMAGE, TUNING.THE_FORGE_ITEM_PACK.FORGINGHAMMER.ALT_RADIUS, nil, DAMAGETYPES.PHYSICAL)

    return inst;
end

local fxs = {
    [1] = {
        assets = { Asset("ANIM", "anim/lavaarena_hammer_attack_fx.zip") };
        deps = { "me_forginghammer_cracklebase_fx" };
        fn = function()
            local inst = CreateEntity()

            inst.entity:AddTransform()
            inst.entity:AddAnimState()
            inst.entity:AddSoundEmitter()
            inst.entity:AddNetwork()

            inst.AnimState:SetBank("lavaarena_hammer_attack_fx")
            inst.AnimState:SetBuild("lavaarena_hammer_attack_fx")
            inst.AnimState:PlayAnimation("crackle_hit")
            inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
            inst.AnimState:SetFinalOffset(1)

            inst:AddTag("FX")
            inst:AddTag("NOCLICK")

            inst.entity:SetPristine()

            if not TheWorld.ismastersim then
                return inst
            end

            inst.persists = false

            inst.SetTarget = function(inst, target)
                inst.Transform:SetPosition(target:GetPosition():Get())
                inst.SoundEmitter:PlaySound("dontstarve/impacts/lava_arena/hammer")
                SpawnPrefab("me_forginghammer_crackle_fx"):SetTarget(inst)
            end

            inst:ListenForEvent("animover", inst.Remove);

            return inst;
        end
    };
    [2] = {
        assets = { Asset("ANIM", "anim/lavaarena_hammer_attack_fx.zip") };
        deps = nil;
        fn = function()
            local inst = CreateEntity()

            inst.entity:AddTransform()
            inst.entity:AddAnimState()
            inst.entity:AddNetwork()

            inst.AnimState:SetBank("lavaarena_hammer_attack_fx")
            inst.AnimState:SetBuild("lavaarena_hammer_attack_fx")
            inst.AnimState:PlayAnimation("crackle_projection")
            inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
            inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
            inst.AnimState:SetLayer(LAYER_BACKGROUND)
            inst.AnimState:SetSortOrder(3)
            inst.AnimState:SetScale(1.5, 1.5)

            inst:AddTag("FX")
            inst:AddTag("NOCLICK")

            inst.entity:SetPristine()

            if not TheWorld.ismastersim then
                return inst
            end

            inst.persists = false

            inst.SetTarget = function(inst, target)
                inst.Transform:SetPosition(target:GetPosition():Get())
            end;

            inst:ListenForEvent("animover", inst.Remove);

            return inst
        end
    };
    [3] = {
        assets = { Asset("ANIM", "anim/lavaarena_hammer_attack_fx.zip") };
        deps = nil;
        fn = function()
            local inst = CreateEntity()

            inst.entity:AddTransform()
            inst.entity:AddAnimState()
            inst.entity:AddSoundEmitter()
            inst.entity:AddNetwork()

            inst.AnimState:SetBank("lavaarena_hammer_attack_fx")
            inst.AnimState:SetBuild("lavaarena_hammer_attack_fx")
            inst.AnimState:PlayAnimation("crackle_loop")
            inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
            inst.AnimState:SetFinalOffset(1)
            inst.AnimState:SetScale(1.5, 1.5)

            inst:AddTag("FX")
            inst:AddTag("NOCLICK")

            inst.entity:SetPristine()

            if not TheWorld.ismastersim then
                return inst
            end

            inst.persists = false

            inst.SetTarget = function(inst, target, ignoresound)
                inst.Transform:SetPosition(target:GetPosition():Get())
                if not ignoresound then
                    inst.SoundEmitter:PlaySound("dontstarve/impacts/lava_arena/electric")
                end
                if target:HasTag("largecreature") or target:HasTag("epic") then
                    inst.AnimState:SetScale(2, 2)
                end
            end;

            inst:ListenForEvent("animover", inst.Remove);

            return inst
        end
    },
    [4] = {
        assets = { Asset("ANIM", "anim/lavaarena_hit_sparks_fx.zip") };
        deps = nil;
        -- TODO：需要理解
        fn = function()
            local inst = CreateEntity()

            inst.entity:AddTransform()
            inst.entity:AddAnimState()
            inst.entity:AddNetwork()

            inst:AddTag("FX")

            inst.AnimState:SetBank("hits_sparks")
            inst.AnimState:SetBuild("lavaarena_hit_sparks_fx")
            inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
            inst.AnimState:SetFinalOffset(1)

            inst.entity:SetPristine()

            if not TheWorld.ismastersim then
                return inst
            end

            inst.persists = false

            inst.SetPosition = function(inst, d, e)
                local f = (d:GetPosition() - e:GetPosition()):GetNormalized() * (e.Physics ~= nil and e.Physics:GetRadius() or 1)
                f.y = f.y + 1 + math.random(-5, 5) / 10;
                inst.Transform:SetPosition((e:GetPosition() + f):Get())
                inst.AnimState:PlayAnimation("hit_3")
                inst.AnimState:SetScale(d:GetRotation() > 0 and -.7 or .7, .7)
            end

            inst.SetPiercing = function(inst, g, e)
                local f = (g:GetPosition() - e:GetPosition()):GetNormalized() * (e.Physics ~= nil and e.Physics:GetRadius() or 1)
                f.y = f.y + 1 + math.random(-5, 5) / 10;
                inst.Transform:SetPosition((e:GetPosition() + f):Get())
                inst.AnimState:PlayAnimation("hit_3")
                inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
                inst.Transform:SetRotation(inst:GetAngleToPoint(e:GetPosition():Get()) + 90)
            end

            inst.SetThrusting = function(inst, g, e)
                local h = inst:GetPosition()
                inst.Transform:SetPosition(h.x, h.y + 1, h.z)
                inst:SetPiercing(g, e)
            end

            inst.SetBounce = function(inst, i)
                inst.Transform:SetPosition(i:GetPosition():Get())
                inst.AnimState:PlayAnimation("hit_2")
                inst.AnimState:Hide("glow")
                inst.AnimState:SetScale(i:GetRotation() > 0 and 1 or -1, 1)
            end

            inst:ListenForEvent("animover", inst.Remove)

            inst.OnLoad = inst.Remove;

            return inst
        end
    }
}

return Prefab(prefab_name, fn, assets, deps),
Prefab("me_forginghammer_crackle_fx", fxs[1].fn, fxs[1].assets, fxs[1].deps),
Prefab("me_forginghammer_cracklebase_fx", fxs[2].fn, fxs[2].assets, fxs[2].deps),
Prefab("me_forgeelectricute_fx", fxs[3].fn, fxs[3].assets, fxs[3].deps),
Prefab("me_weaponsparks_fx", fxs[4].fn, fxs[4].assets, fxs[4].deps);