---
--- @author zsh in 2023/4/28 15:34
---

do
    return;
end

assert(getfenv(1) ~= _G, "ERROR: current environment is global environment.");

assert(Logger, "Logger == nil");

local _Logger = Logger;


-- 2023-04-28：写个简单的日志类
local Logger;

_Logger = Logger;
return _Logger;
