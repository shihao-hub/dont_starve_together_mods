---
--- @author zsh in 2023/4/28 11:09
---

function Print(...)
    local args = { ... };
    print(table.maxn(args));
    for i = 1, table.maxn(args) do
        args[i] = tostring(args[i]);
    end
    print(unpack(args, 1, table.maxn(args)));
end

print(Print, Print, nil, Print);
Print(Print, Print, nil, Print);
print();

function Browse(tab, ...)
    local args = { ... };
    for _, v in ipairs(args) do
        tab = tab[v];
        if v == "components" then
            --tab["eater"] = {};
        end
    end
    return tab;
end

local inst = {
    components = {
        eater = {
            number = 0;
        }
    }
}

print(inst.components.eater);
print(Browse(inst, "components", "eater"));
--print(inst.components.eater);

