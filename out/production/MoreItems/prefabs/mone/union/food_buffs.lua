---
--- @author zsh in 2023/1/18 10:42
---

local buffs = {};

local config_data = TUNING.MONE_TUNING.GET_MOD_CONFIG_DATA;

buffs["mone_buff_bw_attack"] = {
    CanMake = config_data.mone_beef_wellington,
    name = "mone_buff_bw_attack",
    timer = true, -- 有倒计时的 buff
    start_fn = function(inst, target)
        -- inst:buff,target:eater
        if target.components.talker then
            target.components.talker:Say("惠灵顿牛排真好吃，我感觉我充满了力量！")
        end
        if target.components.combat then
            target.components.combat.externaldamagemultipliers:SetModifier(inst, 2.5);
        end
    end,
    end_fn = function(inst, target)
        if target.components.talker then
            target.components.talker:Say("我失去了惠灵顿牛排给我提供的力量");
        end
        if target.components.combat then
            target.components.combat.externaldamagemultipliers:RemoveModifier(inst);
        end
    end,
    refill_fn = function(inst, target)
        if target.components.talker then
            local time_left = inst.components.timer and inst.components.timer:GetTimeLeft("buffover") or 0;
            target.components.talker:Say("我的惠灵顿牛排之力的时间延长了！还有：" .. string.format("%.0f", time_left) .. " 秒！");
        end
    end
}

buffs["mone_buff_hhs_work"] = {
    CanMake = config_data.mone_honey_ham_stick,
    name = "mone_buff_hhs_work",
    timer = true, -- 有倒计时的 buff
    start_fn = function(inst, target)
        target:AddTag("mone_honey_ham_stick_buffer");
        -- inst:buff,target:eater
        if target.components.talker then
            target.components.talker:Say("蜜汁大肉棒真好吃，我感觉我充满了干劲！")
        end
        if target.components.workmultiplier == nil then
            target:AddComponent("workmultiplier")
        end
        target.components.workmultiplier:AddMultiplier(ACTIONS.CHOP, TUNING.BUFF_WORKEFFECTIVENESS_MODIFIER * 1.5, inst)
        target.components.workmultiplier:AddMultiplier(ACTIONS.MINE, TUNING.BUFF_WORKEFFECTIVENESS_MODIFIER * 1.5, inst)
        target.components.workmultiplier:AddMultiplier(ACTIONS.HAMMER, TUNING.BUFF_WORKEFFECTIVENESS_MODIFIER * 1.5, inst)
    end,
    end_fn = function(inst, target)
        target:RemoveTag("mone_honey_ham_stick_buffer");
        if target.components.talker then
            target.components.talker:Say("我失去了蜜汁大肉棒给我提供的力量");
        end
        if target.components.workmultiplier ~= nil then
            target.components.workmultiplier:RemoveMultiplier(ACTIONS.CHOP, inst)
            target.components.workmultiplier:RemoveMultiplier(ACTIONS.MINE, inst)
            target.components.workmultiplier:RemoveMultiplier(ACTIONS.HAMMER, inst)
        end
    end,
    refill_fn = function(inst, target)
        target:AddTag("mone_honey_ham_stick_buffer");
        if target.components.talker then
            local time_left = inst.components.timer and inst.components.timer:GetTimeLeft("buffover") or 0;
            target.components.talker:Say("我的蜜汁大肉棒之力的时间延长了！还有：" .. string.format("%.0f", time_left) .. " 秒！");
        end
    end
}

local function MakeBuff(data)
    local function buffCountDown(inst, data)
        local fns = {};
        -- buff 刚刚生效
        function fns.OnAttached(inst, target)
            -- 对于惠灵顿风干牛排来说，target 就是 eater，inst 就是自身
            inst.entity:SetParent(target.entity);
            inst.Transform:SetPosition(0, 0, 0);
            inst:ListenForEvent("death", function(--[[不要传参，传进来的是 target]])
                --print("---1: "..tostring(inst));
                --print("---2: "..tostring(target));
                --print("---3: "..tostring(inst.components.debuff));
                if inst.components.debuff then
                    -- debuff 会居然出现为空的情况？ 。。。不要传参，要用闭包。参数是后面的 target
                    inst.components.debuff:Stop();
                end
            end, target);

            -- 开始计时
            if not inst.components.timer:TimerExists("buffover") then
                inst.components.timer:StartTimer("buffover", target[data.name].totaltime);
            end

            -- TEMP
            target[data.name] = nil;

            if data.start_fn then
                data.start_fn(inst, target);
            end
        end
        -- buff 时间到
        function fns.OnDetached(inst, target)
            if data.end_fn then
                data.end_fn(inst, target);
            end
            inst:Remove();
        end
        -- buff 续杯
        function fns.OnExtended(inst, target)
            -- 原基础上增加时间
            local time_left = inst.components.timer:GetTimeLeft("buffover") or 0;
            time_left = time_left + target[data.name].totaltime;
            inst.components.timer:StopTimer("buffover");
            inst.components.timer:StartTimer("buffover", time_left);

            if data.refill_fn then
                data.refill_fn(inst, target);
            end
        end

        inst.components.debuff:SetAttachedFn(fns.OnAttached);
        inst.components.debuff:SetDetachedFn(fns.OnDetached);
        inst.components.debuff:SetExtendedFn(fns.OnExtended);

        if inst.components.timer == nil then
            inst:AddComponent("timer");
            inst:ListenForEvent("timerdone", function(inst, data)
                if data.name == "buffover" then
                    inst.components.debuff:Stop();
                end
            end)
        end
    end

    local function fn()
        local inst = CreateEntity()

        --[[ 官方源码 ]]
        if not TheWorld.ismastersim then
            --Not meant for client!
            inst:DoTaskInTime(0, inst.Remove)
            return inst
        end

        inst.entity:AddTransform()
        --[[Non-networked entity]]
        inst.entity:Hide()
        inst.persists = false

        inst:AddTag("CLASSIFIED")

        inst:AddComponent("debuff");

        inst.components.debuff.keepondespawn = true --这个源码中已经被注释掉了

        if data.timer then
            buffCountDown(inst, data); --有倒计时的buff
        end

        return inst
    end
    return Prefab(data.name, fn);
end

local prefabs = {};

for _, v in pairs(buffs) do
    if v.CanMake then
        table.insert(prefabs, MakeBuff(v));
    end
end

return unpack(prefabs);
