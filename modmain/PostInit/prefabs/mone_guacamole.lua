---
--- @author zsh in 2023/5/20 15:33
---

local config_data = TUNING.MONE_TUNING.GET_MOD_CONFIG_DATA;

if config_data.mone_guacamole then
    local GHOSTVISION_COLOURCUBES = {
        day = "images/colour_cubes/ghost_cc.tex",
        dusk = "images/colour_cubes/ghost_cc.tex",
        night = "images/colour_cubes/ghost_cc.tex",
        full_moon = "images/colour_cubes/ghost_cc.tex",
    }

    local NIGHTVISION_COLOURCUBES = {
        day = "images/colour_cubes/mole_vision_off_cc.tex",
        dusk = "images/colour_cubes/mole_vision_on_cc.tex",
        night = "images/colour_cubes/mole_vision_on_cc.tex",
        full_moon = "images/colour_cubes/mole_vision_off_cc.tex",
    }

    local NIGHTMARE_COLORCUBES = {
        calm = "images/colour_cubes/ruins_dark_cc.tex",
        warn = "images/colour_cubes/ruins_dim_cc.tex",
        wild = "images/colour_cubes/ruins_light_cc.tex",
        dawn = "images/colour_cubes/ruins_dim_cc.tex",
    }

    local function CustomCCTable(self)
        local cctable = (self.ghostvision and GHOSTVISION_COLOURCUBES)
                or self.overridecctable
                or ((self.nightvision or self.forcenightvision) and NIGHTVISION_COLOURCUBES)
                or (self.nightmarevision and NIGHTMARE_COLORCUBES)
                or nil;
        -- 主要是这里
        cctable = {
            day = "images/colour_cubes/spring_day_cc.tex",
            dusk = "images/colour_cubes/spring_dusk_cc.tex",
            night = "images/colour_cubes/purple_moon_cc.tex",
            full_moon = "images/colour_cubes/purple_moon_cc.tex",
        }
        return cctable;
    end

    env.AddPlayerPostInit(function(inst)
        inst.mone_guacamole_nightvision = net_bool(inst.GUID, "mone_guacamole_nightvision", "mone_guacamole_nightvisiondirty");

        inst:ListenForEvent("mone_guacamole_nightvisiondirty", function(inst)
            local isnightvision = inst.mone_guacamole_nightvision:value();
            if isnightvision then
                --print("--1");
                if inst.components.playervision then
                    inst.components.playervision:ForceNightVision(true)
                    inst.components.playervision:ForceGoggleVision(true)
                    inst.components.playervision:SetCustomCCTable(CustomCCTable(inst.components.playervision));
                end
            else
                --print("--2");
                if inst.components.playervision then
                    inst.components.playervision:ForceNightVision(inst._forced_nightvision and inst._forced_nightvision:value()); -- 机器人
                    inst.components.playervision:ForceGoggleVision(false)
                    inst.components.playervision:SetCustomCCTable(nil)
                end
            end
        end)
        if not TheWorld.ismastersim then
            return inst;
        end

        inst:DoTaskInTime(0, function(inst)
            if inst.components.timer and inst.components.timer:TimerExists("mone_guacamole_timer") then
                inst.mone_guacamole_nightvision:set(true); --sure?
                if inst.components.talker then
                    inst.components.talker:Say("我的夜视能力还剩 "
                            .. string.format("%.0f", inst.components.timer:GetTimeLeft("mone_guacamole_timer"))
                            .. " 秒！");
                end
            end
        end)

        -- TEST
        --inst:DoPeriodicTask(10, function(inst)
        --    if inst.components.timer and inst.components.timer:TimerExists("mone_guacamole_timer") then
        --        inst.mone_guacamole_nightvision:set(true);
        --        if inst.components.talker then
        --            inst.components.talker:Say("TEST 我的夜视能力还剩 "
        --                    .. string.format("%.0f", inst.components.timer:GetTimeLeft("mone_guacamole_timer"))
        --                    .. " 秒！");
        --        end
        --    end
        --end);

        if inst.components.timer == nil then
            inst:AddComponent("timer");
        end
        inst:ListenForEvent("timerdone", function(inst, data)
            if data and data.name and data.name == "mone_guacamole_timer" then
                if inst.components.talker then
                    inst.components.talker:Say("夜视能力还有5秒消失，请做好准备！");
                end
                inst:DoTaskInTime(5, function(inst)
                    if not inst.components.timer:TimerExists("mone_guacamole_timer") then
                        inst.mone_guacamole_nightvision:set(false);
                    end
                end);
            end
        end);
    end)
end