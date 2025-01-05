---
--- Created by zsh
--- DateTime: 2023/11/1 20:50
---

setfenv(1, _G)
-- Import in advance(提前导入)
if getmetatable(_G) == nil then
    require("new_scripts.mod_a.strict")
end
morel_G = {}

global("morel_env")

-- morel_upper_word represents constant.
morel_IS_DST_ENV = morel_env ~= nil
morel_RELATIVE_SRC_PATH = "new_scripts/"
morel_IS_DST_DEBUG_MODE = morel_IS_DST_ENV and morel_env.GetModConfigData("debug") == true and morel_env.modname == morel_DEBUG_DIR_NAME
morel_IS_LUA_DEBUG_MODE = not morel_IS_DST_ENV
morel_IS_DEBUG_MODE = morel_IS_LUA_DEBUG_MODE or morel_IS_DST_DEBUG_MODE
morel_BRANCH = morel_IS_DEBUG_MODE and "dev" or "release"

-- 通用
require("new_scripts.mod_a.common_global")

-- 工具集模块
morel_Switch = require("new_scripts.mod_a.module.switch_statement")
morel_TrueFalseHandler = require("new_scripts.mod_a.module.true_false_handler")

-- Only for personal test, only is lua environment.
if morel_IS_LUA_DEBUG_MODE then
    -- 其他
    require("new_scripts.mod_a.util.personal_json")
    -- 23/11/1 Lua for windows has a mass of valuable codes to learn !!!!!!
    morel_LfW_global = require("new_scripts.mod_a.module.global")
    morel_LfW_list = require("new_scripts.mod_a.module.list")
end

-- 将 _G 中形如 morel_xxx 的存在放到 morel_G 里面，但是通过 morel_xxx 索引 _G 的时候等价于 morel_G[xxx]
--local function remove_morel_prefix()
--    local prefix = "morel_"
--    local function is_target(k) return type(k) == "string" and k ~= "morel_G" and string.find(k, "^" .. prefix) end
--    local function get_actual_key(k) return string.sub(k, prefix:len() + 1, -1) end
--    for k, v in pairs(_G) do
--        if is_target(k) then
--            morel_G[get_actual_key(k)] = v
--            _G[k] = nil
--        end
--    end
--
--    local mt = getmetatable(_G)
--    local old = mt.__index
--    mt.__index = function(t, k)
--        if is_target(k) then
--            return morel_G[get_actual_key(k)]
--        end
--        return old(t, k)
--    end
--end
--remove_morel_prefix()

--local function remove_morel_prefix2()
--    local prefix = "morel_"
--    local function is_target(k) return type(k) == "string" and k ~= "morel_G" and string.find(k, "^" .. prefix) end
--    local function get_actual_key(k) return string.sub(k, prefix:len() + 1, -1) end
--    for k, v in pairs(_G) do
--        if is_target(k) then
--            morel_G[get_actual_key(k)] = v
--        end
--    end
--end
--remove_morel_prefix2()






