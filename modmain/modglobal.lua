---
--- @author zsh in 2023/4/21 16:36
---

assert(getfenv(1) ~= _G, "ERROR: current environment is global environment.");

-- 设置 GLOBAL.ShiHao 表及其元表的相关内容
env.modimport("modmain/global/haoglobal.lua");

-- 生成当前文件的环境表：modglobalenv
env.modimport("modmain/global/modglobalenv.lua");

-- 说明一下，扩展包导致不能往 ENV 里塞我这个模组的 env 表，一直没处理。
local ENV = modglobalenv;
setfenv(1, ENV);

-- TEST
--GLOBAL.ShiHao.shuffleArray = shuffleArray;
--MODROOT = env.MODROOT;


-- NEW!
--ENV.env = env;
--GLOBAL.ShiHao.env = env; -- 这是大坑，草。
-----------------------------------------------------------------------------------------------------------
--[[ precondition ]]
-----------------------------------------------------------------------------------------------------------
---添加一些被修改了名字的函数，但是为了保证兼容性，函数需要保留
local function InsertValueENV(key, value)
    ENV[key] = value;
end

--\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
-- 以下函数是最小集 --\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
--\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
function isNil(val)
    return val == nil or type(val) == "nil";
end

function isBool(val)
    return val ~= nil and type(val) == "boolean";
end

function isNum(val)
    return (val ~= nil and type(val) == "number") and val or false;
end

function isStr(val)
    return (val ~= nil and type(val) == "string") and val or false;
end

function isFn(val)
    return (val ~= nil and type(val) == "function") and val or false;
end

function isUser(val)
    return (val ~= nil and type(val) == "userdata") and val or false;
end

function isThread(val)
    return (val ~= nil and type(val) == "thread") and val or false;
end

function isTab(val)
    return (val ~= nil and type(val) == "table") and val or false;
end

function null(val)
    return val == nil or type(val) == "nil";
end

function DoNothing()
    return ;
end
--\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
-- 以上函数是最小集 --\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
--\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

InsertValueENV("IsNil", isNil);
InsertValueENV("IsBool", isBool);
InsertValueENV("IsNum", isNum);
InsertValueENV("IsStr", isStr);
InsertValueENV("IsFn", isFn);
InsertValueENV("IsUser", isUser);
InsertValueENV("IsThread", isThread);
InsertValueENV("IsTab", isTab);
InsertValueENV("NULL", null);

-----------------------------------------------------------------------------------------------------------
--[[ ]]
-----------------------------------------------------------------------------------------------------------
--\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
-- 以下函数是第二小集 --\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
--\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
function isValid(inst)
    return isTab(inst) and inst.IsValid and inst:IsValid();
end

function oneOfNull(n, ...)
    if not isNum(n) then
        return false;
    end
    local args = { ... };
    for i = 1, n do
        if null(args[i]) then
            return true;
        end
    end
    return false;
end

function allNull(n, ...)
    if not isNum(n) then
        return false;
    end
    local args = { ... };
    for i = 1, n do
        if not null(args[i]) then
            return false;
        end
    end
    return true;
end

function isSeq(seq)
    if null(seq) or not isTab(seq) then
        return false;
    end
    local maxn = table.maxn(seq);
    for i = 1, maxn do
        if seq[i] == nil then
            return false;
        end
    end
    return true;
end
--\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
-- 以上函数是第二小集 --\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
--\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

--\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
-- 以下函数是第三小集 --\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
--\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
---还行，暂时可以这样用，即使最后一个参数是 nil...
function allSeq(...)
    local args = { ... };
    for i = 1, table.maxn(args) do
        if not isSeq(args[i]) then
            return false;
        end
    end
    return true;
end

--\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
-- 以上函数是第三小集 --\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
--\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

