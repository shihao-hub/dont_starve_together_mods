---
--- DateTime: 2025/1/7 10:15
---

local class = require("moreitems.lib.thirdparty.middleclass.middleclass").class
local luafun = require("moreitems.lib.thirdparty.luafun.fun")
local inspect = require("moreitems.lib.thirdparty.inspect.inspect")

local base = require("moreitems.lib.shihao.base")
local stl_string = require("moreitems.lib.shihao.module.stl_string")

-- 主要，这个 middleclass 隐藏了太多东西，这导致有些事情我做不了啊。只能把代码看一下才行。
-- 稍微看来一下，似乎确实比 Lua 官方书中的那种定义方式好一点，比如 aClass.__instanceDict 和 aClass.__declaredMethods
---@class NamedTuple
local NamedTuple = class("NamedTuple")

local function _check_field_name(name)
    if not base.is_string(name)
            or stl_string.startswith(name, "_") then
        error(base.string_format("The format of the `field_name` seems to be incorrect. Please check it. `field_name: {{field_name}}`", { field_name = name }), 2)
    end
end

function NamedTuple:initialize(field_names, fields)
    --local function test()
    --    local instance = self
    --    local aclass = getmetatable(instance)
    --    print(inspect.inspect(instance))
    --    print(inspect.inspect(aclass))
    --    print(inspect.inspect(getmetatable(aclass)))
    --end
    --test()

    -- check 可以保证数据的正确性
    luafun.foreach(function(e)
        _check_field_name(e)
    end, field_names)

    self._fields_name = field_names
    --self._fields = fields

    for _, name in ipairs(self._fields_name) do
        self[name] = fields[name]
    end
end

function NamedTuple:tostring()
    local out = {}
    for _, name in ipairs(self._fields_name) do
        out[name] = self[name]
    end
    return inspect.inspect(out)
end

if select("#", ...) == 0 then
    --local person = NamedTuple({ "name", "age", "info" }, { name = "zsh", age = "123", info = { money = 1000000, address = { str = "china" } } })
    --print(person:tostring())
end

return NamedTuple
