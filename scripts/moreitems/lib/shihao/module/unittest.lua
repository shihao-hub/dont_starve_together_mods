local base = require("moreitems.lib.shihao.base")

local module = {}


-- TestCase

---@param source table|nil
local function _collect_statistics_on_coverage_of_unittests(source)
    if source == nil then
        return
    end
    local unittests = source.unittests

end

---注意，如果某个函数未实现对应的单元测试，需要考虑将其统计出来
---@param unittests table
---@param source table
---@overload fun(unittests:table)
function module.run_unittests(unittests, source)
    _collect_statistics_on_coverage_of_unittests(source)

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
