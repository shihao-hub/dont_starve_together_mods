---
--- @author zsh in 2023/2/4 15:55
---

local upvalue = require("chang_mone.dsts.upvaluehelper");

local v1 = "v1";
local v2 = "v2";
local function f1()
    local function f2()
        print("f2():" .. tostring(v1));
        v2 = "v2_new";
    end
end

print(upvalue.Get(f1, "v1"));
print(upvalue.Get(f1, "v2"));

require("chang_mone.tests.upvalue_module");
print(upvalue.Get(fn, "f1"));
print(upvalue.Get(fn, "f2"));