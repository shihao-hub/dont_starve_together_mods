---
--- @author zsh in 2023/2/7 16:38
---

local config_data = TUNING.MIE_TUNING.MOD_CONFIG_DATA;

----[[ 衣柜里面的装备可以缓慢恢复耐久 ]]
--if config_data.mone_wardrobe_recovery_durability then
--    env.AddPrefabPostInit("mone_wardrobe", function(inst)
--        if not TheWorld.ismastersim then
--            return inst;
--        end
--        inst.RestoreTask = inst:DoPeriodicTask(TUNING.BOOKSTATION_RESTORE_TIME, function(inst)
--            for _, v in pairs(inst.components.container.slots) do
--                if v:HasTag("_equippable") then
--                    if v.components.finiteuses then
--                        local percent = v.components.finiteuses:GetPercent()
--                        if percent < 1 then
--                            v.components.finiteuses:SetPercent(math.min(1, percent + TUNING.BOOKSTATION_RESTORE_AMOUNT));
--                        end
--                    elseif v.components.armor then
--                        local percent = v.components.armor:GetPercent()
--                        if percent < 1 then
--                            v.components.armor:SetPercent(math.min(1, percent + TUNING.BOOKSTATION_RESTORE_AMOUNT));
--                        end
--                    elseif v.components.fueled then
--                        local percent = v.components.fueled:GetPercent()
--                        if percent < 1 then
--                            v.components.fueled:SetPercent(math.min(1, percent + TUNING.BOOKSTATION_RESTORE_AMOUNT));
--                        end
--                    end
--                end
--            end
--        end);
--    end)
--end

local function tryToFindPlayer(inst)
    local owner = inst.components.inventoryitem and inst.components.inventoryitem.owner;
    --print("", tostring(owner));
    if owner == nil then
        return ;
    end
    if owner:HasTag("player") then
        return owner;
    end
    return tryToFindPlayer(owner);
end

--[[ 监听保鲜袋百分比变换，给予提示 ]]
env.AddPrefabPostInit("mone_storage_bag", function(inst)
    if not TheWorld.ismastersim then
        return inst;
    end
    inst:ListenForEvent("percentusedchange", function(inst, data)
        local percent = data and data.percent;
        local owner = tryToFindPlayer(inst);
        if not (owner and percent) then
            -- DoNothing
            return ;
        end
        local statement = string.format("%s%s%s", "保鲜袋还剩 ", percent * 100, "% 的耐久啦！记得填充哦！");
        --print("statement: "..tostring(statement));
        if percent < 0.5 then
            owner.components.talker:Say(statement);
        end
    end);
end)

--[[ 木头燃烧 50% 概率额外掉落一个木炭 ]]
--if TUNING.MIE_TUNING.MOD_CONFIG_DATA.log_charcoal then
--    env.AddPrefabPostInit("log", function(inst)
--        if not TheWorld.ismastersim then
--            return inst;
--        end
--        if inst.components.burnable then
--            local old_onburnt = inst.components.burnable.onburnt;
--            inst.components.burnable:SetOnBurntFn(function(inst)
--                local my_x, my_y, my_z = inst.Transform:GetWorldPosition();
--                if not TheWorld.Map:IsOceanAtPoint(my_x, my_y, my_z, false) then
--                    local charcoal;
--                    charcoal = SpawnPrefab("charcoal");
--                    if charcoal then
--                        charcoal.Transform:SetPosition(inst.Transform:GetWorldPosition())
--
--                        if inst.components.stackable ~= nil then
--                            charcoal.components.stackable.stacksize = math.min(charcoal.components.stackable.maxsize, inst.components.stackable.stacksize)
--                        end
--                    end
--                end
--
--                if old_onburnt then
--                    old_onburnt(inst);
--                end
--            end);
--        end
--    end)
--end