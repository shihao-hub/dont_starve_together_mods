---
--- @author zsh in 2023/5/20 15:28
---


local API = require("chang_mone.dsts.API");

local config_data = TUNING.MONE_TUNING.GET_MOD_CONFIG_DATA;

-- 相关功能取消：完全失效或过时甚至会崩溃的内容，懒得删掉了。
config_data.mone_piggbag_itemtestfn = false;

-- 个人适配 UI 拖拽缩放模组
if API.isDebug(env) then
    if config_data.container_removable == true then
        config_data.container_removable = 1;
    end
end