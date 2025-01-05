---
--- @author zsh in 2023/4/26 14:34
---

LogInfo = setmetatable({}, {
    __newindex = function(t, k, v)
        rawset(t, k, v);
        print("#t: " .. tostring(#t));
        if #t > 2 then
            print("refresh memory");
            print("t: "..tostring(t));
            t = {};
            print("t: "..tostring(t));
        end
    end
});

print("LogInfo: "..tostring(LogInfo));

local msg1 = "Hello!";
local msg2 = "ni hao!";
local msg3 = "ni hao hao hao!";

table.insert(LogInfo, msg1);
LogInfo[#LogInfo + 1] = msg2;
LogInfo[#LogInfo + 1] = msg3;

for k, v in pairs(LogInfo) do
    print("", tostring(k), tostring(v));
end

