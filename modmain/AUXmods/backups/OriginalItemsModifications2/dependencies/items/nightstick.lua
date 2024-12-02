---
--- @author zsh in 2023/4/25 0:00
---

-- 晨星锤
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

    -- 可以修复
    -- 这里是主机部分，但是我的 mone_repair_materials 需要添加在主客机，懒得修改了，打个补丁吧！
    inst.mone_repair_materials = { transistor = 0.5 };
    inst:AddTag("mone_can_be_repaired");
    inst:AddTag("mone_can_be_repaired_modify_nightstick");
end