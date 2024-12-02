---
--- Created by zsh.
--- DateTime: 2023/9/4 17:20
---

local function RandomGive(inst, data)
    local give = math.random() < 0.001;
    if give then
        local prefab = "mone_pheromonestone";
        if math.random() < 0.5 then
            prefab = "mone_pheromonestone2";
        end
        local spawnPrefab = SpawnPrefab(prefab);
        if spawnPrefab then
            inst.components.inventory:GiveItem(spawnPrefab);
        end
    end
end

env.AddPlayerPostInit(function(inst)
    if not TheWorld.ismastersim then
        return inst;
    end
    inst:ListenForEvent("picksomething", RandomGive);
    inst:ListenForEvent("harvestsomething", RandomGive);
    inst:ListenForEvent("takesomething", RandomGive);
    inst:ListenForEvent("actionfailed", RandomGive);
end)
