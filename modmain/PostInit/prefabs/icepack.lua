---
--- @author zsh in 2023/3/6 22:29
---

env.AddPrefabPostInitAny(function(inst)
    if not TheWorld.ismastersim then
        return inst;
    end
    if inst.components.perishable then
        inst:AddTag("_perishable_mone");
    end
end)