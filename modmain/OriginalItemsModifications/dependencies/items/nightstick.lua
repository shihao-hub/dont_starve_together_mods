---
--- @author zsh in 2023/4/25 0:00
---

-- 晨星锤
items_fns.nightstick.onpreload = function(inst,is_reload_game)
    if not decision_fn(inst, "nightstick") then
        return ;
    end
end
items_fns.nightstick.onload = function(inst,is_reload_game)
    if not decision_fn(inst, "nightstick") then
        return ;
    end
    if inst.components.named == nil then
        return ;
    end

    inst.components.named:SetName("修改版·" .. tostring(STRINGS.NAMES[inst.prefab:upper()]));

    -- 可以修复
    -- 这里是主机部分，但是我的 mone_repair_materials 需要添加在主客机，懒得修改了，打个补丁吧！
    inst.mone_repair_materials = { transistor = 0.5 };
    inst:AddTag("mone_can_be_repaired");
    inst:AddTag("mone_can_be_repaired_modify_nightstick");
end