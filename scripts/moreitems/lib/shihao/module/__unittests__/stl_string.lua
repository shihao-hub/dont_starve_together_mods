local inspect = require("moreitems.lib.thirdparty.inspect.inspect")
local assertion = require("moreitems.lib.shihao.assertion")

local module = require("moreitems.lib.shihao.module.stl_string")

local unittests = {}

function unittests.test_split()
    local str = "123456"
    assertion.assert_true(inspect(module.split(str, "")) == "{ \"1\", \"2\", \"3\", \"4\", \"5\", \"6\" }")
end

function unittests.test_startswith()
    local str, prefix = "123456789", "123456"
    assertion.assert_true(module.startswith(str, prefix))
end

function unittests.test_endswith()
    local test_cases = {
        { "789", "89" },
        --{ "9", "89" },
    }
    for _, case in ipairs(test_cases) do
        assertion.assert_true(module.endswith(unpack(case, 1, table.maxn(case))), case)
    end
end

function unittests.test_strip()
    assertion.assert_true(module.strip("  123  ") == "123")
    assertion.assert_true(module.strip("123---456", "123456") == "---")
end
function unittests.test_is_integer()
    assertion.assert_true(module.is_integer("12345") == true)
    assertion.assert_true(module.is_integer("12345a") == false)
    assertion.assert_true(module.is_integer("aaa") == false)
    assertion.assert_true(module.is_integer("12345.") == false)
    assertion.assert_true(module.is_integer("12345.0") == false)
    assertion.assert_true(module.is_integer("12345.0a") == false)
end
function unittests.test_is_float()

end

if select("#", ...) == 0 then
    for name, fn in pairs(unittests) do
        xpcall(function()
            fn()
        end, function(msg)
            io.stderr:write("testing `" .. name:sub(6, -1) .. "` function: \n")
            io.stderr:write(msg, "\n")
        end)
    end
end