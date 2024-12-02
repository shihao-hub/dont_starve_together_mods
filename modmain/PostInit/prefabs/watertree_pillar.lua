---
--- @author zsh in 2023/4/4 20:15
---

env.AddPrefabPostInit("world", function(inst)
    if not TheWorld.ismastersim then
        return inst;
    end
    if not inst:HasTag("forest") then
        return inst;
    end
    inst:AddComponent("mone_watertree_pillar");
end)