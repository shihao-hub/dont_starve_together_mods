---
--- @author zsh in 2023/1/20 14:27
---


local BaseDataType = {
    _types = {
        -- json
        "nil",
        "number",
        "string",
        "list",
        "dict",
        -- redis
        "string",
        "list",
        "set",
        "zset",
        "hash",
    },
}

local function invoke(fn)
    return fn()
end

--local set = invoke(function()
--    -- class 定义满足如下条件如何？
--    -- static 放到 static 属性内？其余都是 instance 属性？
--
--    local cls = {}
--
--    cls.__call__ = function(t, key, value)
--
--    end
--
--    return cls
--end)
------------------------------------------------------------------------------------------------------------------------

local allow_universal_functionality_enable = false

local config_data = TUNING.MONE_TUNING.GET_MOD_CONFIG_DATA;

if not config_data.mone_lifeinjector_vb then
    return
end

---@type table<any,boolean>
local INCLUDE_PLAYERS = invoke(function()
    local res = {}
    local included_players = {
        -- 排除 旺达、机器人、小鱼人
        "wilson", "willow", "wolfgang", "wendy", "wickerbottom", "woodie", "wes", "waxwell",
        "wathgrithr", "webber", "winona", "warly", "wortox", "wormwood", "wonkey", "walter",
        -- 加回 机器人
        "wx78", --[["wurt","wanda",]] -- 旺达和小鱼人有点不好处理
        "jinx", -- https://steamcommunity.com/sharedfiles/filedetails/?id=479243762
        "monkey_king", "neza", "white_bone", "pigsy", "yangjian", "myth_yutu", "yama_commissioners", "madameweb",
    }
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