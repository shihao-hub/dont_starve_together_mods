---
--- @author zsh in 2023/5/31 15:31
---

local config_data = TUNING.MONE_TUNING.GET_MOD_CONFIG_DATA;

local t = {};
if config_data.backpack then
    table.insert(t, "mone_backpack");
end
if config_data.piggyback then
    table.insert(t, "mone_piggyback");
end

for _, p in ipairs(t) do
    env.AddPrefabPostInit(p, function(inst)
        if not TheWorld.ismastersim then
            return inst;
        end
        if inst.components.inventoryitem then
            inst.components.inventoryitem.canonlygoinpocket = false;
        end

        if inst.components.container then
            --local TEXT = require("languages.mone.loc");
            inst.components.container.onopenfn = function(inst)
                if inst.mi_ignore_sound then
                    return ;
                end
                inst.SoundEmitter:PlaySound("dontstarve/wilson/chest_open")

                --if not inst.components.named then
                --    inst:AddComponent("named");
                --end
                --inst.components.named:SetName(STRINGS.NAMES[inst.prefab:upper()] .. "-" .. TEXT.OPEN_STATUS, "chang");
            end
            inst.components.container.onclosefn = function(inst)
                if inst.mi_ignore_sound then
                    return ;
                end
                inst.SoundEmitter:PlaySound("dontstarve/wilson/chest_close")

                --if not inst.components.named then
                --    inst:AddComponent("named");
                --end
                --inst.components.named:SetName(STRINGS.NAMES[inst.prefab:upper()] .. "-" .. TEXT.CLOSE_STATUS, "chang");
            end
        end
    end)
end