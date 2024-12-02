---
--- @author zsh in 2023/6/25 22:35
---

function subfmt(s, tab)
    return (s:gsub('(%b{})', function(w) return tab[w:sub(2, -2)] or w end))
end

print(subfmt("this is my {adjective} string, read it {number} times!",{
    adjective = "普通的",
    number = 5;
}));