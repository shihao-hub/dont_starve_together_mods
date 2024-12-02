---
--- Created by zsh
--- DateTime: 2023/11/1 4:51
---

require("new_scripts.mod_a.common_global")

local string_builder = morel_c_StringBuilder:new()

string_builder:append("123"):append("456"):append("789")
print(string_builder:tostring())
string_builder:reverse()
print(string_builder:tostring())
string_builder:reverse()
print(string_builder:tostring())

--print(string_builder:index_of("456",4))
--print(string_builder:last_index_of("567",0))
--print(string_builder:index_of())

require("new_scripts.mod_a.class.array_list")

local array_num = morel_c_ArrayList:new("number")

array_num:add(6):add(1):add(2):add(3):add(nil):add(5):add(7)
print(array_num:to_array())

--print(array_num:set(4,100))
--print(array_num:get(6))
--print(array_num:remove(3))
array_num:sort()

print(array_num:to_array())
print(array_num:sub_list(2,5))
local sub_array_num = morel_c_ArrayList:new("number"):add_all(array_num:sub_list(5,5))
print(sub_array_num:to_array())
print(sub_array_num:contains(5))
--array_num:clear()
--print(array_num:to_array())

--local array_str = morel_c_ArrayList:new("string")
--array_str:add("f"):add("a"):add("b"):add("c"):add(nil):add("e")
----array_str:clear()
--print(array_str:to_array())
--array_str:sort()
--print(array_str:to_array())
--
--for v in array_num:values_iter() do
--    io.write(tostring(v) .. " ")
--end
--io.write("\n")
--
--for v in array_str:values_iter() do
--    io.write(tostring(v) .. " ")
--end
--io.write("\n")

require("new_scripts.test.test103")

morel_print_table_deeply(table)
