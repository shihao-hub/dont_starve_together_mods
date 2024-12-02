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

local config_data = TUNING.MONE_TUNING.GET_MOD_CONFIG_DATA;

local DATA = config_data.original_items_modifications_data;

local ORIGINAL_ITEMS = DATA.original_items;

local PostInitFns = {};

local CONST_ROOT = "modmain/OriginalItemsModifications2/dependencies/items/";

for name, switch in pairs(ORIGINAL_ITEMS) do
    if switch then
        PostInitFns[name] = HaoImport(CONST_ROOT .. name .. ".lua");

        env.AddPrefabPostInit(name, function(inst)
            inst:DoTaskInTime(0,function(inst)
                if PostInitFns[name] then
                    PostInitFns[name](inst);
                end
            end)

            if not TheWorld.ismastersim then
                return inst;
            end

            if inst.components.named == nil then
                inst:AddComponent("named");
            end

            --inst:AddComponent("mi_original_items_modifications");

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
            end

            --local old_OnLoad = inst.OnLoad;
            --inst.OnLoad = function(inst, data)
            --    if old_OnLoad then
            --        old_OnLoad(inst, data);
            --    end
            --    if data == nil then
            --        return ;
            --    end
            --    inst.mi_ori_item_modify_tag = data.mi_ori_item_modify_tag;
            --end
        end)
    end
end

print("------1: ");
for k, v in pairs(PostInitFns) do
    print("",tostring(k),tostring(v));
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
        for prefab_name, switch in pairs(ORIGINAL_ITEMS) do
            if switch and prod.prefab == prefab_name and player.mi_temp_recname == prefab_name .. "_mi_copy" then
                prod.mi_ori_item_modify_tag = true;
                if type(PostInitFns[prefab_name]) == "function" then
                    PostInitFns[prefab_name](prod);
                end
                break ;
            end
        end
        player.mi_temp_recname = nil;
    end
end)


