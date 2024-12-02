---
--- @author zsh in 2023/4/29 20:27
---

local fns = {};

--local _null = null;
--local function null2(...)
--    local args = { ... };
--    for i = 1, table.maxn(args) do
--        if not _null(args[i]) then
--            return false;
--        end
--    end
--    return true;
--end

-- 直接判断预制物的部分代码名
local function isFarmPlant(inst)
    if not isValid(inst) or null(inst.components.growable) or not inst.prefab then
        return false;
    end
    return string.find(inst.prefab, "farm_plant_");
end

-- 直接判断预制物的代码名
local function isMarbles(inst)
    if not isValid(inst) then
        return false;
    end
    return inst.prefab == "marbleshrub";
end

-- 直接判断预制物的代码名
local function isTrees(inst)
    if not isValid(inst) then
        return false;
    end
    return table.contains({
        "deciduoustree",
        "evergreen",
        "twiggytree",
        "palmconetree",
    }, inst.prefab);
end

-- 为了避免其他可能的报错，所以我只兼容原版物品
-- 而且 deployable.ondeploy 函数还要传 deployer 参数，获取很不方便...所以干脆自己直接生成了
local TreeSeeds = {
    pinecone = "pinecone_sapling";
    acorn = "acorn_sapling";
    twiggy_nut = "twiggy_nut_sapling";
    marblebean = "marblebean_sapling";
    palmcone_seed = "palmcone_sapling";
}
local function isTreeSeed(inst)
    if not isValid(inst) or null(inst.components.deployable) or not inst:HasTag("treeseed") then
        return false;
    end
    if table.containskey(TreeSeeds, inst.prefab) then
        return true;
    end
    return false;
end

local function isTreeSapling(inst)
    if not isValid(inst) then
        return false;
    end
    if table.contains(TreeSeeds, inst.prefab) then
        return true;
    end
    return false;
end

function fns.isWaterBalloonTarget(inst)
    return isFarmPlant(inst) or isTreeSeed(inst) or isTreeSapling(inst) or isMarbles(inst) or isTrees(inst);
end

local function PlayersSay(inst, message)
    if not isValid(inst) then
        return ;
    end

    local x, y, z = inst.Transform and inst.Transform:GetWorldPosition();

    if null(x) or null(y) or null(z) then
        return ;
    end

    local players = TheSim:FindEntities(x, y, z, 12, { "player" });


end

local function FarmPlantsOverSizedSingletonFn()
    env.AddComponentPostInit("growable", function(self)
        self.inst:DoTaskInTime(0, function(inst, self)
            if isFarmPlant(inst) and isTab(self.stages) then
                for _, v in ipairs(self.stages) do
                    if v and v.name == "full" and v.pregrowfn then
                        local old_pregrowfn = v.pregrowfn;
                        v.pregrowfn = function(inst, ...)
                            if old_pregrowfn then
                                old_pregrowfn(inst, ...)
                            end
                            if inst.water_balloon_effective_mark ~= nil then
                                inst.is_oversized = true;
                            end
                        end
                        break ;
                    end
                end
            end
        end, self)
    end)

    local function MaximizePlant(inst)
        if inst.components.farmplantstress ~= nil then
            if inst.components.farmplanttendable then
                inst.components.farmplanttendable:TendTo()
            end

            inst.magic_tending = true
            local _x, _y, _z = inst.Transform:GetWorldPosition()
            local x, y = TheWorld.Map:GetTileCoordsAtPoint(_x, _y, _z)

            local nutrient_consumption = inst.plant_def.nutrient_consumption
            TheWorld.components.farming_manager:AddTileNutrients(x, y, nutrient_consumption[1] * 6, nutrient_consumption[2] * 6, nutrient_consumption[3] * 6)
        end
    end

    -- helper function for book_gardening
    local function trygrowth(inst, maximize)
        if not inst:IsValid()
                or inst:IsInLimbo()
                or (inst.components.witherable ~= nil and inst.components.witherable:IsWithered()) then

            return false
        end

        if inst:HasTag("leif") then
            inst.components.sleeper:GoToSleep(1000)
            return true
        end

        if maximize then
            MaximizePlant(inst)
        end

        if inst.components.growable ~= nil then
            -- If we're a tree and not a stump, or we've explicitly allowed magic growth, do the growth.
            if inst.components.growable.magicgrowable or ((inst:HasTag("tree") or inst:HasTag("winter_tree")) and not inst:HasTag("stump")) then
                if inst.components.simplemagicgrower ~= nil then
                    inst.components.simplemagicgrower:StartGrowing()
                    return true
                elseif inst.components.growable.domagicgrowthfn ~= nil then
                    -- The upgraded horticulture book has a delayed start to make sure the plants get tended to first
                    inst.magic_growth_delay = maximize and 2 or nil
                    inst.components.growable:DoMagicGrowth()

                    return true
                else
                    return inst.components.growable:DoGrowth()
                end
            end
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

        if inst.components.harvestable ~= nil and inst.components.harvestable:CanBeHarvested() and inst:HasTag("mushroom_farm") then
            if inst.components.harvestable:IsMagicGrowable() then
                inst.components.harvestable:DoMagicGrowth()
                return true
            else
                if inst.components.harvestable:Grow() then
                    return true
                end
            end

        end

        return false
    end

    return function(wateryprotection, inst)
        local self, v = wateryprotection, inst;

        local effective = true;

        -- 2023-05-02：这里面我写错了啊，self不是growable组件啊...
        --print("self.stages: " .. tostring(self.stages));
        --if isTab(self.stages) then
        --    local stage_id = 0;
        --    for _, stage in ipairs(self.stages) do
        --        stage_id = stage_id + 1;
        --        if stage and stage.name == "full" and stage.pregrowfn then
        --            break ;
        --        end
        --    end
        --    if self:GetStage() >= stage_id or v.is_oversized then
        --        effective = false;
        --    end
        --end

        if effective then
            if trygrowth(v) then
                v.water_balloon_effective_mark = true;
            end
        end
    end
