---
--- Created by zsh
--- DateTime: 2023/11/1 15:05
---

require("new_scripts.mod_a.common_global")

--module("table.moreL.table", package.seeall)
--
--function get_key_by_value(t, val)
--    for k, v in pairs(t) do
--        if v == val then
--            return k
--        end
--    end
--    return nil
--end

--print(string.byte("a"))
--print(string.format("%02x", string.byte("a")))
--print(package.path)

if not morel_BRANCH == "dev" then
    return
end

-- useful code
--require("logging")

-- code gravy
--morel_print_table_deeply(logging)

--local logger, msg = logging.new()
--
--if not logger then
--    print(msg)
--end

-- useful code
--local logger, msg = require("logging.console")()
--
--logger:append(logging.DEBUG, "Hello")
--logger:log(logging.DEBUG, "Hello")

--package.cpath=".\?.dll;.\?51.dll;"
require("socket") -- require("socket.core") 这个 socket.core 是 cpath 根目录下的 socket/core.dll
--print("======package.path")
--print((string.gsub(package.path,";",";\n")))
print("======package.cpath")
print((string.gsub(package.cpath,";",";\n")))

--morel_print_table_deeply(socket)
--morel_print_table_deeply(package.loaded)
--print(type(package.loaded["socket.core"]))