---@type fun(seq:table[], name:string, number:number)
function printSequence(seq, name, number)
    name = name or "unknown";
    number = number or 30;

    local newline = 5;
    local msg = {};

    if not isSeq(seq) then
        for _, v in ipairs(seq) do
            local v_format = "%s";
            if isStr(v) then
                v_format = "%q";
            end
            table.insert(msg, string.format("" .. v_format .. "", tostring(v)));
        end
    else
        for i = 1, table.maxn(seq) do
            local v = seq[i];
            local v_format = "%s";
            if isStr(v) then
                v_format = "%q";
            end
            table.insert(msg, string.format("" .. v_format .. "", tostring(v)));
        end
    end

    local function concat(i, j)
        local len = #msg;
        i = i or 1;
        j = j or len;
        for index = 1, len do
            if index < len then
                msg[index] = msg[index] .. ",";
            end
            if index % newline == 1 then
                msg[index] = "    " .. msg[index];
            end
            if index % newline == 0 and index < len then
                msg[index] = msg[index] .. "\n";
            end
        end
        return table.concat(msg);
    end

    local body = concat();

    msg = {};

    table.insert(msg, name .. " = " .. "{\n");
    table.insert(msg, body);
    table.insert(msg, "\n}");

    local message = table.concat(msg);
    print(message);
    return message;
end

---浅打印
---@type fun(tab:table, name:string, number:number)
function printTable(tab, name, number)
    name = name or "unknown";
    number = number or 300;
    if not isTab(tab) then
        return ;
    end
    local msg = {};
    local blocks = "    ";

    local cnt = 0;
    for k, v in pairs(tab) do
        cnt = cnt + 1;
        local k_format, v_format = "%q", "%s";
        if isNum(k) then
            k_format = "%d";
        elseif isBool(k) then
            k_format = "%s";
        end
        if isStr(v) then
            v_format = "%q";
        end
        table.insert(msg, blocks .. string.format("[" .. k_format .. "] = " .. v_format .. "", tostring(k), tostring(v)));
        if cnt >= number then
            break ;
        end
    end
    table.sort(msg);

    local body = table.concat(msg, ",\n");

    msg = {};

    table.insert(msg, name .. " = " .. "{\n");
    table.insert(msg, body);
    table.insert(msg, "\n}");

    local message = table.concat(msg);
    print(message);
    return message;
end

-- todo
---用 .. 操作符链接所有传入的参数，其中传入的参数全部都会调用 tostring() 函数
function printSafe(...)
    local args = { ... };
    local res = {};
    for i = 1, table.maxn(args) do
        table.insert(res, tostring(args[i]));
    end
    res = table.concat(res, " | ");
    print(string.sub(res, 1, 256));
    return res;
end
-----------------------------------------------------------------------------------------------------------
--[[ other ]]
-----------------------------------------------------------------------------------------------------------
local locale = LOC.GetLocaleCode();
L = (locale == "zh" or locale == "zht" or locale == "zhr") and true or false;

Logger = nil; -- 提供给 "modmain/logger.lua" 的全局变量表，此文件中的 Logger 不允许在 main 块调用！！！

-----------------------------------------------------------------------------------------------------------
--[[ LogInfo ]]
-----------------------------------------------------------------------------------------------------------
LogInfo = {};

-- 未来拓展：io.write --> 我自己的日志文件，但是 io.write 好像会闪退啊？

local function InsertLogInfo(message)
    message = type(message) == "string" and message or "error message: type(message) ~= 'string'!";
    if #LogInfo > 50 then
        LogInfo = {};
    end
    table.insert(LogInfo, "[" .. tostring(os.date("%Y-%m-%d %X")) .. "]: " .. message);
end

local function PrintLogInfo()
    for _, msg in ipairs(LogInfo) do
        print("LogInfo:", msg);
    end
end
-----------------------------------------------------------------------------------------------------------
--[[ Tykvesh ]]
-----------------------------------------------------------------------------------------------------------

