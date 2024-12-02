---
--- @author zsh in 2023/5/5 19:08
---

local config_data = TUNING.MONE_TUNING.GET_MOD_CONFIG_DATA;

local SgcCleanList = env.modinfo.SgcCleanList;

if SgcCleanList == nil then
    return ;
end

local fns = {};

local SgcCleanListSwitch = {};
local SgcCleanListSwitchImported = {};

for i = 1, #SgcCleanList do
    local data = SgcCleanList[i];
    local name = data.name;
    local default = env.GetModConfigData("sgc_" .. name);

    SgcCleanListSwitch[name] = default;

    if string.find(name, "^category_") then
        name = string.sub(name, 10, #name);
    end
    SgcCleanListSwitchImported[name] = default;
end

-- TEST
--SgcCleanListSwitch["twigs"] = true;

local old_Import = Import;
local function Import(modulename, environment, ...)
    environment = setmetatable({
        SgcCleanListSwitchImported = setmetatable(SgcCleanListSwitchImported, {
            __call = function(t, ...)
                -- 为什么要写 __call 呢？我写着玩...
                local key = select(1, ...);
                return t[key];
            end
        });
    }, { __index = env });
    modulename = "modmain/AUXmods/other_auxiliary/simple_garbage_collection/" .. modulename;
    return old_Import(modulename, environment, ...);
end

-- 单个物品
local others = {}
for name, switch in pairs(SgcCleanListSwitch) do
    if switch and not string.find(name, "^category_") then
        table.insert(others, name);
    end
end

-- 一类物品
local winter = Import("items/winter.lua");
local halloween = Import("items/halloween.lua");

local CleanList = UnionSeq(others, winter, halloween);

local function genericFX(inst)
    local v = inst;

    -- 生成特效：这个判定应该是可以判定成只在地面上的吧？
    if v.Transform and v.components.inventoryitem
            and v.components.inventoryitem:GetGrandOwner() == nil then
        local x, y, z = v.Transform:GetWorldPosition();
        if null(x) or null(y) or null(z) then
            -- DoNothing
        else
            local fx = SpawnPrefab("sand_puff");
            -- 变色
            --if fx.AnimState then
            --    fx.AnimState:SetMultColour(.1, 1, .1, 1)
            --end
            local scale = 1.2;
            fx.Transform:SetScale(scale, scale, scale);
            fx.Transform:SetPosition(x, y, z);
        end
    end
end

local function GetPrefabName(inst)
    if not isValid(inst) then
        return "NotIsValidPrefabName";
    end
    local v = inst;
    return v.name or STRINGS.NAMES[string.upper(v.prefab)] or v:GetBasicDisplayName() or "MISSING NAME";
end

local function SetSpecialPrefabName(prefab_name)
    local name;
    if string.find(prefab_name, "^winter_ornament_light") then
        name = "圣诞灯";
    elseif string.find(prefab_name, "^winter_ornament_boss") then
        name = "华丽的装饰";
    end
    return name;
end

function fns.Clean(inst, delay, ...)
    inst = inst or TheWorld;
    delay = delay or 5;

    local CleanList = CleanList;

    local TargetedCleanList = (select(1, ...));

    if isTab(TargetedCleanList) then
        CleanList = TargetedCleanList;
    end

    local world_name = "";
    if inst:HasTag("forest") then
        world_name = "森林";
    elseif inst:HasTag("cave") then
        world_name = "洞穴";
    end

    TheNet:Announce("更多物品：" .. world_name .. "服务器将于" .. tostring(delay) .. "秒后清理掉地面上的部分垃圾！");
    inst:DoTaskInTime(delay, function(inst, world_name)
        -- 临时缓存表
        local CleanedPrefabs = {};

        -- 清理垃圾
        for _, v in pairs(Ents) do
            if isValid(v) and v.prefab and table.contains(CleanList, v.prefab) then
                if v.IsInLimbo and not v:IsInLimbo() and v.components then
                    if CleanedPrefabs[v.prefab] == nil then
                        CleanedPrefabs[v.prefab] = {};
                        CleanedPrefabs[v.prefab].name = GetPrefabName(v);
                    end
                    if CleanedPrefabs[v.prefab].count == nil then
                        CleanedPrefabs[v.prefab].count = 0;
                    end

                    -- 计数
                    local addnum = v.components.stackable and v.components.stackable:StackSize() or 1;
                    CleanedPrefabs[v.prefab].count = CleanedPrefabs[v.prefab].count + addnum;

                    genericFX(v);

                    v:Remove();
                end
            end
        end

        -- 生成输出信息
        local msg = {};
        local count = 0;
        for prefab_name, data in pairs(CleanedPrefabs) do
            local name = data.name;
            if null(name) or isStr(name) and string.find(name, "MISSING NAME") then
                name = SetSpecialPrefabName(prefab_name) or "获取不到名字的物品";
            end
            if isStr(name) then
                if count % 5 == 0 then
                    table.insert(msg, name .. tostring(data.count) .. "个");
                else
                    msg[#msg] = msg[#msg] .. " " .. name .. tostring(data.count) .. "个";
                end
                count = count + 1;
            end
        end

        -- 输出信息
        if #msg > 0 then
            table.insert(msg, 1, world_name .. "服务器清理了：");
            for i = 1, #msg do
                TheNet:Announce(msg[i]);
            end
        else
            TheNet:Announce("当前世界的地面上不存在需要被清理的物品。");
        end

        -- 取消引用
        CleanedPrefabs = nil;
    end, world_name)
end

-- 直接清理的命令
TUNING.MONE_TUNING.DebugCommands.Clean = fns.Clean;

GLOBAL.global("c_simple_garbage_collection");
GLOBAL.c_simple_garbage_collection = fns.Clean;

GLOBAL.global("c_mi_sgc");
GLOBAL.c_mi_sgc = fns.Clean;

-- 针对性清理
GLOBAL.global("c_mi_sgc_targ");

local ChsEnsMap = {
    ["草"] = "cutgrass";
}
GLOBAL.c_mi_sgc_targ = function(...)
    local args = { ... };
    local TargetedCleanList = {};
    for i = 1, table.maxn(args) do
        local item = args[i];
        if isStr(item) then
            if ChsEnsMap[item] then
                table.insert(TargetedCleanList, ChsEnsMap[item]);
            else
                table.insert(TargetedCleanList, item);
            end
        end
    end
    fns.Clean(nil, nil, TargetedCleanList);
end;

-- todo: 游戏内增减待删除物品列表
local function AddItem(name)
    local Prefabs = GLOBAL.Prefabs;
    --if not isStr(name) or not isTab(Prefabs) or not table.contains(Prefabs, name) then
    --    TheNet:Announce("更多物品：向列表中插入" .. tostring(name) .. "失败！因为不存在这个预制物！");
    --    return ;
    --end
    TheNet:Announce("更多物品：向列表中插入" .. tostring(name) .. "成功！");
    table.insert(CleanList, name);
end

local function RemoveItem(name)
    local Prefabs = GLOBAL.Prefabs;
    --if not isStr(name) or not isTab(Prefabs) or not table.contains(Prefabs, name) then
    --    TheNet:Announce("更多物品：从列表中删除" .. tostring(name) .. "失败！因为不存在这个预制物！");
    --    return ;
    --end
    local keys = {};
    for i, v in ipairs(CleanList) do
        if v == name then
            table.insert(keys, i);
        end
    end
    if #keys > 0 then
        for i = 1, #keys do
            table.remove(CleanList, keys[i]);
        end
        TheNet:Announce("更多物品：从列表中删除" .. tostring(name) .. "成功！");
    else
        TheNet:Announce("更多物品：列表中不存在" .. tostring(name) .. "！");
    end
end

-- 上下线保存一下？但是配置项岂不是没用了。处理配置项好像有点麻烦啊...先测试测试！

-- TUNING.MONE_TUNING.DebugCommands.Clean
if isDebugSimple() then
    TUNING.MONE_TUNING.DebugCommands.AddItem = AddItem;
    TUNING.MONE_TUNING.DebugCommands.RemoveItem = RemoveItem;
end

if config_data.sgc_interval == 999999999 then
    return ; -- 导入一个 c_simple_garbage_collection/c_mi_sgc 命令。
end

env.AddPrefabPostInit("world", function(inst)
    if not TheWorld.ismastersim then
        return inst;
    end

    inst:DoTaskInTime(2, function(inst)
        TheNet:Announce("更多物品：简易垃圾清理功能已开启。")
        local interval = TUNING.TOTAL_DAY_TIME * config_data.sgc_interval;
        local delay = 30;

        inst:DoPeriodicTask(interval, function(inst, delay)
            if config_data.sgc_delay_take_effect then
                if TheWorld.state.cycles <= 30 then
                    return ;
                end
            end
            fns.Clean(inst, delay);
        end, nil, delay)
    end)
end)