---
--- @author zsh in 2023/5/23 2:04
---

local crackle_assets = { -- TODO rename
    Asset("ANIM", "anim/lavaarena_hammer_attack_fx.zip"),
}
------------

local crackle_prefabs = { -- TODO rename
    "me_forginghammer_cracklebase_fx", -- TODO rename
}
------------

--------------------------------------------------------------------------
-- SHOCK --
--------------------------------------------------------------------------
local function CrackleFN()
    local fx = ReForged.COMMON_FNS.FXEntityInit("lavaarena_hammer_attack_fx", nil, "crackle_hit", {pristine_fn = function(fx)
        fx.entity:AddSoundEmitter()
        ------------

        fx.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
        fx.AnimState:SetFinalOffset(1)
    end})
    ------------

    if not TheWorld.ismastersim then
        return fx
    end
    ------------

    fx.OnSpawn = function(inst, data)
        if data and data.target then
            local target_pos = data.target:GetPosition()
            inst.Transform:SetPosition(target_pos:Get())
            inst.SoundEmitter:PlaySound("dontstarve/impacts/lava_arena/hammer")
            local base_fx = ReForged.COMMON_FNS.CreateFX("me_forginghammer_cracklebase_fx", data.target)
            base_fx.Transform:SetPosition(target_pos:Get())
        end
    end

    return fx
end
------------

local function CrackleBaseFN()
    local fx = ReForged.COMMON_FNS.FXEntityInit("lavaarena_hammer_attack_fx", "lavaarena_hammer_attack_fx", "crackle_projection", {pristine_fn = function(fx)
        fx.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
        fx.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
        fx.AnimState:SetLayer(LAYER_BACKGROUND)
        fx.AnimState:SetSortOrder(3)
        fx.AnimState:SetScale(1.5, 1.5)
    end})
    return fx
end

------------

local function ElectricFN() -- TODO need to attach to ent? for pitpigs their lunge is not stopped instantly so this fx could be behind them a few units. Should it be attached? spawned inside the stun state and the stimuli is passed through and checked there? set parent will attach to ent
    --local inst = COMMON_FNS.FXEntityInit("lavaarena_hammer_attack_fx", "lavaarena_hammer_attack_fx", "crackle_loop", {noanimover = true})
    local fx = ReForged.COMMON_FNS.FXEntityInit("lavaarena_hammer_attack_fx", nil, "crackle_loop", {remove_fn = ElectricRemoveFN, pristine_fn = function(fx)
        fx.entity:AddSoundEmitter()
        ------------

        fx.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
        fx.AnimState:SetFinalOffset(1)
        fx.AnimState:SetScale(1.5, 1.5)
        fx.AnimState:PushAnimation("crackle_loop")
        fx.AnimState:PushAnimation("crackle_pst")
    end})
    ------------

    if not TheWorld.ismastersim then
        return fx
    end
    ------------

    fx.OnSpawn = function(inst, data)
        local target = data and data.target
        if target then
            inst.Transform:SetPosition(target:GetPosition():Get())
            inst.SoundEmitter:PlaySound("dontstarve/impacts/lava_arena/electric")
            if target:HasTag("largecreature") or target:HasTag("epic") then
                inst.AnimState:SetScale(2, 2)
            end
        end
    end
    ------------

    fx:ListenForEvent("animqueueover", function(inst) -- TODO is this used? can't remember if this is triggered
        inst:Remove()
    end)
    ------------

    return fx
end
------------

return
-- Electrocute
Prefab("me_forginghammer_crackle_fx", CrackleFN, crackle_assets, crackle_prefabs),
Prefab("me_forginghammer_cracklebase_fx", CrackleBaseFN, crackle_assets),
Prefab("me_forge_electrocute_fx", ElectricFN, crackle_assets)