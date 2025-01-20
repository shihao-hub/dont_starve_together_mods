--[[
## 自动化
> 自动由 change log 生成 模组说明书
> 更改版本号为当前时间

]]

local function update_version_of_modinfo_file()
    local lfs = require("lfs") -- Lua for Windows
    local base = require("moreitems.lib.shihao.base")
    local time = require("moreitems.lib.shihao.module.time")
    local stl_string = require("moreitems.lib.shihao.module.stl_string")

    local scripts_dir = lfs.currentdir()
    local mod_dir = string.sub(scripts_dir, 1, -string.len("\\scripts") - 1)
    local modinfo_filepath = mod_dir .. "\\modinfo.lua"

    local characteristic_string = "version = "
    local pattern = "version = \"(.*)\""

    local file = io.open(modinfo_filepath, "r")
    assert(file ~= nil)

    local res = {}
    for line in file:lines() do
        if string.match(line, pattern) then
            line = string.gsub(line, pattern, function(version)
                local strs = stl_string.split(version, "_")
                return "version = \""..strs[1] .. "_" .. os.time().."\""
            end)
        end
        table.insert(res, line)
    end
    file:close()

    local new_file = io.open(modinfo_filepath, "w")
    assert(new_file ~= nil)
    for _, line in ipairs(res) do
        new_file:write(line .. "\n")
    end
    new_file:close()

    print("update version success!")
end

if select("#", ...) == 0 then
    update_version_of_modinfo_file()
end