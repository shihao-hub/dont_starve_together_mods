---
--- @author zsh in 2023/1/15 21:26
---


local assets = {
    Asset("ANIM", "anim/wilsonstatue.zip")
};

local function fn_structure()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst.entity:AddLabel()
    inst.Label:SetFontSize(50)
    inst.Label:SetFont(DEFAULTFONT)
    inst.Label:SetWorldOffset(0, 3, 0)
    inst.Label:SetUIOffset(0, 0, 0)
    inst.Label:SetColour(1, 1, 1)
    inst.Label:Enable(true)

    MakeObstaclePhysics(inst, .3)

    inst.AnimState:SetBank("wilsonstatue")
    inst.AnimState:SetBuild("wilsonstatue")
    inst.AnimState:PlayAnimation("idle")

    inst:AddTag("monster")

    MakeSnowCoveredPristine(inst)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst;
    end

    inst:AddComponent("inspectable")

    inst:AddComponent("combat")

    inst:AddComponent("bloomer")

    inst:AddComponent("colouradder")

    inst:AddComponent("debuffable")
    inst.components.debuffable:SetFollowSymbol("ww_head", 0, -250, 0)

    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(1000)
    inst.components.health:StartRegen(1000, .1)
    inst:ListenForEvent("healthdelta", function(inst, data)
        if data.amount <= 0 then
            inst.Label:SetText(data.amount)
            inst.Label:SetUIOffset(math.random() * 20 - 10, math.random() * 20 - 10, 0)
            inst.AnimState:PlayAnimation("hit")
            inst.AnimState:PushAnimation("idle")
        end
    end)

    --if TheNet:GetServerGameMode() == "lavaarena" then
    --    TheWorld:PushEvent("ms_register_for_damage_tracking", { inst = inst })
    --end

end

return Prefab("mone_puppet", fn_structure, assets)