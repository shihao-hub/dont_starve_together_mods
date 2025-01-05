---
--- @author zsh in 2023/4/26 15:35
---

local time = os.time();
print(type(time));

local function GetGUID()
    return tostring({});
end

print(GetGUID());
print(GetGUID());
print(GetGUID());
print(GetGUID());
