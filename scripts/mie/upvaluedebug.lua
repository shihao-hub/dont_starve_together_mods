---
--- @author zsh in 2023/2/9 21:40
---

---@param fn function
---@param fn_name string
---@return function
local function GetLocalValue(fn, fn_name, isfn, istab)
    local level = 1;
    local MAX_LEVEL = 20;
    for i = 1, math.huge do
        local name, value = debug.getupvalue(fn, level);
        --print("", tostring(name), tostring(value));
        if name and name == fn_name then
            if value then
                if isfn and type(value) == "function" then
                    return value;
                elseif istab and type(value) == "table" then
                    return value;
                end
            end
            break ;
        end
        level = level + 1;
        if level > MAX_LEVEL then
            break ;
        end
    end
end

return {
    GetLocalValue = GetLocalValue;
}