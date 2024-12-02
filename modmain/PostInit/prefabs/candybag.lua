---
--- @author zsh in 2023/3/14 10:15
---

env.AddPrefabPostInitAny(function(inst)
    if not TheWorld.ismastersim then
        return inst;
    end
    if inst.components.perishable then
        inst:AddTag("_perishable_mone");
    end
    if inst.components.stackable then
        inst:AddTag("_stackable_mone");
    end
    if inst.components.equippable then
        inst:AddTag("_equippable_mone");
    end
end)