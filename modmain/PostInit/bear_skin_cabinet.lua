---
--- @author zsh in 2023/2/20 0:57
---

env.AddPrefabPostInitAny(function(inst)
    if not TheWorld.ismastersim then
        return inst;
    end
    if inst.components.perishable then
        inst:AddTag("_perishable_mie");
    end
end)