---
--- @author zsh in 2023/5/5 15:28
---


local UpvalueUtil = require("chang_mone.dsts.UpvalueUtil");

local t3 = { name = "t3" };

local function f3()
    print("Scope: f3");
    local t = t3;
end

local t2 = { name = "t2" };

local function f2()
    print("Scope: f2");
    t2 = t2;
    f3();
end

local function f1()
    print("Scope: f1");
    f2();
end

--local upvalue, up, scope_fn = UpvalueUtil.GetUpvalue(f1, "f2.f3.t3.t")
--
--print(upvalue, up, scope_fn);
--
--print();
--f3();
--UpvalueUtil.SetUpvalue(f1, "f2.f3", function()
--    print("Scope: anonymous");
--end)
--f3();
--
--print();
--print(t3);
--print(t3.name);
--UpvalueUtil.SetUpvalue(f1, "f2.f3.t3", { name = "t3_new" });
--print(t3);
--print(t3.name);
--
--print();
--print(t3.name);
--local t = UpvalueUtil.GetUpvalue(f1, "f2.f3.t3");
--if t then
--    t.name = "t3_new";
--    print(t.name);
--end

print();

local str1 = "str1";
local num1 = 1;

local function fx2()
    str1 = str1;
    num1 = num1;
end

local function fx1()
    fx2 = fx2;
end

local function main()
    fx1 = fx1;
    fx2 = fx2;
    str1 = str1;
    num1 = num1;
end

print("main: "..tostring(main));
print("fx1: "..tostring(fx1));
print("fx2: "..tostring(fx2));

--print(UpvalueUtil.GetUpvalue(main, "fx1.fx2.str1"));
--print(UpvalueUtil.GetUpvalue(main, "fx1.fx2.num1"));
print(UpvalueUtil.GetUpvalue(main, "main.fx1.fx2.s"));

UpvalueUtil.SetUpvalue(main,"fx1.fx2.str1","str1_new");
UpvalueUtil.SetUpvalue(main,"fx1.fx2.num1",11111);
print(str1);
print(num1);
