---
--- Created by zsh
--- DateTime: 2023/9/12 1:01
---

function a(...)
    local n = select("#", ...);
    print(n);
end

a(1,2,3,nil);