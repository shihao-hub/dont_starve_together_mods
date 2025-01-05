---
--- Created by zsh
--- DateTime: 2023/9/24 16:17
---


setfenv(1, _G)
package.loaded["lib.shlib.util"] = true

-----------------------------------------------------------------------------
-- Imports and dependencies
-----------------------------------------------------------------------------
require("lib.shlib.env")
local Class = ShiHaoEnv.Class
local ClassPrototype = ShiHaoEnv.ClassPrototype

-- Public functions
string_sh_format = nil
string_sh_split = nil


-- Private functions
local isnil, isboolean, isnumber, istable, isfunction, isstring, isthread, isuserdata


-----------------------------------------------------------------------------
-- PUBLIC FUNCTIONS
-----------------------------------------------------------------------------


-----------------------------------------------------------------------------
-- PRIVATE FUNCTIONS
-----------------------------------------------------------------------------
function isnil(v) return type(v) == "nil" end
function isboolean(v) return type(v) == "boolean" end
function isnumber(v) return type(v) == "number" end
function istable(v) return type(v) == "table" end
function isfunction(v) return type(v) == "function" end
function isstring(v) return type(v) == "string" end
function isthread(v) return type(v) == "thread" end
function isuserdata(v) return type(v) == "userdata" end


-- 先分割一下

--[[ Data Structures --]]

-----------------------------------------------------------------
-- Class RingBuffer (circular array)
---@class RingBuffer
ClassPrototype.RingBuffer = Class(function(self, maxlen)
    if type(maxlen) ~= "number" or maxlen < 1 then
        maxlen = 10
    end
    self.buffer = {}
    self.maxlen = maxlen or 10
    self.entries = 0
    self.pos = #self.buffer
end)

function ClassPrototype.RingBuffer:Clear()
    self.buffer = {}
    self.entries = 0
    self.pos = #self.buffer
end

-- Add an element to the circular buffer
function ClassPrototype.RingBuffer:Add(entry)
    local indx = self.pos % self.maxlen + 1

    self.entries = self.entries + 1
    if self.entries > self.maxlen then
        self.entries = self.maxlen
    end
    self.buffer[indx] = entry
    self.pos = indx
end

-- Access from start of circular buffer
function ClassPrototype.RingBuffer:Get(index)

    if index > self.maxlen or index > self.entries or index < 1 then
        return nil
    end

    local pos = (self.pos - self.entries) + index
    if pos < 1 then
        pos = pos + self.entries
    end

    return self.buffer[pos]
end

