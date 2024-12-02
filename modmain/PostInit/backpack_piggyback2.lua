---
--- @author zsh in 2023/1/14 1:07
---

local API = require("chang_mone.dsts.API");

local fns = {} -- a table to store local functions in so that we don't hit the 60 upvalues limit

local config_data = TUNING.MONE_TUNING.GET_MOD_CONFIG_DATA;

local prefabs = {};
if config_data.backpack then
    table.insert(prefabs, "mone_backpack");
end
if config_data.piggyback then
    table.insert(prefabs, "mone_piggyback");
end

for _, p in ipairs(prefabs) do
    env.AddPrefabPostInit(p, function(inst)
        if not TheWorld.ismastersim then
            return inst;
        end

        if inst.components.inventoryitem then
            inst.components.inventoryitem.canonlygoinpocket = false;
        end

        if inst.components.container then
            inst.components.container.onopenfn = function(inst)
                if inst.mi_ignore_sound then
                    return ;
                end
                inst.SoundEmitter:PlaySound("dontstarve/wilson/chest_open");
            end
            inst.components.container.onclosefn = function(inst)
                if inst.mi_ignore_sound then
                    return ;
                end
                inst.SoundEmitter:PlaySound("dontstarve/wilson/chest_close")
            end
        end
    end)
end

