---
--- @author zsh in 2023/1/10 21:36
---

local assets =
{
    Asset("ANIM", "anim/sprinkler_fx.zip")
}

local prefabs =
{
}

local function fn()
    local inst = CreateEntity()
    inst.entity:AddNetwork() --?
    local trans = inst.entity:AddTransform()
    local anim = inst.entity:AddAnimState()
    local sound = inst.entity:AddSoundEmitter()

    anim:SetBank("sprinkler_fx")
    anim:SetBuild("sprinkler_fx")
    anim:PlayAnimation("spray_loop", true)

    return inst
end

return Prefab("mone_water_spray", fn, assets, prefabs)