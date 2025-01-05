---
--- @author zsh in 2023/4/23 23:45
---

-- loadstring(string, chunkname)：该函数总是在全局环境中编译它的字符串

local function deepcopy(object)
    local lookup_table = {}
    local function _copy(object)
        if type(object) ~= "table" then
            return object
        elseif lookup_table[object] then
            return lookup_table[object]
        end
        local new_table = {}
        lookup_table[object] = new_table
        for index, value in pairs(object) do
            new_table[_copy(index)] = _copy(value)
        end
        return setmetatable(new_table, getmetatable(object))
    end
    return _copy(object)
end

local _GLOBAL = deepcopy(_G);
print(tostring(_GLOBAL));
print(tostring(_G));
setfenv(1, _GLOBAL);
-- for speed optimization? I don't think it's much use.
local ENV = loadstring([[
    local GLOBAL = GLOBAL or _G;
    print(tostring(getfenv(1)));
    local KEYS = { "coroutine", "debug", "io", "math", "os", "package", "string", "table", "assert", "collectgarbage", "dofile", "error", "_G", "getmetatable", "getfenv", "ipairs", "load", "loadstring", "loadfile", "module", "next", "pairs", "pcall", "print", "rawequal", "rawget", "rawset", "require", "select", "setfenv", "setmetatable", "tonumber", "tostring", "type", "unpack", "_VERSION", "xpcall", };
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


local CODE = [[local GLOBAL = GLOBAL or _G;local KEYS = { "coroutine", "debug", "io", "math", "os", "package", "string", "table", "assert", "collectgarbage", "dofile", "error", "_G", "getmetatable", "getfenv", "ipairs", "load", "loadstring", "loadfile", "module", "next", "pairs", "pcall", "print", "rawequal", "rawget", "rawset", "require", "select", "setfenv", "setmetatable", "tonumber", "tostring", "type", "unpack", "_VERSION", "xpcall", };local ENV = {};for _, KEY in ipairs(KEYS) do ENV[KEY] = GLOBAL:rawget(KEY);endGLOBAL.setmetatable(ENV, { __index = function(_, k) local print, string, tostring = GLOBAL.print, GLOBAL.string, GLOBAL.tostring;print(string.format("ENV[%q] doesn't exist, try to search _G.", tostring(k)));return GLOBAL.rawget(GLOBAL, k);end});return ENV;]];


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