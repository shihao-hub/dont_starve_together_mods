---
--- @author zsh in 2023/4/23 23:24
---

local API = require("chang_mone.dsts.API");

if API.isDebug(env) then
    env.modimport("modmain/Optimization/modules/network_synchronization_detection.lua");
end