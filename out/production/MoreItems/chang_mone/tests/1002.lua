---
--- @author zsh in 2023/4/4 17:23
---

local function SpawnWormTest()
    -- 生成一对虫洞
    local wormhole1, wormhole2 = SpawnPrefab("wormhole"), SpawnPrefab("wormhole");
    -- 将二者关联在一起
    wormhole1.components.teleporter:Target(wormhole2);
    wormhole2.components.teleporter:Target(wormhole1);

    wormhole1.Transform:SetPosition(0, 0, 0);
    wormhole2.Transform:SetPosition(20, 0, 20);
end

local function PrintWormholeNumber()
    --ThePlayer.components.talker:Say("整个地面有："..c_countprefabs("wormhole").." 个虫洞！");
    print(c_countprefabs("wormhole"));
end

TUNING.MoreItemsDebugCommands = {};
TUNING.MoreItemsDebugCommands.SpawnWormTest = SpawnWormTest;
TUNING.MoreItemsDebugCommands.PrintWormholeNumber = PrintWormholeNumber;

-- backups
--local monkeyisland_01 = require("map/static_layouts/monkeyisland_01");
--if monkeyisland_01.layers and monkeyisland_01.layers[2] and monkeyisland_01.layers[2].type == "objectgroup" then
--    table.insert()
--end