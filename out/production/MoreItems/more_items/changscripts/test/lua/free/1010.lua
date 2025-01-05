---
--- @author zsh in 2023/4/28 11:47
---

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

function isValid(inst)
    return inst and inst.IsValid and inst:IsValid();
end

function DoNothing()
    return ;
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

--do
--    print("isSeq: ", isSeq({ 1, 2, 3, n = 3 }));
--    print("isSeq: ", isSeq({ 1, 2, 3, nil, n = 4 }));
--    print("isSeq: ", isSeq({ 1, 2, 3, nil, 4, n = 5 }));
--    print("isSeq: ", isSeq(nil));
--end

-- 2023-04-28：以下部分代码尚待测试

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

    return table.concat(msg);
end

--do
--    local _print = print;
--
--    --_print = DoNothing;
--
--    _print(printSequence({
--        1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15,
--        "a", "b", "c", "d"
--    }, "is Seq"));
--
--    print();
--    _print(printSequence({
--        1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, "a", "b", "c", "d", nil, nil
--    }, "is Seq 2"));
--
--    print();
--    _print(printSequence({
--        1, 2, 3, 4, 5, 6, 7, 8, 9, 10, nil, nil, 13, 14, 15, "a", "b", "c", "d"
--    }, "is not Seq, ipairs"));
--
--    _print = print;
--
--    _print();
--end

function shallowPrintTab(tab, name, number)
    name = name or "unknown";
    number = number or 20;
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

    return table.concat(msg);
end

function printSafe(...)
    local args = { ... };
    for i = 1, table.maxn(args) do
        args[i] = tostring(args[i]);
    end
    print(unpack(args, 1, table.maxn(args)));
end

local b1 = true;
local n1 = 1;
local s1 = "str";
local f1 = function()

end
local thread1 = coroutine.create(function()

end)
local tab1 = {};

local test_tab = {
    [b1] = type(b1),
    ["b2"] = true,
    [n1] = type(n1),
    ["n2"] = 2,
    [s1] = type(s1),
    ["s2"] = "s2",
    [f1] = type(f1),
    ["f2"] = function()

    end,
    ["userdata"] = "userdata",
    [thread1] = type(thread1),
    ["thread2"] = coroutine.create(function()

    end),
    [tab1] = type(tab1),
    ["tab2"] = {},
    2, 3, 4, 5, 6,
}

--do
--    print(shallowPrintTab(test_tab, nil, 100));
--end

-- TEMP
function hash(val)
    return tostring(val);
end

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

-- todo!
---拦截预制物的函数，并且指向同一个函数
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

local inst = {};
inst.component = {};
inst.component.eater = {
    number = 0;
    oneatfn = function(n)
        print("original oneatfn: " .. tostring(n));
    end
};

local old_oneatfn = inst.component.eater.oneatfn;

print("-------------------------------1");
print("old_oneatfn: " .. tostring(old_oneatfn));
local new_oneatfn1 = function(n)
    print("new oneatfn1: " .. tostring(n));
end
print("new_oneatfn1: " .. tostring(new_oneatfn1));
HookPrefabFunction(inst.component.eater, { "oneatfn" }, new_oneatfn1);

print("NEW!", inst.component.eater.oneatfn);
inst.component.eater.oneatfn(111);

print("-------------------------------2");
inst.component.eater.oneatfn = old_oneatfn;
print("old_oneatfn: " .. tostring(inst.component.eater.oneatfn));
local new_oneatfn2 = function(n)
    print("new oneatfn2: " .. tostring(n));
end
print("new_oneatfn2: " .. tostring(new_oneatfn2));
HookPrefabFunction(inst.component.eater, { "oneatfn" }, new_oneatfn2,true);

print("NEW!", inst.component.eater.oneatfn);
inst.component.eater.oneatfn(222);

