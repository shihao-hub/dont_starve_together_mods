---
--- Created by zsh
--- DateTime: 2023/11/3 3:34
---

require("new_scripts.mod_a.class")

local global = morel_Module()

---@param predicate fun predicate (function of one argument returning a boolean)
function global.filter(predicate, iter_values, ...)
    local res = {}
    for v in iter_values(...) do
        if predicate(v) then
            table.insert(res, v)
        end
    end
    return res
end


return global