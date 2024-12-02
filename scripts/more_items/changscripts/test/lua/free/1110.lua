---
--- @author zsh in 2023/5/3 16:20
---

function null(val)
    return val == nil or type(val) == "nil";
end

function oneOfNull(...)
    local args = { ... };
    for i = 1, table.maxn(args) do
        if null(args[i]) then
            return true;
        end
    end
    return false;
end

function allNull(...)
    local args = { ... };
    for i = 1, table.maxn(args) do
        if not null(args[i]) then
            return false;
        end
    end
    return true;
end

--print(oneOfNull(1, 2, 3, 4, 5, nil));
--print(allNull(nil, nil));

local function getLength(...)
    local len = 0
    for k, v in pairs({ ... }) do
        len = len + 1;
    end
    return len;
end

print(table.maxn({ 1, 2, 3, nil, 4 }));
print(getLength(1, 2, 3, nil, 4));
