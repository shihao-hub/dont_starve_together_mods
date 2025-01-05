---
--- @author zsh in 2023/8/1 20:52
---


local function oncanspell(self, canspell)
    if canspell then
        self.inst:AddTag("mone_can_spell_whip")
    else
        self.inst:RemoveTag("mone_can_spell_whip")
    end
end

local whip_spell = Class(function(self, inst)
    self.inst = inst;
    self.spell = nil;
    self.canspell = true;
end, nil, { 
    canspell = oncanspell 
})

function whip_spell:SetSpellFn(fn)
    self.spell = fn;
end

function whip_spell:CastSpell(doer, target)
    if self.spell ~= nil then
        self.spell(self.inst, doer, target);
    end
end

return whip_spell
