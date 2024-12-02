---
--- @author zsh in 2023/2/15 15:09
---

local function compare(A, B)
    if #A ~= #B then
        return false;
    end

    local tmpA = {};
    local tmpB = {};
    for _, v in ipairs(A) do
        tmpA[v] = tmpA[v] or 0 + 1;
    end
    for _, v in ipairs(B) do
        tmpB[v] = tmpB[v] or 0 + 1;
    end
    for k, v in pairs(tmpA) do
        if tmpB[k] ~= v then
            return false;
        end
    end
    return true;
end

local A = { "1", "2", "3", "ca" };
local B = { "1", "2", "3", "ca" };

print(compare(A, B));

