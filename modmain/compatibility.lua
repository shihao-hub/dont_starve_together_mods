---
--- @author zsh in 2023/2/7 9:08
---

local config_data = TUNING.MIE_TUNING.MOD_CONFIG_DATA;

--[[ 兼容智能小木牌 ]]
--if config_data.chests_boxs_compatibility then
--    for _, p in ipairs({
--        "mone_dragonflychest", "mone_icebox", "mone_saltbox",
--    }) do
--        env.AddPrefabPostInit(p, function(inst)
--            if not TheWorld.ismastersim then
--                return inst;
--            end
--            if TUNING.SMART_SIGN_DRAW_ENABLE then
--                SMART_SIGN_DRAW(inst);
--            end
--        end)
--    end
--end

--[[ Show Me ]]
do
    local comm = { "treasurechest", true };
    ---@type table<string,table[]>
    local t = {
        ["mie_granary_meats"] = comm,
        ["mie_granary_greens"] = comm,
        ["mie_watersource"] = comm,
        ["mie_sand_pit"] = comm,
        ["mie_bear_skin_cabinet"] = comm,
        ["mie_wooden_drawer"] = comm,
        ["mie_new_granary"] = comm,
        ["mie_fish_box"] = comm,
    };

    --遍历已开启的mod
    for _, mod in pairs(ModManager.mods) do
        if mod and mod.SHOWME_STRINGS then
            for k, v in pairs(t) do
                if v[2] then
                    mod.postinitfns.PrefabPostInit[k] = mod.postinitfns.PrefabPostInit[v[1]];
                end
            end
        end
    end

    TUNING.MONITOR_CHESTS = TUNING.MONITOR_CHESTS or {};
    for k, v in pairs(t) do
        if v[2] then
            TUNING.MONITOR_CHESTS[k] = true;
        end
    end
end
