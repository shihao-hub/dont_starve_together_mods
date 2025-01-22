local class = require("moreitems.lib.thirdparty.middleclass.middleclass").class

---@class Optional
local Optional = class("Optional")

function Optional.of(value)
    return Optional(value)
end

function Optional:initialize(value)
    self.value = value
end

function Optional:is_null()
    return self.value == nil
end

function Optional:get_value()
    return self.value
end

if select("#", ...) == 0 then
    local optional = Optional.of(1)
    print(optional:is_null())
end

return Optional