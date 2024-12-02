---
--- Created by zsh
--- DateTime: 2023/11/3 3:38
---

require("new_scripts.mod_a.class")

-- 此处我命名为 morel_Module，但是 lua for windows 里面似乎就是用 . 作为类来使用的
--[[
-- 举例
-- Meta methods for lists
metatable = {
  -- list .. table = list.concat
  __concat = list.concat, -- 尤其注意这个，运算符重载
  -- list == list retains its referential meaning
  -- list < list = list.compare returns < 0
  __lt = function (l, m) return compare (l, m) < 0 end,
  -- list <= list = list.compare returns <= 0
  __le = function (l, m) return compare (l, m) <= 0 end,
  __append = list.append,
}

-- List constructor.
function new (l)
  return setmetatable (l, metatable)
end
]]

local list = morel_Module()

-- 我认为直接 table.getn(li) == #li 是不是就行了？还是说这两个其实是等价关系
function list.is_array(const_li)
    local li = const_li
    return morel_is_array(li)
end

-- In order not to modify li
-- Why?
function list.append(const_li, x)
    local li = const_li
    local res = { unpack(li) }
    table.insert(res, x)
    return res
end

function list.concat(...)
    local r = {}
    for _, l in ipairs({ ... }) do
        for _, v in ipairs(l) do
            table.insert(r, v)
        end
    end
    return r
end

function list.rep(const_li)
    local li = const_li
    return list.concat(li)
end

function list.reverse(cli)
    local r = {}
    for v in list.iter_values_reverse(cli) do
        table.insert(r, v)
    end
    return r
end

function list.sub_list(const_li, from, to)
    local li = const_li
    local len = #li
    local sub = {}
    if from and from < 0 then
        from = from + len + 1
    end
    if to and to < 0 then
        to = to + len + 1
    end
    if from and to then
        for i = from, to do
            table.insert(sub, li[i])
        end
        return sub
    elseif from and not to then
        to = #li
        return list.sub_list(li, from, to)
    elseif not from and not to then
        from = 1
        to = #li
        return list.sub_list(li, from, to)
    else
        error(morel_get_call_on_position())
    end
end

list.slice = list.sub_list

---@param filter_fn function return boolean
function list.filter(const_li, filter_fn)
    local li = const_li
    return morel_LfW_global.filter(filter_fn, list.iter_values, li)
end

function list.ipairs(const_li)
    local li = const_li
    --[[
        -- 不清楚这个的执行过程，但是有以下几种例子：
        return function(l,i) -- 第一次执行的时候 i = 0, l = li
            i = i + 1 -- 此时，i = 1
            if i <= #l then
                return i, l[i] -- 此时返回的第一个参数 i 应该就是下一次迭代的时候的第二个参数 i
            end
        end, li, 0

        local i = 0
        local function iter(...) -- 此处第一个参数就是下面的 111，第二个参数初始的时候是 222，第二次的时候就是 i 了
            --print("--",unpack({...}))
            --print(iter) -- 注意，这个 iter 只创建一次
            i = i + 1
            if i <= #li then
                return i, li[i]
            end
        end
        return iter, 111, 222
    ]]

    -- In this way, don't need to create closure everytime.
    return function(l, i)
        i = i + 1
        if i <= #l then
            return i, l[i]
        end
    end, li, 0

    -- To the contrary, this closure includes i,li
    --local i = 0
    --return function()
    --    i = i + 1
    --    if i <= #li then
    --        return i, li[i]
    --    end
    --end
end

function list.ipairs_reverse(const_list)
    local li = const_list
    return function(l, i)
        i = i + 1
        local len = #l
        if i <= len then
            return i, l[len - i + 1]
        end
    end, li, 0
end

function list.iter_values(const_list)
    local li = const_list
    local i = 0
    return function(l)
        i = i + 1
        if i <= #l then
            return l[i]
        end
    end, li
end

function list.iter_values_reverse(const_list)
    local li = const_list
    local i = #li + 1
    return function(l)
        i = i - 1
        if i >= 1 then
            return l[i]
        end
    end, li
end

return list