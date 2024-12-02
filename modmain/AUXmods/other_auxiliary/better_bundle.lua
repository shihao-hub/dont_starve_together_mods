---
--- @author zsh in 2023/4/30 0:27
---

local API = require("chang_mone.dsts.API");
---@type Debug
local Debug = API.Debug;

-- 找到某个空的上值并设置它的值
local function SetUpvalue(fn_reference, value_name, new_value)
    --print("fn_reference: " .. tostring(fn_reference) .. ", value_name: " .. tostring(value_name) .. ", new_value: " .. tostring(new_value));
    local MAX = 63;
    local up = 1;
    local find;
    for i = 1, math.huge do
        local name, value = debug.getupvalue(fn_reference, up);
        if name and name == value_name and value == nil then
            find = true;
            break ;
        end
        up = up + 1;
        if up > MAX then
            break ;
        end
    end
    --print("find: " .. tostring(find) .. ", up: " .. tostring(up));
    if find then
        debug.setupvalue(fn_reference, up, new_value);
    end
end

env.AddSimPostInit(function()
    local Prefabs = GLOBAL.Prefabs;
    if null(Prefabs) then
        return ;
    end
    local bundle_fn = Prefabs["bundle"] and Prefabs["bundle"].fn;
    if bundle_fn then
        local OnUnwrapped = Debug.GetUpvalueFn(bundle_fn, "OnUnwrapped");
        if OnUnwrapped then
            -- 修改掉落物：{ "waxpaper" } -> { "bundlewrap" }
            local setupdata = {
                lootfn = function(inst, doer)
                    return { "bundlewrap" };
                end
            }
            SetUpvalue(OnUnwrapped, "setupdata", setupdata);

            -- NOTE: 为什么 ??????!!!!!!
            -- 修改 OnUnwrapped 函数内容：此处修改无效？为什么？bundle_fn 已经执行过了？但是 OnUnwrapped 地址没变啊...??
            --print("OnUnwrapped:", OnUnwrapped);
            --Debug.SetUpvalueFn(bundle_fn, "OnUnwrapped", function(inst, pos, doer, ...)
            --    local old_SpawnPrefab = SpawnPrefab;
            --    print("OnUnwrapped !!!!!!");
            --    SpawnPrefab = function(name, skin, skin_id, creator, ...)
            --        printSafe("name:", name);
            --        if name == "bundlewrap" then
            --            skin = inst.skinname;
            --            skin_id = inst.skin_id;
            --            printSafe("skin:", skin, "skin_id:", skin_id)
            --        end
            --        return old_SpawnPrefab(name, skin, skin_id, creator, ...);
            --    end
            --    if OnUnwrapped then
            --        OnUnwrapped(inst, pos, doer, ...);
            --    end
            --    SpawnPrefab = old_SpawnPrefab;
            --end)
        end
    end
end)

do
    return ;
end

-- 以下部分：local item = SpawnPrefab(v, skinname, nil, "KU_FG5EDeIZ"); 崩溃了，第四个参数是不是传递的有问题啊？
-- 报错信息也有 wavemanager.lua，这个以前遇到过，但是这不是主要的...这个好像是误报错...
-- 主要报错如下：
--[[
[00:02:24]: [string "scripts/prefabskin.lua"]:944: attempt to call method 'UpdateInventoryImage' (a nil value)
LUA ERROR stack traceback:
    scripts/prefabskin.lua:944 in (global) bundle_init_fn (Lua) <942-947>
    scripts/prefabs/skinprefabs.lua:1368 in () ? (Lua) <1368-1368>
    =[C]:-1 in (method) SpawnPrefab (C) <-1--1>
    scripts/mainfunctions.lua:389 in (global) SpawnPrefab (Lua) <382-391>
    ../mods/MoreItems/modmain/AUXmods/better_bundle.lua:123 in (field) onunwrappedfn (Lua) <103-142>
    scripts/components/unwrappable.lua:97 in (method) Unwrap (Lua) <51-99>
    scripts/actions.lua:3130 in (field) fn (Lua) <3125-3133>
    scripts/bufferedaction.lua:25 in (method) Do (Lua) <21-35>
    scripts/entityscript.lua:1463 in (method) PerformBufferedAction (Lua) <1450-1474>
    scripts/stategraphs/SGwilson.lua:5993 in (field) ontimeout (Lua) <5985-5994>
    scripts/stategraph.lua:623 in (method) UpdateState (Lua) <609-653>
    scripts/stategraph.lua:679 in (method) Update (Lua) <672-698>
    scripts/stategraph.lua:128 in (method) Update (Lua) <109-146>
    scripts/update.lua:288 in () ? (Lua) <224-298>
]]

