---
--- @author zsh in 2023/2/15 23:54
---


local function GetLocalFn(fn, fn_name)
    local up = 1; -- level
    local MAX_LEVEL = 20;
    for i = 1, math.huge do
        local name, value = debug.getupvalue(fn, up);
        if name and name == fn_name then
            if value and type(value) == "function" then
                return value, up;
            end
            break ;
        end
        up = up + 1;
        if up > MAX_LEVEL then
            break ;
        end
    end
end

local function GetLocalValue(fn, value_name)
    local up = 1;
    local MAX_LEVEL = 20;
    for i = 1, math.huge do
        local name, value = debug.getupvalue(fn, up);
        if name and name == value_name and value then
            return value, up;
        end
        up = up + 1;
        if up > MAX_LEVEL then
            break ;
        end
    end
end

-- 先调用 GetLocalValue 找到后再调用这个函数！！！
local function SetLocalValue(fn, up, value)
    debug.setupvalue(fn, up, value);
end

local v1 = "v1";
local v2 = "v1";
local v3 = "v1";
local f1 = function()
    print("f1");
end

local function Main()
    local a = v1;
    local b = v2;
    local c = v3;
end

local f1_upvalue, up_f1 = GetLocalFn(Main, "f1");
local v1_upvalue, up_v1 = GetLocalValue(Main, "v1");
if v1_upvalue and up_v1 then
    print("v1_upvalue: " .. tostring(v1_upvalue));
    print("up_v1: " .. tostring(up_v1));
    SetLocalValue(Main,up_v1,"v1_new");
end
print("v1: "..tostring(v1));