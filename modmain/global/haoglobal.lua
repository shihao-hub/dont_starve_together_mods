---
--- @author zsh in 2023/4/27 16:55
---

assert(getfenv(1) ~= _G, "ERROR: current environment is global environment.");

local EXCEPTIONS_CACHE = { ShiHao = {} };

---@class ShiHao
---@field ReForged ReForged
---
---@field Logger table
---
---@field isNil function
---@field isBool function
---@field isNum function
---@field isStr function
---@field isFn function
---@field isUser function
---@field isThread function
---@field isTab function
---@field null function
---@field isValid function
---@field DoNothing function
---@field isSeq function
---
---@field printSequence function
---@field printTable function
---@field printSafe function
---
---@field Parallel function
---@field Browse function
---
---@field isDebugSimple function
---@field HookComponent function
---@field HookComponentSimulated function
---@field HookPrefabFunction function
---@field Import function
---@field IsModEnabled function
local ShiHao = setmetatable({
    GLOBAL = setmetatable({}, { __index = GLOBAL });
}, {
    __index = function(t, k)
        if rawget(t, k) then
            return rawget(t, k);
        end
        return rawget(GLOBAL, k); -- 2023-05-10：我觉得应该报错，而不是去 GLOBAL 里搜索
    end;
    -- 不需要这里呀，ShiHao这个表我显然不会设置成某个模块的环境变量，应该是：local ShiHao = GLOBAL.ShiHao 这种方式使用。
    --__newindex = function(t, k, v)
    --    rawset(t, k, v);
    --    if rawget(GLOBAL, k) then
    --        if EXCEPTIONS_CACHE.ShiHao[k] == nil then
    --            EXCEPTIONS_CACHE.ShiHao[k] = true;
    --            local msg = string.format("Warning: GLOBAL.ShiHao has the same key(%s type:%s) in GLOBAL.", tostring(k), tostring(type(k)));
    --            print(msg);
    --            StartThread(function()
    --                if TheWorld ~= nil and not TheWorld.ismastersim then
    --                    return ;
    --                end
    --                Sleep(5);
    --                TheNet:Announce("更多物品：当你看到这条信息的时候，请及时与作者联系。谢谢配合！");
    --                TheNet:Announce(msg);
    --                c_save();
    --                Sleep(60);
    --            end, tostring({}))
    --        end
    --    end
    --end
});

-- 注意一下这个全局变量的命名，我的每个模组都应该不一样
GLOBAL.global("ShiHao");
GLOBAL.ShiHao = ShiHao;

