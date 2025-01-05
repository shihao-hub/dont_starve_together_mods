---
--- @author zsh in 2023/4/27 16:03
---

local mt = getmetatable(_G)
if mt == nil then
    mt = {}
    setmetatable(_G, mt)
end

__STRICT = true
mt.__declared = {}

mt.__newindex = function(t, n, v)
    if __STRICT and not mt.__declared[n] then
        local w = debug.getinfo(2, "S").what
        if w ~= "main" and w ~= "C" then
            error("assign to undeclared variable '" .. n .. "'", 2)
        end
        mt.__declared[n] = true
    end
    rawset(t, n, v)
end

mt.__index = function(t, n)
    if not mt.__declared[n] and debug.getinfo(2, "S").what ~= "C" then
        error("variable '" .. n .. "' is not declared", 2)
    end
    return rawget(t, n)
end

function global(...)
    for _, v in ipairs { ... } do
        mt.__declared[v] = true
    end
end

global("MAIN", "WORLDGEN_MAIN")

print(tostring(_G.MAIN));
--print(tostring(_G.Hello));
--print(tostring(Hello));

local function getSpecialString()
    local words = {};
    local keys = {};
    for i = 65, 65 + 26 - 1 do
        table.insert(keys, i);
    end

    local arrayCount = #keys;
    for i = arrayCount, 2, -1 do
        local j = math.random(1, i);
        keys[i], keys[j] = keys[j], keys[i];
    end

    for i = 1, arrayCount do
        table.insert(words, keys[i]);
        table.insert(words, 95 or string.byte("_"));
    end
    words = string.char(unpack(words));
    return string.sub(words, 1, #words - 1);
end

print(getSpecialString());
print(getSpecialString());
print(string.byte("_"));
print(string.byte("a"));
print(string.byte("A"));


local EXCEPTIONS_CACHE = setmetatable({}, { __index = function(t, k)
    if rawget(t, k) == nil then
        rawset(t, k, {});
    end
    return rawget(t, k);
end });

print(EXCEPTIONS_CACHE.a);
print(EXCEPTIONS_CACHE.a);

--assert(getfenv(1) ~= _G,"current environment is global environment.");