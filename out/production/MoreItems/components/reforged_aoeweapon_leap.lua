---
--- @author zsh in 2023/5/22 16:49
---


-- 呃，这里应该需要继承一下基类 AOEWeapon_Base，不然少东西
local AOEWeapon_Leap = Class(function(self, inst)
    self.inst = inst
    self.radius = 4
    self.damage = nil
    self.stimuli = nil
    self.onleap = nil
end)

function AOEWeapon_Leap:SetRange(radius)
    self.radius = radius
end

function AOEWeapon_Leap:SetStimuli(stimuli)
    self.stimuli = stimuli
end

function AOEWeapon_Leap:SetOnLeapFn(fn)
    self.onleap = fn
end
------------


function AOEWeapon_Leap:DoLeap(leaper, startingpos, targetpos)
    local scale = leaper.components.scaler and leaper.components.scaler.scale or 1
    local targets = ShiHao.ReForged.COMMON_FNS.EQUIPMENT.GetAOETargets(leaper, targetpos, self.radius * scale, nil, ShiHao.ReForged.COMMON_FNS.GetPlayerExcludeTags(leaper))

    --if self.inst.components.weapon and self.inst.components.weapon:HasAltAttack() then
    --    self.inst.components.weapon:DoAltAttack(leaper, targets, nil, self.stimuli)
    --end
    self.inst.components.weapon:ReForgedDoAttack(leaper, targets, nil, self.stimuli)

    if self.onleap then
        self.onleap(self.inst, leaper, startingpos, targetpos)
    end
end

return AOEWeapon_Leap