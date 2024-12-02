---
--- @author zsh in 2023/2/9 21:32
---

env.AddPrefabPostInit("nutrients_overlay", function(inst)
    inst:AddTag("mie_nutrients_overlay");
end)

--[[env.AddPrefabPostInit("fruitflyfruit", function(inst)
    if not TheWorld.ismastersim then
        return inst;
    end
    inst:AddComponent("tradable");
end)]]
