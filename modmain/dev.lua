---
--- @author zsh in 2023/5/20 15:37
---

-- 超级攻速测试：写的不对，简单这样写是没用的。还需要改 sg
if false then
    -----@return
    ---- SuperAttackSpeed
    --local function SuperAttackSpeedSingleTab()
    --    ---@class SuperAttackSpeed
    --    local Data = {
    --        PLAYERS_ATTACK_PERIOD = {};
    --    };
    --
    --    local PLAYERS_ATTACK_PERIOD = Data.PLAYERS_ATTACK_PERIOD;
    --
    --    function Data.oneat(inst, data)
    --        local food = data and data.food;
    --        if null(food) then
    --            return ;
    --        end
    --        if food.prefab == "meatballs" then
    --            local TOTAL_TIME = 480;
    --            local MIN_ATTACK_PERIOD = 0.2;
    --            if not inst.components.timer:TimerExists("super_attack_speed") then
    --                inst.components.talker:Say("超级攻速效果生效了");
    --                inst.components.timer:StartTimer("super_attack_speed", TOTAL_TIME);
    --                inst.components.combat:SetAttackPeriod(MIN_ATTACK_PERIOD);
    --            else
    --                -- DoNothing：续上？
    --                local timeleft = inst.components.timer:GetTimeLeft("super_attack_speed");
    --                if timeleft then
    --                    inst.components.talker:Say("超级攻速效果续上了");
    --                    inst.super_attack_speed_extended_tag = true;
    --                    inst.components.timer:StopTimer("super_attack_speed");
    --                    inst.components.timer:StartTimer("super_attack_speed", TOTAL_TIME + timeleft);
    --                    inst.components.combat:SetAttackPeriod(MIN_ATTACK_PERIOD);
    --                end
    --            end
    --        end
    --    end
    --
    --    function Data.timerdone(inst, data)
    --        local name = data and data.name;
    --        if name == "super_attack_speed" then
    --            if inst.super_attack_speed_extended_tag then
    --                inst.super_attack_speed_extended_tag = nil;
    --            else
    --                inst.components.talker:Say("超级攻速效果消失了");
    --            end
    --            if PLAYERS_ATTACK_PERIOD[inst.prefab] then
    --                inst.components.combat:SetAttackPeriod(PLAYERS_ATTACK_PERIOD[inst.prefab]);
    --            end
    --        end
    --    end
    --
    --    return Data;
    --end
    -----@type
    ---- SuperAttackSpeed
    --local SuperAttackSpeedData = SuperAttackSpeedSingleTab();
    --env.AddPlayerPostInit(function(inst)
    --    if not TheWorld.ismastersim then
    --        return inst;
    --    end
    --    local Data = SuperAttackSpeedData;
    --
    --    if Data.PLAYERS_ATTACK_PERIOD[inst.prefab] == nil then
    --        Data.PLAYERS_ATTACK_PERIOD[inst.prefab] = inst.components.combat.min_attack_period;
    --    end
    --
    --    if null(inst.components.timer) then
    --        inst:AddComponent("timer");
    --    end
    --    inst:ListenForEvent("timerdone", Data.timerdone);
    --    inst:ListenForEvent("oneat", Data.oneat);
    --end)
end