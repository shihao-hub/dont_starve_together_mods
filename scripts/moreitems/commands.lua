local base = require("moreitems.lib.shihao.base")

local commands = {}

commands.test = setmetatable({}, {
    __call = function()
        local lfs = require("lfs")

        local luafun = require("moreitems.lib.thirdparty.luafun.fun")
        local inspect = require("moreitems.lib.thirdparty.inspect.inspect")

        local stl_string = require("moreitems.lib.shihao.module.stl_string")

        local totable = luafun.totable
        local map = luafun.map
        local filter = luafun.filter
        local iter = luafun.iter

        local function Local()
            local this = {}

            ---@return string[]
            function this.find_all_matched_lua_files()
                local res = {}

                local current_dir = lfs.currentdir() .. "\\moreitems"
                for file in lfs.dir(current_dir) do
                    if file:match("%.lua$") then
                        table.insert(res, file)
                    end
                end

                local function listFiles(directory)
                    local files = {}

                    -- 遍历目录
                    for file in lfs.dir(directory) do
                        if file ~= "." and file ~= ".." then
                            -- 排除当前目录和父级目录
                            local fullPath = directory .. '/' .. file  -- 获取完整路径
                            local attr = lfs.attributes(fullPath)  -- 获取文件属性

                            if attr then
                                if attr.mode == "directory" then
                                    -- 如果是目录，递归调用listFiles
                                    local subFiles = listFiles(fullPath)
                                    for _, subFile in ipairs(subFiles) do
                                        table.insert(files, subFile)  -- 将子目录的文件加入列表
                                    end
                                elseif attr.mode == "file" then
                                    -- 如果是文件，将文件添加到列表中
                                    table.insert(files, fullPath)
                                end
                            end
                        end
                    end

                    local map_fn = function(e)
                        return e:gsub("/", "\\")
                    end

                    local filter_fn = function(e)
                        return stl_string.endswith(e, ".lua")
                                and not stl_string.endswith(e, "commands.lua")
                    end

                    return totable(map(map_fn, filter(filter_fn, files)))
                end
                res = listFiles(current_dir)

                --for _, e in ipairs(res) do
                --    base.log.info(e)
                --end

                -- test
                --table.insert(res, "moreitems\\main.lua")
                --res = { res[1] }

                return res
            end

            return this
        end

        local loc = Local()

        --local current_dir = lfs.currentdir()
        --base.log.info(current_dir)

        -- 将 moreitems 目录下的所有正常命名的 lua 文件全部执行一遍
        -- 说起来，test 可以用 python 实现啊？python lua 库啊。
        local files = loc.find_all_matched_lua_files()
        --base.log.info(inspect.inspect(files))
        for _, filename in ipairs(files) do
            local command = base.string_format("lua.exe \"{{filename}}\"", { filename = filename })
            --base.log.info(command)
            os.execute(command)
        end
    end
})

local function run(command)
    xpcall(function()
        command() -- 解耦？还是多态？
    end, base.log.error)
end

if select("#", ...) == 0 then
    run(commands.test)
end