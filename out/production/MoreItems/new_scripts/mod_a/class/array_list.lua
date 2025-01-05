---
--- Created by zsh
--- DateTime: 2023/11/1 4:38
---

require("new_scripts.mod_a.class")

local PRIMITIVE_DATA_TYPES = { ["nil"] = true, ["boolean"] = true, ["number"] = true, ["string"] = true, ["function"] = true, ["thread"] = true, ["userdata"] = true }

---@class ArrayList
local ArrayList = morel_Class(function(self, data_type, init_capacity)
    morel_super()
    self:set_type("ArrayList")

    if data_type == nil then
        error("data_type can't be nil")
    elseif not PRIMITIVE_DATA_TYPES[data_type] then
        error(string.format("data_type(%q) does not belong to the primitive data types.", data_type))
    end
    self.data_type = data_type
    if init_capacity then
        for i = 1, init_capacity do
            self.data = {}
            self.data[i] = nil
        end
    else
        self.data = { nil, nil, nil, nil, nil, nil, nil, nil, nil, nil } -- just for testing knowledge
    end
    self.field_size = 0
end)

function ArrayList:new(data_type)
    return ArrayList(data_type, nil) -- Lua does not need init_capacity, because lua table is variable.
end

-- todo: Similar to(与...相似) "for i,v in Array_instance:iterator() do end"
-- fixme
function ArrayList:values_iter()
    --[[
        Usage:
        for v in array:iterator() do
            io.write(tostring(v) .. " ")
        end
        io.write("\n")
    ]]
    local i = 0
    return function()
        --print("--1--",tostring(self.data[i]),i)
        i = i + 1
        return self.data[i]
    end
end

local function iter(t, i)
    --print("--2--",tostring(t[i]),i)
    i = i + 1
    if t[i] then
        return i, t[i]
    end
end

-- fixme
function ArrayList:ipairs_iter()
    --[[
        Usage:
        for i, v in array:iterator() do
            io.write(tostring(v) .. " ")
        end
        io.write("\n")
    ]]
    return iter, self.data, 0
end

function ArrayList:size()
    return self.field_size
end

function ArrayList:is_empty()
    return self.field_size == 0
end

function ArrayList:set(index, obj)
    self:_check_data_type(obj)
    self:_check_index_range(index)

    local old_value = self.data[index]
    self.data[index] = obj
    return old_value
end

function ArrayList:clear()
    -- clear to let GC do its work
    -- TIP: In Java, when a object is assigned(赋值) the result of null, then GC can do its work timely.
    --[[
        public void clear() {
            modCount++;

            // clear to let GC do its work
            for (int i = 0; i < size; i++)
                elementData[i] = null;

            size = 0;
        }
    ]]
    --      In Lua, when table's reference count is equal to 0, then GC can do its work timely.
    self.data = {}
    self.field_size = 0
end

function ArrayList:add(obj)
    self:_check_data_type(obj)

    self.field_size = self.field_size + 1
    self.data[self.field_size] = obj
    return self -- in order to use like "array:add(1):add(2):"
end

---@overload fun(list:table[])
---@overload fun(n:number, list:table[])
function ArrayList:add_all(...)
    local args = { ... }
    local n = args[1]
    local list = args[2]
    if n and list then
        for i = 1, n do
            self:add(list[i])
        end
    elseif n and not list then
        list = n
        n = list.n or #list
        --if not (list.n ~= nil) then error("not (list.n ~= nil)", 2) end
        for i = 1, n do
            self:add(list[i])
        end
    end
    return self
end

function ArrayList:index_of(obj)
    self:_check_data_type(obj)

    for i = 1, self:size() do
        if self.data[i] == obj then
            return i
        end
    end
    return -1
end

function ArrayList:last_index_of(obj)
    self:_check_data_type(obj)

    for i = self:size(), 1, -1 do
        if self.data[i] == obj then
            return i
        end
    end
    return -1
end

function ArrayList:to_array(from_index, end_index)
    if from_index and end_index then
        self:_check_index_range(from_index)
        self:_check_index_range(end_index)
        if not (from_index <= end_index) then error("not (from_index <= end_index)", 2) end

        local array = setmetatable({}, {
            __tostring = function(t)
                local r = { "[" }
                for i = 1, t.n do
                    table.insert(r, tostring(t[i]) .. ",")
                end
                r[#r] = string.sub(r[#r], 1, -2)
                table.insert(r, "]")
                return table.concat(r)
            end
        })
        local cnt = 0
        for i = from_index, end_index do
            cnt = cnt + 1
            array[cnt] = self:get(i)
        end
        array.n = end_index - from_index + 1
        return array
    elseif not from_index and not end_index then
        if self:is_empty() then
            return setmetatable({ n = 0 }, { __tostring = function(t) return "[]" end })
        end
        return self:to_array(1, self:size())
    else
        error("overloads as follows: fun(), fun(from_index, end_index)")
    end
end

function ArrayList:sub_list(from_index, end_index)
    return self:to_array(from_index, end_index)
end

function ArrayList:get(index)
    self:_check_index_range(index)

    return self.data[index]
end

function ArrayList:remove(index)
    self:_check_index_range(index)

    local old_value = self.data[index]
    for i = index + 1, self:size() do
        self.data[i - 1] = self.data[i]
    end
    self.data[self:size()] = nil
    self.field_size = self.field_size - 1
    return old_value
end

function ArrayList:contains(obj)
    return self:index_of(obj) >= 1
end

function ArrayList:_bubble_sort(from_index, to_index)
    for i = from_index, to_index do
        for j = to_index - 1, i, -1 do
            --print(" ",i,j)
            --print(self.data[j],self.data[j + 1])
            if self.data[j] > self.data[j + 1] then
                local tmp = self.data[j]
                self.data[j] = self.data[j + 1]
                self.data[j + 1] = tmp
            end
        end
        --print("  ",self:to_array())
    end
end

-- todo: table.sort 似乎只允许是无空洞的数组
function ArrayList:sort()
    --local function cmp_of_num_str(a, b)
    --    if a == b then
    --        return true
    --    end
    --    -- small -> large
    --    if a == nil and b then
    --        return false
    --    elseif a and b == nil then
    --        return true
    --    end
    --    return a < b
    --end

    local pos = 1
    for i = 1, self:size() do
        if self.data[i] ~= nil then
            self.data[pos] = self.data[i]
            pos = pos + 1
        end
    end
    pos = pos - 1
    for i = pos + 1, self:size() do
        if self.data[i] ~= nil then
            self.data[i] = nil
        end
    end
    --print("--1--", self:to_array())
    --
    --if self.data_type == "number" then
    --    table.sort(self.data, cmp_of_num_str)
    --elseif self.data_type == "string" then
    --    table.sort(self.data, cmp_of_num_str)
    --end
    if self.data_type == "number" or self.data_type == "string" then
        self:_bubble_sort(1, pos)
    end
end

-- obj can be nil
function ArrayList:_check_data_type(obj)
    if not (type(obj) == self.data_type or obj == nil) then
        error(string.format("not (type(obj) == %s)", self.data_type), 3)
    end
end

function ArrayList:_out_of_bounds_msg(index)
    return string.format("Index: %s, Size: %s", index, self.field_size)
end

function ArrayList:_check_index_range(index)
    if not (index >= 1 and index <= self.field_size) then
        --error(string.format("not (index >= 1 and index <= %s)", self.max_size), 2)
        error("IndexOutOfBoundsException: " .. self:_out_of_bounds_msg(index), 3)
    end
end

--morel_c_ArrayList = ArrayList

return ArrayList
