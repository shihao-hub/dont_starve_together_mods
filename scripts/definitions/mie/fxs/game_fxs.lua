---
--- @author zsh in 2023/2/27 14:52
---

local function FinalOffset1(inst)
    inst.AnimState:SetFinalOffset(1)
end

local function FinalOffset2(inst)
    inst.AnimState:SetFinalOffset(2)
end

local function FinalOffset3(inst)
    inst.AnimState:SetFinalOffset(3)
end

local function FinalOffsetNegative1(inst)
    inst.AnimState:SetFinalOffset(-1)
end

local function UsePointFiltering(inst)
    inst.AnimState:UsePointFiltering(true)
end

local function GroundOrientation(inst)
    inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
    inst.AnimState:SetLayer(LAYER_BACKGROUND)
end

local function Bloom(inst)
    inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
    inst.AnimState:SetFinalOffset(1)
end

local function BloomOrange(inst)
    inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
    --    inst.AnimState:SetMultColour(204/255,131/255,57/255,1)
    inst.AnimState:SetMultColour(219 / 255, 168 / 255, 117 / 255, 1)
    inst.AnimState:SetFinalOffset(1)
end

local function OceanTreeLeafFxFallUpdate(inst)
    local x, y, z = inst.Transform:GetWorldPosition()
    inst.Transform:SetPosition(x, y - inst.fall_speed * FRAMES, z)
end

local fx = {
    {
        name = "wanda_attack_pocketwatch_old_fx",
        bank = "pocketwatch_weapon_fx",
        build = "pocketwatch_weapon_fx",
        anim = function()
            return "idle_big_" .. math.random(3)
        end,
        --sound = "wanda2/characters/wanda/watch/weapon/shadow_hit_old",
        fn = FinalOffset1,
    },
    {
        name = "wanda_attack_pocketwatch_normal_fx",
        bank = "pocketwatch_weapon_fx",
        build = "pocketwatch_weapon_fx",
        anim = function()
            return "idle_med_" .. math.random(3)
        end,
        --sound = "wanda2/characters/wanda/watch/weapon/nightmare_FX",
        fn = FinalOffset1,
    },
    {
        name = "wanda_attack_shadowweapon_old_fx",
        bank = "pocketwatch_weapon_fx",
        build = "pocketwatch_weapon_fx",
        anim = function()
            return "idle_big_" .. math.random(3)
        end,
        --sound = "wanda2/characters/wanda/watch/weapon/shadow_hit",
        fn = function(inst)
            inst.AnimState:Hide("white")
            inst.AnimState:SetFinalOffset(1)
        end,
    },
    {
        name = "wanda_attack_shadowweapon_normal_fx",
        bank = "pocketwatch_weapon_fx",
        build = "pocketwatch_weapon_fx",
        anim = function()
            return "idle_med_" .. math.random(3)
        end,
        --sound = "wanda2/characters/wanda/watch/weapon/nightmare_FX",
        fn = FinalOffset1,
    }
}

for _, v in ipairs(fx) do
    v.name = "mie_" .. v.name;
end

FinalOffset1 = nil
FinalOffset2 = nil

return fx
