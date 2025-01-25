local base = require("moreitems.lib.shihao.base")

local module = {}


-- TestCase

---@param module_or_unittests
local function _collect_statistics_on_coverage_of_unittests(module_or_unittests)
    local source = module_or_unittests
    if source.unittests == nil then
        return
    end
    local unittests = source.unittests

end

---注意，如果某个函数未实现对应的单元测试，需要考虑将其统计出来
---@param module_or_unittests table
function module.run_unittests(module_or_unittests)
    _collect_statistics_on_coverage_of_unittests(module_or_unittests)

    local unittests = module_or_unittests.unittests or module_or_unittests
    for name, fn in pairs(unittests) do
        base.continue_or_break(function()
            if type(fn) ~= "function" then
                return
            end

            xpcall(function()
                fn()
            end, function(msg)
                io.stderr:write("testing `" .. name .. "` function: \n")
                io.stderr:write(msg, "\n")
            end)
        end)
    end
end

return module
