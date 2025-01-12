---
--- DateTime: 2025/1/7 10:39
---

-- 放入 __shared__.lua 中的代码绝对不会依赖同级文件和子目录文件

-- TODO: insepect 很值得学习一下，运用了 Lua 的高级知识，强的可怕。
local insepect = require("moreitems.lib.thirdparty.inspect.inspect")

local base = require("moreitems.lib.shihao.base")
local settings = require("moreitems.settings")

local function _check_args_for_array_equals(array1, array2)
    -- 突然发现总是要校验参数类型好难受，我记得有个编程规范是相信输入是正确的？
    -- 校验参数类型在静态语言不需要，动态语言如果不校验，会导致 bug 和错误发生点相隔太远
end

local function array_equals(array1, array2)
    _check_args_for_array_equals(array1, array2)

    local len1 = table.maxn(array1)
    local len2 = table.maxn(array2)

    if len1 ~= len2 then
        return false
    end

    for i = 1, len1 do
        if array1[i] ~= array2[i] then
            return false, i
        end
    end

    return true
end

local function _assertion(debug_flag)
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
    function module.assert_array_equals(expected, actual, case)
        if _is_disabled() then
            return
        end

        if not base.is_table(expected) or not base.is_table(actual) then
            error("The expected and actual arguments must be table type.")
        end

        local equal, index = array_equals(expected, actual)
        if equal then
            return
        end
        error(base.string_format("AssertionFailedError: Message ==> Array contents differ at index {{index}}, expected: {{expected}} but was: {{actual}}. {{case_str}}", {
            index = index,
            expected = insepect.inspect(expected, { newline = "" }),
            actual = insepect.inspect(actual, { newline = "" }),
            case_str = _get_case_str(case)
        }), 2)
    end

    ---验证条件是否为 true
    function module.assert_true(condition, case)
        if _is_disabled() then
            return
        end

        if condition == true then
            return
        end
        error("AssertionFailedError: Message ==> Expected condition to be true, but was false." .. _get_case_str(case), 2)
    end

    ---验证条件是否为 false
    function module.assert_false(condition, case)
        if _is_disabled() then
            return
        end

        if condition == false then
            return
        end
        error("AssertionFailedError: Message ==> Expected condition to be false, but was true." .. _get_case_str(case), 2)
    end

    ---验证值是否为 nil
    function module.assert_nil(value, case)
        if _is_disabled() then
            return
        end

        if value == nil then
            return
        end
        error("Message ==> Expected value to be null, but was: " .. tostring(value) .. "." .. _get_case_str(case), 2)
    end

    ---验证值是否不为 nil
    function module.assert_not_nil(value, case)
        if _is_disabled() then
            return
        end

        if value ~= nil then
            return
        end
        error("AssertionFailedError: Message ==> Expected value to not be null." .. _get_case_str(case), 2)
    end

    if debug_flag then
        --[[ assert_array_equals ]]
        xpcall(function()
            local test_cases = {
                { { 1, 2, 3, 4, 5 }, { 1, 2, 3, 4, 5 } },
                { { 1, nil, 3, nil, 5 }, { 1, nil, 3, nil, 5 }, }
            }
            for _, case in ipairs(test_cases) do
                module.assert_array_equals(case[1], case[2], case)
            end
        end, print)

        --[[ assert_true ]]
        xpcall(function()
            module.assert_true(true)
        end, print)

        --[[ assert_false ]]
        xpcall(function()
            module.assert_false(false)
        end, print)

        --[[ assert_nil ]]
        xpcall(function()
            module.assert_nil(nil)
        end, print)

        --[[ assert_not_nil ]]
        xpcall(function()
            module.assert_not_nil(1)
        end, print)
    end

    return module
end

-- TODO: 这个 _assertion 这样还是有问题的，按道理应该可以将其再往上层移动一下
-- 2025-01-11：可以将其同样放入 base 中？暂且放在此处吧，未来我还能看到我这段代码。
return {
    -- NOTE: 此处的模块放入 base.assertion 中其实挺好的。base.lua 一个文件还是太少了。built-in 多个文件比较好。【慢慢完善吧，重构+设计】
    assertion = _assertion(settings.TEST_ENABLED),

    log = base.log, -- 运用了重构，由于 log 已经被广泛使用过了，因此选择在这里设置委托

    array_equals = array_equals,
}
