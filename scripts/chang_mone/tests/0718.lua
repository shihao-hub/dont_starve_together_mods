---
--- @author zsh in 2023/7/18 23:24
---

local function test1()
    local items = {
        { index = 3, priority = 3, item = { prefab = "3_3" } },
        { index = 3, priority = 2, item = { prefab = "3_2" } },
        { index = 3, priority = 1, item = { prefab = "3_1" } },
        { index = 2, priority = 4, item = { prefab = "2_4" } },
        { index = 2, priority = 3, item = { prefab = "2_3" } },
    }

    table.sort(items, function(a, b)
        if a.index < b.index then
            return true;
        elseif a.index == b.index then
            if a.priority < b.priority then
                return true;
            elseif a.priority == b.priority then
                return a.item.prefab < b.item.prefab;
            end
        end
        return false;

        --return a.index < b.index or a.priority < b.priority or a.item.prefab < b.item.prefab;
    end)

    for _, v in ipairs(items) do
        print(v.item.prefab)
    end
end
--test1();

local function test2()
    --local state, res = pcall(function()
    --    return 1 / x;
    --end);
    --if not state then
    --    print(res);
    --end
    xpcall(function()
        return 1 / x;
    end, function(msg)
        print(msg);
    end)
end
--test2();

local function test3()
    local msg = "000/111/222.lua:xxxx"
    print(string.find(msg,"/[^/]*.lua.*"));
    print(string.sub(msg,string.find(msg,"/[^/]*.lua.*")));
end
test3();