---
--- @author zsh in 2023/4/3 0:41
---

local function SpawnOneWormhole(pt1, pt2)
    if not (pt1 and pt2) then
        return ;
    end
    local wormhole1, wormhole2 = SpawnPrefab("wormhole"), SpawnPrefab("wormhole");
    wormhole1.components.teleporter:Target(wormhole2);
    wormhole2.components.teleporter:Target(wormhole1);
    wormhole1.Transform:SetPosition(pt1:Get());
    wormhole2.Transform:SetPosition(pt2:Get());
end

---@param site1 table @Prefab
---@param site2 table @Prefab
local function SpawnOnWalkablePosition(site1, site2)
    if not (site1 and site2) then
        return ;
    end
    local pt1 = site1:GetPosition();
    local pt2 = site2:GetPosition();
    if not TheWorld.Map:IsAboveGroundAtPoint(pt1.x, pt1.y, pt1.z, false) then
        pt1 = FindNearbyLand(pt1) or pt1;
    end
    if not TheWorld.Map:IsAboveGroundAtPoint(pt2.x, pt2.y, pt2.z, false) then
        pt2 = FindNearbyLand(pt2) or pt2;
    end
    local offset1 = FindWalkableOffset(site1:GetPosition(), math.random() * 2 * PI, 16, 12, true);
    local offset2 = FindWalkableOffset(site2:GetPosition(), math.random() * 2 * PI, 16, 12, true);
    if pt1 and pt2 and offset1 and offset2 then
        offset1.x = offset1.x + pt1.x;
        offset1.z = offset1.z + pt1.z;
        offset2.x = offset2.x + pt2.x;
        offset2.z = offset2.z + pt2.z;
        SpawnOneWormhole(offset1, offset2);
    end
end

local function SpawnWormholes(inst, self)
    local world = inst;
    local prefabs = {
        moonbase = false, moon_altar_rock_glass = false;
        pigking = false, monkeyqueen = false;
        oasislake = false, hermithouse_construction1 = false;
    }
    for k, v in pairs(Ents) do
        if v and v.IsValid and v:IsValid() and v.prefab then
            if prefabs[v.prefab] == false then
                prefabs[v.prefab] = v;
            end
        end
    end
    SpawnOnWalkablePosition(prefabs.moonbase, prefabs.moon_altar_rock_glass);
    SpawnOnWalkablePosition(prefabs.pigking, prefabs.monkeyqueen);
    SpawnOnWalkablePosition(prefabs.oasislake, prefabs.hermithouse_construction1);
end

local SpawnWormhole = Class(function(self, inst)
    self.inst = inst;

    self.has_take_effect = nil;

    -- 生成虫洞
    self.inst:DoTaskInTime(0, function(inst, self)
        if self.has_take_effect == nil then
            self.has_take_effect = true;
            SpawnWormholes(inst, self);
        end
    end, self)
end)

function SpawnWormhole:OnSave()
    return {
        has_take_effect = self.has_take_effect;
    }
end

function SpawnWormhole:OnLoad(data)
    if data then
        if data.has_take_effect then
            self.has_take_effect = data.has_take_effect;
        end
    end
end

return SpawnWormhole;