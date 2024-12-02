---
--- @author zsh in 2023/4/25 1:07
---

local API = require("chang_mone.dsts.API");

-- 眼面具
local function eyemaskhat()
    local Debug = API.Debug;
    local armor = require("components/armor");
    if armor then
        -- 这个不需要了，因为 armorbroke 控制的是切换装备，没有其他内容。
        --local PercentChanged = Debug.GetUpvalueFn(armor._ctor, "PercentChanged");
        --if PercentChanged then
        --    function armor:DisablePercentChangedArmorBrokeEvent()
        --        --print("Call DisablePercentChangedArmorBroke: PercentChanged: " .. tostring(PercentChanged));
        --        if PercentChanged then
        --            self.inst:RemoveEventCallback("percentusedchange", PercentChanged);
        --        end
        --    end
        --end

        local old_SetCondition = armor.SetCondition;
        if old_SetCondition then
            function armor:SetCondition(amount, ...)
                if self.inst.prefab == "eyemaskhat" and self.inst.mi_ori_item_modify_tag then
                    local old_Remove = self.inst.Remove;
                    self.inst.Remove = assert(DoNothing);
                    if old_SetCondition then
                        old_SetCondition(self, amount, ...);
                    end
                    self.inst.Remove = old_Remove;

                    self.condition = math.max(0, math.min(amount, self.maxcondition));
                    self.inst:PushEvent("percentusedchange", { percent = self:GetPercent() });

                    return ;
                end
                if old_SetCondition then
                    old_SetCondition(self, amount, ...);
                end
            end
        end
    end

    -- 耐久为 0 的时候压根就不会触发 attacked 事件 以及 不会调用 armor:SetCondition 函数...
    --local function onattacked(inst, data)
    --    -- 修改后的眼面具耐久为 0 自动脱落
    --    local eyemaskhat_inst = inst.components.inventory and inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HEAD);
    --    print("onattacked:eyemaskhat_inst:"..tostring(eyemaskhat_inst));
    --    if eyemaskhat_inst and eyemaskhat_inst.prefab == "eyemaskhat" and eyemaskhat_inst.mi_ori_item_modify_tag then
    --        local percent = eyemaskhat_inst.components.armor and eyemaskhat_inst.components.armor:GetPercent();
    --        print("onattacked:percent:"..tostring(percent));
    --        if percent and percent <= 0 then
    --            inst.components.inventory:Unequip(EQUIPSLOTS.HEAD);
    --        end
    --    end
    --end
    --env.AddPlayerPostInit(function(inst)
    --    if not TheWorld.ismastersim then
    --        return inst;
    --    end
    --    inst:ListenForEvent("attacked", onattacked);
    --end)
end

local ABSORB_PERCENT = TUNING.ARMOR_WATHGRITHRHAT_ABSORPTION;

local eyemaskhat_fns = {
    onpercentusedchange = function(inst, data)
        local percent = data and data.percent;
        if type(percent) ~= "number" then
            return ;
        end
        if inst.components.armor == nil or inst.components.inventoryitem == nil or inst.components.equippable == nil then
            return ;
        end
        local armor = inst.components.armor;
        if percent <= 0 then
            armor.absorb_percent = 0;
        else
            armor.absorb_percent = ABSORB_PERCENT;
        end
    end,
    consumeFood = function(self, food, feeder, ...)
        local inst = self.inst;
        if food and food:IsValid() and inst.components.armor then
            local armor = inst.components.armor;
            local health = math.abs(food.components.edible:GetHealth(inst)) * inst.components.eater.healthabsorption
            local hunger = math.abs(food.components.edible:GetHunger(inst)) * inst.components.eater.hungerabsorption
            local delta = armor.maxcondition - armor.condition;
            if delta > 0 then
                local num = math.floor(delta / (health + hunger)) or 0;
                local food_num = food.components.stackable and food.components.stackable:StackSize() or 1;
                local eat_num = num < food_num and num or food_num;
                inst.components.armor:Repair(eat_num * (health + hunger));
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
    end
}

items_fns.eyemaskhat.onpreload = function(inst, is_reload_game)
    if not decision_fn(inst, "eyemaskhat") then
        return ;
    end
    --inst:AddComponent("mone_teraria");
end

items_fns.eyemaskhat.onload = function(inst, is_reload_game)
    if not decision_fn(inst, "eyemaskhat") then
        return ;
    end
    if inst.components.armor == nil or inst.components.waterproofer == nil or inst.components.eater == nil then
        return ;
    end

    if inst.components.named then
        inst.components.named:SetName("修改版·" .. tostring(STRINGS.NAMES[inst.prefab:upper()]));
    end

    local armor = inst.components.armor;

    -- 女武神头盔的耐久：ps，延迟一下执行试试！
    --armor:InitCondition(TUNING.ARMOR_WATHGRITHRHAT, ABSORB_PERCENT);
    --if is_reload_game then
    --    local condition = inst.components.mone_teraria.condition;
    --    if condition then
    --        armor:InitCondition(condition, ABSORB_PERCENT);
    --    end
    --end

    -- 成组喂食
    local old_Eat = inst.components.eater.Eat;
    function inst.components.eater:Eat(food, feeder, ...)
        local res;
        if old_Eat then
            res = old_Eat(self, food, feeder, ...);
        end
        if res then
            eyemaskhat_fns.consumeFood(self, food, feeder, ...);
        end
        return res;
    end

    -- 女武神头盔的耐久度：为什么会这样：315->525，但是每次重启游戏，只要保存的 condition 超出了 315，头盔的 condition 都会变成 315...

    -- 耐久为 0 不消失
    inst:ListenForEvent("percentusedchange", eyemaskhat_fns.onpercentusedchange);
    inst:DoTaskInTime(0, function(inst)
        if inst.components.armor then
            eyemaskhat_fns.onpercentusedchange(inst, { percent = inst.components.armor:GetPercent() })
        end
    end)
end

-- 耐久为 0 不消失
eyemaskhat();