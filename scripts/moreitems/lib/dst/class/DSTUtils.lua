---
--- DateTime: 2024/12/5 16:38
---

local class = require("moreitems.lib.thirdparty.middleclass.middleclass")
local checker = require("moreitems.lib.shihao.module.checker")

---@class DSTUtils
local DSTUtils = class("DSTUtils")

---需要用到 env 的函数将封装到此处
---@param env env
function DSTUtils:initialize(env)
    checker.require_not_null(env)
    self.env = env
end

---@param modulename string
---@return table
function DSTUtils:modimport(modulename)
    local env = self.env

    print("modimport: " .. env.MODROOT .. modulename)
    if string.sub(modulename, #modulename - 3, #modulename) ~= ".lua" then
        modulename = modulename .. ".lua"
    end
    local result = kleiloadlua(env.MODROOT .. modulename)
    if result == nil then
        error("Error in modimport: " .. modulename .. " not found!")
    elseif type(result) == "string" then
        error("Error in modimport: " .. ModInfoname(modname) .. " importing " .. modulename .. "!\n" .. result)
    else
        setfenv(result, env.env)
        -- 2024-12-05：复制于 modimport 函数，修改其返回值
        return result()
    end
end

function DSTUtils:is_debug()
    local env = self.env
    return env.GetModConfigData("debug") == true and env.modname == morel_DEBUG_DIR_NAME
end

function DSTUtils:get_mod_root()
    local env = self.env
    return MODS_ROOT .. env.modname .. "/";
end

function DSTUtils:add_assets(assets)
    local env = self.env

    -- 有可能出现没有传递 { Asset, Asset, ... } 而是传递 Asset 的情况
    if assets.is_a and assets:is_a(Asset) then
        assets = { assets }
    end

    for _, asset in ipairs(assets) do
        table.insert(env.Assets, asset);
    end
end
function DSTUtils:add_prefab_files(prefabfiles)
    local function Local()
        local obj = {}

        function obj:delete_path_lua_suffix(path)
            local i, j = string.find(path, "%.lua$");
            if i ~= nil then
                path = string.sub(path, 1, i - 1);
            end
            return path
        end

        return obj
    end
    -- 很像 Python 呀，没有 new 好舒服
    local loc = Local()

    local env = self.env

    for _, path in ipairs(prefabfiles) do
        path = loc:delete_path_lua_suffix(path)
        table.insert(env.PrefabFiles, path);
    end
end

---@return any module file 的返回值，一般是 return {}
function DSTUtils:import_module(modulename, environment)
    local env = self.env

    environment = environment or env;

    --install our crazy loader!
    print("import_module: " .. env.MODROOT .. modulename)
    if string.sub(modulename, #modulename - 3, #modulename) ~= ".lua" then
        modulename = modulename .. ".lua"
    end
    local result = kleiloadlua(env.MODROOT .. modulename)
    if result == nil then
        error("Error in import_module: " .. modulename .. " not found!")
    elseif type(result) == "string" then
        error("Error in import_module: " .. ModInfoname(env.modname) .. " importing " .. modulename .. "!\n" .. result)
    else
        setfenv(result, environment);
        return result();
    end
end


return DSTUtils
