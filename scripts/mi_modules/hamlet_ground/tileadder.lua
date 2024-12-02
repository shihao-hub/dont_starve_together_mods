---
--- @author zsh in 2023/3/24 13:07
---

-- tile adder

-- 环境设置
local ENV = TUNING.MONE_TUNING.MI_MODULES.HAMLET_GROUND.ENV;
setfenv(1, ENV);

-- 变量局部化
local _G = GLOBAL
local require = GLOBAL.require
local Asset = _G.Asset
local error = _G.error
local unpack = _G.unpack
local GROUND = _G.GROUND
local GROUND_NAMES = _G.GROUND_NAMES
local GROUND_FLOORING = _G.GROUND_FLOORING
local resolvefilepath = _G.resolvefilepath
-- local softresolvefilepath = _G.softresolvefilepath

-- 文件导入
require "map/terrain"
local tiledefs = require "worldtiledefs"

modimport("scripts/mi_modules/hamlet_ground/tiledescription.lua")

local newTilesProperties = SetInfo() --Loading data from tiledescription.lua
local minStartID = 33 -- 1-32 is reserved by game

print("Strating Tileadder")

-- levels 路径
local function GroundTextures(name)
    return MORE_ITEMS_MODULES_HAMLET_GROUND_ROOT .. "levels/textures/noise_" .. name .. ".tex"
end
local function MiniGroundTextures(name)
    return MORE_ITEMS_MODULES_HAMLET_GROUND_ROOT .. "levels/textures/mini_noise_" .. name .. ".tex"
end
local function GroundImage(name)
    return MORE_ITEMS_MODULES_HAMLET_GROUND_ROOT .. "levels/tiles/" .. name .. ".tex"
end
local function GroundAtlas(name)
    return MORE_ITEMS_MODULES_HAMLET_GROUND_ROOT .. "levels/tiles/" .. name .. ".xml"
end
-- local function FirstToUpper( str )           return ( str:gsub("^%l", string.upper) )                    end

---添加地皮
function AddTiles()
    for tilename, data in pairs(newTilesProperties) do
        _G.assert(_G.type(tilename) == "string", "Name should be a string parameter")
        _G.assert(_G.type(data.specs) == "table", "Specs should be a table parameter")

        local mapspecs = data.specs
        local numid = (_G.type(data.numid) == "number" and data.numid > minStartID) and data.numid or minStartID
        local layer = _G.type(data.layer) == "number" and data.layer or nil
        if layer and (layer < 0 or layer >= 255) then
            return error(("Layer level shoud be in range 1..255, now it is %d"):format(layer))
        end

        local chk = true
        while chk do
            chk = false
            for _, val2 in pairs(tiledefs.ground) do
                if val2[1] == numid then
                    print("[tileadder]", numid, "is reserved, incrementing...")
                    numid = numid + 1
                    chk = true
                end
            end
        end

        if numid >= GROUND.UNDERGROUND then
            return error(("Numerical id %d is out of limits"):format(numid, GROUND.UNDERGROUND), 3)
        end

        print("lowest founded value:", numid)
        ------------------------------------------------------
        GROUND[tilename:upper()] = numid
        GROUND_NAMES[numid] = tilename
        GROUND_FLOORING[numid] = data.isfloor

        mapspecs = mapspecs or {}

        local tileSpecDefault = {
            name = "carpet",
            noise_texture = GroundTextures(tilename:lower()),
            runsound = "dontstarve/movement/run_dirt",
            walksound = "dontstarve/movement/walk_dirt",
            snowsound = "dontstarve/movement/run_ice",
            mudsound = "dontstarve/movement/run_mud",
            flashpoint_modifier = 0
        }

        local realMapspecs = {}

        for k, spec in pairs(mapspecs) do
            realMapspecs[k] = spec
        end

        for k, default in pairs(tileSpecDefault) do
            --adding defaults, if not setted
            if realMapspecs[k] == nil then
                realMapspecs[k] = default
            end
        end

        if layer then
            table.insert(tiledefs.ground, layer, { numid, realMapspecs })
        else
            table.insert(tiledefs.ground, { numid, realMapspecs })
        end

        table.insert(tiledefs.assets, Asset("IMAGE", realMapspecs.noise_texture))
        table.insert(tiledefs.assets, Asset("IMAGE", GroundImage(realMapspecs.name)))
        table.insert(tiledefs.assets, Asset("FILE", GroundAtlas(realMapspecs.name)))
        print("[tileadder]", tilename, "added!")
    end
