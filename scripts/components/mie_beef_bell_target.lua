---
--- @author zsh in 2023/2/5 20:25
---

local BeefBellTarget = Class(function(self, inst)
    self.inst = inst;

    self.beefalo_record = nil;

    -- NOTE: 移除 inuse_targeted 标签就可以让断开连接的动作消失。
    -- 但是还需要保证其他人仍然无法连接，inst.UseableTargetedItem_ValidTarget(inst, target, doer) 函数hook一下应该就行了。

    if inst.components.timer == nil then
        inst:AddComponent("timer");
    end

    ---? 锁血如何？
    inst:ListenForEvent("death", function(inst, data)
        if inst.components.mie_beef_bell_target then
            inst.components.mie_beef_bell_target.beefalo_record = inst:GetSaveRecord();
        end
        if not inst.components.timer:TimerExists("mie_bb_revive") then
            inst.components.timer:StartTimer("mie_bb_revive", TUNING.SEG_TIME * 16 * 3);
        end
    end);

end)

function BeefBellTarget:Main()
    local inst = self.inst;
    -- 死亡无掉落物
    if inst.components.lootdropper then
        inst.components.lootdropper:SetChanceLootTable(nil);
    end
end

function BeefBellTarget:OnSave()
    return {
        beefalo_record = self.beefalo_record;
    }
end

function BeefBellTarget:OnLoad(data)
    if data then
        if data.beefalo_record then
            self.beefalo_record = data.beefalo_record;
        end
    end
end

return BeefBellTarget;