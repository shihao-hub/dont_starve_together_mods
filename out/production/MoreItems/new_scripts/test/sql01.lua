---
--- Created by zsh
--- DateTime: 2023/11/1 22:59
---

require("new_scripts.mod_a.main")

local config = {
    file_path_root = "new_scripts/test/",
    data_base_name = "java",
    account_name = "root",
    password = "zsh20010417",
    result_file_name = "sql01.txt"
}

local sql_file = assert(io.open(config.file_path_root .. "sql01.sql", "r"))
local result_file = assert(io.open(config.file_path_root .. config.result_file_name, "w"))
local env = assert(require("luasql.mysql").mysql())
local conn = assert(env:connect(config.data_base_name, config.account_name, config.password))

conn:execute("SET NAMES UTF8")

local DUMP_TEST_ENABLED = false
local dump_test = {}

-- 23/11/1
-- 注意，每次只读入一个字符的方式，只兼容 ASCII 码...
-- 而且此处是默认一句 sql 只在一行
local line = {}
local line_num = 1
local c = sql_file:read(1)
while c do
    if c ~= ';' then
        if c ~= '\n' then
            table.insert(line, c)
        end
    else
        local commands = table.concat(line)
        local cur, err = conn:execute(commands)
        if not cur and err then
            error(string.format("In %s line %d: ", config.result_file_name, line_num) .. err)
        end
        --print(cur,err)
        print("sql command [[ " .. commands .. " ]] executes successfully.")
        if morel_is_table(cur) or morel_is_userdata(cur) then
            local row = cur:fetch({}, "a")
            while row do
                local str_of_table = morel_print_table_deeply(row, true)
                if DUMP_TEST_ENABLED then table.insert(dump_test, str_of_table) end
                result_file:write(str_of_table, "\n")
                row = cur:fetch(row, "a")
            end
        end
        line = {}
        line_num = line_num + 1
    end
    c = sql_file:read(1)
end

if DUMP_TEST_ENABLED then
    for i = 1, #dump_test do
        local fn = loadstring("return " .. dump_test[i])
        dump_test[i] = fn()
    end

    morel_print_table_deeply(dump_test)
end