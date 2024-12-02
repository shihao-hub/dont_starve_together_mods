---
--- @author zsh in 2023/4/18 20:29
---

--local path = "OnSpawned";
--print(path:gmatch("[^%.]+"));
--
--for value in path:gmatch("[^%.]+") do
--    print(value);
--end

--local string = "";
--print(string.upper("xxxx"));
--local DEFAULT_ATTACK_DELAY = 335;
--print(string.format("%s", DEFAULT_ATTACK_DELAY));

local _print = print;
local function print0(...)
    local args = { ... };
    local cnt_tab, MAX = {}, 3;
    local new_args = {};
    local length = 0;
    for i = 1, math.huge do
        length = i;
        table.insert(new_args, tostring(args[i]));
        if args[i] == nil then
            cnt_tab[tostring(i)] = true;
        end
        i = i + 1;
        local keys = {};
        for k, v in pairs(cnt_tab) do
            if v == true then
                table.insert(keys, tonumber(k));
            end
        end
        local first_term = keys[1];
        for _, v in ipairs(keys) do
            v = v - (first_term - 1);
        end
        local cnt, jump_out = 0, nil;
        for index, v in ipairs(keys) do
            if index ~= v then
                cnt = cnt + 1;
            end
            if cnt >= MAX then
                jump_out = true;
            end
        end
        if jump_out then
            break ;
        end
    end
    length = length - MAX;
    _print(...);
end

local modname = "workshop-1001";
local i, j = string.find(modname, "workshop%-");
print(tostring(i), tostring(j));
if i and j then
    print(string.sub(modname, i, j));
end