local function ParallelSingletonFn()
    local memory = setmetatable({}, { __mode = "v" });

    local function argstohash(...)
        local args = { ... };
        local str = "";
        for _, v in ipairs(args) do
            str = str .. tostring(v);
        end
        return hash(str);
    end

    local function memget(...)
        return memory[argstohash(...)];
    end

    local function memset(value, ...)
        memory[argstohash(...)] = value;
    end

    -- fixme:
    ---只适用于：函数 + 执行结果简单，仅仅是要么先执行旧函数，要么后执行旧函数。
    return function(root, key, fn, lowprio)
        if isTab(root) and isFn(fn) then
            local oldfn = root[key];
            assert(oldfn and isFn(oldfn) or true);
            local newfn = oldfn and memget("Parallel", oldfn, fn);

            -- 整合在一起就是: if not oldfn or newfn then root[key] = newfn or fn; end！
            if not oldfn then
                root[key] = fn;
            elseif newfn then
                root[key] = newfn;
            else
                -- NOTE: 此处多少还是不是完全通用的，比如：local res = oldfn(...); if res then return fn(...); end 这种！
                if lowprio then
                    root[key] = function(...)
                        oldfn(...);
                        return fn(...);
                    end
                else
                    root[key] = function(...)
                        fn(...);
                        return oldfn(...);
                    end
                end
                -- 同一组函数的话，只设置一次缓存！
                memset(root[key], "Parallel", oldfn, fn);
            end
        end
    end
end

local ParallelFn = ParallelSingletonFn();
-- FIXME
function Parallel(root, key, fn, lowprio)
    return ParallelFn(root, key, fn, lowprio);
end

-- FIXME
---用法：获取 inst.components.container.inst -> Browse(inst,"components","container",inst);
function Browse(tab, ...)
    if not isTab(tab) then
        return ;
    end
    local args = { ... };
    for _, v in ipairs(args) do
        tab = tab[v];
    end
    return tab;
end



-----------------------------------------------------------------------------------------------------------
--[[ Shi Hao ]]
-----------------------------------------------------------------------------------------------------------

---此函数算是临时判定函数
function isDebugSimple()
    -- 23/10/29 添加的，Debug 模式就应该是严格的。而且我应该是在 modmain 执行的时候直接搞个 MODA_BRANCH 变量存起来比较好
    return env.modname == morel_DEBUG_DIR_NAME
end

---此函数算是本模组的正式判断函数
function isDebug()
    return env.GetModConfigData("debug") == true and env.modname == morel_DEBUG_DIR_NAME
end

function getModRoot()
    return GLOBAL.MODS_ROOT .. env.modname .. "/";
end

---如果 seq 或者 ... 不全是序列，就返回空表
function UnionSeq(seq, ...)
    local args = { ... };
    local res = isSeq(seq) and seq or {};
    if allSeq(args) then
        for i = 1, table.maxn(args) do
            for _, v in ipairs(args[i]) do
                table.insert(res, v);
            end
        end
    end
    return res;
end

---简单类
function SimpleClass()

end

---直接修改文件，避免内存占用
---@param name string
---@param fn fun(component:table)
function HookComponent(name, fn)
    local component = ({ pcall(function()
        return require("components/" .. name);
    end) })[2];
    --print("HookComponent: component: "..tostring(component));
    if isNil(component) or not isTab(component) then
        local msg = "Warning: HookComponent: components/" .. tostring(name) .. " doesn't exist!";
        print(msg);
        InsertLogInfo(msg);
        return ;
    end
    fn(component);
end

---直接修改文件，避免内存占用
---@param package string
---@param fn fun(class:table)
function HookGeneralClass(package, fn)
    local class = ({ pcall(function()
        return require(package);
    end) })[2];
    if isTab(class) then
        fn(class);
    end
end
------------

MOD_RPC_NAMESPACE = "more_items";
function EncAddModRPCHandler(name, fn)
    AddModRPCHandler(MOD_RPC_NAMESPACE, name, fn);
end

---模拟的/假的 HookComponent，并没有避免内存占用...懒.其次是我需要的是模组稳定，新的东西暂时不尝试了.
---提示：通过配置缓存上值是可以实现指向同一个函数的，但是算了，不缺我一个。。。
---@param name string
---@param entity table
---@param fn fun(component:table, entity:table, ...) @ ... 是为了避免闭包，只创建临时变量...但是意义不是太大吧...只是一个指针地址而已。
function HookComponentSimulated(name, entity, fn, ...)
    if isNil(entity) then
        local msg = "Warning: HookComponentSimulated: `entity` param doesn't exist!";
        print(msg);
        InsertLogInfo(msg);
        return ;
    end
    local component = entity.components and entity.components[name];
    if component then
        fn(component, entity, ...);
    end
