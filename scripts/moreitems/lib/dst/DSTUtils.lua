---
--- DateTime: 2024/12/5 16:38
---

local class = require("moreitems.lib.middleclass.middleclass")

---@class DSTUtils
local DSTUtils = class("DSTUtils")

---@param env env
function DSTUtils:__init__(env)
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

return DSTUtils
