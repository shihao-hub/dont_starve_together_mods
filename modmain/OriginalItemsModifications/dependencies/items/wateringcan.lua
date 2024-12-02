---
--- @author zsh in 2023/4/25 0:00
---

-- 空浇水壶
local wateringcan_fns = {
    onopenfn = function(inst)
        inst.SoundEmitter:PlaySound("dontstarve/wilson/chest_open")
    end,
    onclosefn = function(inst)
        inst.SoundEmitter:PlaySound("dontstarve/wilson/chest_close")
    end
};

items_fns.wateringcan.onpreload = function(inst,is_reload_game)
    if not decision_fn(inst, "wateringcan") then
        return ;
    end
    if inst.components.container or inst.components.preserver then
        return ;
    end
    inst.more_items_modify_enter_tag = true;

    --inst:AddTag("tool_bag_notag");

    -- 水壶添加容器，同时具有返鲜功能
    inst:AddComponent("container");
    inst.components.container:WidgetSetup("wateringcan");
    inst.components.container.skipclosesnd = true;
    inst.components.container.skipopensnd = true;
    inst.components.container.onopenfn = wateringcan_fns.onopenfn;
    inst.components.container.onclosefn = wateringcan_fns.onclosefn;

    inst:AddComponent("preserver");
    inst.components.preserver:SetPerishRateMultiplier(TUNING.FISH_BOX_PRESERVER_RATE);
end
items_fns.wateringcan.onload = function(inst,is_reload_game)
    if not decision_fn(inst, "wateringcan") then
        return ;
    end
    if not inst.more_items_modify_enter_tag then
        return ;
    end

    if inst.components.named == nil or inst.components.finiteuses == nil or inst.components.equippable == nil then
        return ;
    end

    if inst.components.finiteuses.current > 0 then
        inst.components.named:SetName("修改版·" .. tostring(STRINGS.NAMES[inst.prefab:upper() .. "_NOT_EMPTY"]));
    else
        inst.components.named:SetName("修改版·" .. tostring(STRINGS.NAMES[inst.prefab:upper()]));
    end

    local old_onequipfn = inst.components.equippable.onequipfn;
    local old_onunequipfn = inst.components.equippable.onunequipfn;
    inst.components.equippable:SetOnEquip(function(inst, owner, ...)
        if old_onequipfn then
            old_onequipfn(inst, owner, ...);
        end
        if inst.components.container then
            inst.components.container:Open(owner);
        end
    end);
    inst.components.equippable:SetOnUnequip(function(inst, owner, ...)
        if old_onunequipfn then
            old_onunequipfn(inst, owner, ...);
        end
        if inst.components.container then
            inst.components.container:Close();
        end
    end);
end