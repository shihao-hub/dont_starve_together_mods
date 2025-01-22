local lfs = require("lfs") -- Lua for Windows

local luafun = require("moreitems.lib.thirdparty.luafun.fun")
local inspect = require("moreitems.lib.thirdparty.inspect.inspect")

local assertion = require("moreitems.lib.shihao..assertion")
local base = require("moreitems.lib.shihao.base")
local stl_string = require("moreitems.lib.shihao.module.stl_string")
local stl_table = require("moreitems.lib.shihao.module.stl_table")
local utils = require("moreitems.lib.shihao.utils")

local current_file_basename = (debug.getinfo(1, "S").source:gsub(".*[/\\]", "", 1))
--assertion.assert_true(current_file_basename == "commands.lua")
--print(current_file_basename)

return setmetatable({
    Helper = function()
        local this = {}

        local function list_files(directory)
            local res = {}

            -- 如果是 lambda(closure) 就用 local fn = function() end，反之用 local function fn() end，太美妙了 Lua
            -- 除此以外，对比 Python、Js 还有个让我舒服的点就是没有 locals()，不至于莫名其妙...
            -- 提取出来的目的是为了配合卫语句来解决 lua 没有 continue 而存在的 if 嵌套问题
            --local process_file = function(file)
            --    -- 当时没过 1 分钟，我就意识到，这个情况直接匿名函数调用不就解决了？
            --    -- 用函数的 return 来替代 continue！
            --    -- 太美妙了！！！
            --end

            -- TODO: 解决由于没有 continue 导致的 if 嵌套层数的问题
            -- 遍历目录
            for file in lfs.dir(directory) do
                --[[
                    用匿名函数 + 闭包 + 卫语句 + return 来替代 continue

                    但是这里存在一个问题，循环中创建闭包是不是不太好？
                    > 确实不太好，但是其实还是那句话，性能优化应该是系统开发完成之后进行热点分析的事情。  <br>
                    > 此处的循环创建函数优化起来也很简单，大不了在 for 上定义一个 local process_file 函数，
                    > 然后在循环中调用 process_file，类似 file 这种可变闭包参数可以改为参数传递，很简单！  <br>
                    > 总之，性能热点分析工具很重要，优化应该放在最后考虑！大部分情况根本不需要考虑！
                ]]
                utils.invoke(function()
                    -- 排除当前目录和父级目录，注意此处就是原始的操作系统，操作系统的目录有个表，前两个是 . 和 ..
                    if file == "." or file == ".." then
                        return
                    end
                    if stl_string.endswith(directory, "commands") then
                        return
                    end
                    if stl_string.endswith(directory, "tests") then
                        return
                    end

                    -- file 是 directory 下的相对路径（没有 ./ 的相对路径）
                    local full_path = directory .. '/' .. file  -- 获取完整路径
                    local attr = lfs.attributes(full_path)  -- 获取文件属性

                    if not attr then
                        return
                    end

                    if attr.mode == "directory" then
                        local sub_files = list_files(full_path)
                        for _, sub_file in ipairs(sub_files) do
                            table.insert(res, sub_file)
                        end
                    elseif attr.mode == "file" then
                        table.insert(res, full_path)
                    end
                end)
                --process_file(file)
            end

            local Stream = require("moreitems.lib.thirdparty.extensions").Stream

            return Stream.of(res)
                         :map(function(e) return e:gsub("/", "\\") end)
                         :filter(function(e) return stl_string.endswith(e, ".lua") and not stl_string.endswith(e, "commands.lua") and not stl_string.endswith(e, "automation.lua") end)
                         :totable()
        end

        ---@return string[]
        function this.find_all_matched_lua_files()
            -- currentdir() 返回的是 scripts 所在位置
            local current_dir = lfs.currentdir() .. "\\moreitems"
            return list_files(current_dir)
        end

        return this
    end
}, {
    __call = function(t)
        local helper = t.Helper()

        -- ATTENTION: 测试时，记得将 commands 目录和 commands.lua 文件排除！

        -- setup
        -- 将 settings 中的 DEBUG 和 TEST_ENABLED 修改
        --local filepath = lfs.currentdir() .. "\\moreitems" .. "\\settings.lua"
        --local settings_file = io.open(filepath, "r")
        --assert(settings_file ~= nil)
        --local old_content = settings_file:read("*a")
        --settings_file:close()
        --
        --settings_file = io.open(filepath, "w")
        --local replacements = {
        --    ["module%.DEBUG%s*=.+"] = "module.DEBUG = true",
        --    ["module%.TEST_ENABLED%s*=.+"] = "module.TEST_ENABLED = true"
        --}
        --local pattern = table.concat(stl_table.keys(replacements, true), "|")
        --settings_file:write(string.gsub(old_content, pattern, function(matched)
        --    print(matched)
        --    return matched
        --end))
        --settings_file:close()

        local files = helper.find_all_matched_lua_files()
        --print(inspect.inspect(files))
        for _, filename in ipairs(files) do
            print(filename .. ": ")
            io.stdout:flush()
            local command = base.string_format("lua.exe \"{{filename}}\"", { filename = filename })
            os.execute(command)
        end

        -- tear down
        --settings_file = io.open(filepath, "w")
        --settings_file:write(old_content)
        --settings_file:close()

    end
})