end
InsertValueENV("SimulatedHookComponent", HookComponentSimulated);

function AddAssets(env, assets)
    if isTab(assets) and not (assets.is_a and assets:is_a(Asset)) then
        for _, asset in ipairs(assets) do
            table.insert(env.Assets, asset);
        end
    end
end
function AddPrefabFiles(env, prefabfiles)
    if isTab(prefabfiles) then
        for _, path in ipairs(prefabfiles) do
            local i, j = string.find(path, "%.lua$");
            if i ~= nil then
                path = string.sub(path, 1, i - 1);
            end
            table.insert(env.PrefabFiles, path);
        end
    end
end
-------------------------------------------------------------------------------------------------------------
--[[ 垃圾代码：未来再处理 ]]
-------------------------------------------------------------------------------------------------------------
---单例模型：只调用一次！
local function HookPrefabFunctionSingletonTab()
    local MEMORY = setmetatable({}, { __mode = "v" });

    local function _argstohash(...)
        local args = { ... };
        local str = "";
        for i = 1, table.maxn(args) do
            str = str .. tostring(args[i]);
        end
        return hash(str);
    end

    local function memoryget(...)
        return MEMORY[_argstohash(...)];
    end

    local function memoryset(value, ...)
        MEMORY[_argstohash(...)] = value;
    end

    return {
        memoryget = memoryget;
        memoryset = memoryset;
    }
end
local HookPrefabFunctionTab = HookPrefabFunctionSingletonTab();
-- todo: 目的是即使在 AddPrefabPostInit 里面修改函数，仍可以指向同一个函数，减少内存占用。
-- todo: 但是我的评价是，必要性没那么大。就用 HookComponentSimulated 这种方式吧...
-- fixme: 注意此处大致功能实现了，但是未彻底测试。
---拦截预制物的函数，并且指向同一个函数
---2023-06-30:TMD，我这函数写的是什么垃圾玩意
function HookPrefabFunction(root, params, fn, fn_low_priority, typ)

    local memoryset, memoryget = HookPrefabFunctionTab.memoryset, HookPrefabFunctionTab.memoryget;

    local old_root = root;

    if not (isTab(root) and isTab(params) and isFn(fn)) then
        return ;
    end

    local msg = {};
    for i = 1, table.maxn(params) do
        for index = 1, i do
            local insertStr = tostring(type(params[index]));
            table.insert(msg, "[?.." .. insertStr .. "..]");
        end

        local key = params[i];
        if null(key) then
            print(string.format("HookPrefabFunction: the %s index of params is nil.", tostring(i)));
            return ;
        end
        root = root[key]; -- 注意，直接赋值是不会有问题的，因为 root 此时只是参数，但是要是操作表内容那就会更新表了！
        if root == nil then
            print("HookPrefabFunction: root" .. table.concat(msg) .. " == nil.");
            return ;
        end
    end

    if not isFn(root) then
        print("HookPrefabFunction: root" .. table.concat(msg) .. " is not a function type.");
        return ;
    end

    local old_fn = root;
    local new_fn = old_fn and memoryget("HookPrefabFunction", old_fn, fn);

    root = old_root;

    local function GetFn(root, params)
        for i = 1, table.maxn(params) do
            root = root[params[i]];
        end
        return root;
    end
    local function SetFn(root, params, new_fn_value)
        local maxn = table.maxn(params);
        for i = 1, maxn do
            if i == maxn then
                root[params[i]] = new_fn_value;
            end
            root = root[params[i]];
        end
    end

    if not old_fn then
        SetFn(root, params, fn);
    elseif new_fn then
        SetFn(root, params, new_fn);
    else
        if typ then
            -- 暂时啥也不做
        else
            if fn_low_priority then
                SetFn(root, params, function(...)
                    old_fn(...);
                    return fn(...);
                end);
            else
                SetFn(root, params, function(...)
                    fn(...);
                    return old_fn(...);
                end);
            end
        end
        memoryset(GetFn(root, params), "HookPrefabFunction", old_fn, fn);
    end
end
------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------

