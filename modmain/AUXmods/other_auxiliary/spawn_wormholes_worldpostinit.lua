---
--- @author zsh in 2023/4/3 0:38
---


--env.AddPrefabPostInit("wormhole", function(inst)
--    if not TheWorld.ismastersim then
--        return inst;
--    end
--    if inst.components.timer == nil then
--        inst:AddComponent("timer");
--    end
--end)

env.AddPrefabPostInit("world", function(inst)
    if not TheWorld.ismastersim then
        return inst;
    end
    if not inst:HasTag("forest") then
        return inst;
    end
    inst:AddComponent("more_items_spawn_wormholes");
end)

------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------
TUNING.MONE_TUNING.DebugCommands.SpawnWormTest = function()
    -- 生成一对虫洞
    local wormhole1, wormhole2 = SpawnPrefab("wormhole"), SpawnPrefab("wormhole");
    -- 将二者关联在一起
    wormhole1.components.teleporter:Target(wormhole2);
    wormhole2.components.teleporter:Target(wormhole1);

    wormhole1.Transform:SetPosition(0, 0, 0);
    wormhole2.Transform:SetPosition(20, 0, 20);
end
