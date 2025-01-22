---
--- DateTime: 2025/1/7 10:35
---

-- 同级文件间的函数共享区，因此该文件将不允许依赖除了 built-in 外的其他文件/函数
-- 一般来说，这个共享区应该不会太大，对我而言，这个架构应该够了！
-- 【架构？架构！】


local module = {}

local function _check_args_for_array_equals(array1, array2)
    -- 突然发现总是要校验参数类型好难受，我记得有个编程规范是相信输入是正确的？
    -- 校验参数类型在静态语言不需要，动态语言如果不校验，会导致 bug 和错误发生点相隔太远
end

---用 table.maxn 判断两个 table。如果长度不一样，那就不相等，如果一样，那就遍历比较。
---@return boolean,number 第二个返回值在不相等时，返回未匹配的那个 index。
function module.array_equals(array1, array2)
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

return module
