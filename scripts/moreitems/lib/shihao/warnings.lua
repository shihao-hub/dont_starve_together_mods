-- 本来该文件放在 module 目录下的，但是 log.lua 也在 module 下，所以将 warnings.lua 移到上一层

local log = require("moreitems.lib.shihao.module.log")
local base = require("moreitems.lib.shihao.base")
local stl_debug = require("moreitems.lib.shihao.module.stl_debug")

local module = {}
local static = {
    filter_all = false
}

function module.warn(msg)
    if static.filter_all then
        return
    end
    log.warning(base.string_format("{{ call_location }}: warnings.warn(\"{{ msg }}\")", {
        call_location = stl_debug.get_call_location(),
        msg = msg,
    }))
end

function module.filterwarnings(action)
    if action == "ignore" then
        static.filter_all = true
    end
end

if select("#", ...) == 0 then
    module.warn("123")
end

return module
