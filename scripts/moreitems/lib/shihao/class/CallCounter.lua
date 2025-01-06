local class = require("moreitems.lib.thirdparty.middleclass.middleclass").class
local inspect = require("moreitems.lib.thirdparty.inspect.inspect")

local base = require("moreitems.lib.shihao.base")
local utils = require("moreitems.lib.shihao.utils")
local log = require("moreitems.lib.shihao.module.log")
local guards = require("moreitems.lib.shihao.module.guards")

---@class CallCounter
local CallCounter = class("CallCounter")

---@param data table
local function _persistent(data)
    --log.info(inspect.inspect(data))
    log.info("persistent")
end

local function _modify_instance_metatable(instance)
    local data = inspect.counter
    local mt = getmetatable(instance)
    guards.if_present(mt, function()
        log.info(inspect.inspect(instance))
        log.info(mt)
        log.info(mt.__index)
        mt.__index = utils.hook(mt.__index, function(old)
            return function(t, k)
                local res = old(t, k)
                _persistent(data)
                return res
            end
        end)
    end)
end

function CallCounter:initialize()
    self.counter = {}

    -- 不对，middleclass 和 dst 的 Class 实现原理不一样，比如 mt.__index 不是函数，暂且搁置，之后在思考。
    --_modify_instance_metatable(self)
end

function CallCounter:set(key, value)
    self.counter[key] = value

    _persistent(self.counter)
end

function CallCounter:get(key)
    return self.counter[key]
end

-- Question: function CallCounter:_increase(key, step) 和 local function _increase(key, step) 相比如何？
local function _increase(self, key, step)
    local value = self.counter[key]

    if value and not base.is_number(value) then
        log.warning("CallCounter:incr: self.counter[key] is not a number: " .. tostring(value))
        return
    end

    value = base.ternary_operator(value, value, 0)
    self.counter[key] = value + step
end

function CallCounter:incr(key, step)
    if step == nil or step < 0 then
        step = 1
    end
    _increase(self, key, step)

    _persistent(self.counter)
end

function CallCounter:decr(key, step)
    if step == nil or step > 0 then
        step = -1
    end
    _increase(self, key, step)

    _persistent(self.counter)
end

function CallCounter:tostring()
    return inspect.inspect(self.counter)
end

--function CallCounter:persistent()
--    _persistent(self.counter)
--end

-- TODO: 这是一个全局 CallCounter 实例，然后在设置一个定时器，周期存储到文件中？

if select("#", ...) == 0 then
    local luafun = require("moreitems.lib.thirdparty.luafun.fun")
    local stl_debug = require("moreitems.lib.shihao.stl.debug")
    local counter = CallCounter()
    --counter:incr(stl_debug.get_call_location() .. ":unknown")
    for i in luafun.range(10) do
        counter:incr(stl_debug.get_call_filepath() .. ".unknown")
    end

    print(counter:get("moreitems.lib.shihao.class.CallCounter.unknown"))
    print(counter:tostring())

    local info = debug.getinfo(2, "l")
    print("错误发生的行号是: " .. info.currentline)
end

return CallCounter