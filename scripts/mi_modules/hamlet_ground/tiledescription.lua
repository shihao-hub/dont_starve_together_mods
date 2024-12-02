---
--- @author zsh in 2023/3/24 13:06
---

-- 环境设置
local ENV = TUNING.MONE_TUNING.MI_MODULES.HAMLET_GROUND.ENV;
setfenv(1, ENV);

-- 按道理来说我应该是可以修改 package.path? 但是那岂不是又有模组之间相互覆盖的风险了？
MORE_ITEMS_MODULES_HAMLET_GROUND_ROOT = "scripts/mi_modules/hamlet_ground/";

--2023-03-25-19:00：算了，levels 应该必须放在根目录下吧，底层报错了。。。服了。
MORE_ITEMS_MODULES_HAMLET_GROUND_ROOT = "";


---@return table @ 新的地皮描述信息
function SetInfo()
    local NEW_TILE_DESCRIPTION = {
        PIGRUINS = {
            numid = 89,
            layer = 13,
            specs = {
                name = "blocky",
                noise_texture = "levels/textures/ground_ruins_slab.tex",
                runsound = "dontstarve/movement/run_dirt",
                walksound = "dontstarve/movement/walk_dirt",
                snowsound = "dontstarve/movement/run_ice",
                mudsound = "dontstarve/movement/run_mud"
            },
            mgt = "levels/textures/mini_ruins_slab.tex",
            turf = { { "turf_pigruins" } },
            isfloor = true
        },
        RAINFOREST = {
            numid = 86,
            layer = 13,
            specs = {
                name = "rain_forest",
                noise_texture = "levels/textures/Ground_noise_rainforest.tex",
                runsound = "dontstarve/movement/run_woods",
                walksound = "dontstarve/movement/walk_woods",
                snowsound = "dontstarve/movement/run_snow",
                mudsound = "dontstarve/movement/run_mud"
            },
            mgt = "levels/textures/mini_noise_rainforest.tex",
            turf = { { "turf_rainforest" } }
        },
        DEEPRAINFOREST = {
            numid = 81,
            layer = 13,
            specs = {
                name = "jungle_deep",
                noise_texture = "levels/textures/Ground_noise_jungle_deep.tex",
                runsound = "dontstarve/movement/run_woods",
                walksound = "dontstarve/movement/walk_woods",
                snowsound = "dontstarve/movement/run_snow",
                mudsound = "dontstarve/movement/run_mud"
            },
            mgt = "levels/textures/mini_noise_jungle_deep.tex",
            turf = { { "turf_deeprainforest" } }
        },
        FIELDS = {
            numid = 87,
            layer = 13,
            specs = {
                name = "yellowgrass",
                noise_texture = "levels/textures/noise_farmland.tex",
                runsound = "dontstarve/movement/run_woods",
                walksound = "dontstarve/movement/walk_woods",
                snowsound = "dontstarve/movement/run_snow",
                mudsound = "dontstarve/movement/run_mud"
            },
            mgt = "levels/textures/mini_noise_farmland.tex",
            turf = { { "turf_fields" } }
        },
        SUBURB = {
            numid = 88,
            layer = 13,
            specs = {
                name = "desert_dirt",
                noise_texture = "levels/textures/noise_mossy_blossom.tex",
                runsound = "dontstarve/movement/run_dirt",
                walksound = "dontstarve/movement/walk_dirt",
                snowsound = "dontstarve/movement/run_ice",
                mudsound = "dontstarve/movement/run_mud"
            },
            mgt = "levels/textures/mini_noise_mossy_blossom.tex",
            turf = { { "turf_moss" } }
        },
        FOUNDATION = {
            numid = 82,
            layer = 15,
            specs = {
                name = "blocky",
                noise_texture = "levels/textures/noise_ruinsbrick_scaled.tex",
                runsound = "dontstarve/movement/run_dirt",
                walksound = "dontstarve/movement/walk_dirt",
                snowsound = "dontstarve/movement/run_ice",
                mudsound = "dontstarve/movement/run_mud"
            },
            mgt = "levels/textures/mini_grass_noise.tex",
            turf = { { "turf_foundation" } },
            isfloor = true
        },
        LAWN = {
            numid = 84,
            layer = 32,
            specs = {
                name = "pebble",
                noise_texture = "levels/textures/ground_noise_checkeredlawn.tex",
                runsound = "dontstarve/movement/run_grass",
                walksound = "dontstarve/movement/walk_grass",
                snowsound = "dontstarve/movement/run_snow",
                mudsound = "dontstarve/movement/run_mud"
            },
            mgt = "levels/textures/mini_grasslawn_noise.tex",
            turf = { { "turf_lawn" } }
        },
        COBBLEROAD = {
            numid = 83,
            layer = 31,
            specs = {
                name = "stoneroad",
                noise_texture = "levels/textures/Ground_noise_cobbleroad.tex",
                -- runsound = "dontstarve/movement/run_rock",
                -- walksound = "dontstarve/movement/walk_rock",
                snowsound = "dontstarve/movement/run_ice",
                mudsound = "dontstarve/movement/run_mud"
            },
            mgt = "levels/textures/mini_brickroad_noise.tex",
            turf = { { "turf_cobbleroad" } },
            isfloor = true
        },
        GASJUNGLE = {
            numid = 85,
            layer = 13,
            specs = {
                name = "jungle_deep",
                noise_texture = "levels/textures/ground_noise_gas.tex",
                runsound = "dontstarve/movement/run_moss",
                walksound = "dontstarve/movement/walk_moss",
                snowsound = "dontstarve/movement/run_snow",
                mudsound = "dontstarve/movement/run_mud"
            },
            mgt = "levels/textures/mini_gasbiome_noise.tex",
            turf = { { "turf_gasjungle" } }
        }
    }

    return NEW_TILE_DESCRIPTION
end