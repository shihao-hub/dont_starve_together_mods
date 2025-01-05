---
--- @author zsh in 2023/1/8 5:57
---


-- 此处已弃用，内容已经完全过时
do
    return nil;
end

local API = require("chang_mone.dsts.API");

local prefabs_path = {

    "prefabs/mone/game/backpack.lua",
    "prefabs/mone/game/piggyback.lua",

    "prefabs/mone/game/treasurechest.lua",
    "prefabs/mone/game/dragonfly_chest.lua",
    "prefabs/mone/game/icebox.lua",
    "prefabs/mone/game/saltbox.lua",

    "prefabs/mone/game/firesuppressor.lua",


    "prefabs/mone/mine/arborist.lua",
    "prefabs/mone/mine/harvester_staff.lua",
    "prefabs/mone/mine/nightspace_cape.lua",
    "prefabs/mone/mine/seasack.lua",
    "prefabs/mone/mine/spear_poison.lua",
    "prefabs/mone/mine/storage_bag.lua",
    "prefabs/mone/mine/waterchest.lua",


    "prefabs/mone/union/hats.lua"


}

local prefabs = {};
for _, path in ipairs(prefabs_path) do
    if not string.find(path, ".lua$") then
        path = path .. ".lua";
    end
    local f, msg = loadfile(path);
    if not f then
        print("loadfile error: ", msg);
    else
        for _, p in pairs({ f() }) do
            --print(type(p) == "table" and tostring(p.prefab) or "type p ~= table");
            if type(p) == "table" and p.is_a and p:is_a(Prefab) then
                table.insert(prefabs, p);
            end
        end
    end
end


--- ??? ERROR
--[[
-- 2023-02-10-17:04 这不就是 MakePlacer 的问题吗？现在倒是无所谓了。
[00:02:44]: [string "scripts/components/playercontroller.lua"]:1260: attempt to index field 'placer' (a nil value)
LUA ERROR stack traceback:
    scripts/components/playercontroller.lua:1260 in (method) StartBuildPlacementMode (Lua) <1247-1265>
    scripts/widgets/widgetutil.lua:72 in (global) DoRecipeClick (Lua) <38-151>
    scripts/widgets/redux/craftingmenu_widget.lua:912 in (field) whiledown (Lua) <910-914>
    scripts/widgets/button.lua:98 in (method) OnUpdate (Lua) <95-101>
    scripts/frontend.lua:836 in (method) Update (Lua) <657-854>
    scripts/update.lua:92 in () ? (Lua) <33-135>
]]

return unpack(prefabs);