function ClassPrototype.RingBuffer:GetBuffer()
    local t = {}
    for i = 1, self.entries do
        t[#t + 1] = self:GetElementAt(i)
    end
    return t
end

function ClassPrototype.RingBuffer:Resize(newsize)
    if type(newsize) ~= "number" or newsize < 1 then
        newsize = 1
    end

    -- not dealing with making the buffer smaller
    local nb = self:GetBuffer()

    self.buffer = nb
    self.maxlen = newsize
    self.entries = #nb
    self.pos = #nb

end

-----------------------------------------------------------------
-- Class LinkedList (singly linked)
-- Get elements using the iterator

---@class LinkedList
ClassPrototype.LinkedList = Class(function(self)
    self._head = nil
    self._tail = nil
end)

function ClassPrototype.LinkedList:Append(v)
    local elem = { data = v }
    if self._head == nil and self._tail == nil then
        self._head = elem
        self._tail = elem
    else
        elem._prev = self._tail
        self._tail._next = elem
        self._tail = elem
    end

    return v
end

function ClassPrototype.LinkedList:Remove(v)
    local current = self._head
    while current ~= nil do
        if current.data == v then
            if current._prev ~= nil then
                current._prev._next = current._next
            else
                self._head = current._next
            end

            if current._next ~= nil then
                current._next._prev = current._prev
            else
                self._tail = current._prev
            end
            return true
        end

        current = current._next
    end

    return false
end

function ClassPrototype.LinkedList:Head()
    return self._head and self._head.data or nil
end

function ClassPrototype.LinkedList:Tail()
    return self._tail and self._tail.data or nil
end

function ClassPrototype.LinkedList:Clear()
    self._head = nil
    self._tail = nil
end

function ClassPrototype.LinkedList:Count()
    local count = 0
    local it = self:Iterator()
    while it:Next() ~= nil do
        count = count + 1
    end
    return count
end

function ClassPrototype.LinkedList:Iterator()
    return {
        _list = self,
        _current = nil,
        Current = function(it)
            return it._current and it._current.data or nil
        end,
        RemoveCurrent = function(it)
            -- use to snip out the current element during iteration

            if it._current._prev == nil and it._current._next == nil then
                -- empty the list!
                it._list:Clear()
                return
            end

            local count = it._list:Count()

            if it._current._prev ~= nil then
                it._current._prev._next = it._current._next
            else
                assert(it._list._head == it._current)
                it._list._head = it._current._next
            end

            if it._current._next ~= nil then
                it._current._next._prev = it._current._prev
            else
                assert(it._list._tail == it._current)
                it._list._tail = it._current._prev
            end

            assert(count - 1 == it._list:Count())

            -- NOTE! "current" is now not part of the list, but its _next and _prev still work for iterating off of it.
        end,
        Next = function(it)
            if it._current == nil then
                it._current = it._list._head
            else
                it._current = it._current._next
            end
            return it:Current()
        end,
    }
end

--END--

--[[ string --]]

-----------------------------------------------------------------
string.sh_format = function(formatstring, ...)
    local n = select("#", ...)
    local args = { ... }
    for i = 1, n do
        local elem = args[i];
        if isnil(elem) or isboolean(elem) or isfunction(elem) or istable(elem) or isthread(elem) or isuserdata(elem) then
            args[i] = tostring(elem)
        end
    end
    return string.format(formatstring, unpack(args, 1, n))
end

-- 返回数组，数组元素为 string
---@return table[]
string.sh_split = function(self, sep)
    sep = sep or ":"
    local fields = {}
    local pattern = string.format("([^%s]+)", sep)
    self:gsub(pattern, function(c) fields[#fields + 1] = c end)
    return fields
end

-- 返回数组，数组元素为 { number, number, string }，内容为每次匹配到的返回值
---@return table[]
string.sh_findall = function(s, pattern, init, plain)
    local matches = {}
    local first = init or 1
    local last = first
    local str
    while first ~= nil do
        first, last, str = string.find(s, pattern, first, plain)
        if first ~= nil then
            table.insert(matches, { first, last, str })
            first = last + 1
        end
    end
    return matches
end

-- 类似 string.find，但是返回的是最后一次匹配的结果
---@return number, number, string
string.sh_rfind = function(s, pattern, init, plain)
    local matches = s:sh_findall(pattern, init, plain)
    if #matches > 0 then
        return unpack(matches[#matches])
    end
    return nil
end

-- 23/10/27
-- 我认为这样应该是不对的（不好评价，按道理很正常），函数定义的时候，不应该执行内容，
-- 如果不得不执行，那相关执行应该在函数第一次调用的时候执行，且只执行一次。
local function define_sh_random_fn()
    local Chars = {}
    for Loop = 0, 255 do
        Chars[Loop + 1] = string.char(Loop)
    end
    local String = table.concat(Chars)

    local Built = { ['.'] = Chars }

    local AddLookup = function(CharSet)
        local Substitute = string.gsub(String, '[^' .. CharSet .. ']', '')
        -- Q: string.gsub(String, '[^' .. CharSet .. ']', '%0') 为什么返回空
        --print("1:",Substitute)
        --print("2:",(string.gsub(String, '[^' .. CharSet .. ']','')))
        local Lookup = {}
        for Loop = 1, string.len(Substitute) do
            Lookup[Loop] = string.sub(Substitute, Loop, Loop)
        end
        Built[CharSet] = Lookup

        return Lookup
    end

    string.sh_random = function(Length, CharSet)
        -- Length (number)
        -- CharSet (string, optional); e.g. %l%d for lower case letters and digits

        CharSet = CharSet or '.'

        if CharSet == '' then
            return ''
        else
            local Result = {}
            local Lookup = Built[CharSet] or AddLookup(CharSet)
            local Range = table.getn(Lookup)

            for Loop = 1, Length do
                Result[Loop] = Lookup[math.random(1, Range)]
            end

            return table.concat(Result)
        end
    end
end

define_sh_random_fn()

local old_sh_random = string.sh_random
string.sh_random = function(Length, CharSet) return old_sh_random(Length, CharSet) end

--END--

--[[ table --]]

-----------------------------------------------------------------
-- If `value` is a nil, the result is the count of all no nil value in the table.
-- 如果 value 非空，返回的结果是表中与 value 相等的键值的数量
---@return number
table.sh_count = function(t, value)
    local count = 0
    for k, v in pairs(t) do
        if value == nil or v == value then
            count = count + 1
        end
    end
    return count
end

-- 暂且搁置：这边暂时不能随便调用，因为用到了 global
table.sh_set_field = function(Table, Name, Value)
    if true then
        error("illegally called table.sh_setfield")
    end

    -- Table (table, optional); default is _G
    -- Name (string); name of the variable--e.g. A.B.C ensures the tables A
    --   and A.B and sets A.B.C to <Value>.
    --   Using single dots at the end inserts the value in the last position
    --   of the array--e.g. A. ensures table A and sets A[table.getn(A)]
    --   to <Value>.  Multiple dots are interpreted as a string--e.g. A..B.
    --   ensures the table A..B.
    -- Value (any)
    -- Compatible with Lua 5.0 and 5.1

    if type(Table) ~= 'table' then
        Table, Name, Value = _G, Table, Name
    end

    local Concat, Key = false, ''

    string.gsub(Name, '([^%.]+)(%.*)',
            function(Word, Delimiter)
                if Delimiter == '.' then
                    if Concat then
                        Word = Key .. Word
                        Concat, Key = false, ''
                    end
                    if Table == _G then
                        -- using strict.lua have to declare global before using it
                        if global then
                            global(Word)
                        end
                    end
                    if type(Table[Word]) ~= 'table' then
                        Table[Word] = {}
                    end
                    Table = Table[Word]
                else
                    Key = Key .. Word .. Delimiter
                    Concat = true
                end
            end
    )

    if Key == '' then
        Table[#Table + 1] = Value
    else
        Table[Key] = Value
    end

end

-- 暂且搁置：这个应该是 Don't Starve together 底层实现的
table.sh_get_field = function(Table, Name)
    if true then
        error("illegally called table.sh_get_field, because string.gfind function is nonexistent.")
    end

    -- Access a value in a table using a string
    -- table.getfield(A,"A.b.c.foo.bar")

    if type(Table) ~= 'table' then
        Table, Name = _G, Table
    end

    for w in string.gfind(Name, "[%w_]+") do
        Table = Table[w]
        if Table == nil then
            return nil
        end
    end
    return Table
end

table.sh_type_checked_get_field = function(Table, Type, ...)
    if type(Table) ~= "table" then return end

    local Names = { ... }
    local Names_Count = #Names
    for i, Name in ipairs(Names) do
        if i == Names_Count then
            if Type == nil or type(Table[Name]) == Type then
                return Table[Name]
            end
            return
        else
            if type(Table[Name]) == "table" then
                Table = Table[Name]
            else
                return
            end
        end
    end
end

---@param Name any
table.sh_find_field = function(Table, Name)
    local indx = ""

    for i, v in pairs(Table) do
        if i == Name then
            return i
        end
        if type(v) == "table" then
            indx = table.sh_find_field(v, Name)
            if indx then
                return i .. "." .. indx
            end
        end
    end
    return nil
end

---@param Names string|table[]
---@param indx number
table.sh_find_path = function(Table, Names, indx)
    local path = ""
    indx = indx or 1
    if type(Names) == "string" then
        Names = { Names }
        --ShiHaoEnv.PrintTableShadow(Names)
    end

    for i, v in pairs(Table) do
        if i == Names[indx] then
            if indx == #Names then
                return i
            elseif type(v) == "table" then
                path = table.sh_find_path(v, Names, indx + 1)
                if path then
                    return i .. "." .. path
                else
                    return nil
                end
            end
        end
        if type(v) == "table" then
            path = table.sh_find_path(v, Names, indx)
            if path then
                return i .. "." .. path
            end
        end
    end
    return nil
end

table.sh_keys_are_identical = function(a, b)
    for k, _ in pairs(a) do
        if b[k] == nil then
            return false
        end
    end
    for k, _ in pairs(b) do
        if a[k] == nil then
            return false
        end
    end
    return true
end
--END--

function ShiHaoEnv.PrintTableShadow(t)
    local buffer = { "{\n" }
    for i, v in pairs(t) do
        if v ~= nil then
            if isnumber(i) then
                if isstring(v) then
                    table.insert(buffer, string.sh_format("    [%d] = %q,\n", i, v))
                else
                    table.insert(buffer, string.sh_format("    [%d] = %s,\n", i, v))
                end
            end
        end
    end
    for i, v in pairs(t) do
        if v ~= nil then
            if isstring(i) then
                if isstring(v) then
                    table.insert(buffer, string.sh_format("    [%q] = %q,\n", i, v))
                else
                    table.insert(buffer, string.sh_format("    [%q] = %s,\n", i, v))
                end
            elseif isboolean(i) or istable(i) or isfunction(i) or isthread(i) or isuserdata(i) then
                if isstring(v) then
                    table.insert(buffer, string.sh_format("    [%s] = %q,\n", i, v))
                else
                    table.insert(buffer, string.sh_format("    [%s] = %s,\n", i, v))
                end
            end
        end
    end
    if #buffer > 1 then
        local last = buffer[#buffer]
        buffer[#buffer] = string.sub(last, 1, #last - 2) .. "\n"
    end
    table.insert(buffer, "}")
    print(table.concat(buffer))
end

-- 往里面多打印一层表
function ShiHaoEnv.PrintTableDeep(t, only_return)
    -- only_return added in 23/11/01, just for test
    local base = _G
    if base.type(t) ~= "table" then
        print(string.format("Warning: invalid #1 param, expected type 'table'."))
        return
    end
    local buffer = { "{\n" }
    local block = string.rep(" ", 4)
    local dblock = string.rep(" ", 8)
    if only_return then
        block = ""
        dblock = ""
    end
    for i, v in pairs(t) do
        if v ~= nil then
            local function print_table(t, i)
                if isnumber(i) then
                    table.insert(buffer, string.sh_format(block .. "[%d] = {\n", i))
                elseif isstring(i) then
                    table.insert(buffer, string.sh_format(block .. "[%q] = {\n", i))
                elseif istable(i) or isboolean(i) or isfunction(i) or isthread(i) or isuserdata(i) then
                    table.insert(buffer, string.sh_format(block .. "[%s] = {\n", i))
                end

                for i1, v1 in pairs(t) do
                    if isnumber(i1) then
                        if isstring(v1) then
                            table.insert(buffer, string.sh_format(dblock .. "[%d] = %q,\n", i1, v1))
                        else
                            table.insert(buffer, string.sh_format(dblock .. "[%d] = %s,\n", i1, v1))
                        end
                    elseif isstring(i1) then
                        if isstring(v1) then
                            table.insert(buffer, string.sh_format(dblock .. "[%q] = %q,\n", i1, v1))
                        else
                            table.insert(buffer, string.sh_format(dblock .. "[%q] = %s,\n", i1, v1))
                        end
                    elseif istable(i1) or isboolean(i1) or isfunction(i1) or isthread(i1) or isuserdata(i1) then
                        if isstring(v1) then
                            table.insert(buffer, string.sh_format(dblock .. "[%s] = %q,\n", i1, v1))
                        else
                            table.insert(buffer, string.sh_format(dblock .. "[%s] = %s,\n", i1, v1))
                        end
                    end
                end
                if #buffer > 1 then
                    local last = buffer[#buffer]
                    buffer[#buffer] = string.sub(last, 1, #last - 2) .. "\n"
                end
                table.insert(buffer, block .. "},\n")
            end

            if istable(v) then
                print_table(v, i)
            else
                if isnumber(i) then
                    if isstring(v) then
                        table.insert(buffer, string.sh_format(block .. "[%d] = %q,\n", i, v))
                    else
                        table.insert(buffer, string.sh_format(block .. "[%d] = %s,\n", i, v))
                    end
                elseif isstring(i) then
                    if isstring(v) then
                        table.insert(buffer, string.sh_format(block .. "[%q] = %q,\n", i, v))
                    else
                        table.insert(buffer, string.sh_format(block .. "[%q] = %s,\n", i, v))
                    end
                elseif istable(i) or isboolean(i) or isfunction(i) or isthread(i) or isuserdata(i) then
                    if isstring(v) then
                        table.insert(buffer, string.sh_format(block .. "[%s] = %q,\n", i, v))
                    else
                        table.insert(buffer, string.sh_format(block .. "[%s] = %s,\n", i, v))
                    end
                end
            end
        end
    end
    if #buffer > 1 then
        local last = buffer[#buffer]
        buffer[#buffer] = string.sub(last, 1, #last - 2) .. "\n"
    end
    table.insert(buffer, "}")
    if only_return then
        for i, v in ipairs(buffer) do
            buffer[i] = string.gsub(v, "\n", "")
        end
    end
    local out_text = table.concat(buffer, "")
    if not only_return then
        print(out_text)
    end
    return only_return and out_text or nil
end

function ShiHaoEnv.PrintFuncAllUpValuesName(fn)
    local upvalues = { "{ " }

    local up = 1
    while true do
        local name, value = debug.getupvalue(fn, up)
        if not name then
            break
        end
        table.insert(upvalues, string.sh_format("%s,", name))
        up = up + 1
    end

    --ShiHaoEnv.PrintTableShadow(upvalues)
    if #upvalues > 1 then
        local last = upvalues[#upvalues]
        upvalues[#upvalues] = string.sub(last, 1, #last - 1)
    end
    table.insert(upvalues, " }")
    print(table.concat(upvalues))
end

-- 此处是直接从 Don't Starve together 源码（util.lua）里直接复制的，甚至都没仔细看看
-- 有空挑点有用的看看吧
require("lib.shlib.util_dst")