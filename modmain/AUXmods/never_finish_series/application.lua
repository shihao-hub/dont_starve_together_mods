---
--- @author zsh in 2023/5/15 15:33
---


if isDebug() then
    env.modimport("modmain/AUXmods/never_finish_series/application1.lua");
    -- 2023-07-02：application2 每次游戏内 c_reset() 居然回闪退？就是一直以来的那种未名闪退...算了，反正也不打算写了。
else
    env.modimport("modmain/AUXmods/never_finish_series/application1.lua")
end