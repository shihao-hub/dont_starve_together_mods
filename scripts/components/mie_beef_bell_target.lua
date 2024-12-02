---
--- @author zsh in 2023/2/5 20:25
---

local BeefBellTarget = Class(function(self, inst)
    self.inst = inst;

    self.beefalo_record = nil;

    -- NOTE: �Ƴ� inuse_targeted ��ǩ�Ϳ����öϿ����ӵĶ�����ʧ��
    -- ���ǻ���Ҫ��֤��������Ȼ�޷����ӣ�inst.UseableTargetedItem_ValidTarget(inst, target, doer) ����hookһ��Ӧ�þ����ˡ�

    if inst.components.timer == nil then
        inst:AddComponent("timer");
    end

    ---? ��Ѫ��Σ�
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
    -- �����޵�����
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