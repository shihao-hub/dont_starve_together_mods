---
--- @author zsh in 2023/7/8 0:01
---

local fertilizer_projectile_assets =
{
    Asset("ANIM", "anim/poop.zip"),
}

local fertilizer_projectile_prefabs =
{
    "slingshotammo_hitfx_poop",
}

local DAMAGE_SANITY=10
local WORMWOOD_HEAL=2

local function OnHitPoop(inst, attacker, target)
    local proj=SpawnPrefab("slingshotammo_hitfx_poop")
    local x,y,z=inst.Transform:GetWorldPosition()
    proj.Transform:SetPosition(x,y-2,z)

    local ent=TheSim:FindEntities(x,y,z,1, {"player"})
    if #ent > 0 then
        for k,v in ipairs(ent) do
            if (inst.item.prefab=="poop" or inst.item.prefab=="guano") and v.prefab=="wormwood" then
                v.components.health:DoDelta(WORMWOOD_HEAL)
            else
                v.components.sanity:DoDelta(-DAMAGE_SANITY)
                v:PushEvent("attacked", { attacker = attacker, damage = 0 })
            end
        end

    else
        inst.SoundEmitter:PlaySound(inst.item.components.fertilizer.fertilize_sound)

        if inst.target.components.pickable and inst.target.components.pickable:IsBarren() then
            inst.target.components.pickable:Fertilize(inst.item)
        end
        if inst.target.components.grower then
            inst.target.components.grower:Fertilize(inst.item)
        end
    end


    inst:DoTaskInTime(0.11, function() inst:Remove() end) -- This timer is just to give time to the item to play the sound
end

local function fertilizer_projectile_fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst.entity:AddPhysics()
    inst.Physics:SetMass(1)
    inst.Physics:SetFriction(0)
    inst.Physics:SetDamping(0)
    inst.Physics:SetCollisionGroup(COLLISION.CHARACTERS)
    inst.Physics:ClearCollisionMask()
    inst.Physics:CollidesWith(COLLISION.GROUND)
    inst.Physics:SetCapsule(0.2, 0.2)
    inst.Physics:SetDontRemoveOnSleep(true)

    inst:AddTag("projectile")
    inst:AddTag("NOCLICK")

    inst.AnimState:SetBank("poop")
    inst.AnimState:SetBuild("poop")
    inst.AnimState:PlayAnimation("idle", true)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("locomotor")

    inst:AddComponent("complexprojectile")


    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false

    inst.target=nil
    inst.item=nil

    inst.components.complexprojectile:SetHorizontalSpeed(15)
    inst.components.complexprojectile:SetGravity(-25)
    inst.components.complexprojectile:SetLaunchOffset(Vector3(0, 2.35, 0))
    inst.components.complexprojectile:SetOnHit(OnHitPoop)

    return inst
end


return Prefab("fertilizer_projectile", fertilizer_projectile_fn, fertilizer_projectile_assets, fertilizer_projectile_prefabs)
