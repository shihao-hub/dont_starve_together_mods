---
--- @author zsh in 2023/4/1 15:19
---

local Layouts = require("map/layouts").Layouts;
local StaticLayout = require("map/static_layout");

local ALL_TASKS = { "Make a pick", "Dig that rock", "Great Plains", "Squeltch", "Beeeees!", "Speak to the king", "Forest hunters", "Befriend the pigs", "For a nice walk", "Kill the spiders", "Killer bees!", "Make a Beehat", "The hunters", "Magic meadow", "Frogs and bugs", "Badlands" };

env.AddTaskSetPreInitAny(function(task_set_data)
    if task_set_data.location == "forest" then
        for i = 1, 2 do
            Layouts["MoreItemsWormhole" .. i] = StaticLayout.Get("map/static_layouts/wormhole_grass");
        end
        task_set_data.set_pieces["MoreItemsWormhole1"] = { count = 1, tasks = { "MoonIsland_Forest" } };
        task_set_data.set_pieces["MoreItemsWormhole2"] = { count = 1, tasks = ALL_TASKS }
    end
end)