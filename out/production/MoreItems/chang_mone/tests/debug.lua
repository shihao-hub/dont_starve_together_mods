---
--- @author zsh in 2023/3/14 9:17
---

--local f2;
--
--local function f1()
--    f2 = function()
--        local info = debug.getinfo(1);
--        if info then
--            for k, v in pairs(info) do
--                print(tostring(k),tostring(v));
--            end
--        end
--    end
--end
--
--f1();
--f2();

print(("workshop-2951068194"):find("workshop%-2951068194"))










do
    return ;
end
local Debug = require("chang_mone.dsts.API").Debug;

local up_fn_1 = function()
    print("up_fn_1");
end
local up_tab_1 = { "up_tab_1" }

local function f1(a, b, c)
    local upfn = up_fn_1;
    local uptab = up_tab_1;
end

print("---------------------------");
local up_fn = Debug.GetUpvalueFn(f1, "up_fn_1");
up_fn();
Debug.SetUpvalueFn(f1, "up_fn_1", function()
    print("new up_fn_1");
end)
up_fn_1();
print("---------------------------");
local up_tab = Debug.GetUpvalueTab(f1, "up_tab_1");
print(up_tab[1]);
Debug.SetUpvalueTab(f1, "up_tab_1", { "new up_tab_1" })
print(up_tab_1[1]);