---@return any @ 执行模块代码并返回模块代码的执行结果
function Import(modulename, environment)
    environment = environment or env;

    --install our crazy loader!
    print("HaoImport: " .. env.MODROOT .. modulename)
    if string.sub(modulename, #modulename - 3, #modulename) ~= ".lua" then
        modulename = modulename .. ".lua"
    end
    local result = kleiloadlua(env.MODROOT .. modulename)
    if result == nil then
        error("Error in HaoImport: " .. modulename .. " not found!")
    elseif type(result) == "string" then
        error("Error in HaoImport: " .. ModInfoname(modname) .. " importing " .. modulename .. "!\n" .. result)
    else
        setfenv(result, environment);
        return result();
    end
end
InsertValueENV("HaoImport", Import);

local function getEnabledMods()
    local EnabledMods = {};
    for _, dir in pairs(KnownModIndex:GetModsToLoad(true)) do
        local info = KnownModIndex:GetModInfo(dir);
        local name = info and info.name or "unknown";
        EnabledMods[dir] = name;
    end
    return EnabledMods; -- table<string:DirectoryName, string:ModInfoName>
end

local EnabledMods = getEnabledMods();

---模组是否开启：name/id 均可
function IsModEnabled(name)
    for k, v in pairs(EnabledMods) do
        if v and (k:match(name) or v:match(name)) then
            return true;
        end
    end
    return false;
end

-- 调用了 IsModEnabled 函数
function OneOfModEnabled(...)
    local args = { ... };
    for i = 1, table.maxn(args) do
        if IsModEnabled(args[i]) then
            return true;
        end
    end
    return false;
end

--\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
-- 以下函数是非通用集 --\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
--\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
NonGeneralFns = {};

function NonGeneralFns.SortFilterValues(filter_name, sort_tab)

end

function NonGeneralFns.PlaySoundOnGotNewItem(player, data)
    if not isValid(player) or data == nil then
        return ;
    end

    local sound = data.item and data.item.pickupsound or "DEFAULT_FALLBACK"

    if player._PICKUPSOUNDS and player._PICKUPSOUNDS[sound] then
        TheFocalPoint.SoundEmitter:PlaySound(player._PICKUPSOUNDS[sound]);
    else
        local PICKUPSOUNDS = {
            ["wood"] = "aqol/new_test/wood",
            ["gem"] = "aqol/new_test/gem",
            ["cloth"] = "aqol/new_test/cloth",
            ["metal"] = "aqol/new_test/metal",
            ["rock"] = "aqol/new_test/rock",
            ["vegetation_firm"] = "aqol/new_test/vegetation_firm",
            ["vegetation_grassy"] = "aqol/new_test/vegetation_grassy",

            ["DEFAULT_FALLBACK"] = "dontstarve/HUD/collect_resource",
        }
        if PICKUPSOUNDS[sound] then
            TheFocalPoint.SoundEmitter:PlaySound(PICKUPSOUNDS[sound])
        end
    end
end



-----------------------------------------------------------------------------------------------------------
--[[ 标签管理模块：暂时先放在此处，且未完成 ]]
-----------------------------------------------------------------------------------------------------------
--[[local TagManage = {
    KEY = env.modname .. "_TagManage";
    RegisteredTags = {};
};

---注册标签，主客机都要注册一下
function RegisterTag(tag)
    local Tags = TagManage.RegisteredTags;
    Tags[tag] = string.lower(tag);
end

function AddTag(inst, tag, ...)
    local KEY, Tags = TagManage.KEY, TagManage.RegisteredTags;
    if not isTab(inst) or not isStr(tag) then
        return ;
    end
    if inst[KEY] == nil then
        inst[KEY] = setmetatable({}, { __index = inst });
    end
    tag = string.lower(tag);
    if Tags[tag] then

    else
        return inst:AddTag(tag, ...);
    end
end

function RemoveTag(inst, tag, ...)

end

function HasTag(inst, tag, ...)
    local KEY, Tags = TagManage.KEY, TagManage.RegisteredTags;
    if not isTab(inst) or not isStr(tag) then
        return ;
    end
    tag = string.lower(tag);
end]]
-----------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------

return ENV;