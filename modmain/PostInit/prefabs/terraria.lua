---
--- @author zsh in 2023/7/4 13:51
---

local API = require("chang_mone.dsts.API");

local Debug = API.Debug;
local armor = require("components/armor");
if armor then
    local PercentChanged = Debug.GetUpvalueFn(armor._ctor, "PercentChanged");
    if PercentChanged then
        function armor:DisablePercentChangedArmorBrokeEvent2()
            if PercentChanged then
                self.inst:RemoveEventCallback("percentusedchange", PercentChanged);
            end
        end
    end
end