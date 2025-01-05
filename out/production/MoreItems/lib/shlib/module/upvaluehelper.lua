---
--- Created by zsh
--- DateTime: 2023/9/28 22:58
---

setfenv(1,_G)
local UpvalueHelper = {}

local function GetUpvalue(fn, val_name)
    local up = 1
    while true do
        local name, value = debug.getupvalue(fn, up);
        if name == nil then
            return
        end
        if name == val_name then
            return value, up
        end
        up = up + 1
    end
end

local function get_whole_path(path, index)
    local cnt = 0
    local len = 0
    for name in path:gmatch("[^%.]+") do
        len = len + string.len(name) + 1
        cnt = cnt + 1
        if index == cnt then
            return string.sub(path, 1, len - 1)
        end
    end
end

---@param path string 格式为 word.word.word，未进行防御式编程以验证该变量的有效性，请用户注意
function UpvalueHelper.GetUpvalue(start_fn, path)
    if type(start_fn) ~= "function" then
        print(string.format("Warning: the first param(%s) is not a function.", tostring(start_fn)))
        return nil
    end
    local names = {}
    for name in path:gmatch("[^%.]+") do
        table.insert(names, name)
    end

    local value, up

    -- 初始参数
    local scope_fn = start_fn
    -- 开始迭代
    for i, name in ipairs(names) do
        value, up = GetUpvalue(scope_fn, name)
        if type(value) == "function" then
            -- 如果是函数，则接着迭代
            scope_fn = value
        else
            if i ~= #names then
                value, up, scope_fn = nil, nil, nil
                print(string.format("Warning: `%s` in the `%s` not is a function.", name, get_whole_path(path, i)))
            end
            break
        end
    end
    return value, up, scope_fn
end

function UpvalueHelper.SetUpvalue(start_fn, path, new_upvalue)
    local value, up, scope_fn = UpvalueHelper.GetUpvalue(start_fn, path)
    if value then
        debug.setupvalue(scope_fn, up, new_upvalue)
    end
end

return UpvalueHelper