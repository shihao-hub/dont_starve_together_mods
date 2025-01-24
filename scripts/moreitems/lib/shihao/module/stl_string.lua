---
--- DateTime: 2025/1/6 17:18
---


local inspect = require("moreitems.lib.thirdparty.inspect.inspect")

local base = require("moreitems.lib.shihao.base")
local assertion = require("moreitems.lib.shihao.assertion")



-- NOTE: `__shared__.lua`
-- when one file needs to use another file that belongs to the same directory,
-- please move the content that is being used to the `__shared__.lua` file,
-- and access it through `shared`.
local shared = require("moreitems.lib.shihao.module.__shared__")

-- 注意，此处的函数第一个参数必定都是 string
local module = { unittests = {} }

function module.unittests.split()
    local str = "123456"
    assertion.assert_true(inspect(module.split(str, "")) == "{ \"1\", \"2\", \"3\", \"4\", \"5\", \"6\" }")
    assertion.assert_array_equals(module.split("1;2;3;4;5;", ";"), { "1", "2", "3", "4", "5" })
end

---@return table[]
function module.split(str, sep)
    -- 如果 sep 为空字符串，则返回字符列表
    if sep == "" then
        local res = {}
        for i = 1, #str do
            res[i] = string.sub(str, i, i)
        end
        return res
    end

    sep = sep or ":"

    local fields = {}
    local pattern = string.format("([^%s]+)", sep)
    string.gsub(str, pattern, function(c)
        -- fields 可以理解为 输出参数 或者是 C 语言中的指针参数
        fields[#fields + 1] = c
    end)
    return fields
end

function module.unittests.startswith()
    local str, prefix = "123456789", "123456"
    assertion.assert_true(module.startswith(str, prefix))
end

function module.startswith(str, prefix)
    return string.sub(str, 1, string.len(prefix)) == prefix
end

function module.unittests.endswith()
    local test_cases = {
        { "789", "89" },
        --{ "9", "89" },
    }
    for _, case in ipairs(test_cases) do
        assertion.assert_true(module.endswith(unpack(case, 1, table.maxn(case))), case)
    end
end

function module.endswith(str, suffix)
    return string.sub(str, -string.len(suffix), -1) == suffix
end

function module.unittests.strip()
    assertion.assert_true(module.strip("  123  ") == "123")
    assertion.assert_true(module.strip("123---456", "123456") == "---")
end

---默认移除空白字符，但你可以传入一个字符串，指定要移除的字符集。
---@overload fun(str:string)
function module.strip(str, chars)
    if chars then
        -- NOTE: Lua 的模式匹配值得深入学习，在我的记忆中，它并不是正则表达式，而是自己实现的，代码量不多，功能足够强大
        local pattern = base.f_string("^[{{chars}}]*(.-)[{{chars}}]*$", { chars = chars })
        return str:gsub(pattern, "%1")
    end
    return str:gsub("^%s*(.-)%s*$", "%1")
end

function module.unittests.is_integer()
    assertion.assert_true(module.is_integer("12345") == true)
    assertion.assert_true(module.is_integer("12345a") == false)
    assertion.assert_true(module.is_integer("aaa") == false)
    assertion.assert_true(module.is_integer("12345.") == false)
    assertion.assert_true(module.is_integer("12345.0") == false)
    assertion.assert_true(module.is_integer("12345.0a") == false)
end

---@param str string
---@return boolean, nil|number
function module.is_integer(str)
    if str:find("%.") then
        return false
    end
    -- 为什么 tonumber 居然返回 nil，而不是直接报错
    local res = tonumber(str)
    if not res then
        return false
    end
    return true, res
end

function module.unittests.is_float()
    assertion.assert_true(module.is_float("12345") == false)
    assertion.assert_true(module.is_float("12345a") == false)
    assertion.assert_true(module.is_float("12345.") == false)
    assertion.assert_true(module.is_float("12345.1") == true)
end

---@param str string
function module.is_float(str)
    if not str:find("%.") then
        return false
    end
    local res = tonumber(str)
    if not res or not tostring(res):find("%.") then
        return false
    end
    return true, res
end

if select("#", ...) == 0 then
    local unittest = require("moreitems.lib.shihao.module.unittest")

    unittest.run_unittests(module.unittests)

    -- 在 Lua 5.1 及之前的版本中，`table.maxn` 函数确实可以用来获取一个表的最大整数索引
    --print(table.maxn({ nil, nil, nil, 1, 2, 3, nil, 5, nil, 7, nil, nil, 10, nil }))

    print(module.is_float("123."))

    --xpcall(function()
    --    assertion.assert_true(module.is_float("12345.1") == false)
    --end,function(msg)
    --    print(msg)
    --end)

end

return module
