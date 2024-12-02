---
--- @author zsh in 2023/2/8 15:53
---

local API = require("chang_mone.dsts.API");

local config_data = TUNING.MIE_TUNING.MOD_CONFIG_DATA;

--if config_data.mone_walking_stick_illusion then
--    API.reskin2(env, "cane", "cane", "swap_cane", {
--        "mone_walking_stick"
--    });
--end

if config_data.bushhat then
    API.reskin2(env, "bushhat", "bushhat", "hat_bush", {
        "mie_bushhat"
    });
end

if config_data.tophat then
    API.reskin2(env, "tophat", "tophat", "hat_top", {
        "mie_tophat"
    });
end
if config_data.walterhat then
    API.reskin2(env, "walterhat", "walterhat", "hat_walter", {
        "mie_walterhat"
    });
end

API.reskin("waterpump", "boat_waterpump", {
    "mie_waterpump"
});

if config_data.mie_fish_box_animstate then
    API.reskin("saltbox", "saltbox", {
        "mie_fish_box"
    });
else
    API.reskin("fish_box", "fish_box", {
        "mie_fish_box"
    });
end

API.reskin("resurrectionstatue", "wilsonstatue", {
    "mone_dummytarget"
});

-- 2023-02-10-14:38：有问题，bundle_init_fn、bundle_clear_fn 函数里面有个函数调用需要手动添加。有点太麻烦！
--API.reskin("bundle", "bundle", {
--    "mie_bundle_state1",
--    "mie_bundle_state2"
--});