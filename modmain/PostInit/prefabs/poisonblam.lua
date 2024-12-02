---
--- @author zsh in 2023/1/25 4:09
---

--[[ 毒药膏是目标直接腐烂 ]]
env.AddPrefabPostInitAny(function(inst)
    if not TheWorld.ismastersim then
        return inst;
    end
    if inst.components.perishable then
        inst:AddTag("mone_poisonblam_perishable_target");
    end
end)