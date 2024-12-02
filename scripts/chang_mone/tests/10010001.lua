---
--- @author zsh in 2023/4/23 23:45
---

-- for speed optimization? I don't think it's much use.
local ENV = loadstring([[
    local GLOBAL = GLOBAL or _G;
    local KEYS = { "coroutine", "debug", "io", "", "os", "package", "string", "table", "assert", "collectgarbage", "dofile", "error", "_G", "getmetatable", "getfenv", "ipairs", "load", "loadstring", "loadfile", "module", "next", "pairs", "pcall", "print", "rawequal", "rawget", "rawset", "require", "select", "setfenv", "setmetatable", "tonumber", "tostring", "type", "unpack", "_VERSION", "xpcall", };
    local ENV = {};
    for _, KEY in ipairs(KEYS) do
        ENV[KEY] = GLOBAL:rawget(KEY);
    end
    GLOBAL.setmetatable(ENV, {
        __index = function(_, k)
            local print, string, tostring = GLOBAL.print, GLOBAL.string, GLOBAL.tostring;
            print(string.format("ENV[%q] doesn't exist, try to search _G.", tostring(k)));
            return GLOBAL.rawget(GLOBAL, k);
        end
    });
    return ENV;
]])();
setfenv(1, ENV);

-- 2023-04-24-00:16：之后尝试用 pcall 包住我的代码？避免游戏崩溃？但是似乎不简单。

--print("hello!");
print(_VERSION);
--print(tostring(unpack));
--print(tostring(string));
--print(tostring(math.abs(-111)));

local t = nil;
print(tostring((t or math).abs(-111)))


--local GLOBAL = GLOBAL or _G;
--local KEYS = { "coroutine", "debug", "io", "", "os", "package", "string", "table", "assert", "collectgarbage", "dofile", "error", "_G", "getmetatable", "getfenv", "ipairs", "load", "loadstring", "loadfile", "module", "next", "pairs", "pcall", "print", "rawequal", "rawget", "rawset", "require", "select", "setfenv", "setmetatable", "tonumber", "tostring", "type", "unpack", "_VERSION", "xpcall", };
--local ENV = {};
--for _, KEY in ipairs(KEYS) do
--    ENV[KEY] = GLOBAL:rawget(KEY);
--end
--GLOBAL.setmetatable(ENV, {
--    __index = function(_, k)
--        local print, string, tostring = GLOBAL.print, GLOBAL.string, GLOBAL.tostring;
--        print(string.format("ENV[%q] doesn't exist, try to search _G.", tostring(k)));
--        return GLOBAL.rawget(GLOBAL, k);
--    end
--});
--_G.setfenv(1, ENV);

--local ENV = GLOBAL.setmetatable({
--    coroutine = GLOBAL.coroutine;
--    debug = GLOBAL.debug;
--    io = GLOBAL.io;
--    math = GLOBAL.math;
--    os = GLOBAL.os;
--    package = GLOBAL.package;
--    string = GLOBAL.string;
--    table = GLOBAL.table;
--
--    assert = GLOBAL.assert;
--    collectgarbage = GLOBAL.collectgarbage;
--    dofile = GLOBAL.dofile;
--    error = GLOBAL.error;
--    _G = GLOBAL;
--    getmetatable = GLOBAL.getmetatable;
--    getfenv = GLOBAL.getfenv;
--    ipairs = GLOBAL.ipairs;
--    load = GLOBAL.load;
--    loadstring = GLOBAL.loadstring;
--    loadfile = GLOBAL.loadfile;
--    module = GLOBAL.module;
--    next = GLOBAL.next;
--    pairs = GLOBAL.pairs;
--    pcall = GLOBAL.pcall;
--    print = GLOBAL.print;
--    rawequal = GLOBAL.rawequal;
--    rawget = GLOBAL.rawget;
--    rawset = GLOBAL.rawset;
--    require = GLOBAL.require;
--    select = GLOBAL.select;
--    setfenv = GLOBAL.setfenv;
--    setmetatable = GLOBAL.setmetatable;
--    tonumber = GLOBAL.tonumber;
--    tostring = GLOBAL.tostring;
--    type = GLOBAL.type;
--    unpack = GLOBAL.unpack;
--    _VERSION = GLOBAL._VERSION;
--    xpcall = GLOBAL.xpcall;
--}, {
--    __index = function(_, k)
--        local print, string, tostring = GLOBAL.print, GLOBAL.string, GLOBAL.tostring;
--        print(string.format("ENV[%q] doesn't exist, try to search _G.", tostring(k)));
--        return GLOBAL.rawget(GLOBAL, k);
--    end
--})
--_G.setfenv(1, ENV);