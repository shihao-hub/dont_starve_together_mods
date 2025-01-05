---
--- @author zsh in 2023/4/18 20:40
---


local UpvalueUtil = {};

local function GetUpvalueHelper(fn_reference, value_name)
    local level = 1;
    while true do
        local name, value = debug.getupvalue(fn_reference, level);
        if name == nil then
            return ;
        end
        if name == value_name then
            return value, level;
        end
        level = level + 1;
    end
end

---返回 start_fn 中的嵌套式的值。
---举例：path = f1.f2.tab3，那么最终返回值的第一个就是 tab3。但是如果是
function UpvalueUtil.GetUpvalue(start_fn, path)
    if type(start_fn) ~= "function" then
        return ;
    end
    local scope_fn, upvalue, up;
    local pre_fn, pre_value_name = start_fn, nil;
    for value_name in path:gmatch("[^%.]+") do
        if type(pre_fn) ~= "function" then
            print("Warning: scope_fn isn't a function, it is impossible!" .. " scope_fn's name is `" .. tostring(pre_value_name) .. "`.");
            return ;
        end
        pre_value_name = value_name;
        scope_fn = pre_fn;
        upvalue, up = GetUpvalueHelper(scope_fn, value_name);
        pre_fn = upvalue;
    end
    if not up then
        print("Warning: Can't find `" .. path .. "` from `" .. tostring(start_fn) .. "`.");
    end
    return upvalue, up, scope_fn;
end

function UpvalueUtil.SetUpvalue(start_fn, path, new_upvalue)
    local upvalue, upvalue_up, scope_fn = UpvalueUtil.GetUpvalue(start_fn, path);
    if upvalue_up and scope_fn then
        debug.setupvalue(scope_fn, upvalue_up, new_upvalue);
    end
end

return UpvalueUtil;