if config_data.mone_backpack_auto then
    ---@param typ string @ 1:OnItemRanOut 2:OnUmbrellaRanOut 3:ArmorBroke 4:WeaponBroke
    local function findSpecItem(inst, data, typ)
        if not inst.components.inventory then
            return ;
        end
        local opencontainers = inst.components.inventory.opencontainers;
        local containers = {};
        for container_inst, _ in pairs(opencontainers) do
            local prefab_name = container_inst and container_inst.prefab;
            if prefab_name and table.contains({
                "mone_tool_bag", "mone_backpack", "mone_piggybag"
            }, prefab_name) then
                table.insert(containers, container_inst);
            end
        end

        local item;
        for _, con in ipairs(containers) do
            if item == nil then
                if typ == 1 then
                    item = con.components.container:FindItem(function(item)
                        return item.prefab == data.prefab and
                                item.components.equippable ~= nil and
                                item.components.equippable.equipslot == data.equipslot
                    end);
                elseif typ == 2 then
                    item = con.components.container:FindItem(function(item)
                        return item:HasTag("umbrella") and
                                item.components.equippable ~= nil and
                                item.components.equippable.equipslot == data.equipslot
                    end)
                elseif typ == 3 then
                    item = con.components.container:FindItem(function(item)
                        return item.prefab == (data.armor and data.armor.prefab);
                    end)
                elseif typ == 4 then
                    item = con.components.container:FindItem(function(item)
                        return item.prefab == (data.weapon and data.weapon.prefab);
                    end)
                else
                    error("Invalid parameter: typ == " .. tostring(typ));
                end
            else
                break ;
            end
        end

        return item;
    end

    function fns.OnItemRanOut(inst, data)
        --print("more items: OnItemRanOut");
        if inst.components.inventory:GetEquippedItem(data.equipslot) == nil then
            local sameItem = inst.components.inventory:FindItem(function(item)
                return item.prefab == data.prefab and
                        item.components.equippable ~= nil and
                        item.components.equippable.equipslot == data.equipslot
            end)
            if sameItem ~= nil then
                inst.components.inventory:Equip(sameItem);
            else
                sameItem = findSpecItem(inst, data, 1);
                if sameItem then
                    inst.components.inventory:Equip(sameItem);
                end
            end
        end
    end

    function fns.OnUmbrellaRanOut(inst, data)
        --print("more items: OnUmbrellaRanOut");
        if inst.components.inventory:GetEquippedItem(data.equipslot) == nil then
            local sameItem = inst.components.inventory:FindItem(function(item)
                return item:HasTag("umbrella") and
                        item.components.equippable ~= nil and
                        item.components.equippable.equipslot == data.equipslot
            end)
            if sameItem then
                inst.components.inventory:Equip(sameItem);
            else
                sameItem = findSpecItem(inst, data, 2);
                if sameItem then
                    inst.components.inventory:Equip(sameItem);
                end
            end
        end
    end

    function fns.ArmorBroke(inst, data)
        --print("more items: ArmorBroke");
        if data.armor ~= nil then
            local sameArmor = inst.components.inventory:FindItem(function(item)
                return item.prefab == (data.armor and data.armor.prefab)
            end)
            if sameArmor ~= nil then
                inst.components.inventory:Equip(sameArmor)
            else
                sameArmor = findSpecItem(inst, data, 3);
                if sameArmor then
                    inst.components.inventory:Equip(sameArmor);
                end
            end
        end
    end

    function fns.WeaponBroke(inst, data)
        --print("more items: WeaponBroke");
        if data.weapon ~= nil then
            local sameWeapon = inst.components.inventory:FindItem(function(item)
                return item.prefab == (data.weapon and data.weapon.prefab)
            end)
            if sameWeapon ~= nil then
                inst.components.inventory:Equip(sameWeapon)
            else
                sameWeapon = findSpecItem(inst, data, 4);
                if sameWeapon then
                    inst.components.inventory:Equip(sameWeapon);
                end
            end
        end
    end

    local function RegisterMasterEventListeners(inst)
        inst:ListenForEvent("more_items_weaponbroke", fns.WeaponBroke);
    end

    -- 推送相关事件
    local weapon = require("components/weapon");
    if weapon then
        local old_weapon_ctor = weapon._ctor;
        if old_weapon_ctor then
            local function onpercentusedchange(inst, data)
                if inst.components.weapon ~= nil and
                        data.percent ~= nil and
                        data.percent <= 0 and
                        inst.components.inventoryitem ~= nil and
                        inst.components.inventoryitem.owner ~= nil then
                    inst.components.inventoryitem.owner:PushEvent("more_items_weaponbroke", { weapon = inst })
                end
            end
            weapon._ctor = function(self, ...)
                if old_weapon_ctor then
                    old_weapon_ctor(self, ...);
                end
                self.inst:ListenForEvent("percentusedchange", onpercentusedchange);
            end
        end
    end

    -- 设置相关事件监听器
    env.AddPlayerPostInit(function(inst)
        if not TheWorld.ismastersim then
            return inst;
        end
        RegisterMasterEventListeners(inst);
    end)

    -- 重写相关事件监听的函数
    local function getPlayerPrefabTabData(name)
        local Prefabs = GLOBAL.Prefabs;
        if Prefabs == nil then
            return ;
        end
        if type(name) == "string" then
            return Prefabs[name];
        end
        local players = { "wathgrithr" }; -- 补充？但是按道理来说，所有人物的预制物应该都被注册了吧？
        for _, player_name in ipairs(players) do
            if Prefabs[player_name] then
                return Prefabs[player_name];
            end
        end
    end

    env.AddSimPostInit(function()
        local Prefabs = GLOBAL.Prefabs;
        if Prefabs == nil then
            return ;
        end
        local player_common = getPlayerPrefabTabData();
        if player_common and player_common.fn then
            local Debug = API.Debug;
            local player_common_fns = Debug.GetUpvalueTab(player_common.fn, "fns");
            if type(player_common_fns) == "table" then
                --print("player_common_fns.OnItemRanOut: " .. tostring(player_common_fns.OnItemRanOut));
                --print("fns.OnItemRanOut: " .. tostring(fns.OnItemRanOut));
                player_common_fns.OnItemRanOut = fns.OnItemRanOut;
                player_common_fns.OnUmbrellaRanOut = fns.OnUmbrellaRanOut;
                player_common_fns.ArmorBroke = fns.ArmorBroke;
                --print("player_common_fns.OnItemRanOut: " .. tostring(player_common_fns.OnItemRanOut));
            end
        end
    end)
end






