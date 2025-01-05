local assets =
{
    -- Asset("ANIM", "anim/fireflies.zip"),
}

local function CastSpell(player)
    local function CastSpell_p(player)
        -- SpawnPrefab("shadow_bishop_fx").Transform:SetPosition(theplayer.Transform:GetWorldPosition()) 
        player:SpawnChild("panda_casting_spell_fx")
        local san = player.components.sanity:GetPercent()
        local health = player.components.health:GetPercent()
        player.components.sanity:SetPercent(health)
        if san < 0.01 then
            san = 0.01
        end
        player.components.health:SetPercent(san)
    end
    local flg,ret = pcall(CastSpell_p,player)    
end

local function builder_onbuilt(inst, builder)
    -- print(inst,builder,"fake error")
	if builder then
        local spell_name =  inst.prefab
        if builder:HasTag("panda_fisherman") then
            ----------------- 施法者判断并播放立绘
            CastSpell(builder)
            ------ 技能立绘
        else
            ------------------ 其它玩家只能使用一次
            CastSpell(builder)
            builder:PushEvent("Panda_Spell_Remove",{tag = spell_name})
            --------------- 其它特效
        end
    end
    inst:Remove()
end

local function fn()

    local inst = CreateEntity()

    inst.entity:AddTransform()

    inst:AddTag("CLASSIFIED")

    inst.persists = false

    inst:DoTaskInTime(0, inst.Remove)

    


    if not TheWorld.ismastersim then
        return inst
    end

    inst.OnBuiltFn = builder_onbuilt

   
    return inst
end

return Prefab("panda_spell_sanity2health", fn,assets)