end

-- 让农作物直接巨大化
local FarmPlantsOverSized = FarmPlantsOverSizedSingletonFn();

-- 让生命水球的效果只生效一次
env.AddPrefabPostInitAny(function(inst)
    if not TheWorld.ismastersim then
        return inst;
    end
    if isFarmPlant(inst) or isMarbles(inst) or isTrees(inst) then
        local old_OnSave = inst.OnSave;
        inst.OnSave = function(inst, data)
            if old_OnSave then
                old_OnSave(inst, data)
            end
            data.water_balloon_effective_mark = inst.water_balloon_effective_mark;
        end

        local old_OnLoad = inst.OnLoad;
        inst.OnLoad = function(inst, data)
            if old_OnLoad then
                old_OnLoad(inst, data)
            end
            if data then
                inst.water_balloon_effective_mark = data.water_balloon_effective_mark;
            end
        end
    end
end)

env.AddPrefabPostInit("mone_waterballoon", function(inst)
    -- 变色
    inst.AnimState:SetMultColour(.1, 1, .1, 1);

    if not TheWorld.ismastersim then
        return inst;
    end

    if null(inst.components.wateryprotection) then
        return inst;
    end

    HookComponentSimulated("wateryprotection", inst, function(self, inst)
        local old_SpreadProtectionAtPoint = self.SpreadProtectionAtPoint;
        function self:SpreadProtectionAtPoint(x, y, z, dist, noextinguish, ...)
            if old_SpreadProtectionAtPoint then
                old_SpreadProtectionAtPoint(self, x, y, z, dist, noextinguish, ...);
            end
            if not (x and y and z) then
                return ;
            end
            local DIST = dist or self.protection_dist or 4;
            local MUST_TAGS = nil;
            local CANT_TAGS = self.ignoretags;
            local ONEOF_TAGS = nil;
            local ents = TheSim:FindEntities(x, y, z, DIST, MUST_TAGS, CANT_TAGS, ONEOF_TAGS);

            local treeseedscount = 0;
            local MAX_TREE_SEEDS_NUMBER = 80;

            for _, v in ipairs(ents) do
                if fns.isWaterBalloonTarget(v) then
                    if isFarmPlant(v) and null(v.water_balloon_effective_mark) --[[让农作物直接巨大化]] then
                        FarmPlantsOverSized(self, v);
                    elseif isTreeSeed(v) and treeseedscount <= MAX_TREE_SEEDS_NUMBER --[[让树种发芽]] then
                        local stack_size = v.components.stackable and v.components.stackable:StackSize() or 1;

                        treeseedscount = treeseedscount + stack_size;

                        if treeseedscount > MAX_TREE_SEEDS_NUMBER then
                            stack_size = stack_size - (treeseedscount - MAX_TREE_SEEDS_NUMBER);
                        end

                        local seed_num = stack_size;

                        if seed_num > 0 then
                            local pt = v:GetPosition();

                            -- 此处弄个线程是不是好点
                            for i = 1, seed_num do
                                local tree = SpawnPrefab(TreeSeeds[v.prefab]);
                                if tree then
                                    tree.Transform:SetPosition(pt:Get());
                                    tree:StartGrowing();
                                    tree.SoundEmitter:PlaySound("dontstarve/wilson/plant_tree");
                                end
                            end

                            --StartThread(function()
                            --    for i = 1, seed_num do
                            --        Sleep((0.2) * 0.001);
                            --        local tree = SpawnPrefab(TreeSeeds[v.prefab]);
                            --        if tree and pt then
                            --            tree.Transform:SetPosition(pt:Get());
                            --            tree:StartGrowing();
                            --            if i == 1 then
                            --                tree.SoundEmitter:PlaySound("dontstarve/wilson/plant_tree");
                            --            end
                            --        end
                            --    end
                            --end, tostring({}))

                            if v.components.stackable then
                                v.components.stackable:Get(seed_num):Remove();
                            else
                                v:Remove();
                            end
                        end
                    elseif isTreeSapling(v) --[[让树苗长到第一阶段]] then
                        if v.components.timer then
                            v.components.timer:StopTimer("grow");
                            v:PushEvent("timerdone", { name = "grow" });
                        end
                    elseif isMarbles(v) and null(v.water_balloon_effective_mark) --[[让大理石灌木直接长到最高阶段]] then
                        if v.prefab == "marbleshrub" then
                            if v.components.growable then
                                v.components.growable:SetStage(2);
                                v.components.growable:DoGrowth();
                                v.water_balloon_effective_mark = true;
                            end
                        end
                    elseif isTrees(v) and null(v.water_balloon_effective_mark) then
                        -- twiggytree、evergreen、deciduoustree、palmconetree
                        if v.components.growable then
                            v.components.growable:SetStage(2);
                            v.components.growable:DoGrowth();
                            v.water_balloon_effective_mark = true;
                        end
                    end
                end
            end
        end
    end)
end)
