---
--- Created by zsh
--- DateTime: 2023/11/1 16:18
---

require("new_scripts.mod_a.common_global")

--local mysql = require("luasql.mysql")
--local odbc = require("luasql.odbc")
--local sqlite3 = require("luasql.sqlite3")
--
--morel_print_table_deeply(mysql)
--morel_print_table_deeply(odbc)
--morel_print_table_deeply(sqlite3)


--require "luasql.odbc"
--env = luasql.odbc()
--
--print(env.__index)
--morel_print_table_deeply(env.__index)

require "luasql.mysql"

local stream_objects = setmetatable({}, {
    __call = function(t, fn_name, ...)
        local n = select("#", ...)
        local args = { ... }
        if fn_name == "insert" then
            local obj = args[1]
            local obj_type = type(obj)
            if obj ~= nil and (obj_type == "table" or obj_type == "userdata") then
                if not morel_contains_value(t, obj) then
                    table.insert(t, obj)
                    print("dump -> " .. tostring(obj))
                end
            else
                print(tostring(obj) .. " insertion failure, because type(obj) == " .. obj_type)
            end
            return unpack(args, 1, n)
        elseif fn_name == "close_and_remove" then
            local size = #t
            for i = size, 1, -1 do
                print("close -> " .. tostring(t[i]))
                t[i]:close()
                t[i] = nil
            end
            print("All streams are closed.")
        else
            error(string.format("%s isn't declared.", fn_name), 2)
        end
    end
})

local env = stream_objects("insert", assert(luasql.mysql()))

--print(env.__index)
--morel_print_table_deeply(env.__index)

local connect = stream_objects("insert", assert(env:connect("java", "root", "zsh20010417")))

connect:execute("SET NAMES UTF8")

local cursor, err = stream_objects("insert", assert(connect:execute([[select * from websites;]])))

local row = cursor:fetch({}, "a")
local database_file = assert(io.open("new_scripts/test/test104_database.txt", "w"))
while row do
    database_file:write(morel_print_table_deeply(row, true), "\n")
    row = cursor:fetch(row, "a")
end
database_file:close()

assert(connect:execute([[insert into websites(id,name,url,alexa,country) values(8,"知乎3","https://www.zhihu.com/",100,"China")]]))

stream_objects("close_and_remove")



-- Basic use: ? error

-- load driver
--require "luasql.postgres"
---- create environment object
--env = assert (luasql.postgres())
---- connect to data source
--con = assert (env:connect("luasql-test"))
---- reset our table
--res = con:execute"DROP TABLE people"
--res = assert (con:execute[[
--  CREATE TABLE people(
--    name  varchar(50),
--    email varchar(50)
--  )
--]])
---- add a few elements
--list = {
--    { name="Jose das Couves", email="jose@couves.com", },
--    { name="Manoel Joaquim", email="manoel.joaquim@cafundo.com", },
--    { name="Maria das Dores", email="maria@dores.com", },
--}
--for i, p in pairs (list) do
--    res = assert (con:execute(string.format([[
--    INSERT INTO people
--    VALUES ('%s', '%s')]], p.name, p.email)
--    ))
--end
---- retrieve a cursor
--cur = assert (con:execute"SELECT name, email from people")
---- print all rows, the rows will be indexed by field names
--row = cur:fetch ({}, "a")
--while row do
--    print(string.format("Name: %s, E-mail: %s", row.name, row.email))
--    -- reusing the table of results
--    row = cur:fetch (row, "a")
--end
---- close everything
--cur:close()
--con:close()
--env:close()

