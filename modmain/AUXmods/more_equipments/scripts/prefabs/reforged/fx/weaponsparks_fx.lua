---
--- @author zsh in 2023/5/22 18:04
---

-- 注意：此处是自定义的内容，不是模板化内容

local assets = {
    Asset("ANIM", "anim/lavaarena_hit_sparks_fx.zip"),
}

local function fn()
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
    ------------

    inst.SetPosition = function(inst, player, target) -- For melee weapons
        local offset = (player:GetPosition() - target:GetPosition()):GetNormalized()*(target.Physics and target.Physics:GetRadius() or 1)
        offset.y = offset.y + 1 + math.random(-5, 5)/10
        inst.Transform:SetPosition((target:GetPosition() + offset):Get())
        inst.AnimState:PlayAnimation("hit_3")
        inst.AnimState:SetScale(player:GetRotation() > 0 and -.7 or .7,.7)
    end
    ------------

    inst.SetPiercing = function(inst, source, target) -- For projectile weapons
        local offset = (source:GetPosition() - target:GetPosition()):GetNormalized()*(target.Physics and target.Physics:GetRadius() or 1)
        offset.y = offset.y + 1 + math.random(-5, 5)/10
        inst.Transform:SetPosition((target:GetPosition() + offset):Get())
        inst.AnimState:PlayAnimation("hit_3")
        inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
        inst.Transform:SetRotation(inst:GetAngleToPoint(target:GetPosition():Get()) + 90)
    end
    ------------

    inst.SetThrusting = function(inst, target, offset) -- For Maxwell's shadow puppets
        inst.Transform:SetPosition((target:GetPosition() + offset):Get())
        inst.AnimState:PlayAnimation("hit_3")
        inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
        inst.Transform:SetRotation(inst:GetAngleToPoint(target:GetPosition():Get()) + 90)
    end
    ------------

    inst.SetBounce = function(inst, owner) -- For missing with Lucy
        inst.Transform:SetPosition(owner:GetPosition():Get())
        inst.AnimState:PlayAnimation("hit_2")
        inst.AnimState:Hide("glow")
        inst.AnimState:SetScale(owner:GetRotation() > 0 and 1 or -1, 1)
    end
    ------------

    inst:ListenForEvent("animover", inst.Remove)
    inst.OnLoad = inst.Remove;

    return inst
end

return Prefab("me_weaponsparks_fx", fn, assets)