---
--- @author zsh in 2023/2/25 12:07
---

--local cnt = 100;
--if cnt < 100 then
--    print(1);
--elseif cnt > 200 then
--    print(2);
--else
--    -- 100 <= cnt <= 200 ? YES!!!
--    print(3);
--end

--local ENV = {
--    a1 = "a1_global_ENV";
--    print = print;
--};
--setfenv(1, ENV);
--local a1 = "a1_local";

a1 = "a1_global_G";
local function fa()
    local ENV = {
        --a1 = "a1_global_ENV";
        print = print;
    };
    setfenv(1, ENV);
    --local a1 = "a1_local_local"
    local function fb()
        print(a1);
    end
    fb();
end
fa();