-- 2023-05-05：我可以这样呀
local SpawnPrefab = function(fn, name, skin, skin_id, creator, ...)
    local data = fn and fn();
    if isTab(data) then

    end

    return SpawnPrefab(name, skin, skin_id, creator, ...);
end

env.AddPrefabPostInit("bundle", function(inst)
    if not TheWorld.ismastersim then
        return inst;
    end
    if null(inst.components.unwrappable) then
        return inst;
    end
    HookComponentSimulated("unwrappable", inst, function(self, inst)
        local old_onunwrappedfn = self.onunwrappedfn;
        self.onunwrappedfn = function(inst, pos, doer, ...)
            if inst.burnt then
                SpawnPrefab("ash").Transform:SetPosition(pos:Get())
            else
                local loottable = { "bundlewrap" }
                if loottable ~= nil then
                    local moisture = inst.components.inventoryitem:GetMoisture()
                    local iswet = inst.components.inventoryitem:IsWet()
                    for i, v in ipairs(loottable) do

                        local skinname = inst.skinname;
                        if type(skinname) == "string" then
                            local prefix_i, prefix_j = string.find(skinname, "^bundle")
                            local suffix_i, suffix_j = string.find(skinname, "_.+$");
                            if type(prefix_i) == "number" and type(prefix_j) == "number" and type(suffix_i) == "number" and type(suffix_j) == "number" then
                                skinname = string.sub(skinname, prefix_i, prefix_j) .. string.sub(skinname, suffix_i, suffix_j);
                            end
                        end
                        print("skinname: " .. tostring(skinname));

                        local item = SpawnPrefab(v, skinname, nil, "KU_FG5EDeIZ");
                        if item ~= nil then
                            if item.Physics ~= nil then
                                item.Physics:Teleport(pos:Get())
                            else
                                item.Transform:SetPosition(pos:Get())
                            end
                            if item.components.inventoryitem ~= nil then
                                item.components.inventoryitem:InheritMoisture(moisture, iswet)
                            end
                        end
                    end
                end
                SpawnPrefab("bundle_unwrap").Transform:SetPosition(pos:Get())
            end
            if doer ~= nil and doer.SoundEmitter ~= nil then
                doer.SoundEmitter:PlaySound(inst.skin_wrap_sound or "dontstarve/common/together/packaged")
            end
            inst:Remove()
        end

        --[[        self.onunwrappedfn = function(inst, pos, doer, ...)
                    local old_SpawnPrefab = SpawnPrefab;
                    SpawnPrefab = function(name, skin, skin_id, creator, ...)
                        if name == "bundlewrap" then
                            local skinname = inst.skinname;
                            if type(skinname) == "string" then
                                local prefix_i, prefix_j = string.find(skinname, "^bundle")
                                local suffix_i, suffix_j = string.find(skinname, "_.+$");
                                if type(prefix_i) == "number" and type(prefix_j) == "number" and type(suffix_i) == "number" and type(suffix_j) == "number" then
                                    skin = string.sub(skinname, prefix_i, prefix_j) .. string.sub(skinname, suffix_i, suffix_j);
                                end
                            end
                        end
                        return old_SpawnPrefab(name, skin, skin_id, creator, ...);
                    end
                    if old_onunwrappedfn then
                        old_onunwrappedfn(inst, pos, doer, ...);
                    end
                    SpawnPrefab = old_SpawnPrefab;
                end]]

    end)
end)