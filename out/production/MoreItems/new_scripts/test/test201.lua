---
--- Created by zsh
--- DateTime: 2023/11/28 5:14
---
require("new_scripts.mod_a.main")

--local t = {}
--table.insert(t, "a")
--table.insert(t, (morel_get_call_on_position(1)))
--
----print(next(t))
--
--local stl_set = require("new_scripts.mod_a.stl.set")
--local set = stl_set:new()
--set:insert("a")
--set:insert("b")
--set:insert("c")
--set:insert("c")
--set:insert("c")
--for v, _ in set:pairs() do
--    print(v)
--end
--
--morel_print_table_deeply(set:to_array())
--
--print(set:tostring())
--
--local mt2 = {
--    a = "mt a"
--}
--mt2.__index = mt2
--local t2 = setmetatable({
--    --a = "ins a"
--}, mt2)
--
--print(t2.a)

--local IOException = require("new_scripts.mod_a.class.exception.io_exception")
--local filename = morel_RELATIVE_SRC_PATH .. "test201.txt"
--local file = io.open(filename, "r")
--if file == nil then
--    --morel_throw_exception(IOException(filename .. " is existent."))
--    morel_throw_exception(IOException("error"))
--end

--local i = 1000
--while i>0 do
--    i=i-1
--    print(os.time())
--end

--local start = os.clock()
--while true do
--    local now = os.clock()
--    if (now - start) >= 1 then
--        start = now
--        morel_print_flush(os.time())
--    end
--end

function table.invert(t)
    local invt = {}
    for k, v in pairs(t) do
        invt[v] = k
    end
    return invt
end
local filter = {
    recipes = { "a", "b", "c", "d" },
    default_sort_values = { }
}
local index = 0
for i, v in ipairs(filter.recipes) do
    if v == "c" then
        index = i
        break
    end
end
print("index: "..index)
if index ~= 0 then
    for i = index, 2, -1 do
        local tmp = filter.recipes[i]
        filter.recipes[i] = filter.recipes[i - 1]
        filter.recipes[i - 1] = tmp
    end
    filter.default_sort_values = table.invert(filter.recipes)
end

morel_print_table_deeply(filter.recipes)
--morel_print_table_deeply(filter.default_sort_values)