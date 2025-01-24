-- TODO: insepect 很值得学习一下，运用了 Lua 的高级知识，强的可怕。
local insepect = require("moreitems.lib.thirdparty.inspect.inspect")

local base = require("moreitems.lib.shihao.base")
local _shihao_shared = require("moreitems.lib.shihao.__shared__")

local __main__ = select("#", ...) == 0

local module = {}
local static = { switch = true }

local function _is_disabled()
    return static.switch == false
end

local function _get_case_str(case)
    if base.is_table(case) then
        return " case: " .. insepect.inspect(case, { newline = "" })
    end
    return ""
end

function module.on()
    static.switch = true
end

function module.off()
    static.switch = false
end

---验证两个数组是否相等（元素相同且顺序一致）
---@overload fun(expected:table[], actual:table[])
function module.assert_array_equals(expected, actual, case)
    if _is_disabled() then return end

    if not base.is_table(expected) or not base.is_table(actual) then
        error("The expected and actual arguments must be table type.")
    end

    local equal, index = _shihao_shared.array_equals(expected, actual)
    if equal then
        return
    end

    error(base.string_format("AssertionFailedError: Message ==> Array contents differ at index `{{index}}`, expected: `{{expected}}` but was: `{{actual}}`. {{case_str}}", {
        index = index,
        expected = insepect.inspect(expected, { newline = "" }),
        actual = insepect.inspect(actual, { newline = "" }),
        case_str = _get_case_str(case)
    }), 2)
end

---@param expected string
---@param actual string
function module.assert_string_equals(expected, actual)
    if _is_disabled() then return end

    if not base.is_string(expected) or not base.is_string(actual) then
        error("The expected and actual arguments must be string type.")
    end

    if expected == actual then
        return
    end
    error(base.string_format("AssertionFailedError: Message ==> expected: `{{expected}}` but was: `{{actual}}`.", {
        expected = expected,
        actual = actual,
    }), 2)
end

---验证条件是否为 true
---@overload fun(condition:boolean)
function module.assert_true(condition, case)
    if _is_disabled() then return end

    if condition == true then
        return
    end
    error("AssertionFailedError: Message ==> Expected condition to be true, but was false." .. _get_case_str(case), 2)
end

---验证条件是否为 false
---@overload fun(condition:boolean)
function module.assert_false(condition, case)
    if _is_disabled() then return end

    if condition == false then
        return
    end
    error("AssertionFailedError: Message ==> Expected condition to be false, but was true." .. _get_case_str(case), 2)
end

---验证值是否为 nil
---@overload fun(value:any)
function module.assert_nil(value, case)
    if _is_disabled() then return end

    if value == nil then
        return
    end
    error("Message ==> Expected value to be null, but was: " .. tostring(value) .. "." .. _get_case_str(case), 2)
end

---验证值是否不为 nil
---@overload fun(value:any)
function module.assert_not_nil(value, case)
    if _is_disabled() then return end

    if value ~= nil then
        return
    end
    error("AssertionFailedError: Message ==> Expected value to not be null." .. _get_case_str(case), 2)
end


-- 这会导致 error 不提示出错位置！有问题！
--local function _wrap_assert_functions()
--    for k, v in pairs(module) do
--        if base.is_string(k) and base.is_function(v) and k:sub(1, 7) == "assert_" then
--            module[k] = function(...)
--                if _is_disabled() then
--                    return
--                end
--                return v(...)
--            end
--        end
--    end
--end

--_wrap_assert_functions()

if __main__ then
    local function error_print(message)
        io.stderr:write(message, "\n")
    end

    -- 2025-01-18：此处多个 xpcall 是为了单独测试

    --[[ on | off ]]
    -- 如果失效了，则会报错。
    module.off()
    xpcall(function()
        module.assert_true(false)
    end, error_print)
    module.on()

    --[[ assert_array_equals ]]
    xpcall(function()
        local test_cases = {
            { { 1, 2, 3, 4, 5 }, { 1, 2, 3, 4, 5 } },
            { { 1, nil, 3, nil, 5 }, { 1, nil, 3, nil, 5 }, }
        }
        for _, case in ipairs(test_cases) do
            module.assert_array_equals(case[1], case[2], case)
        end
    end, error_print)

    --[[ assert_true ]]
    xpcall(function()
        module.assert_true(true)
    end, error_print)

    --[[ assert_false ]]
    xpcall(function()
        module.assert_false(false)
    end, error_print)

    --[[ assert_nil ]]
    xpcall(function()
        module.assert_nil(nil)
    end, error_print)

    --[[ assert_not_nil ]]
    xpcall(function()
        module.assert_not_nil(1)
    end, error_print)
end

return module
