---
--- @author zsh in 2023/1/9 18:09
---


local API = require("chang_mone.dsts.API");

local config_data = TUNING.MONE_TUNING.GET_MOD_CONFIG_DATA;

config_data.mone_walking_stick_illusion = true; -- 默认执行
if config_data.mone_walking_stick_illusion then
    API.reskin2(env, "cane", "cane", "swap_cane", {
        "mone_walking_stick"
    });
end

API.reskin("orangestaff", "staffs", {
    "mone_orangestaff"
});

API.reskin("boomerang", "boomerang", {
    "mone_boomerang"
});

API.reskin("backpack", "swap_backpack", {
    "mone_backpack"
});

API.reskin("piggyback", "swap_piggyback", {
    "mone_piggyback"
});

API.reskin("icepack", "swap_icepack", {
    "mone_icepack"
});

API.reskin("firesuppressor", "firefighter", {
    "mone_firesuppressor"
});

API.reskin("treasurechest", "treasure_chest", {
    "mone_treasurechest"
});
API.reskin("dragonflychest", "dragonfly_chest", {
    "mone_dragonflychest"
});
API.reskin("icebox", "ice_box", {
    "mone_icebox"
});
API.reskin("saltbox", "saltbox", {
    "mone_saltbox"
});
API.reskin("wardrobe", "wardrobe", {
    "mone_wardrobe"
});
API.reskin("dragonflyfurnace", "dragonfly_furnace", {
    "mone_dragonflyfurnace"
});
API.reskin("moondial", "moondial_build", {
    "mone_moondial"
});

API.reskin("seedpouch", "seedpouch", {
    "mone_seedpouch"
});

if config_data.mone_seasack_new_anim then
    API.reskin("krampus_sack", "swap_krampus_sack", {
        "mone_seasack"
    });
end

-- 路灯套皮个蘑菇灯或菌伞灯试试
-- 算了，要改 build 吧？emm，我这个功能其实写的挺烂的。。。
--if config_data.mone_city_lamp_reskin == 1 then
--    API.reskin("mushroom_light", "mushroom_light", {
--        "mone_city_lamp"
--    });
--elseif config_data.mone_city_lamp_reskin == 2 then
--    API.reskin("mushroom_light2", "mushroom_light2", {
--        "mone_city_lamp"
--    });
--end

-- 不行，如果只是单纯的显示贴图倒是没啥问题。但是如果后面播放动画，只是这样简单处理是不行的！
--API.reskin2(env, "mushroom_light2", "mushroom_light2", "mushroom_light2", {
--    "mone_city_lamp"
--});
