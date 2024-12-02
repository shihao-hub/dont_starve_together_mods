---
--- @author zsh in 2023/2/10 9:46
---

local API = require("chang_mone.dsts.API");

-- 热更新
local data = {};
local data_locate = {};

data_locate["API.reskin2 == nil"] = true;
data[#data + 1] = {
    CanMake = API.reskin2 == nil,
    fn = function()
        local function containsValue(t, e)
            for _, v in pairs(t) do
                if v == e then
                    return true;
                end
            end
            return false;
        end

        local fns = {};
        function fns.bushhat_equipped(inst, data)
            if inst.vfx_fx ~= nil then
                if inst._vfx_fx_inst == nil then
                    inst._vfx_fx_inst = SpawnPrefab(inst.vfx_fx)
                    inst._vfx_fx_inst.entity:AddFollower()
                    inst._vfx_fx_inst.entity:SetParent(data.owner.entity)
                    inst._vfx_fx_inst.Follower:FollowSymbol(data.owner.GUID, "swap_hat", 0, -55, 0)
                end
            end
        end

        function fns.bushhat_unequipped(inst, owner)
            if inst._vfx_fx_inst ~= nil then
                inst._vfx_fx_inst:Remove()
                inst._vfx_fx_inst = nil
            end
        end

        function API.reskin2(env, prefabname, bank, build, prefabs)
            local name = prefabname;

            -- 补丁
            if prefabname == "cane" and #prefabs > 1 then
                return ;
            end

            local init_fn_name = name .. '_init_fn';
            local init_fn = rawget(_G, init_fn_name);
            if not init_fn then
                print('`' .. init_fn_name .. '` global function does not exist!');
                return ;
            end

            rawset(_G, init_fn_name, function(inst, build_name, def_build)
                if not containsValue(prefabs, inst.prefab) then
                    return init_fn(inst, build_name, def_build);
                else
                    if bank then
                        inst.AnimState:SetBank(bank);
                    end
                    basic_init_fn(inst, build_name, build);

                    -- 补丁
                    if prefabname == "cane" then
                        if inst.components.inventoryitem then
                            inst.components.inventoryitem:ChangeImageName("walkingstick");
                        end
                    elseif prefabname == "bushhat" then
                        if not TheWorld.ismastersim then
                            return
                        end
                        --print("build_name: "..tostring(build_name));
                        local skin_fx = SKIN_FX_PREFAB[build_name] --build_name is prefab name for bushhat
                        if skin_fx ~= nil then
                            inst.vfx_fx = skin_fx[1] ~= nil and skin_fx[1]:len() > 0 and skin_fx[1] or nil
                            if inst.vfx_fx ~= nil then
                                inst:ListenForEvent("equipped", fns.bushhat_equipped)
                                inst:ListenForEvent("unequipped", fns.bushhat_unequipped)
                                inst:ListenForEvent("onremove", fns.bushhat_unequipped)
                            end
                        end
                    end
                end
            end);

            local clear_fn_name = name .. '_clear_fn';
            local clear_fn = rawget(_G, clear_fn_name);
            if not clear_fn then
                print('`' .. clear_fn_name .. '` global function does not exist!');
                return ;
            end

            rawset(_G, clear_fn_name, function(inst, def_build)
                if not containsValue(prefabs, inst.prefab) then
                    return clear_fn(inst, def_build);
                else
                    if bank then
                        inst.AnimState:SetBank(bank);
                    end
                    basic_clear_fn(inst, build);

                    -- 补丁
                    if prefabname == "cane" then
                        if inst.components.inventoryitem then
                            inst.components.inventoryitem:ChangeImageName("walkingstick");
                        end
                    elseif prefabname == "bushhat" then
                        inst:RemoveEventCallback("equipped", fns.bushhat_equipped)
                        inst:RemoveEventCallback("unequipped", fns.bushhat_unequipped)
                        inst:RemoveEventCallback("onremove", fns.bushhat_unequipped)
                    end
                end
            end);

            -- 补丁
            if prefabname == "cane" then
                for _, v in ipairs(prefabs) do
                    env.AddPrefabPostInit(v, function(inst)
                        if not TheWorld.ismastersim then
                            return inst;
                        end
                        if inst.components.equippable then
                            local old_onequipfn = inst.components.equippable.onequipfn;
                            inst.components.equippable.onequipfn = function(inst, owner, ...)
                                if old_onequipfn then
                                    old_onequipfn(inst, owner, ...);
                                end

                                --local skin_name = inst:GetSkinName();
                                --if skin_name then
                                --    if inst.components.inventoryitem then
                                --        inst.components.inventoryitem:ChangeImageName(skin_name); -- 这样是换不了的！
                                --    end
                                --end

                                local skin_build = inst:GetSkinBuild();
                                if skin_build then
                                    owner:PushEvent("equipskinneditem", skin_build);
                                    owner.AnimState:OverrideItemSkinSymbol("swap_object", skin_build, "swap_cane", inst.GUID, "swap_cane");
                                end
                            end

                            local old_onunequipfn = inst.components.equippable.onunequipfn;
                            inst.components.equippable.onunequipfn = function(inst, owner, ...)
                                if old_onunequipfn then
                                    old_onunequipfn(inst, owner, ...);
                                end

                                local skin_build = inst:GetSkinBuild()
                                if skin_build then
                                    owner:PushEvent("unequipskinneditem", inst:GetSkinName())
                                end
                            end
                        end
                    end)
                end
            end

            -- 修改全局表，应该可以让制作物品页面可以选皮肤
            if ((rawget(_G, 'PREFAB_SKINS') or {})[name] and (rawget(_G, 'PREFAB_SKINS_IDS') or {})[name]) then
                for _, reskin_prefab in ipairs(prefabs) do
                    PREFAB_SKINS[reskin_prefab] = PREFAB_SKINS[name];
                    PREFAB_SKINS_IDS[reskin_prefab] = PREFAB_SKINS_IDS[name];
                end
            end

        end
    end
}