--local MEMORY;
--MEMORY = {
--    CACHE = setmetatable({}, { __mode = "v" });
--    _argstohash = function(...)
--        local args = { ... };
--        local str = "";
--        for i = 1, table.maxn(args) do
--            str = str .. tostring(args[i]);
--        end
--        return hash(str);
--    end,
--    memoryset = function(value, ...)
--        MEMORY.CACHE[MEMORY._argstohash(...)] = value;
--    end,
--    memoryget = function(...)
--        return MEMORY.CACHE[MEMORY._argstohash(...)];
--    end
--}
--
-----劫持预制物的函数，并且指向同一个函数
--function HookPrefabFunction(root, params, fn, lowprio, typ)
--    local memoryset, memoryget = MEMORY.memoryset, MEMORY.memoryget;
--
--    local _root = root;
--
--    if not (isTab(root) and isTab(params) and isFn(fn)) then
--        return ;
--    end
--
--    local msg = {};
--    for i = 1, table.maxn(params) do
--        for _ = 1, i do
--            local insertStr = tostring(type(params[i]));
--            table.insert(msg, "[?.." .. insertStr .. "..]");
--        end
--
--        local key = params[i];
--        if null(key) then
--            print(string.format("HookPrefabFunction: params[%s] == nil.", tostring(i)));
--            return ;
--        end
--        root = root[key]; -- 注意，直接赋值是不会有问题的，因为 root 此时只是参数，但是要是操作表内容那就会更新表了！
--        if root == nil then
--            print("HookPrefabFunction: root" .. table.concat(msg) .. " == nil.");
--            return ;
--        end
--    end
--
--    if not isFn(root) then
--        print("HookPrefabFunction: root" .. table.concat(msg) .. " is not a function type.");
--        return ;
--    end
--
--    local old_fn = root;
--    local new_fn = old_fn and memoryget("HookPrefabFunction", old_fn, fn);
--
--    -- 注意执行到此处的时候 root 按 params 的顺序所有键以及键值都存在，而且最后一个键值还是函数类型的
--    local function getFn(root, params)
--        for i = 1, table.maxn(params) do
--            root = root[params[i]];
--        end
--        return root;
--    end
--    local function setFn(root, params, new_fn_value)
--        local maxn = table.maxn(params);
--        for i = 1, maxn do
--            if i == maxn then
--                root[params[i]] = new_fn_value;
--            end
--            root = root[params[i]];
--        end
--    end
--
--    if not old_fn then
--        setFn(_root, params, fn);
--    elseif new_fn then
--        setFn(_root, params, new_fn);
--    else
--        if lowprio then
--            setFn(function(...)
--                old_fn(...);
--                return fn(...);
--            end);
--        else
--            setFn(function(...)
--                fn(...);
--                return old_fn(...);
--            end);
--        end
--        memoryset(getFn(_root, params), "HookPrefabFunction", old_fn, fn);
--    end
--end






--[[function PrintSequence(seq, name, number)
    name = name or "unknown";
    number = number or 30;

    local newline = 5;
    local msg = {};

    if not isSeq(seq) then
        print("--1");
        for _, v in ipairs(seq) do
            local v_format = "%s";
            if isStr(v) then
                v_format = "%q";
            end
            table.insert(msg, string.format("" .. v_format .. "", tostring(v)));
        end
    else
        print("--2");
        for i = 1, table.maxn(seq) do
            local v = seq[i];
            local v_format = "%s";
            if isStr(v) then
                v_format = "%q";
            end
            table.insert(msg, string.format("" .. v_format .. "", tostring(v)));
        end
    end

    table.sort(msg);
    local body = msg, table.concat(msg, ",\n");
    msg = { name .. " = " .. "{\n" };
    table.insert(msg, body);
    table.insert(msg, "\n}");
    for i = 2, #msg - 1 do
        if (i - 1) % newline == 0 then
            msg[i] = msg[i] .. "\n";
        end
    end
    return table.concat(msg);
end]]

--[[function shallowPrintTab(tab, name, number)
    name = name or "unknown";
    number = number or 20;
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
    msg = { table.concat(msg, ",\n") };
    table.insert(msg, 1, name .. " = " .. "{\n");
    table.insert(msg, "\n}");
    return table.concat(msg);
end]]