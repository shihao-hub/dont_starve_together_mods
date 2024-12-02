---
--- @author zsh in 2023/4/25 0:00
---

-- 三尾猫鞭
return function(inst)
    if not inst.mi_ori_item_modify_tag then
        return inst;
    end

    if not TheWorld.ismastersim then
        return inst;
    end

    if inst.components.named then
        inst.components.named:SetName("修改版·" .. tostring(STRINGS.NAMES[inst.prefab:upper()]));
    end

    if inst.components.weapon == nil then
        return inst;
    end

    -- 武器伤害翻倍
    inst.components.weapon:SetDamage(TUNING.WHIP_DAMAGE * 2);
end