data_locate["API.AutoSorter.beginTransfer_HOT_UPDATE2 ~= false"] = true;
data[#data + 1] = {
    CanMake = API.AutoSorter.beginTransfer_HOT_UPDATE2 ~= false,
    fn = function()
        -- TEMP
        local temp_fns = {};
        function temp_fns.entsNumberEstimate(ents)
            local n = #ents;

            return true;
        end
        function temp_fns.isIceboxOrSaltboxETC(con)
            if con.components.preserver or con:HasTag("fridge") then
                return true;
            end
            return false;
        end
        function temp_fns.transferIntoSomeCon(self, con, slot)
            --if findMinisignItem(self, con, slot) then
            --    return true;
            --end

            if con.prefab == "mie_watersource" or con.prefab == "mone_wardrobe" then
                local item = self.components.container:GetItemInSlot(slot);
                local src_pos = self:GetPosition();
                src_pos = nil;
                if item and item:HasTag("_equippable") and con and con.components.container and con.prefab ~= self.prefab and item.components.inventoryitem.cangoincontainer then
                    item = self.components.container:RemoveItemBySlot(slot);
                    item.prevslot = nil;
                    item.prevcontainer = nil;
                    if con.components.container:GiveItem(item, nil, src_pos) then
                        return true;
                    else
                        self.components.container:GiveItem(item, slot);
                        return false;
                    end
                end
            end
            return false;
        end
        function temp_fns.findSameObjectAndTransfer(self, con, slot)
            local item = self.components.container:GetItemInSlot(slot);
            local src_pos = self:GetPosition();
            src_pos = nil;
            if item and con and con.components.container and con.components.container:Has(item.prefab, 1)
                    and con.prefab ~= self.prefab and item.components.inventoryitem.cangoincontainer then
                item = self.components.container:RemoveItemBySlot(slot);
                item.prevslot = nil;
                item.prevcontainer = nil;
                if con.components.container:GiveItem(item, nil, src_pos) then
                    return true;
                else
                    self.components.container:GiveItem(item, slot);
                    return false;
                end
            end
            return false;
        end
        function temp_fns.noFindObjectAndTransfer(self, con, slot)
            local item = self.components.container:GetItemInSlot(slot);
            local src_pos = self:GetPosition();
            src_pos = nil;
            if item and con and con.components.container and con.prefab ~= self.prefab
                    and item.components.inventoryitem.cangoincontainer then
                item = self.components.container:RemoveItemBySlot(slot);
                item.prevslot = nil;
                item.prevcontainer = nil;
                if item.components.perishable then
                    if temp_fns.isIceboxOrSaltboxETC(con) and con.components.container:GiveItem(item, nil) then
                        return true;
                    else
                        self.components.container:GiveItem(item, slot);
                        return false;
                    end
                else
                    if not temp_fns.isIceboxOrSaltboxETC(con) and con.components.container:GiveItem(item, nil, src_pos) then
                        return true;
                    else
                        self.components.container:GiveItem(item, slot);
                        return false;
                    end
                end
            end
        end
        function temp_fns.genericFX(self, con)
            local selfFX = SpawnPrefab("sand_puff_large_front");
            local conFX = SpawnPrefab("sand_puff")
            local scale = 1.5;
            conFX.Transform:SetScale(scale, scale, scale)
            selfFX.Transform:SetScale(scale, scale, scale)
            conFX.Transform:SetPosition(con.Transform:GetWorldPosition())
            selfFX.Transform:SetPosition(self.Transform:GetWorldPosition())
        end

        function API.AutoSorter.beginTransfer(inst)
            local x, y, z = inst.Transform:GetWorldPosition();
            local DIST = 18; -- 转移的话，范围大一点点
            local MUST_TAGS = { "_container" };
            local CANT_TAGS = {
                "INLIMBO", "NOCLICK", "knockbackdelayinteraction", "catchable", "mineactive",
                "stewer",
                "_inventoryitem", "_health",
                "mie_sand_pit", "mone_firesuppressor",
                "mone_chiminea", "pets_container_tag", "mie_wooden_drawer"
            };
            if x and y and z then
                local ents = TheSim:FindEntities(x, y, z, DIST, MUST_TAGS, CANT_TAGS);

                -- 补充一个种子袋（之后限制在地上？），所以 FindEntities 函数到底占不占用性能？
                local excludes = TheSim:FindEntities(x, y, z, DIST, { "mone_seedpouch" }, nil--[[{ "INLIMBO", "NOCLICK" }]]);
                for _, v in ipairs(excludes) do
                    if v then
                        table.insert(ents, 1, v);
                    end
                end

                if temp_fns.entsNumberEstimate(ents) then
                    -- 第一次遍历：转移进指定容器
                    local slotsNum = inst.components.container:GetNumSlots();
                    slotsNum = inst.components.container:GetNumSlots();
                    for i = 1, slotsNum do
                        for _, v in ipairs(ents) do
                            if temp_fns.transferIntoSomeCon(inst, v, i) then
                                --print("transferIntoSomeCon---[" .. tostring(i) .. "]");
                                temp_fns.genericFX(inst, v);
                                break ;
                            end
                        end
                    end
                    -- 第二次遍历：转移同类物品
                    slotsNum = inst.components.container:GetNumSlots();
                    for i = 1, slotsNum do
                        for _, v in ipairs(ents) do
                            if temp_fns.findSameObjectAndTransfer(inst, v, i) then
                                --print("findSameObjectAndTransfer---[" .. tostring(i) .. "]");
                                temp_fns.genericFX(inst, v);
                                break ;
                            end
                        end
                    end
                    -- 第三次遍历：转移剩余物品
                    slotsNum = inst.components.container:GetNumSlots();
                    for i = 1, slotsNum do
                        for _, v in ipairs(ents) do
                            if temp_fns.noFindObjectAndTransfer(inst, v, i) then
                                --print("noFindObjectAndTransfer---[" .. tostring(i) .. "]");
                                temp_fns.genericFX(inst, v);
                                break ;
                            end
                        end
                    end
                end
            end
            -- 转移结束，掉落所有物品
            --inst.components.container:DropEverything(); -- 别掉落了，不好
        end
    end
}

data_locate = nil;
for _, v in ipairs(data) do
    if v.CanMake then
        v.fn();
    end
end