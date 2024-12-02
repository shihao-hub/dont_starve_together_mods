---
--- Created by zsh
--- DateTime: 2023/11/1 1:39
---

require("new_scripts.mod_a.class")

-- just for memorizing some knowledge
local function is_true(v)
    return v ~= nil or v ~= false
end

local function is_obj(o)
    local o_type = type(o)
    return o_type == "table"
end

local function string_value_of(obj)
    return obj == nil and "nil" or tostring(obj)
end

local function array_len(arr)
    if not morel_is_array(arr) then assert(false, "not is array") end
    return #arr
end

---@class STL_StringBuilder
local StringBuilder = morel_Class(function(self)
    morel_super()
    self:set_type("StringBuilder")

    --self.length = is_true(length) and length or 10 -- Is this needed?
    --self.buffer = { '', '', '', '', '', '', '', '', '', '' } -- initialization early is useful, but I supposed only a little.

    self.buffer = {}
    self.length = 0
end)


--function StringBuilder:new()
--    local instance = StringBuilder()
--    --local mt = getmetatable(instance)
--    ---- 注意，底层代码实现 tostring 这个全局函数的时候，会先检查元表中有没有 __tostring 字段，如果有的话，就执行这个函数
--    --mt.__tostring = function(t)
--    --    return table.concat(t.buffer)
--    --end
--    return instance
--end

function StringBuilder:tostring()
    return table.concat(self.buffer)
end

-- 不应该
--function StringBuilder:__tostring()
--    return table.concat(self.buffer)
--end

function StringBuilder:append(str)
    -- These three lines of code is a imitation of java, ohh~
    -- What I want to say is Java has a lot of function overload to
    -- adapt many types, such as bool, char[], Object, etc.
    -- But Lua does not have these matters, using tostring(obj) can solve
    -- almost all questions.
    --if is_obj(obj) then
    --    obj = string_value_of(obj)
    --end

    -- old implementation
    --local e = tostring(str)
    --table.insert(self.buffer, e)
    --self.length = self.length + string.len(e)
    if str == "" then
        return self
    end

    str = tostring(str)
    local len = string.len(str)
    for i = 1, len do
        table.insert(self.buffer, string.sub(str, i, i))
    end
    self.length = self.length + len

    return self
end

-- 这几个函数实现似乎用数组更方便一点...
-- 特别地，如果只是 26 个字母，那么不可变特性好像没那么好用了（但是不必在意）。
-- 这里说的不可变特性是，Lua 的字符串是不可变的，比如 abc, abc 内存中只有一个 abc
-- fixme: 这里的代码可能有缺陷，未测试，请注意
function StringBuilder:delete(start_pos, end_pos)
    start_pos = self:_negative_pos_convert(start_pos)
    end_pos = self:_negative_pos_convert(end_pos)

    if not (start_pos <= end_pos) then assert(false, "not start_pos <= end_pos") end

    if start_pos and end_pos then
        end_pos = end_pos < self.length and end_pos or self.length
        local i = start_pos
        local j = end_pos
        while i <= end_pos do
            self.buffer[i] = self.buffer[j + 1]
            i = i + 1
            j = j + 1
        end
        while j - 1 <= self.length do
            self.buffer[j] = nil
            j = j + 1
        end
    elseif start_pos and not end_pos then
        return self:delete(start_pos, self.length)
    elseif not start_pos and not end_pos then
        return self:delete(1, self.length)
    end
end

-- todo: I need to sure that what would happen if "[start_pos..end_pos]"'s length is bigger than "str"'s length
--function StringBuilder:replace(start_pos, end_pos, str)
--    start_pos = self:_negative_pos_convert(start_pos)
--    end_pos = self:_negative_pos_convert(end_pos)
--
--    if not start_pos <= end_pos then assert(false, "not start_pos <= end_pos") end
--
--    local cnt = 0
--    for i = start_pos, end_pos do
--
--    end
--end

-- todo
--function StringBuilder:insert(offset, str)
--
--end


