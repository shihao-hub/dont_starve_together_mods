---
--- @author zsh in 2023/6/2 11:59
---

local assets =
{
    Asset("ANIM", "anim/boat_net.zip"),
}

local function fn()
    local inst = CreateEntity()

    inst:AddTag("ignorewalkableplatforms")

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()

    inst.Transform:SetFourFaced()

    inst:AddTag("NOCLICK")
    inst:AddTag("mone_fishingnetvisualizer")

    inst.AnimState:SetBank("boat_net")
    inst.AnimState:SetBuild("boat_net")
    inst.AnimState:SetSortOrder(5)

    inst:AddComponent("groundshadowhandler")
    inst.components.groundshadowhandler:SetSize(3, 2)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.item = nil -- uc:new

    inst:SetStateGraph("mone_SGfishingnetvisualizer")

    inst:AddComponent("fishingnetvisualizer")

    return inst
end

return Prefab("mone_fishingnetvisualizer", fn, assets)
