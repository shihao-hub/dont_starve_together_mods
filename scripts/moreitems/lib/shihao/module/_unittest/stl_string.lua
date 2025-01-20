local inspect = require("moreitems.lib.thirdparty.inspect.inspect")

local assertion = require("moreitems.lib.shihao.module.assertion")
local stl_string = require("moreitems.lib.shihao.module.stl_string")

local module = setmetatable({}, { __index = stl_string })

function module.test_split()
    xpcall(function()
        local str = "123456"
        assertion.assert_true(inspect(module.split(str, "")) == "{ \"1\", \"2\", \"3\", \"4\", \"5\", \"6\" }")
    end, print)
end

if select("#", ...) == 0 then
    module.test_split()
end

return module