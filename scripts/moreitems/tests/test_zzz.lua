local inspect = require("moreitems.lib.thirdparty.inspect.inspect")

local DSTUtils = require("moreitems.main").dst.class.DSTUtils

--print(inspect(DSTUtils))

local dst_utils = DSTUtils({})
print(inspect(dst_utils))