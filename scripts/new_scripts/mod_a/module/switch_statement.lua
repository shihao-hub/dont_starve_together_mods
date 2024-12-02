---
--- Created by zsh
--- DateTime: 2023/11/14 2:27
---


require("new_scripts.mod_a.class")

local Switch = morel_Module()

function Switch.execute(condition, switch)
    if condition == nil then return end
    if type(condition) ~= "string" and type(condition) ~= "number" then
        print("warning: switch statement's condition should be string or number.")
    end
    if not type(switch) == "table" then assert(false, 'type(switch) == "table"') end

    if switch["default"] == nil then switch["default"] = function() end end
    if switch[condition] then
        switch[condition]()
    else
        switch["default"]()
    end
end

return Switch