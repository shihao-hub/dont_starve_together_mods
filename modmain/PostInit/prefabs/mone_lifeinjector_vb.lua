---
--- @author zsh in 2023/1/20 14:27
---


local config_data = TUNING.MONE_TUNING.GET_MOD_CONFIG_DATA;

if config_data.mone_lifeinjector_vb then
    env.AddPlayerPostInit(function(inst)
        if not TheWorld.ismastersim then
            return inst;
        end

        inst:AddComponent("mone_lifeinjector_vb")

        for _, v in ipairs({
            -- 排除 旺达、机器人、小鱼人
            "wilson", "willow", "wolfgang", "wendy", "wickerbottom", "woodie", "wes", "waxwell",
            "wathgrithr", "webber", "winona", "warly", "wortox", "wormwood", "wonkey", "walter",
            -- 加回 机器人
            "wx78", --[["wurt","wanda",]] -- 旺达和小鱼人有点不好处理
            "jinx", -- https://steamcommunity.com/sharedfiles/filedetails/?id=479243762
            "monkey_king", "neza", "white_bone", "pigsy", "yangjian", "myth_yutu", "yama_commissioners", "madameweb",
        }) do
            if inst.prefab == v then
                inst.mone_vb_non_ban = true;

                inst:DoTaskInTime(0, function(inst)
                    inst:ListenForEvent("healthdelta", function(inst, data)
                        inst.components.mone_lifeinjector_vb.save_currenthealth = inst.components.health.currenthealth;
                        inst.components.mone_lifeinjector_vb.save_maxhealth = inst.components.health.maxhealth;
                    end);
                end)
            end
        end
    end)
end