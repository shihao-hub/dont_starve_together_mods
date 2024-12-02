---
--- @author zsh in 2023/4/30 1:11
---

--local res = "123456789"
--local res_remake = string.sub(res, 1, 20);
--print(res_remake);
--print(#res_remake);

function printSafe(...)
    local args = { ... };
    local res, block = "", "  ";
    for i = 1, table.maxn(args) do
        res = res .. block .. tostring(args[i]);
    end
    print(string.sub(res, #block + 1, 256));
    return res;
end

local t1, t2, t3, t4, t5, t6, t7 = nil, true, 1, "a", function()

end, coroutine.create(function()

end), {};

printSafe(t1, t2, t3, t4, t5, t6, t7);