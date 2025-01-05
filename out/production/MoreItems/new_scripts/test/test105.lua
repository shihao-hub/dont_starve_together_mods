---
--- Created by zsh
--- DateTime: 2023/11/1 20:48
---

local function newline()
    io.write("\n")
end

require("new_scripts.mod_a.main")

--for i, v in morel_lua_for_windows_list.ipairs({ 3, 2, 1 }) do
--    print(i, v)
--end
--
--for i, v in morel_lua_for_windows_list.ipairs_reverse({ 3, 2, 1 }) do
--    print(i, v)
--end
--
--for v in morel_lua_for_windows_list.iter_values({ 11, 22, 33 }) do
--    io.write(v," ")
--end
--newline()
--
--for v in morel_lua_for_windows_list.iter_values_reverse({ 11, 22, 33 }) do
--    io.write(v," ")
--end
--newline()

local list = morel_lua_for_windows_list

--morel_print_table_deeply(list.filter({ 11, 22, 33, 44 }, function(v) return v > 25 end))
--morel_print_table_deeply(list.concat({ 1, 2, 3 }, { 4, 5, 6 }))
--morel_print_table_deeply(list.reverse({ 11, 22, 33 }))

--print_table(_G.op)


local sb = morel_c_StringBuilder:new()
sb:append("123123123123123")
print(sb:index_of("3"))
print(sb:last_index_of("3"))
print(tostring(sb))

print(type(table.insert({},1)))