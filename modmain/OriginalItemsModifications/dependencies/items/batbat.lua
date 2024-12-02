---
--- @author zsh in 2023/4/25 0:00
---

-- 蝙蝠棒
items_fns.batbat.onpreload = function(inst, is_reload_game)
    if not decision_fn(inst, "batbat") then
        return ;
    end
end
items_fns.batbat.onload = function(inst, is_reload_game)
    if not decision_fn(inst, "batbat") then
        return ;
    end
    if inst.components.named == nil or inst.components.finiteuses == nil then
        return ;
    end

    inst.components.named:SetName("修改版·" .. tostring(STRINGS.NAMES[inst.prefab:upper()]));

    -- 耐久翻倍
    inst.components.finiteuses:SetMaxUses(TUNING.BATBAT_USES * 2);

    if is_reload_game then
        -- DoNothing
    else
        inst.components.finiteuses:SetUses(TUNING.BATBAT_USES * 2);
    end
end