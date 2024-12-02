---
--- @author zsh in 2023/5/20 15:34
---

local config_data = TUNING.MONE_TUNING.GET_MOD_CONFIG_DATA;

--[[ 保鲜袋兼容45格 ]]
if config_data.storage_bag then
    if config_data.rewrite_storage_bag_45_slots then
        env.AddPrefabPostInit("mone_storage_bag", function(inst)
            if not TheWorld.ismastersim then
                return inst;
            end
            local containers = require "containers";
            local params = containers.params;
            if params.mone_storage_bag then
                params.mone_storage_bag.widget.pos = Vector3(0, 500, 0);
                params.mone_storage_bag.type = "rewrite_storage_bag_45_slots";
            end
        end)
    end
end