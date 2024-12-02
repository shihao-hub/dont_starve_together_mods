---
--- @author zsh in 2023/1/15 15:11
---

env.AddPrefabPostInit("mone_gogglesnormal",function(inst)

    if not TheWorld.ismastersim then
        return inst;
    end

end)