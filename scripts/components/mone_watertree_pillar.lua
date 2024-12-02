---
--- @author zsh in 2023/4/4 20:17
---

local function SpawnOneWormhole(pt1, wormhole2)
    if not (pt1 and wormhole2) then
        return ;
    end
    local wormhole1 = SpawnPrefab("wormhole");
    wormhole1.components.teleporter:Target(wormhole2);
    wormhole2.components.teleporter:Target(wormhole1);
    wormhole1.Transform:SetPosition(pt1:Get());
end

---@param site1 table @Prefab
---@param site2 table @Prefab
local function SpawnOnWalkablePosition(site1, site2)
    if not (site1 and site2) then
        return ;
    end
    local pt1 = site1:GetPosition();
    if not TheWorld.Map:IsAboveGroundAtPoint(pt1.x, pt1.y, pt1.z, false) then
        pt1 = FindNearbyLand(pt1) or pt1;
    end
    local offset1 = FindWalkableOffset(site1:GetPosition(), math.random() * 2 * PI, 12, 20, true);
    if pt1 and offset1 then
        offset1.x = offset1.x + pt1.x;
        offset1.z = offset1.z + pt1.z;

        local x, y, z = site2.Transform:GetWorldPosition();
        local wormhole;
        local ents = TheSim:FindEntities(x, y, z, 30, nil, nil, { "trader", "alltrader", "antlion_sinkhole_blocker" });
        for _, v in ipairs(ents) do
            if v and v.IsValid and v:IsValid() and v.prefab == "wormhole" then
                wormhole = v;
                break ;
            end
        end
        if wormhole then
            SpawnOneWormhole(offset1, wormhole);
        end
    end
end

local function SpawnWormholes(inst, self)
    local world = inst;
    local prefabs = {
        multiplayer_portal = false, mone_watertree_pillar = false;
    }
    for k, v in pairs(Ents) do
        if v and v.IsValid and v:IsValid() and v.prefab then
            if prefabs[v.prefab] == false then
                prefabs[v.prefab] = v;
            end
        end
    end
    SpawnOnWalkablePosition(prefabs.multiplayer_portal, prefabs.mone_watertree_pillar);
end

local WaterTreePillar = Class(function(self, inst)
    self.inst = inst;

    self.has_take_effect = nil;

    -- 生成虫洞
    self.inst:DoTaskInTime(0, function(inst, self)
        if self.has_take_effect == nil then
            self.has_take_effect = true;
            SpawnWormholes(inst, self); -- 注意，岛屿太小的话，FindWalkableOffset 好像找不到位置。所以该函数将不再具有普遍性。
        end
    end, self)
end)

function WaterTreePillar:OnSave()
    return {
        has_take_effect = self.has_take_effect;
    }
end

function WaterTreePillar:OnLoad(data)
    if data then
        if data.has_take_effect then
            self.has_take_effect = data.has_take_effect;
        end
    end
end

return WaterTreePillar;