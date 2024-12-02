---
--- @author zsh in 2023/1/13 23:09
---

local BALANCE = TUNING.MONE_TUNING.GET_MOD_CONFIG_DATA.BALANCE;

local function trygrowth(inst)
    if not inst:IsValid() or inst:IsInLimbo() or
            (inst.components.witherable ~= nil and inst.components.witherable:IsWithered())
    then
        return false
    end

    if inst.components.pickable ~= nil then
        if inst.components.pickable:CanBePicked() and inst.components.pickable.caninteractwith then
            return false
        end
        if inst.components.pickable:FinishGrowing() then
            inst.components.pickable:ConsumeCycles(1) -- magic grow is hard on plants
            return true
        end
    end

    if inst.components.crop ~= nil and (inst.components.crop.rate or 0) > 0 then
        if inst.components.crop:DoGrow(1 / inst.components.crop.rate, true) then
            return true
        end
    end

    if inst.components.growable ~= nil then
        -- If we're a tree and not a stump, or we've explicitly allowed magic growth, do the growth.
        if
        inst.components.growable.magicgrowable or
                ((inst:HasTag("tree") or inst:HasTag("winter_tree")) and not inst:HasTag("stump"))
        then
            if inst.components.growable.domagicgrowthfn ~= nil then
                return inst.components.growable:DoMagicGrowth()
            else
                return inst.components.growable:DoGrowth()
            end
        end
    end

    if
    inst.components.harvestable ~= nil and inst.components.harvestable:CanBeHarvested() and
            inst:HasTag("mushroom_farm")
    then
        if inst.components.harvestable:Grow() then
            return true
        end
    end

    return false
end

env.AddPrefabPostInit("mone_waterballoon", function(inst)
    if not TheWorld.ismastersim then
        return inst;
    end
    if inst.components.wateryprotection then
        local old_SpreadProtectionAtPoint = inst.components.wateryprotection.SpreadProtectionAtPoint;
        inst.components.wateryprotection.SpreadProtectionAtPoint = function(self, x, y, z, dist, noextinguish)
            if old_SpreadProtectionAtPoint then
                old_SpreadProtectionAtPoint(self, x, y, z, dist, noextinguish);
            end
            if x and y and z then
                local DIST = dist or self.protection_dist or 4;
                local MUST_TAGS = nil;
                local CANT_TAGS = self.ignoretags;
                local ents = TheSim:FindEntities(x, y, z, DIST, MUST_TAGS, CANT_TAGS);
                --print(1111111);
                for _, v in ipairs(ents) do
                    --print("    " .. tostring(v.prefab));
                    if v and v.prefab and string.find(v.prefab, "farm_plant_")
                            and self.inst.prefab == "mone_waterballoon" and v.components.growable
                            and v.mone_waterballoon_tag == nil then
                        --print("hello!");
                        local stateFlag = true;
                        if self.stages and type(self.stages) == "table" then
                            local stage = 0
                            for _, sta in ipairs(self.stages) do
                                stage = stage + 1
                                if sta and sta.name and sta.name == "full" and sta.pregrowfn then
                                    break
                                end
                            end
                            if self:GetStage() >= stage or v.is_oversized then
                                stateFlag = false
                            end
                        end

                        if stateFlag then
                            if trygrowth(v) then
                                -- key point
                                v.mone_waterballoon_tag = "not the first time" --给予一个标识，让他成为巨大作物
                            end
                        end
                    end
                end
            end
        end
    end
end)

env.AddPrefabPostInitAny(function(inst)
    if not TheWorld.ismastersim then
        return inst;
    end
    if inst.prefab and string.match(tostring(inst.prefab), "farm_plant_") then
        local old_OnSave = inst.OnSave
        local old_OnLoad = inst.OnLoad
        inst.OnSave = function(inst, data)
            if old_OnSave then
                old_OnSave(inst, data)
            end
            if inst.mone_waterballoon_tag then
                data.mone_waterballoon_tag = inst.mone_waterballoon_tag;
            end
        end
        inst.OnLoad = function(inst, data)
            if old_OnLoad then
                old_OnLoad(inst, data)
            end
            if data then
                if data.mone_waterballoon_tag then
                    inst.mone_waterballoon_tag = data.mone_waterballoon_tag;
                end
            end
        end
    end
end)

-- 现在有个问题，催熟函数生效的时候必须在白天
env.AddComponentPostInit("growable", function(self)
    self.inst:DoTaskInTime(0, function()
        if self.inst and self.inst.prefab and string.match(tostring(self.inst.prefab), "farm_plant_") then
            if self.stages and type(self.stages) == "table" then
                for _, v in ipairs(self.stages) do
                    if v and v.name and v.name == "full" and v.pregrowfn then
                        local old_pregrowfn = v.pregrowfn
                        v.pregrowfn = function(inst)
                            if old_pregrowfn then
                                old_pregrowfn(inst)
                            end
                            if inst.mone_waterballoon_tag ~= nil then
                                inst.is_oversized = true
                            end
                        end
                        break
                    end
                end
            end
        end
    end)
end)

--[[
    target.force_oversized = true;
    target.components.growable:DoGrowth()

    target.force_oversized = true;

    给它实体的 force_oversized 变量赋予 true

    然后再催熟， 就是巨大化
]]

-- boss 掉落
if BALANCE then
    for _, p in ipairs({
        "moose", -- 春
        "antlion", -- 夏
        "bearger", -- 秋
        "deerclops", -- 冬
        "dragonfly"
    }) do
        env.AddPrefabPostInit(p, function(inst)
            if not TheWorld.ismastersim then
                return inst;
            end
            if inst.components.lootdropper then
                inst.components.lootdropper:AddChanceLoot("mone_waterballoon", 0.6);
                inst.components.lootdropper:AddChanceLoot("mone_waterballoon", 0.3);
            end
        end)
    end
end