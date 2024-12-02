---
--- Created by zsh
--- DateTime: 2023/11/25 10:15
---

require("new_scripts.mod_a.class")
local StringBuilder = require("new_scripts.mod_a.class.string_builder")

local function get_call_on_position(level_incr)
    --[[
        -- debug.getinfo(thread, what), the below content refers to "what"
        -- S: source, short_src, linedefined, lastlinedefined, what
        -- l: currentline
        -- u: nups
        -- n: name, namewhat
        -- L: activelines
        -- f: func
    ]]

    -- level_incr, incr(增量)
    level_incr = level_incr and level_incr or 0
    -- It is better to provide a second param, because it can improve performance(改善性能). (maybe?)
    -- but I think this is meaningless.
    local info = debug.getinfo(2 + level_incr)
    if info and info.short_src and info.currentline then
        return string.gsub(string.format("%s:%d", info.short_src, info.currentline), "\\", "/")
    end
    return ""
end

local TimeInterval = morel_Class(function(self)
    morel_super()
    self:set_type("TimeInterval")

    self.start_time = nil
    self.intervals = {}
    self.len = 0
    self.locations = { status = "valid" }
end)

function TimeInterval:start()
    self.start_time = os.clock()
end

-- 每次存储的是距离起始点的时间间隔：<0.3>[0.5,0.8,1.2] -> <0.3>[0.2,0.5,0.9]
function TimeInterval:insert()
    table.insert(self.intervals, os.clock() - self.start_time)
    self.len = self.len + 1
    -- 这里 get_call_on_position 需要加括号保证只是一个参数。
    -- 嗯？所以这似乎有点特别是吗，否则会被视为 table.insert(list, pos, value) 这个重载函数
    --table.insert(self.locations, "->" .. (get_call_on_position(1)))
    self.locations.status = "invalid"
end

function TimeInterval:anchor()
    return self:insert()
end

---@overload fun(id)
function TimeInterval:get(from, to)
    if from and not to then
        local id = from
        assert(id >= 1 and id <= self.len, "Not -> id >= 1 and id <= self.len")
        return self.intervals[id]
    elseif from and to then
        assert(from <= to and from >= 1 and to <= self.len, "NOT -> from <= to and from >= 1 and to <= self.len")
        return self.intervals[to] - self.intervals[from]
    else
        error("overloads as follows: fun(id), fun(from, to)")
    end
end

function TimeInterval:get_span()
    return self.intervals[self.len]
end

function TimeInterval:tostring()
    local sb = StringBuilder:new()
    sb:append(string.format("<%.3f>[", self.start_time))
    for i = 1, self.len do
        sb:append(tostring(self.intervals[i]))
          :append(self.locations.status == "valid" and self.locations[i] or "")
          :append(i ~= self.len and "," or "")
    end
    sb:append("]")
    return sb:tostring()
end

function TimeInterval:clear()
    self.start_time = nil
    self.intervals = {}
    self.len = 0
end

return TimeInterval