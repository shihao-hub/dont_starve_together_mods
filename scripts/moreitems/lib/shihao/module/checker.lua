local base = require("moreitems.lib.shihao.base")

local module = {}

---@param value any
---@param _type string
local function _check_template_method(value, _type)
    if type(value) == _type then
        return
    end
    error("Expected " .. _type .. ", got " .. type(value))
end

function module.check_string(value)
    _check_template_method(value, "string")
end

function module.check_function(value)
    _check_template_method(value, "function")
end

function module.require_not_nil(value, message)
    message = base.ternary_operator(message, message, "Expected " .. "not nil" .. ", got " .. "nil")
    if value == nil then
        error(message)
    end
end

if select('#', ...) == 0 then

end

return module
