---
--- @author zsh in 2023/2/19 1:10
---

local config_data = TUNING.MIE_TUNING.MOD_CONFIG_DATA;

local inf_on = config_data.mie_meatballs
        or config_data.mie_bonestew
        or config_data.mie_leafymeatsouffle
        or config_data.mie_perogies
        or config_data.mie_icecream
        or config_data.mie_lobsterdinner
        or config_data.mie_dragonpie
        or config_data.mie_beefalofeed;

if TUNING.NEVER_FINISH_SERIES_ENABLED then
    inf_on = config_data.mie_beefalofeed;
end

if inf_on then
    env.AddPrefabPostInit("greenstaff", function(inst)
        if not TheWorld.ismastersim then
            return inst;
        end
        if inst.components.spellcaster then
            local old_spell = inst.components.spellcaster.spell;
            inst.components.spellcaster.spell = function(inst, target, pos, doer, ...)
                if target:HasTag("mie_inf_food") or target:HasTag("mie_inf_roughage") then
                    -- DoNothing
                    if doer.components.talker then
                        doer.components.talker:Say("我根本拆不掉它！");
                    end
                    return ;
                end

                if old_spell then
                    old_spell(inst, target, pos, doer, ...);
                end
            end
        end
    end)

    if not TUNING.NEVER_FINISH_SERIES_ENABLED then
        -- 修改所有预制物的 eater 组件
        env.AddPrefabPostInitAny(function(inst)
            if not TheWorld.ismastersim then
                return inst;
            end
            if inst.components.eater then
                local old_Eat = inst.components.eater.Eat;
                inst.components.eater.Eat = function(self, food, feeder, ...)
                    --print("food: "..tostring(food));
                    local old_Remove;
                    if food and food:IsValid() and food:HasTag("mie_inf_food") then
                        old_Remove = food.Remove;
                        food.Remove = function(inst)
                            -- DoNothing
                            --print("", tostring(inst) .. ":Remove(), but DoNothing!");
                        end
                    end

                    local success;
                    if old_Eat then
                        success = old_Eat(self, food, feeder, ...);
                    end

                    if old_Remove then
                        --print("old_Remove: " .. tostring(old_Remove));
                        if food and food:IsValid() then
                            --print("food: " .. tostring(food));
                            food.Remove = old_Remove;
                        end
                    end

                    return success;
                end
            end
        end)
    end

    -- 修改交易组件
    if config_data.mie_beefalofeed then
        env.AddComponentPostInit("trader", function(self)
            local old_AcceptGift = self.AcceptGift;
            function self:AcceptGift(giver, item, ...)
                if item and item:HasTag("mie_inf_roughage") and giver:HasTag("player") then
                    local item_save_record = item:GetSaveRecord();
                    local result = old_AcceptGift(self, giver, item, ...);
                    -- 删除了，item ~= nil, 但是 item:IsValid() == false!!!
                    --print("item: " .. tostring(item));
                    --if item then
                    --    print("item:IsValid(): " .. tostring(item:IsValid()));
                    --end
                    if not (item and item:IsValid()) then
                        if item_save_record then
                            giver.components.inventory:GiveItem(SpawnSaveRecord(item_save_record));
                        end
                    end
                    return result;
                end
                return old_AcceptGift(self, giver, item, ...);
            end
        end)
    end




    -- 以下部分暂时保留，留作记录！

    -- 白板物品所需（如果设定成白板的话，需要写此处。）
    -- 不必了，MEAT_eater + player 即可限制
    --env.AddPlayerPostInit(function(inst)
    --    if not TheWorld.ismastersim then
    --        return inst;
    --    end
    --
    --end)



    -- 开摆，其他生物也能吃。无所谓了！虽然会导致无限雇佣猪人、诱惑疯猪、蜘蛛等，但是无所谓了！

    -- 不不不，我可以写个白板物品！

    -- 简单尝试修改 sg，实现人物吃非 MEAT 类型某个食物才会触发 eat sg，而不是 quickeat。失败！
    -- 缝缝补补：说实话，这这么大范围的修改，是不是很危险啊。(2023-02-19-02:16：此处暂未生效。)
    --[[    local old_GoToState = StateGraphInstance.GoToState;
        function StateGraphInstance:GoToState(statename, params)
            local feed = params and params.feed;
            -- ERROR: attempt to index local 'params'
            -- 当把食物丢到地上的时候！才执行此处的函数！

            if feed then
                print("feed: " .. tostring(feed));
                if feed and feed.HasTag and feed:HasTag("mie_inf_food_meat")
                        and self.inst:HasTag("mie_player")
                        and statename == "quickeat"
                then
                    statename = "eat";
                end
            end
            if old_GoToState then
                old_GoToState(self, statename, params);
            end
        end]]

    -- 修改成人物才能吃的食物
    --[[    FOODTYPE.MIE_INF_FOOD = "MIE_INF_FOOD";
        env.AddPlayerPostInit(function(inst)
            inst:AddTag("mie_player");
            if not TheWorld.ismastersim then
                return inst;
            end
            if inst.components.eater then
                inst:DoTaskInTime(0, function(inst)
                    local caneat = inst.components.eater.caneat;
                    local preferseating = inst.components.eater.preferseating;

                    table.insert(caneat, FOODTYPE.MIE_INF_FOOD);
                    table.insert(preferseating, FOODTYPE.MIE_INF_FOOD);

                    inst.components.eater:SetDiet(caneat, preferseating);
                end);
            end
        end)

        -- 2023-02-19-02:33 SG需要去了解了解。但是我没需求啊，不想了解。
        local function inf_food(self)
            if not (self and self.states) then
                return
            end

            print("");
            if self.states.eat then

            end
        end

        env.AddStategraphPostInit("wilson", inf_food);
        env.AddStategraphPostInit("wilson_client", inf_food);]]

end