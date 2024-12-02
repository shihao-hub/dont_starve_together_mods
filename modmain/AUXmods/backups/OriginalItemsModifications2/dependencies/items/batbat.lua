---
--- @author zsh in 2023/4/25 0:00
---

-- 蝙蝠棒
return function(inst)
    print("蝙蝠棒：inst.mi_ori_item_modify_tag：" .. tostring(inst.mi_ori_item_modify_tag));
    if not inst.mi_ori_item_modify_tag then
        return inst;
    end

    if not TheWorld.ismastersim then
        return inst;
    end

    if inst.components.named then
        inst.components.named:SetName("修改版·" .. tostring(STRINGS.NAMES[inst.prefab:upper()]));
    end

    if inst.components.finiteuses == nil then
        return inst;
    end

    -- 耐久翻倍
    local percent = inst.components.finiteuses:GetPercent();
    inst.components.finiteuses:SetMaxUses(TUNING.BATBAT_USES * 2);
    inst.components.finiteuses:SetUses(inst.components.finiteuses.total * percent);

end