end

---添加小地图图标
function AddMinimap()
    local addedTilesTurfInfo = {}
    local minimapGroundProperties = {}

    for tilename, data in pairs(newTilesProperties) do
        local groundID = nil
        for k, v in pairs(GROUND_NAMES) do
            --print(k, v, tilename)
            if v == tilename then
                groundID = k
                break
            end
        end
        local mapspecs = data.specs or {}
        local name = mapspecs.name or tilename
        local mgt = data.mgt or MiniGroundTextures(name)
        table.insert(Assets, Asset("IMAGE", mapspecs.noise_texture or GroundTextures(name)))
        table.insert(Assets, Asset("IMAGE", mgt))
        table.insert(Assets, Asset("IMAGE", GroundImage(name)))
        table.insert(Assets, Asset("FILE", GroundAtlas(name)))
        table.insert(minimapGroundProperties, { groundID, { name = "map_edge", noise_texture = mgt } })

        if data.turf then
            _G.assert(_G.type(data.turf) == "table")
            addedTilesTurfInfo[groundID] = data.turf
        end
    end

    --Adding layers info for the minimap. Tiles will work without it, but the minimap will got empty spaces.
    env.AddPrefabPostInit("minimap", function(inst)
        for _, data in pairs(minimapGroundProperties) do
            local tile_type, layer_properties = unpack(data)
            print(layer_properties.name, GroundAtlas(layer_properties.name))
            local handle = _G.MapLayerManager:CreateRenderLayer(
                    tile_type,
                    resolvefilepath(GroundAtlas(layer_properties.name)),
                    resolvefilepath(GroundImage(layer_properties.name)),
                    resolvefilepath(layer_properties.noise_texture)
            )
            inst.MiniMap:AddRenderLayer(handle)
        end
    end)

    env.AddComponentPostInit("terraformer", function(self)
        --overload terraformer component
        local _Terraform = self.Terraform
        self.Terraform = function(self, pt, spawnturf)
            local tile = GLOBAL.TheWorld.Map:GetTileAtPoint(pt:Get())
            --print("tile: "..tostring(tile));
            if _Terraform(self, pt, spawnturf) then
                --print("--1");
                if addedTilesTurfInfo[tile] then
                    --print("--2");
                    for k, lootinfo in pairs(addedTilesTurfInfo[tile]) do
                        --print("--3");
                        local min = lootinfo[2] or 1
                        local max = lootinfo[3] or min
                        --print("lootinfo[2]: "..tostring(lootinfo[2]));
                        --print("lootinfo[3]: "..tostring(lootinfo[3]));
                        --print("min: "..tostring(min));
                        --print("max: "..tostring(max));
                        for i = 1, math.random(min, max) do
                            local loot = GLOBAL.SpawnPrefab("mone_" .. lootinfo[1])
                            --print("lootinfo[1]: "..tostring(lootinfo[1]));
                            --print("loot: "..tostring(loot));
                            if loot then
                                loot.Transform:SetPosition(pt:Get())
                                if loot.Physics ~= nil then
                                    local angle = math.random() * 2 * GLOBAL.PI
                                    loot.Physics:SetVel(2 * math.cos(angle), 10, 2 * math.sin(angle))
                                end
                            end
                        end
                    end
                end
            else
                return false
            end
            return true
        end
    end)
end
