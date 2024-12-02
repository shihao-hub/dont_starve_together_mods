---
--- @author zsh in 2023/4/25 1:07
---

local API = require("chang_mone.dsts.API");


-- 恐怖盾牌

local ABSORB_PERCENT = TUNING.SHIELDOFTERROR_ABSORPTION;

local shieldofterror_fns = {
    onpercentusedchange = function(inst, data)
        local percent = data and data.percent;
        if type(percent) ~= "number" then
            return ;
        end
        if inst.components.armor == nil then
            return ;
        end
        local armor = inst.components.armor;
        if percent <= 0 then
            armor.absorb_percent = 0;
            --inst.components.waterproofer:SetEffectiveness(0);
        else
            armor.absorb_percent = ABSORB_PERCENT;
            --inst.components.waterproofer:SetEffectiveness(TUNING.WATERPROOFNESS_SMALL);
        end
    end,
}

return function(inst)
    if not inst.mi_ori_item_modify_tag then
        return inst;
    end

    if not TheWorld.ismastersim then
        return inst;
    end

    if inst.components.named then
        inst.components.named:SetName("修改版·" .. tostring(STRINGS.NAMES[inst.prefab:upper()]));
    end

    if inst.components.armor == nil or inst.components.waterproofer == nil or inst.components.eater == nil then
        return inst;
    end

    local armor = inst.components.armor;

    -- 成组喂食
    local old_Eat = inst.components.eater.Eat;
    function inst.components.eater:Eat(food, feeder, ...)
        local res;
        if old_Eat then
            res = old_Eat(self, food, feeder, ...);
        end

        local inst = self.inst;
        if res and food and food:IsValid() and inst.components.armor then
            local armor = inst.components.armor;
            local health = math.abs(food.components.edible:GetHealth(inst)) * inst.components.eater.healthabsorption
            local hunger = math.abs(food.components.edible:GetHunger(inst)) * inst.components.eater.hungerabsorption
            local delta = armor.maxcondition - armor.condition;
            if delta > 0 then
                print("delta: " .. tostring(delta) .. ", (health + hunger): " .. tostring(health + hunger))
                local num = math.floor(delta / (health + hunger)) or 0;
                print("需要再吃：" .. tostring(num) .. " 个");
                local food_num = food.components.stackable and food.components.stackable:StackSize() or 1;
                local eat_num = num < food_num and num or food_num;
                print("真正吃了：" .. tostring(eat_num) .. " 个，恢复了：" .. tostring(eat_num * (health + hunger)));
                inst.components.armor:Repair(num * (health + hunger));
                if not self.eatwholestack and food.components.stackable ~= nil then
                    if food.components.stackable:StackSize() > eat_num then
                        food.components.stackable:Get(eat_num):Remove();
                    else
                        food:Remove();
                    end
                else
                    food:Remove();
                end
            end
        end

        return res;
    end

    -- 女武神头盔的耐久度
    local percent = armor:GetPercent();
    armor.maxcondition = TUNING.ARMOR_WATHGRITHRHAT;
    armor.absorb_percent = ABSORB_PERCENT;
    armor.condition = armor.maxcondition * percent;

    -- 耐久为0不消失
    local old_SetCondition = armor.SetCondition;
    if old_SetCondition then
        function armor:SetCondition(amount, ...)
            if self.inst.prefab == "shieldofterror" and self.inst.mi_ori_item_modify_tag then
                local old_Remove = self.inst.Remove;
                self.inst.Remove = function()
                    -- DoNothing
                end;
                if old_SetCondition then
                    old_SetCondition(self, amount, ...);
                end
                self.inst.Remove = old_Remove;
                return ;
            end
            if old_SetCondition then
                old_SetCondition(self, amount, ...);
            end
        end
    end

    inst:ListenForEvent("percentusedchange", shieldofterror_fns.onpercentusedchange);
end