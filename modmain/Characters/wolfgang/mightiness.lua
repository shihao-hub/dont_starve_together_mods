---
--- @author zsh in 2023/3/20 20:50
---

local config_data = TUNING.MONE_TUNING.GET_MOD_CONFIG_DATA;

local fns = {};

function fns.oneat(inst, data)
    local food = data and data.food;
    if NULL(food) then
        return ;
    end
    local hunger = food.components.edible:GetHunger(inst);
    if isNum(hunger) and hunger > 0 then
        local mightiness = hunger / 3;
        inst.components.mightiness:DoDelta(mightiness);
    end
end

env.AddPrefabPostInit("wolfgang", function(inst)
    if not TheWorld.ismastersim then
        return inst;
    end
    if null(inst.components.mightiness) then
        return inst;
    end

    -- 饥饿值高于 100 力量值不降低 或者 力量值永远都不会减少
    if config_data.wolfgang_mightiness then
        local old_DoDelta = inst.components.mightiness.DoDelta;
        function inst.components.mightiness:DoDelta(delta, ...)
            if delta < 0 and not (config_data.wolfgang_mightiness == 1) then
                delta = 0;
            elseif delta < 0 and (config_data.wolfgang_mightiness == 1) then
                if self.inst.components.hunger.current >= 100 then
                    delta = 0;
                end
            end
            old_DoDelta(self, delta, ...);
        end
    end

    -- 吃东西增加力量值
    if config_data.wolfgang_mightiness_oneat then
        inst:ListenForEvent("oneat", fns.oneat);
    end
end)

-- 移除状态变化的僵直效果？
