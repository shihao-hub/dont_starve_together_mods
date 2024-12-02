---
--- @author zsh in 2023/4/27 17:20
---

assert(getfenv(1) ~= _G, "ERROR: current environment is global environment.");

local function isDebug()
    return not string.find(env.modname, "workshop%-");
end

local ThreadIDS = {};

local function getSpecialString()
    local words = {};
    local keys = {};
    for i = 65, 65 + 26 - 1 do
        table.insert(keys, i);
    end

    -- shuffleArray
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

---请忽略这个函数的命名和其中的参数的命名...毫无意义的函数...
local function getGUID(key)
    key = key or "unknown";
    local guid = tostring({}) .. getSpecialString();
    ThreadIDS[key] = guid;
    return guid;
end

local EXCEPTIONS_CACHE = { ENV = {} };

---@class ShiHaomodglobalenv
local ENV = setmetatable({}, {
    __index = env;
    __newindex = function(t, k, v)
        rawset(t, k, v);
        --if rawget(GLOBAL, "ShiHao") and GLOBAL.ShiHao[k] == nil then
        if rawget(GLOBAL, "ShiHao") and rawget(GLOBAL.ShiHao, k) == nil then
            GLOBAL.ShiHao[k] = v; -- 应该是 rawset(ShiHao,k,v); 但是该表目前没有 __newindex，因此没关系。
        end
        if rawget(env, k) == nil then
            rawset(env, k, v);
        else
            -- 不需要玩家也生效...我自己测试用就够了啊，反正是 env...但是咋说呢，假如我长时间不玩多少有那么0.1%的用处吧?...
            -- 2023-06-12：
            ---- 首先，每个模组都有个独立的环境
            ---- 其次，env中的函数和内容，应该全都在 mods.lua、modutil.lua 这两个文件中
            if isDebug() then
                if EXCEPTIONS_CACHE.ENV[k] == nil then
                    EXCEPTIONS_CACHE.ENV[k] = true;
                    local msg = string.format("Warning: `env[%q]` has existed, please check it carefully!", tostring(k));
                    print(msg);
                    StartThread(function()
                        if TheWorld ~= nil and not TheWorld.ismastersim then
                            return ;
                        end
                        Sleep(5);
                        TheNet:Announce("更多物品：当你看到这条信息的时候，请及时与作者联系。谢谢配合！");
                        TheNet:Announce(msg);
                        --c_save();
                        Sleep(60);
                    end, getGUID(k))
                end
            end
        end
    end
});

modglobalenv = ENV;

return ENV;