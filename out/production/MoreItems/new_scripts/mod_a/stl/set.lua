---
--- Created by zsh
--- DateTime: 2023/11/23 3:51
---

require("new_scripts.mod_a.class")
local StringBuilder = require("new_scripts.mod_a.class.string_builder")

-- 随便按个人浅显理解简单实现一下

local set = morel_Class(function(self, src_set)
    self:set_type("stl_set")

    self.data = { proxy = {} }
    self.len = 0
    if self:_is_set(src_set) then
        for v, _ in src_set:pairs() do
            self.data[v] = true
        end
    end
end)

---@overload fun()
function set:new(src_set)
    return set(src_set)
end

function set:tostring()
    local sb = StringBuilder:new()
    sb:append("[")
    for v, _ in self:pairs() do
        sb:append(tostring(v)):append(",")
    end
    sb:delete(-1, -1)
    sb:append("]\n")
    return sb:tostring()
end

function set:find(elem)
    self:_check_elem(elem)

    return self.data.proxy[elem]
end

function set:insert(elem)
    self:_check_elem(elem)

    self.len = self.len + 1
    self.data.proxy[elem] = true
end

function set:erase(elem)
    self:_check_elem(elem)

    self.data.proxy[elem] = nil
    self.len = self.len - 1
end

function set:to_array()
    local arr = {}
    for v,_ in self:pairs() do
        table.insert(arr, v)
    end
    return arr
end

-- 不行
--function set:ipairs()
--    local i = 0
--    return function(t)
--        local k, v = next(t)
--        i = i + 1
--        if v == nil then return end
--        return i, k
--    end, self.data.proxy, nil
--end

function set:pairs()
    return next, self.data.proxy, nil
end

function set:empty()
    return self.len == 0
end

function set:size()
    return self.len
end

function set:_is_set(set_val)
    return set_val and set_val.is_a and set_val:is_a(set)
end

function set:_check_elem(elem)
    if elem == nil then
        error("elem == nil", 2)
    end
end

return set