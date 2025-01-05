---
--- @author zsh in 2023/5/23 1:46
---

-- 2023-05-26：此处暂时未使用

local SYMBOL_OFFSET = -130

local ArmorBreak_Debuff = Class(function(self, inst)
    self.inst = inst
    self.followsymbol = nil
    self.debuffed = false
    self.debufflevel = 0
    self.timer = 0
    self.followoffset = Vector3(0, SYMBOL_OFFSET, 0)
end)

function ArmorBreak_Debuff:SetFollowSymbol(symbol, offset)
    self.followsymbol = symbol
    if offset then
        self.followoffset = Vector3(offset.x, offset.y, offset.z)
    end
end

function ArmorBreak_Debuff:ApplyDebuff(time)
    self.timer = time or 4
    if not self.debuffed then
        self.debuffed = true
        self:RunTimer()
    end
    if self.debufflevel < 5 then
        self.debufflevel = self.debufflevel + 1
    end
    self.inst.components.combat:AddDamageBuff("armorbreak", {
        buff = function(attacker, victim, weapon, stimuli)
            if victim and victim == self.inst then
                return 1 + 0.02*self.debufflevel
            end
        end
    }, true)
    if self.debuff_fx == nil then
        self.debuff_fx = ShiHao.ReForged.COMMON_FNS.CreateFX("forgedebuff_fx", self.inst)
    end
end

function ArmorBreak_Debuff:RunTimer()
    if self.timer == 0 then
        self:RemoveDebuff()
    elseif self.timer > 0 then --if its negative, then never run the timer.
        self.timer = self.timer - 1
        self.inst:DoTaskInTime(1, function() self:RunTimer() end)
    end
end

function ArmorBreak_Debuff:RemoveDebuff()
    if self.debuff_fx then
        self.debuff_fx.AnimState:PlayAnimation("pst")
        self.debuff_fx = nil
    end
    self.debuffed = false
    self.debufflevel = 0
    self.inst.components.combat:RemoveDamageBuff("armorbreak", true)
end

return ArmorBreak_Debuff
