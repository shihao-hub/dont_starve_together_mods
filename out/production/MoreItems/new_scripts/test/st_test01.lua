local preload = {}
function preload.add_package_path()
   local debuginfo = debug.getinfo(1)
   --[[
		nups	0
		what	main
		func	function: 00A8C640
		lastlinedefined	0
		source	@D:\games\Steam\steamapps\common\Don't Starve Together\mods\MoreItems\scripts\new_scripts\test\st_test01.lua
		currentline	1
		namewhat	
		linedefined	0
		short_src	...ods\MoreItems\scripts\new_scripts\test\st_test01.lua
	--]]
   if not debuginfo then assert(false, "debuginfo is nil") end
   local source = debuginfo.source
   local i, j = string.find(source, "scripts\\")
   package.path = package.path .. ";" .. string.sub(source, 2, j) .. "?.lua"
end
preload.add_package_path()

-- local str = "|?string"
-- print(str:match "[^|?]+")
require("new_scripts.mod_a.main")
-- print(string.dump(function()end):sub(1, 12))

print(morel_BRANCH)
morel_print_table_deeply({a = 1, b = 2, c = 3})
