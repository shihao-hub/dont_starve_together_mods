---
--- @author zsh in 2023/5/22 16:54
---

-- 2023-05-26：此处不是太算被使用

local Multithruster = Class(function(self, inst)
    self.inst = inst
    self.ready = true
    self.damage = 0
    self.cooldown = 5

    self.inst:ListenForEvent("battlecry", function()
        if self.ready then
            self.inst:AddTag("multithruster")
        end
    end)
end)

-- Starts the thrust attack
function Multithruster:StartThrusting(player)
    if player.sg then
        self.damage = player.components.combat:CalcDamage(nil, self.inst, nil)
        player.sg:PushEvent("start_multithrust")
        return true
    end
    return false
end

-- Creates a thrust that hits the given target
function Multithruster:DoThrust(player, target)
    if player.sg then
        player.sg:PushEvent("do_multithrust")
    end
    player.components.combat:DoAttack(target, nil, nil, "strong", nil, self.damage)
end

-- Stop thrusting and reset it
function Multithruster:StopThrusting(player)
    if player.sg then
        player.sg:PushEvent("stop_multithrust")
    end
    self.ready = false
    self.inst:RemoveTag("multithruster")
    self.damage = 0
    self.inst:DoTaskInTime(5, function()
        self.ready = true
    end)
end

function Multithruster:SetCooldown(cooldown)
    self.cooldown = cooldown
end

return Multithruster