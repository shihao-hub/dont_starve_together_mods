---
--- @author zsh in 2023/4/24 8:56
---

local isDebug = true;

local _print = print;
print = function(...)
    if not isDebug then
        return ;
    end
    return _print(...);
end

print(_G);

--local CODE = [[local GLOBAL = GLOBAL or _G;local KEYS = { "coroutine", "debug", "io", "", "os", "package", "string", "table", "assert", "collectgarbage", "dofile", "error", "_G", "getmetatable", "getfenv", "ipairs", "load", "loadstring", "loadfile", "module", "next", "pairs", "pcall", "print", "rawequal", "rawget", "rawset", "require", "select", "setfenv", "setmetatable", "tonumber", "tostring", "type", "unpack", "_VERSION", "xpcall", };local ENV = {};for _, KEY in ipairs(KEYS) do ENV[KEY] = GLOBAL:rawget(KEY);end GLOBAL.setmetatable(ENV, { __index = function(_, k) local print, string, tostring = GLOBAL.print, GLOBAL.string, GLOBAL.tostring;print(string.format("ENV[%q] doesn't exist, try to search _G.", tostring(k)));return GLOBAL.rawget(GLOBAL, k);end });return ENV;]];
local CODE = [[local GLOBAL = GLOBAL or _G;local KEYS = { "coroutine", "debug", "io", "math", "os", "package", "string", "table", "assert", "collectgarbage", "dofile", "error", "_G", "getmetatable", "getfenv", "ipairs", "load", "loadstring", "loadfile", "module", "next", "pairs", "pcall", "print", "rawequal", "rawget", "rawset", "require", "select", "setfenv", "setmetatable", "tonumber", "tostring", "type", "unpack", "_VERSION", "xpcall", };local ENV = {};for _, KEY in ipairs(KEYS) do ENV[KEY] = GLOBAL:rawget(KEY);end GLOBAL.setmetatable(ENV, { __index = function(_, k) return GLOBAL.rawget(GLOBAL, k);end });return ENV;]];
local RESULT = ({ pcall(loadstring(CODE)) })[2];
local ENV = (type(RESULT) == "table") and RESULT or GLOBAL or _G;
setfenv(1, ENV);

print(ENV);

print(math.random());