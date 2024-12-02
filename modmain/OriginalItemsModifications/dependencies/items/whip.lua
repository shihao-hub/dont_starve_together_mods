---
--- @author zsh in 2023/4/25 0:00
---

-- 三尾猫鞭
items_fns.whip.onpreload = function(inst, is_reload_game)
    if not decision_fn(inst, "whip") then
        return ;
    end
end
items_fns.whip.onload = function(inst, is_reload_game)
    if not decision_fn(inst, "whip") then
        return ;
    end
    if inst.components.named == nil or inst.components.weapon == nil then
        return ;
    end

    inst.components.named:SetName("修改版·" .. tostring(STRINGS.NAMES[inst.prefab:upper()]));

    -- 武器伤害翻倍
    inst.components.weapon:SetDamage(TUNING.WHIP_DAMAGE * 2);
end