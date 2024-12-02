---
--- @author zsh in 2023/2/11 22:42
---

-- 修改所有有combat的预制物

-- 其实还需要完善的...
env.AddComponentPostInit("combat", function(self)
    self.inst:DoTaskInTime(0, function(inst)
        local function player_say(player, target)
            if player == target then
                if player.components.talker then
                    player.components.talker:Say("它息怒了！");
                end
            end
        end
        -- 我还是想知道，为什么在 combat 组件里面，具体还有没有 combat 组件的预制物？
        -- 虽然因为我加了延迟，但是为什么有某个预制物会在初始化 combat 后，又把 combat 移除了呢？
        if inst and inst.components and inst.components.combat then
            if inst.components.combat.targetfn then
                local old_TryRetarget = inst.components.combat.TryRetarget;
                inst.components.combat.TryRetarget = function(self)
                    if old_TryRetarget then
                        old_TryRetarget(self);
                    end
                    if self.targetfn ~= nil
                            and not (self.inst.components.health ~= nil and
                            self.inst.components.health:IsDead())
                            and not (self.inst.components.sleeper ~= nil and
                            self.inst.components.sleeper:IsInDeepSleep()) then
                        --if self.inst.prefab == "klaus" then
                        --    print("[1] self.target: "..tostring(self.target));
                        --end
                        if self.target and self.target:HasTag("mie_notarget") then
                            --player_say(self.target); -- 不行，这个想法实现不了。
                            self:SetTarget(nil);
                            -- 尝试搜搜其他目标
                            -- 目前已知克劳斯需要修改一下
                        end
                    end
                end
            end

            if inst.components.combat.keeptargetfn then
                local old_keeptargetfn = inst.components.combat.keeptargetfn;
                inst.components.combat.keeptargetfn = function(inst, target)
                    if target:HasTag("mie_notarget") then
                        return false;
                    end
                    return old_keeptargetfn(inst, target);
                end
            end
        end
    end)
end);