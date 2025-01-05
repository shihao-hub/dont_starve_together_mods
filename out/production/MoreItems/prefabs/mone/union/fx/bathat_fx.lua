---
--- @author zsh in 2023/1/15 2:42
---

local assets = {
    Asset("ANIM", "anim/mone_bathat_fx.zip")
}

-- TEMP
local Despawn = function(inst, time)
    -- 渐隐消失
    time = time or 1
    local progress = 1
    inst:DoPeriodicTask(0, function()
        for k in pairs(inst.fx)do
            if k:IsValid() then
                k.scale_mult = progress
                local a = progress * inst.base_alpha
                k.AnimState:SetMultColour(a, a, a, a)
            end
        end
        progress = progress - FRAMES/time
        if progress < 0 then
            inst:Remove()
        end
    end)
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("mone_bathat_fx")
    inst.AnimState:SetBuild("mone_bathat_fx")
    inst.AnimState:PlayAnimation("idle")

    inst:AddTag("NOCLICK")
    inst:AddTag("FX")

    inst:AddTag("acb_cloud_fx_beta")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    -- inst.Despawn = Despawn

    return inst
end

return Prefab("mone_bathat_fx", fn, assets)
