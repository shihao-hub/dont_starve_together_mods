---
--- @author zsh in 2023/7/6 9:56
---


STRINGS.MI_HOVER_TIPS.NIGHTMARE_TIMEPIECE_INITIAL_MODE = [[
务农 {farmer_current}/{farmer_max}
神厨 {kitchen_current}/{kitchen_max}
渔翁 {fisherman_current}/{fisherman_max}
采集 {picker_current}/{picker_max}
战斗 {combat_current}/{combat_max}
]];

-- 啊哦，这样不对，进程唯一变量怎么可以这样呢！
STRINGS.MI_HOVER_TIPS.NIGHTMARE_TIMEPIECE = subfmt(STRINGS.MI_HOVER_TIPS.NIGHTMARE_TIMEPIECE_INITIAL_MODE, {
    farmer_current = 0, farmer_max = 100;
    kitchen_current = 0, kitchen_max = 100;
    fisherman_current = 0, fisherman_max = 100;
    picker_current = 0, picker_max = 100;
    combat_current = 0, combat_max = 100;
})

env.AddClassPostConstruct("widgets/hoverer", function(hoverer)
    local old_SetString = hoverer.text.SetString;
    function hoverer.text:SetString(str, ...)
        local target = TheInput:GetHUDEntityUnderMouse();
        target = (target and target.widget and target.widget.parent ~= nil and target.widget.parent.item) or TheInput:GetWorldEntityUnderMouse() or nil;

        if target and target.prefab == "mone_nightmare_timepiece" then
            str = str .. "\n" .. STRINGS.MI_HOVER_TIPS.NIGHTMARE_TIMEPIECE;

        end

        return old_SetString(self, str, ...);
    end
end)

env.AddPlayerPostInit(function(inst)
    if not TheWorld.ismastersim then
        return inst;
    end

    inst.get_nightmare_timepiece = function(inst)
        return inst.components.inventory:FindItem(function(item)
            return item.prefab == "mone_nightmare_timepiece";
        end)
    end

    -- TODO:添加管理组件
    --inst:AddComponent("mone_nightmare_timepiece");
end)