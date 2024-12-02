---
--- @author zsh in 2023/5/22 18:08
---

-- 注意：此处是自定义的内容，不是模板化内容
local assets = {
    Asset("ANIM", "anim/lavaarena_hits_variety.zip"),
}

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    inst:AddTag("FX")

    inst.AnimState:SetBank("lavaarena_hits_variety")
    inst.AnimState:SetBuild("lavaarena_hits_variety")
    inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
    inst.AnimState:SetFinalOffset(1)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end
    ------------

    inst.SetTarget = function(inst, target)
        inst.Transform:SetPosition(target:GetPosition():Get())
        inst.AnimState:PlayAnimation("hit_"..(target:HasTag("minion") and 1 or (target:HasTag("largecreature") and 3 or 2)))
        inst.AnimState:SetScale(target:HasTag("minion") and 1 or -1, 1)
    end
    ------------

    inst:ListenForEvent("animover", inst.Remove);
    inst.OnLoad = inst.Remove;

    return inst;
end
return Prefab("me_forgespear_fx", fn, assets)