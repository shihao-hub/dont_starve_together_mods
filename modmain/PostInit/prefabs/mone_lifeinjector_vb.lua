---
--- @author zsh in 2023/1/20 14:27
---

local utils = require("moreitems.main").shihao.utils

local invoke = utils.invoke

------------------------------------------------------------------------------------------------------------------------

local allow_universal_functionality_enable = TUNING.MONE_TUNING.GET_MOD_CONFIG_DATA["lifeinjector_vb__allow_universal_functionality_enable"]
local constants = require("more_items_constants")

local config_data = TUNING.MONE_TUNING.GET_MOD_CONFIG_DATA;

if not config_data.mone_lifeinjector_vb then
    return
end

---@type table<any,boolean>
local INCLUDE_PLAYERS = invoke(function()
    local res = {}
    local included_players = constants.LIFE_INJECTOR_VB__INCLUDED_PLAYERS
    for _, v in ipairs(included_players) do
        res[v] = true
    end
    return res
end)

local function perform(inst)
    -- 给吃食物时使用的，这个命名很奇怪，需要优化
    inst.mone_vb_non_ban = true;

    inst:DoTaskInTime(0, function(inst)
        inst:ListenForEvent("healthdelta", function(inst, data)
            -- TODO: 学习 Java 进行封装
            inst.components.mone_lifeinjector_vb.save_currenthealth = inst.components.health.currenthealth;
            inst.components.mone_lifeinjector_vb.save_maxhealth = inst.components.health.maxhealth;
        end);
    end)
end

env.AddPlayerPostInit(function(inst)
    if not TheWorld.ismastersim then
        return
    end

    inst:AddComponent("mone_lifeinjector_vb")

    if allow_universal_functionality_enable
            or INCLUDE_PLAYERS[inst.prefab] then
        perform(inst)
    end
end)