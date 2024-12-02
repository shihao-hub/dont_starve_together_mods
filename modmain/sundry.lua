---
--- @author zsh in 2023/1/28 2:37
---

-- 这里放那些我也不知道放哪里的东西

local API = require("chang_mone.dsts.API");

local config_data = TUNING.MONE_TUNING.GET_MOD_CONFIG_DATA;

--[[ 不能攻击盟友 ]]
if config_data.forced_attack_lightflier then
    local combat_replica = require "components/combat_replica";
    local old_IsAlly = combat_replica.IsAlly;
    function combat_replica:IsAlly(guy, ...)
        if config_data.forced_attack_lightflier then
            if guy and guy.prefab and guy.prefab == "lightflier" then
                return true;
            end
        end
        return old_IsAlly(self, guy, ...);
    end
end

--[[ Debug：控制台命令 ]]
if API.isDebug(env) then
    env.AddClassPostConstruct("screens/consolescreen", function(self)
        if self.console_edit then
            local commands = {
                "GetPrefabNumber"
            }
            local dictionary = self.console_edit.prediction_widget.word_predictor.dictionaries[3];
            for _, word in ipairs(commands) do
                table.insert(dictionary.words, word)
            end
        end
    end)
end

--[[ 悄咪咪改一下乌龟壳的爆率？ ]]
