---
--- @author zsh in 2023/5/22 17:07
---

local AOESpell = Class(function(self, inst)
    self.inst = inst
    self.casting = false
    self.spell_types = {}
    self.is_spell = false
    self.aoe_cast = nil

    self.inst:AddTag("reforged_aoespell_item");
end)

function AOESpell:SetAOESpell(fn)
    self.aoe_cast = fn
end

function AOESpell:CanCast(caster, pos)
    return self.inst.components.aoetargeting ~= nil and self.inst.components.aoetargeting.alwaysvalid or
            (TheWorld.Map:IsPassableAtPoint(pos:Get()) and not TheWorld.Map:IsGroundTargetBlocked(pos) and TheWorld.Map:IsAboveGroundAtPoint(pos:Get()))
end

function AOESpell:CastSpell(caster, pos, options)
    -- 骑牛不能施法，但是只是施法失败，而不是骑牛的时候没有施法动作...
    ---- 呃，这样不行，这样还是会执行动作的...
    --if caster and caster.components.rider and caster.components.rider:IsRiding() then
    --    return false;
    --end

    self.casting = true
    if self.aoe_cast ~= nil then
        self.aoe_cast(self.inst, caster, pos, options)
    end

    self.inst:PushEvent("aoe_casted", { caster = caster, pos = pos })

    -- 2023-05-22：补充一下
    return true, nil;
end

function AOESpell:SetSpellTypes(spell_types)
    for _, spell_type in pairs(spell_types) do
        self.spell_types[spell_type] = true
        self.is_spell = true
    end
end

function AOESpell:OnSpellCast(caster, targets, projectiles)
    self.casting = false
    caster:PushEvent("spell_complete", { weapon = self.inst, is_spell = self.is_spell, spell_types = self.spell_types, targets = targets, projectiles = projectiles })
end

return AOESpell
