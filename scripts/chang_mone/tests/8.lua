---
--- @author zsh in 2023/3/12 12:56
---

--local recname = "critter_kitten_builder"
--print(string.sub(recname, 1, string.find(recname, "_builderxx$") or 2 - 1));

--
--t1 = t2;
--t2 = { "1" };
--
--print(t1[1]);

local t1 = { "t1" };
local t2 = setmetatable({
    [t1] = "::t1";
    ["a"] = "::a";
}, {
    __mode = "k"
})
for k, v in pairs(t2) do
    if k ~= nil then
        print(tostring(k), tostring(v));
    end
end
print("---------------");
t1 = nil;
collectgarbage();
for k, v in pairs(t2) do
    if k ~= nil then
        print(tostring(k), tostring(v));
    end
end

--print(tostring(debug.getinfo(2,"S").what)); =="main"

local function f1()
    print(tostring(debug.getinfo(2, "S").what))
end

f1();
--math