-- 这个简单
function StringBuilder:reverse()
    -- old implementation
    --local count = #self.buffer
    --for i = 1, count / 2 do
    --    local tmp = string.reverse(self.buffer[i])
    --    self.buffer[i] = string.reverse(self.buffer[count - i + 1])
    --    self.buffer[count - i + 1] = tmp
    --end

    for i = 1, self.length / 2 do
        local tmp = self.buffer[i]
        self.buffer[i] = self.buffer[self.length - i + 1]
        self.buffer[self.length - i + 1] = tmp
    end
end

-- notice: this is a brute force algorithm
-- Java (seemingly?) does not seem to use kmp to implement the function.
function StringBuilder:index_of(str, from_index)
    if from_index then
        from_index = self:_negative_pos_convert(from_index)
    else
        from_index = 1
    end
    assert(from_index >= 1 and from_index <= self.length, "assert: not (from_index >= 1 and from_index <= self.length)")

    if str and from_index then
        -- notice: brute force
        local len = string.len(str)
        for i = from_index, self.length do
            local old_i = i
            for j = 1, len do
                local c = string.sub(str, j, j)
                --print(self.buffer[i], c)
                if self.buffer[i] ~= c then
                    break
                end
                if j == len then return i - len + 1 end
                i = i + 1
            end
            i = old_i
        end
        return -1
    elseif str and not from_index then
        return self:index_of(str, 1)
    else
        error("overloads as follows: fun(str), fun(str,from_index)")
    end
end

function StringBuilder:last_index_of(str, from_index)
    if from_index then
        from_index = self:_negative_pos_convert(from_index)
    else
        from_index = self.length
    end

    if not (from_index >= 1 and from_index <= self.length) then
        morel_tracked_assert(false, "not (from_index >= 1 and from_index <= self.length)")
    end
    local len = string.len(str)
    if str and from_index then
        --local pre = -1
        --local pos = self:index_of(str)
        --while pos ~= -1 do
        --    pre = pos
        --    if pos >= from_index then
        --        break
        --    end
        --    pos = self:index_of(str, pos + 1)
        --end
        --return pre
        -- 不知道为什么，这种代码我写起来就是很费解。脑子内存太小了？还是说多看别人的代码能解决这个问题？
        -- 真的脑壳疼，感觉脑子根本转不过来弯。应该怎么办呢？
        -- 这里的算法思路：
        -- 0. 注意初始化条件，也就是各变量初始值的确定也是很重要的
        -- 1. 明确每次迭代的目的：找到不同起始时的第一个匹配项
        -- 2. 从头开始查找，直到 pos + len - 1 <= from_index 为止，在结束之前，我需要将上一次的查询结果存起来，然后返回。
        -- 唉，这么简单的东西我的脑子都转不过来，编程不至于如此吧？我真的没天赋吗？还是说代码写少了，看少了。
        -- 首先我觉得我需要明确一点的是：确实要多阅读其他人的代码，至于如何阅读再说吧。反正一定一定要多阅读代码。
        -- TIPS: 下面这短短的代码，我真的觉得脑子里转不过来，不知道怎么描述这个情况，就是没有那种通透感。
        --       到底是什么原因呢？是因为逻辑 -> 机器语言的问题吗。还是说，我的逻辑能力太差了？...
        local pre = -1
        local pos = self:index_of(str)
        while pos ~= -1 and pos + len - 1 <= from_index do
            -- 将结果先存下来
            pre = pos
            pos = self:index_of(str, pos + 1)
        end
        return pre
    elseif str and not from_index then
        return self:last_index_of(str, self.length)
    else
        error("overloads as follows: fun(str), fun(str,from_index)")
    end
end

function StringBuilder:_negative_pos_convert(pos)
    assert(pos ~= nil, "pos shouldn't be equal to nil")
    return pos < 0 and (pos + self.length + 1) or pos
    --return (pos ~= nil and pos < 0) and (pos + self.length + 1) or pos
end

return StringBuilder
