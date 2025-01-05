---
--- @author zsh in 2023/6/17 11:59
---

local str = "hello world"
local sub = string.sub(str, 3, 8)
--print(sub);

local CommonSubstitution = "人家";
local FirstPersonPronouns = {
    ["我"] = { CommonSubstitution, "我们" };
    ["吾"] = { CommonSubstitution, "吾辈" };
    ["余"] = { CommonSubstitution };
    ["朕"] = { CommonSubstitution };
    ["寡人"] = { CommonSubstitution };
    ["俺"] = { CommonSubstitution };
    ["老夫"] = { CommonSubstitution };
    ["洒家"] = { CommonSubstitution };
}
FirstPersonPronouns.n = table.maxn(FirstPersonPronouns);
print(FirstPersonPronouns.n);

do
    return;
end

local CommonSubstitution = "人家";
local FirstPersonPronouns = {
    ["我"] = CommonSubstitution;
    ["吾"] = CommonSubstitution;
    ["余"] = CommonSubstitution;
    ["朕"] = CommonSubstitution;
    ["寡人"] = CommonSubstitution;
    ["俺"] = CommonSubstitution;
    ["老夫"] = CommonSubstitution;
    ["洒家"] = CommonSubstitution;
}

-- 在 UTF-8 中中文标点符号编码范围是 0xEA84BF~0xEAA980
local Punctuations = {
    32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47,
    58, 59, 60, 61, 62, 63, 64,
    91, 92, 93, 94, 95, 96,
    123, 124, 125, 126,
    "。", "？", "！", "，", "、", "；", "：",
}

-------------------------------------------------------------------------
local message = "我需要一些材料!!!!!!";
if message then
    for k, v in pairs(FirstPersonPronouns) do
        if message:find(k) and not message:find(k .. "们") then
            message = string.gsub(message, k, v);
        end
    end

    local pos = -1;
    for i = string.len(message), 1, -1 do
        for _, v in ipairs(Punctuations) do
            v = type(v) == "number" and string.char(v) or v;
            -- 呃，好像 string.sub 只能截获字母...
            if string.sub(message, i, i) == v and string.sub(message, i + 1, i + 1) ~= v then
                pos = i;
                break ;
            end
        end
        if pos > 0 then
            message = string.sub(message, 1, pos - 1);
            message = message .. "喵~❤";
            break ;
        end
    end
end
-------------------------------------------------------------------------

print(message);