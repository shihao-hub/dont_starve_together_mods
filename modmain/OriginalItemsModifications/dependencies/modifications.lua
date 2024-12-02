---
--- @author zsh in 2023/4/24 14:52
---

--[[
    蝙蝠棒：耐久翻倍
    晨星锤：电子元件可以修复
    三尾猫鞭：攻击伤害翻倍
    空浇水壶：格子、返鲜
    空鸟嘴壶：格子、返鲜
    ?传送法杖：不再消耗耐久，改为消耗饥饿度？或者是CD？
    ?克眼帽子和盾牌：耐久度840，还是会爆炸比较好
    蜂王冠：采集蜂蜜不会出杀人蜂、佩戴者拥有昆虫标签，蜜蜂不会主动攻击
    ?刷子
]]

local API = require("chang_mone.dsts.API");
local TEXT = require("languages.mone.loc");
local config_data = TUNING.MONE_TUNING.GET_MOD_CONFIG_DATA;
local DATA = config_data.original_items_modifications_data;
local items_fns = DATA.items_fns;

local fns = {};

local PASSED_ENV = {
    API = API;
    TEXT = TEXT;
    config_data = config_data;
    items_fns = items_fns;
    decision_fn = function(inst, prefabname)
        return inst.prefab == prefabname and inst.mi_ori_item_modify_tag and config_data[prefabname];
    end;
    DoNothing = function()
        return ;
    end
};

local function haomodimport(modulename, ENV)
    ENV = setmetatable(ENV, { __index = env });

    --install our crazy loader!
    print("haomodimport: " .. env.MODROOT .. modulename)
    if string.sub(modulename, #modulename - 3, #modulename) ~= ".lua" then
        modulename = modulename .. ".lua"
    end
    local result = kleiloadlua(env.MODROOT .. modulename)
    if result == nil then
        error("Error in haomodimport: " .. modulename .. " not found!")
    elseif type(result) == "string" then
        error("Error in haomodimport: " .. ModInfoname(modname) .. " importing " .. modulename .. "!\n" .. result)
    else
        setfenv(result, ENV)
        result()
    end

end

local CONST_ROOT = "modmain/OriginalItemsModifications/dependencies/items/";

haomodimport(CONST_ROOT .. "batbat.lua", PASSED_ENV);
haomodimport(CONST_ROOT .. "nightstick.lua", PASSED_ENV);
haomodimport(CONST_ROOT .. "whip.lua", PASSED_ENV);
haomodimport(CONST_ROOT .. "wateringcan.lua", PASSED_ENV);
haomodimport(CONST_ROOT .. "premiumwateringcan.lua", PASSED_ENV);
haomodimport(CONST_ROOT .. "hivehat.lua", PASSED_ENV);
haomodimport(CONST_ROOT .. "eyemaskhat.lua", PASSED_ENV);
haomodimport(CONST_ROOT .. "shieldofterror.lua", PASSED_ENV);

for name, data in pairs(items_fns) do
    if data.CanMake then
        fns[name .. "_onpreload"] = data.onpreload;
        fns[name .. "_onload"] = data.onload;
    end
end

for name, data in pairs(items_fns) do
    if data.CanMake then
        env.AddPrefabPostInit(name, function(inst)
            if not TheWorld.ismastersim then
                return inst;
            end

            if inst.components.named == nil then
                inst:AddComponent("named");
            end

            -- OnSave OnPreLoad OnLoad 客机是不会执行的！！！
            local old_OnSave = inst.OnSave;
            inst.OnSave = function(inst, data)
                if old_OnSave then
                    old_OnSave(inst, data);
                end
                data.mi_ori_item_modify_tag = inst.mi_ori_item_modify_tag;
            end

            local old_OnPreLoad = inst.OnPreLoad;
            inst.OnPreLoad = function(inst, data)
                if old_OnPreLoad then
                    old_OnPreLoad(inst, data);
                end
                if data == nil then
                    return ;
                end
                inst.mi_ori_item_modify_tag = data.mi_ori_item_modify_tag;
                if inst.mi_ori_item_modify_tag then
                    for prefab_name, _ in pairs(items_fns) do
                        if inst.prefab == prefab_name and fns[prefab_name .. "_onpreload"] then
                            fns[prefab_name .. "_onpreload"](inst, true);
                            break ;
                        end
                    end
                end
            end

            local old_OnLoad = inst.OnLoad;
            inst.OnLoad = function(inst, data)
                if old_OnLoad then
                    old_OnLoad(inst, data);
                end
                if data == nil then
                    return ;
                end
                inst.mi_ori_item_modify_tag = data.mi_ori_item_modify_tag;
                if inst.mi_ori_item_modify_tag then
                    for prefab_name, _ in pairs(items_fns) do
                        if inst.prefab == prefab_name and fns[prefab_name .. "_onload"] then
                            fns[prefab_name .. "_onload"](inst, true);
                            break ;
                        end
                    end
                end
            end
        end)
    end
end

env.AddPlayerPostInit(function(inst)
    if not TheWorld.ismastersim then
        return inst;
    end
    if inst.components.builder == nil then
        return inst;
    end
    local old_DoBuild = inst.components.builder.DoBuild;
    function inst.components.builder:DoBuild(recname, ...)
        self.inst.mi_temp_recname = recname;
        return old_DoBuild(self, recname, ...);
    end

    -- 此函数是在 DoBuild 内执行的！
    local old_onBuild = inst.components.builder.onBuild;
    inst.components.builder.onBuild = function(player, prod, ...)
        if old_onBuild then
            old_onBuild(player, prod, ...);
        end
        if not (prod and prod:IsValid()) then
            return ;
        end
        for prefab_name, _ in pairs(items_fns) do
            if prod.prefab == prefab_name and player.mi_temp_recname == prefab_name .. "_mi_copy" then
                prod.mi_ori_item_modify_tag = true;
                if fns[prefab_name .. "_onpreload"] then
                    fns[prefab_name .. "_onpreload"](prod);
                end
                if fns[prefab_name .. "_onload"] then
                    fns[prefab_name .. "_onload"](prod);
                end
                break ;
            end
        end
        player.mi_temp_recname = nil;
    end
end)


