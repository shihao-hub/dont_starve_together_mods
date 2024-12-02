---
--- @author zsh in 2023/1/17 21:34
---

-- 设置小偷的掉落物


env.AddComponentPostInit("combat", function(self)
    -- 去除尝试攻击
    local old_TryRetarget = self.TryRetarget;
    function self:TryRetarget(...)
        if self.inst.mone_bandit_near then
            -- klei scripts/components/combat.lua TryRetarget 函数源代码
            if self.targetfn ~= nil
                    and not (self.inst.components.health ~= nil and
                    self.inst.components.health:IsDead())
                    and not (self.inst.components.sleeper ~= nil and
                    self.inst.components.sleeper:IsInDeepSleep()) then

                local newtarget, forcechange = self.targetfn(self.inst)
                if newtarget ~= nil and newtarget ~= self.target and not newtarget:HasTag("notarget") then
                    if newtarget:HasTag("equip_mone_bandit") then
                        return;
                    end
                end
            end
        elseif old_TryRetarget then
            old_TryRetarget(self, ...);
        end
    end
end)
