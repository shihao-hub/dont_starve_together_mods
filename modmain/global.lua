---
--- @author zsh in 2023/4/27 17:32
---

assert(getfenv(1) ~= _G, "ERROR: current environment is global environment.");

---@type env
local env = env;

---@type ShiHaomodglobalenv
local modglobalenv = modglobalenv;

---@type ShiHao
local ShiHao = GLOBAL.ShiHao;

local ENV = setmetatable({}, {
    __index = function(t, k)
        return rawget(GLOBAL, k);
    end,
    __newindex = function(t, k, v)
        if rawget(GLOBAL, k) then
            GLOBAL[k] = v;
            return ;
        end
        rawset(t, k, v); -- be equivalent to DoNothing
    end
})

setfenv(1, ENV);

require "consolecommands"; -- 为什么这里会需要我导入？科雷不是导入过了吗？

local old_c_save = c_save;
c_save = function(...)
    local res = { old_c_save(...) };
    print("Server AutoSaved");
    return unpack(res, 1, table.maxn(res));
end

if modglobalenv.isDebugSimple() then
    local old_print = print;
    print = function(...)
        local args = { ... };
        local message = "";
        for i = 1, table.maxn(args) do
            message = message .. tostring(args[i]);
        end
        -- 排除垃圾信息
        local junk_information = {
            -- 这个特别恐怖...我的日志被刷了 1.3G，但是不知道是哪个模组
            ---- 不是模组，是存档的 cluster.ini 文件中的 game_mode = "" 导致的
            ------ 我又有个问题，为什么此处修改，我服务器的其他朋友还是会打印呢？我自己确实不打印了。
            -------- 算了算了，我手动改一下服务器的 cluster.ini 吧。但是网页开服会被覆盖吧？这难搞。我先去联系联系作者。
            "MOD ERROR: unknown mod: Game mode '' not found in GAME_MODES",
        }

        if modglobalenv.isDebugSimple() then
            junk_information = {
                -- C层打印的，所以去不掉...
                "WARNING! Invalid resource handle for atlas 'FROMNUM', did you remember to load the asset?",
                "MiniMapComponent::AddAtlas",
                -- Lua层打印的
                "MOD ERROR: unknown mod: Game mode '' not found in GAME_MODES", -- 超异常问题
                "Missing reference:", -- klei
                --"Server Autopaused", -- 不要排除
                --"Server Unpaused", -- 不要排除
                "Could not find anim build FROMNUM",
                "存储数据", -- UI拖拽缩放
                "读取失败, 再次尝试",
                "ModDragZoomUI存储数据",
                "ModDragZoomUI读取失败, 再次尝试",
                "Stale Component Reference: GUID", -- 蘑菇姆斯
                "component knownfoods already exists on entity",
                "存储数据",
                "读取失败, 再次尝试",
                "Tex	table:",
                "TW_Pos_world_",
                "^false", -- 永不妥协
                "^0.2",
                "Craft Pot ~~~ component loaded 80 known food recipes", -- 其他
            }
        end

        for _, pattern in ipairs(junk_information) do
            if string.find(message, pattern) then
                return ;
            end
        end

        return old_print(...);
    end
end


-- 崩溃的时候保存一下游戏：不太行...因为可能保存下来错误状态了
--if modglobalenv.isDebugSimple() then
--    local old_traceback = debug.traceback;
--    debug.traceback = function(...)
--        c_save();
--        return old_traceback(...);
--    end
--end


