---
--- DateTime: 2025/1/6 16:27
---

local base = require("moreitems.lib.shihao.base")

local _shared = require("moreitems.lib.shihao.module.__shared__")

-- 注意，此处的函数第一个参数必定都是 table
local module = {}

function module.contains_key(t, key)
    for i, v in pairs(t) do
        if i == key then
            return true
        end
    end
    return false
end

function module.contains_value(t, value)
    for i, v in pairs(t) do
        if v == value then
            return true
        end
    end
    return false
end

---@overload fun(t:table)
function module.keys(t, sorted)
    local res = {}
    for k, _ in pairs(t) do
        assert(k ~= nil)
        table.insert(res, k)
    end
    if sorted then
        ---让参数可以统一被处理
        local function normalize_parameter(arg)
            if base.is_number(arg) or base.is_function(arg) then
                return arg
            end
            return tostring(arg)
        end

        table.sort(res, function(o1, o2)
            o1 = normalize_parameter(o1)
            o2 = normalize_parameter(o2)
            return o1 < o2
        end)
    end
    return res
end

---类似 Python 的 enumerate，返回 index 和 value，或者可以视为进阶版的 ipairs，不会因为 nil 跳过
function module.enumerate(t)
    -- NOTE: 我建议，大部分情况下，table 的键都不应该使用 number 类型，number 类型理当视为数组！
    -- NOTE: 虽然联想 Java，Map<Integer, Object> 的情况非常多...
    local index = 1
    local max_len = table.maxn(t)
    return function()
        if index > max_len then
            return nil
        end
        local value = t[index]
        index = index + 1
        return index - 1, value
    end
end

---是稀疏数组
function module.is_sparse_array(t)
    local max_len = table.maxn(t)
    for i = 1, max_len do
        if t[i] == nil then
            return true
        end
    end
    return false
end

---用 table.maxn 判断两个 table。如果长度不一样，那就不相等，如果一样，那就遍历比较。
---@return boolean,number 第二个返回值在不相等时，返回未匹配的那个 index。
function module.array_equals(array1, array2)
    return _shared.array_equals(array1, array2)
end

function module.reverse(t)
    local size = table.maxn(t)
    local res = {}

    for i = 1, size do
        res[size - i + 1] = t[i]
    end

    return res
end

function module.invert(t)
    local invt = {}
    for k, v in pairs(t) do
        invt[v] = k
    end
    return invt
end

---如果 value 等于 nil，该函数的作用为统计可以被 pairs 遍历到的所有键值对的数量。
---
---否则就是统计值为 value 的键值对的数量
---
---但是我有个问题，这种靠参数来决定函数作用的编码风格是及其不建议的。哪怕抽成两个函数，也比这样好！
function module.count(t, value)
    local res = 0
    for k, v in pairs(t) do
        if value == nil or v == value then
            res = res + 1
        end
    end
    return res
end

if select("#", ...) == 0 then
    local inspect = require("moreitems.lib.thirdparty.inspect.inspect")
    local assertion = require("moreitems.lib.shihao.module.assertion")

    local test_z = function()
        print(module.is_sparse_array({ 1, 2, 3, nil, 5 }))
        print(module.is_sparse_array({ 1, 2, 3, 4, 5 }))
        for i, v in module.enumerate({ 1, nil, 3, nil, 5, nil }) do
            print(i, v)
        end
    end

    --test_z()

    print(inspect(module.keys({

    })))
end

return module
