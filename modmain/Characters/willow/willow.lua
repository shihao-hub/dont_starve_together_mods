---
--- @author zsh in 2023/4/21 12:33
---

local config_data = TUNING.MONE_TUNING.GET_MOD_CONFIG_DATA;

local function onkilled(inst, data)
    local victim = data and data.victim;
    if victim and victim.components.burnable then
        if victim.components.burnable:IsBurning() then
            -- true 好像可以停止蔓延？
            victim.components.burnable:Extinguish(true, -1, nil);
        end
    end
end

local TEMPERATURE_OFFSET = 20;

local function IsOverheating(old_fn)
    return function(inst, ...)
        if inst.components.temperature ~= nil then
            return inst.components.temperature:IsOverheating()
        elseif inst.player_classified ~= nil then
            return inst.player_classified.currenttemperature > TUNING.OVERHEAT_TEMP + TEMPERATURE_OFFSET;
        else
            return old_fn and old_fn(inst, ...);
        end
    end
end

env.AddPrefabPostInit("willow", function(inst)
    -- 更不容易过热
    --if config_data.willow_overheattemp then
    --    inst.IsOverheating = IsOverheating(inst.IsOverheating);
    --end

    if not TheWorld.ismastersim then
        return inst;
    end

    -- 更不容易过热：但是似乎会导致降温过快...
    --if config_data.willow_overheattemp then
    --    if inst.components.temperature then
    --        inst.components.temperature.maxtemp = TUNING.MAX_ENTITY_TEMP + TEMPERATURE_OFFSET;
    --        inst.components.temperature.overheattemp = TUNING.OVERHEAT_TEMP + TEMPERATURE_OFFSET;
    --    end
    --end

    -- 不会烧掉战利品
    if config_data.willow_not_burning_loots then
        inst:ListenForEvent("killed", onkilled);
    end
end)

-- 添加新动作：右键点击薇洛可以灭掉周围的火焰和焖烧，其中该动作优先级应该设置为极低



-- 薇洛可以拥抱伯尼，拥抱期间伯尼处于无敌状态
