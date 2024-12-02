---
--- @author zsh in 2023/3/7 9:00
---

local config_data = TUNING.MONE_TUNING.GET_MOD_CONFIG_DATA;

local API = require("chang_mone.dsts.API");

--if API.isDebug(env) then
--    config_data.containers_onpickupfn_piggybag = true;
--end

local tool_bag_auto_open = TUNING.MONE_TUNING.GET_MOD_CONFIG_DATA.tool_bag_auto_open;
local storage_bag_auto_open = TUNING.MONE_TUNING.GET_MOD_CONFIG_DATA.storage_bag_auto_open;

-- 容器在猪猪袋里的时候，拿起就会打开
if config_data.containers_onpickupfn_piggybag then

    local fns = {};
    function fns.isDesignatedContainer(item)
        if item == nil or item.prefab == nil then
            return false;
        end
        return not tool_bag_auto_open and item.prefab == "mone_tool_bag"
                or not storage_bag_auto_open and item.prefab == "mone_storage_bag"
                or item.prefab == "mone_icepack"
                or item.prefab == "mie_book_silviculture"
                or item.prefab == "mone_wathgrithr_box"
                or item.prefab == "medal_box";
    end
    local vars = {};
    vars.prefabs = { "mone_icepack", "mie_book_silviculture", "mone_wathgrithr_box" };
    if not tool_bag_auto_open then
        table.insert(vars.prefabs, "mone_tool_bag");
    end
    if not storage_bag_auto_open then
        table.insert(vars.prefabs, "mone_storage_bag");
    end

    if config_data.mods_nlxz_medal_box then
        table.insert(vars.prefabs, "medal_box");
    end

    env.AddPrefabPostInit("mone_piggybag", function(inst)
        if not TheWorld.ismastersim then
            return inst;
        end

        inst:ListenForEvent("dropitem", function(inst, data)
            if data and fns.isDesignatedContainer(data.item) then
                data.item.mone_containers_isnotpiggybag = true;
            end
        end)

        inst:ListenForEvent("itemlose", function(inst, data)
            -- 必须要加个延迟！不然不生效！
            inst:DoTaskInTime(0, function(inst, data)
                if data and fns.isDesignatedContainer(data.prev_item) then
                    data.prev_item.mone_containers_isnotpiggybag = true;
                end
            end, data)
        end)

        inst:ListenForEvent("gotnewitem", function(inst, data)
            if data and fns.isDesignatedContainer(data.item) then
                data.item.mone_containers_isnotpiggybag = nil;
            end
        end)

        inst:ListenForEvent("itemget", function(inst, data)
            if data and fns.isDesignatedContainer(data.item) then
                data.item.mone_containers_isnotpiggybag = nil;
            end
        end)

    end)

    local function OnSave(inst, data)
        data.mone_containers_isnotpiggybag = inst.mone_containers_isnotpiggybag;
    end

    local function OnLoad(inst, data)
        inst.mone_containers_isnotpiggybag = data.mone_containers_isnotpiggybag;
    end

    for _, p in ipairs(vars.prefabs) do
        env.AddPrefabPostInit(p, function(inst)
            if not TheWorld.ismastersim then
                return inst;
            end
            if inst.components.inventoryitem then
                inst.mone_containers_isnotpiggybag = true;
                local old_onpickupfn = inst.components.inventoryitem.onpickupfn;
                inst.components.inventoryitem:SetOnPickupFn(function(inst, pickupguy, ...)
                    --if old_onpickupfn then
                    --    old_onpickupfn(inst, pickupguy, ...);
                    --end
                    if inst.mone_containers_isnotpiggybag then
                        return ;
                    end
                    if inst.components.container == nil then
                        return ;
                    end
                    if inst.components.container:IsOpen() then
                        inst.components.container:Close();
                        if inst.prefab == "medal_box" then
                            API.arrangeContainer(inst);
                        end
                    elseif pickupguy then
                        inst.components.container:Open(pickupguy);
                    end
                end);
                inst.OnSave = OnSave;
                inst.OnLoad = OnLoad;
            end
        end)
    end
end