---
--- @author zsh in 2023/1/16 21:19
---

local function handle_playsound_exception()
    local function preload()
        local function AddSpecialTag(item)
            if item and item:HasTag("_container") then
                item:AddTag("more_items_owner_is_piggybag");
            end
        end

        local function RemoveSpecialTag(item)
            if item and item:HasTag("_container") then
                item:RemoveTag("more_items_owner_is_piggybag");
            end
        end

        local function OnItemGet(inst, data)
            AddSpecialTag(data and data.item);
        end

        local function OnGotNewItem(inst, data)
            AddSpecialTag(data and data.item);
        end

        local function OnItemLose(inst, data)
            inst:DoTaskInTime(0, function(inst, data)
                RemoveSpecialTag(data and data.prev_item);
            end, data)
        end

        local function OnDropItem(inst, data)
            RemoveSpecialTag(data and data.item);
        end

        env.AddPrefabPostInit("mone_piggybag", function(inst)
            inst:ListenForEvent("itemget", OnItemGet);
            inst:ListenForEvent("gotnewitem", OnGotNewItem);
            inst:ListenForEvent("itemlose", OnItemLose);
            inst:ListenForEvent("dropitem", OnDropItem);
        end)
    end
    preload();

    local function client_playsound()
        local rpc_namespace = "more_items";
        local rpc_name = "container_client_play_sound";
        AddClientModRPCHandler(rpc_namespace, rpc_name, function(...)
            local item = (select(1, ...));
            local pickupsound = (select(2, ...));
            local player = ThePlayer;

            local data = { item = { pickupsound = pickupsound } };

            if item and type(item) == "table" and item.HasTag --[[and item:HasTag("more_items_owner_is_piggybag")]] then
                if TheNet:GetServerIsClientHosted() --[[不是专用服务器]] then
                    if TheNet:IsDedicated() --[[开洞的房主服务端进程]] then
                        NonGeneralFns.PlaySoundOnGotNewItem(player, data);
                    elseif TheNet:GetIsServer() --[[不开洞的房主饥荒过程]] then
                        -- DoNothing
                    else
                        NonGeneralFns.PlaySoundOnGotNewItem(player, data);
                    end
                else
                    --[[是专用服务器]]
                    NonGeneralFns.PlaySoundOnGotNewItem(player, data);
                end
            end
        end)
    end
    client_playsound();
end
handle_playsound_exception();

local config_data = TUNING.MONE_TUNING.GET_MOD_CONFIG_DATA;

local prefabs_table = {};

if not config_data.mone_piggbag_itemtestfn then
    -- 照明工具现在有点碍事了。
    prefabs_table = {
        "lighter", "torch", "minerhat", "molehat",
        "pumpkin_lantern", "lantern", "thurible",
        "nightstick", "wx78module_light", "wx78module_nightvision",
        "yellowamulet",

        "mone_redlantern",
        --"hat_lichen",
    }
end
table.insert(prefabs_table, "mie_storage_ring");
table.insert(prefabs_table, "那八的空间戒指");

for _, p in ipairs(prefabs_table) do
    env.AddPrefabPostInit(p, function(inst)
        inst:AddTag("mone_piggybag_itemtesttag");
    end)
end

if config_data.mone_piggbag_itemtestfn then
    env.AddPrefabPostInitAny(function(inst)
        if not TheWorld.ismastersim then
            return inst;
        end
        if inst:HasTag("mone_piggybag_itemtesttag") then
            return inst;
        end
        if inst.components.equippable then
            inst:AddTag("mone_piggybag_notag");
        end
    end)
end