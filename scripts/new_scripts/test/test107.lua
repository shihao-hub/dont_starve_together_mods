---
--- Created by zsh
--- DateTime: 2023/11/20 21:16
---

require("new_scripts.mod_a.main")
morel_print_table_deeply(morel_G)
local StringBuilder = require("new_scripts.mod_a.class.string_builder")

--morel_Switch.execute("abc",{
--    ["abc"] = function()
--        print("Hello, Lua.")
--    end
--})
--
--print(morel_LfW_global)

local sb = StringBuilder:new()
sb:append("123123123")
print(sb:index_of("1234"))
print(sb:last_index_of("123", 6))

print(sb)
morel_assert_no_throw(false, "sb can't be a nil.", true)
morel_logger_print("Are you kidding me?")
xpcall(function() return nil .. 1 end, morel_common_msgh)

function morel_assert(v,message)
    string.dump(v)
end

print(loadstring(string.dump(function()
    return 123
end)))

