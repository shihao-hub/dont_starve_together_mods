local settings = require("moreitems.settings")

local __main__ = select("#", ...) == 0

local function _third_party_checker()
    -- lustache lib adds a new function to the `string` table,
    -- which causes the original function to be overridden.
    local module = {}

    -- check whether third-party libraries have invaded the global environment.
    local TABLE_NAMES = { "_G", "coroutine", "debug", "io", "math", "os", "string", "table" }

    local origin_record = {}

    local function _get_metatable_key(name)
        return name .. ":" .. "metatable"
    end

    local function _record()
        for _, name in ipairs(TABLE_NAMES) do
            origin_record[_get_metatable_key(name)] = getmetatable(rawget(_G, name))
        end
    end

    function module.check()
        _record()

        local mt = {
            __newindex = function(t, k, v)
                error("The third-party libraries can't invade the global environment.", 2)
            end
        }
        for _, name in ipairs(TABLE_NAMES) do
            local t = rawget(_G, name)
            setmetatable(t, mt)
        end
    end

    function module.revert()
        for _, name in ipairs(TABLE_NAMES) do
            local t = rawget(_G, name)
            local value = origin_record[_get_metatable_key(name)]
            if value ~= nil then
                assert(type(value) == "table")
                setmetatable(t, value)
            end
        end
    end

    if __main__ then
        -- NOTE: 测试中使用的库不需要放在文件开头
        local inspect = require("moreitems.lib.thirdparty.inspect.inspect")
        local assertion = require("moreitems.lib.shihao.assertion")

        local base = require("moreitems.lib.shihao.base")
        local utils = require("moreitems.lib.shihao.utils")

        for _, name in ipairs(TABLE_NAMES) do
            utils.invoke_safe(function()
                print("testing `" .. name .. "`")
                local target = rawget(_G, name)
                local mt = {}
                setmetatable(target, mt)

                module.check()
                assertion.assert_true(origin_record[_get_metatable_key(name)] == mt)
                module.revert()
                assertion.assert_true(getmetatable(target) == mt)
            end)
        end
    end

    return module
end

return {
    third_party_checker = _third_party_checker()
}