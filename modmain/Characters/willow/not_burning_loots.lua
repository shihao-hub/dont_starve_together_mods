---
--- @author zsh in 2023/4/21 12:25
---


local function OverrideDropLoot(override_fn, self, pt, ...)
    if override_fn then
        override_fn();
    end
    local combat = self.inst.components.combat;
    local iswillow = combat and combat.lastattacker and combat.lastattacker.prefab == "willow";

    local prefabs = self:GenerateLoot()
    if self.inst:HasTag("burnt")
            or (self.inst.components.burnable ~= nil and
            self.inst.components.burnable:IsBurning() and
            (self.inst.components.fueled == nil or self.inst.components.burnable.ignorefuel)) then

        local isstructure = self.inst:HasTag("structure");
        for k, v in pairs(prefabs) do
            if TUNING.BURNED_LOOT_OVERRIDES[v] ~= nil then
                prefabs[k] = TUNING.BURNED_LOOT_OVERRIDES[v]
            elseif PrefabExists(v .. "_cooked") then
                prefabs[k] = v .. "_cooked"
            elseif PrefabExists("cooked" .. v) then
                prefabs[k] = "cooked" .. v
                --V2C: This used to make hammering WHILE burning give ash only
                --     while hammering AFTER burnt give back good ingredients.
                --     It *should* ALWAYS return ash based on certain types of
                --     ingredients (wood), but we'll let them have this one :O
            elseif (not isstructure and not self.inst:HasTag("tree")) or self.inst:HasTag("hive") then
                -- because trees have specific burnt loot and "hive"s are structures...
                prefabs[k] = iswillow and prefabs[k] or "ash"
            end
        end
    end
    for k, v in pairs(prefabs) do
        self:SpawnLootPrefab(v, pt)
    end

    if IsSpecialEventActive(SPECIAL_EVENTS.WINTERS_FEAST) then
        local prefabname = string.upper(self.inst.prefab)
        local num_decor_loot = self.GetWintersFeastOrnaments ~= nil and self.GetWintersFeastOrnaments(self.inst) or TUNING.WINTERS_FEAST_TREE_DECOR_LOOT[prefabname] or nil
        if num_decor_loot ~= nil then
            for i = 1, num_decor_loot.basic do
                self:SpawnLootPrefab(GetRandomBasicWinterOrnament(), pt)
            end
            if num_decor_loot.special ~= nil then
                self:SpawnLootPrefab(num_decor_loot.special, pt)
            end
        elseif not TUNING.WINTERS_FEAST_LOOT_EXCLUSION[prefabname] and (self.inst:HasTag("monster") or self.inst:HasTag("animal")) then
            local loot = math.random()
            if loot < 0.005 then
                self:SpawnLootPrefab(GetRandomBasicWinterOrnament(), pt)
            elseif loot < 0.20 then
                self:SpawnLootPrefab("winter_food" .. math.random(NUM_WINTERFOOD), pt)
            end
        end
    end

    TheWorld:PushEvent("entity_droploot", { inst = self.inst })
end

env.AddComponentPostInit("lootdropper", function(self, inst)
    local old_DropLoot = self.DropLoot;
    if old_DropLoot then
        function self:DropLoot(pt, ...)
            local combat = self.inst.components.combat;
            local willow = combat and combat.lastattacker and combat.lastattacker.prefab == "willow";
            if willow then
                return OverrideDropLoot(function()
                    -- DoNothing
                end, self, pt, ...);
            else
                if old_DropLoot then
                    return old_DropLoot(self, pt, ...);
                end
            end
        end
    end
end)