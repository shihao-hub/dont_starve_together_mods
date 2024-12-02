---
--- @author zsh in 2023/4/4 14:19
---

require("map/tasks");
require("map/lockandkey");

local Layouts = require("map/layouts").Layouts;
local StaticLayout = require("map/static_layout");

local ALL_TASKS = { "Make a pick", "Dig that rock", "Great Plains", "Squeltch", "Beeeees!", "Speak to the king", "Forest hunters", "Befriend the pigs", "For a nice walk", "Kill the spiders", "Killer bees!", "Make a Beehat", "The hunters", "Magic meadow", "Frogs and bugs", "Badlands" };

-- 将定义的地图放在静态地图表里
Layouts["more_items_island"] = StaticLayout.Get("map/static_layouts/more_items_island", {
    start_mask = PLACE_MASK.IGNORE_IMPASSABLE_BARREN_RESERVED,
    fill_mask = PLACE_MASK.IGNORE_IMPASSABLE_BARREN_RESERVED,
    layout_position = LAYOUT_POSITION.CENTER,
    disable_transform = true;
})

-- 生成挂机小岛
env.AddLevelPreInitAny(function(level)
    if level.location == "forest" then
        if level.ocean_prefill_setpieces then
            level.ocean_prefill_setpieces["more_items_island"] = { count = 1 }
        end
    end
end)


