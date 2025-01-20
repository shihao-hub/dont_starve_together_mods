local class = require("moreitems.lib.thirdparty.middleclass.middleclass").class

local str_string = require("moreitems.lib.shihao.module.stl_string")

local IniParser = class("IniParser")

if select("#", ...) == 0 then
    local inspect = require("moreitems.lib.thirdparty.inspect.inspect")

    local function load_ini(filename)
        -- check_file_exsits

        local config = {}
        local current_section -- 值得学习，ai 确实是个好工具

        for line in io.lines(filename) do
            line = str_string.strip(line)

            -- 忽略空行和注释：`.ini` 的注释好像是 ; 和 #
            if line ~= "" and not line:match("^[;#]") then
                -- match 在匹配到之后会返回匹配到的内容，而不是 find 那样返回索引
                local section = line:match("^%[(.-)%]$")
                if section then
                    current_section = section
                    config[current_section] = config[current_section] or {}
                else
                    -- 收集键值对
                    local key, value = line:match("^(.-)%s*=%s*(.-)$")
                    if key and value then
                        -- 将匹配到的替换成捕获的 %1
                        key = key:gsub("^%s*(.-)%s*$", "%1")
                        value = value:gsub("^%s*(.-)%s*$", "%1")
                        config[current_section][key] = value
                    end
                end
            end
        end

        return config
    end



    -- 使用示例
    -- TODO: 类似 Python，config 实例 + config.read 生成数据，这个过程中可以多次解析刷新数据
    local config = load_ini("./moreitems/lib/shihao/class/IniParser.ini")

    -- 访问配置
    print(inspect(config))
    print("Title:", config.general.title)
    print("Database Host:", config.database.host)
    print("Database Port:", config.database.port)
end

return IniParser