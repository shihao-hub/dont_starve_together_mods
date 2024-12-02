---
--- @author zsh in 2023/3/2 10:27
---

local config_data = TUNING.MONE_TUNING.GET_MOD_CONFIG_DATA;

if config_data.mone_stomach_warming_hamburger then
    env.AddPlayerPostInit(function(inst)
        if not TheWorld.ismastersim then
            return inst;
        end

        inst:AddComponent("mone_stomach_warming_hamburger")

        for _, v in ipairs({
            "wilson", "willow", "wolfgang", "wendy", "wickerbottom", "woodie", "wes", "waxwell",
            "wathgrithr", "webber", "winona", "warly", "wortox", "wormwood", "wonkey", "walter",
            --"wx78", "wurt",
            "wanda",
            "jinx",
            "monkey_king","neza","white_bone","pigsy","yangjian","myth_yutu","yama_commissioners","madameweb",
        }) do
            if inst.prefab == v then
                inst.mone_swh_non_ban = true;

                inst:DoTaskInTime(0, function(inst)
                    inst:ListenForEvent("hungerdelta", function(inst, data)
                        inst.components.mone_stomach_warming_hamburger.save_currenthunger = inst.components.hunger.current;
                        inst.components.mone_stomach_warming_hamburger.save_maxhunger = inst.components.hunger.max;
                    end);
                end)
            end
        end
    end)
end