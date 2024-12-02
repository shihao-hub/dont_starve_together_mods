---
--- @author zsh in 2023/3/6 21:19
---

local config_data=TUNING.MONE_TUNING.GET_MOD_CONFIG_DATA;

--[[ 衣柜里面的装备可以缓慢恢复耐久 ]]
if config_data.mone_wardrobe_recovery_durability then
    env.AddPrefabPostInit("mone_wardrobe", function(inst)
        if not TheWorld.ismastersim then
            return inst;
        end
        inst.RestoreTask = inst:DoPeriodicTask(TUNING.BOOKSTATION_RESTORE_TIME, function(inst)
            for _, v in pairs(inst.components.container.slots) do
                if v:HasTag("_equippable") then
                    if v.components.finiteuses then
                        local percent = v.components.finiteuses:GetPercent()
                        if percent < 1 then
                            v.components.finiteuses:SetPercent(math.min(1, percent + TUNING.BOOKSTATION_RESTORE_AMOUNT));
                        end
                    elseif v.components.armor then
                        local percent = v.components.armor:GetPercent()
                        if percent < 1 then
                            v.components.armor:SetPercent(math.min(1, percent + TUNING.BOOKSTATION_RESTORE_AMOUNT));
                        end
                    elseif v.components.fueled then
                        local percent = v.components.fueled:GetPercent()
                        if percent < 1 then
                            v.components.fueled:SetPercent(math.min(1, percent + TUNING.BOOKSTATION_RESTORE_AMOUNT));
                        end
                    else
                        -- 其他类型的不回复，包括但不限于有新鲜度的物品
                    end
                end
            end
        end);
    end)
end