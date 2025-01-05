---
--- @author zsh in 2023/1/24 16:27
---

local function OnPhaseChange(inst, phase)
    if not phase then
        return ;
    end
    if phase == "night" then
        inst:DoTaskInTime(1, function(inst)
            if inst and inst:IsValid() and inst.Light then
                inst.Light:Enable(true);
            end
        end)
        return ;
    end
    inst:DoTaskInTime(1, function(inst)
        if inst and inst:IsValid() and inst.Light then
            inst.Light:Enable(false);
        end
    end)
end

-- 好像不需要 Network？
local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()
    inst.entity:AddSoundEmitter()

    inst.entity:AddLight()
    inst.Light:SetIntensity(0.5) -- 提灯[0.4,0.6]
    --inst.Light:SetColour(200 / 255, 200 / 255, 200 / 255) -- 雪白？
    inst.Light:SetColour(180 / 255, 195 / 255, 150 / 255) -- 提灯
    inst.Light:SetFalloff(.9)  -- 提灯
    inst.Light:SetRadius(4) -- 提灯[3,5]
    inst.Light:Enable(false);

    inst:AddTag("FX")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false;

    inst:WatchWorldState("phase", OnPhaseChange);

    --inst.OnPhaseChange = OnPhaseChange;

    -- 执行一次
    inst:DoTaskInTime(0.1, function(inst)
        OnPhaseChange(inst, TheWorld.state.phase);
    end);

    return inst;
end

return Prefab("mone_light_fx", fn);