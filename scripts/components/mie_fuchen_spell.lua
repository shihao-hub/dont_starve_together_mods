---
--- @author zsh in 2023/6/1 13:03
---


local function oncanspell(self,canspell)
    if canspell then
        self.inst:AddTag("mie_can_spell_fuchen")
    else
        self.inst:RemoveTag("mie_can_spell_fuchen")
    end
end

local fuchen_spell = Class(function(self, inst)
    self.inst = inst
    self.spell = nil
    self.canspell = true
end,
        nil,
        {
            canspell = oncanspell
        })


function fuchen_spell:SetSpellFn(fn)
    self.spell = fn
end

function fuchen_spell:CastSpell(doer,target)
    if self.spell ~= nil then
        self.spell(self.inst, doer, target)
    end
end

return fuchen_spell
