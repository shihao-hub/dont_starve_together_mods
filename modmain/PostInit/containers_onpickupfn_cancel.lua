---
--- @author zsh in 2023/3/6 20:20
---

local config_data = TUNING.MONE_TUNING.GET_MOD_CONFIG_DATA;

-- 让某些容器不再会自动打开
if config_data.containers_onpickupfn_cancel then
    for _, v in ipairs({
        "mone_storage_bag", -- 保鲜袋
        "mone_piggybag", -- 猪猪袋
        "mone_tool_bag", -- 工具袋

        "mone_backpack", -- 装备袋
        "mone_candybag", -- 材料袋
        "mone_icepack", -- 食物袋
        "mone_piggyback", -- 收纳袋

        "mone_wathgrithr_box", -- 女武神的歌谣盒
        "mone_wanda_box" -- 旺达的钟表盒
    }) do
        env.AddPrefabPostInit(v, function(inst)
            if not TheWorld.ismastersim then
                return inst;
            end
            if inst.components.inventoryitem and inst.components.inventoryitem.onpickupfn then
                inst.components.inventoryitem:SetOnPickupFn(function()
                    -- DoNothing
                end);
            end
        end)
    end

    -- 修改猪猪容器袋的 onopenfn 和 onclosefn
    env.AddPrefabPostInit("mone_piggybag", function(inst)
        if not TheWorld.ismastersim then
            return inst;
        end
        if inst.components.container then
            inst.components.container.onopenfn = function(inst, data)
                inst.SoundEmitter:PlaySound("dontstarve/wilson/chest_open")
            end
        end
    end)
end