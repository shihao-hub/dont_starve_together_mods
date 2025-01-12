local luafun = require("moreitems.lib.thirdparty.luafun.fun")
local inspect = require("moreitems.lib.thirdparty.inspect.inspect")

local Stream = require("moreitems.lib.thirdparty.extensions").Stream

local two_axis_martix = {
    { 1, 2, 3 },
    { 4, 5, 6 }
}

--print(inspect.inspect(luafun.iter(two_axis_martix):foldl():totable()))


local t = { 1, 2, 3 }

--local iter = luafun.iter(t)
--luafun.foreach(function(e)
--    print(e)
--end, iter)

print("\nStream: ")
local stream = Stream.of(t)
--stream:foreach(function(e)
--    print(e)
--end)

stream = Stream.of(t)
print(inspect.inspect(stream:drop(1):totable()))
--stream = Stream.of(t)
--print(inspect.inspect(stream:take(1):totable()))