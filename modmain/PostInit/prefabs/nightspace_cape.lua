---
--- @author zsh in 2023/1/14 1:04
---

local API = require("chang_mone.dsts.API");

local function runningOnWater(inst, owner)
    if inst.running_on_water_task then
        inst.running_on_water_task:Cancel();
        inst.running_on_water_task = nil;
    end

    if owner.components.drownable and owner.components.drownable.enabled ~= false then
        if null(owner.Transform) or null(owner.Physics) then
            return ;
        end

        owner.components.drownable.enabled = false;
        owner.Physics:ClearCollisionMask();
        owner.Physics:CollidesWith(COLLISION.GROUND);
        owner.Physics:CollidesWith(COLLISION.OBSTACLES);
        owner.Physics:CollidesWith(COLLISION.SMALLOBSTACLES);
        owner.Physics:CollidesWith(COLLISION.CHARACTERS);
        owner.Physics:CollidesWith(COLLISION.GIANTS);

        local x, y, z = owner.Transform:GetWorldPosition()
        if x and y and z then
            owner.Physics:Teleport(x, y, z);
        end
    end

    inst.delay_count = 0;

    inst.running_on_water_task = inst:DoPeriodicTask(0.1, function(inst, owner)
        if null(owner.sg) or null(owner.Transform) or null(owner.Physics) or null(owner.components) then
            return ;
        end

        local is_moving = owner.sg:HasStateTag("moving"); -- 玩家正在移动
        local is_running = owner.sg:HasStateTag("running"); -- 玩家正在奔跑
        local x, y, z = owner.Transform:GetWorldPosition();
        local drownable = owner.components.drownable;

        if null(x) or null(y) or null(z) or null(drownable) then
            return ;
        end

        -- 每次都清理一下...还是说判定一下比较好？
        owner.Physics:ClearCollisionMask()
        owner.Physics:CollidesWith(COLLISION.GROUND)
        owner.Physics:CollidesWith(COLLISION.OBSTACLES)
        owner.Physics:CollidesWith(COLLISION.SMALLOBSTACLES)
        owner.Physics:CollidesWith(COLLISION.CHARACTERS)
        owner.Physics:CollidesWith(COLLISION.GIANTS)

        if drownable:IsOverWater() then
            -- 正在移动
            if is_running or is_moving then
                inst.delay_count = inst.delay_count + 1;
                if inst.delay_count >= 5 then
                    SpawnPrefab("weregoose_splash_less" .. tostring(math.random(2))).entity:SetParent(owner.entity)
                    inst.delay_count = 0;
                end
            end
        end
    end, nil, owner)
end

local function runningOnWaterCancel(inst, owner)
    if inst.running_on_water_task then
        inst.running_on_water_task:Cancel()
        inst.running_on_water_task = nil
    end

    if null(owner.components.drownable) then
        return ;
    end

    if owner.components.drownable.enabled == false then
        owner.components.drownable.enabled = true
        if not owner:HasTag("playerghost") then
            owner.Physics:ClearCollisionMask()
            owner.Physics:CollidesWith(COLLISION.WORLD)
            owner.Physics:CollidesWith(COLLISION.OBSTACLES)
            owner.Physics:CollidesWith(COLLISION.SMALLOBSTACLES)
            owner.Physics:CollidesWith(COLLISION.CHARACTERS)
            owner.Physics:CollidesWith(COLLISION.GIANTS)
            local x, y, z = owner.Transform:GetWorldPosition()
            if x and y and z then
                owner.Physics:Teleport(x, y, z);
            end
        end
    end
end

env.AddPrefabPostInit("mone_nightspace_cape", function(inst)
    if not TheWorld.ismastersim then
        return inst;
    end

    -- 轻功水上漂
    if inst.components.equippable then
        local equippable = inst.components.equippable;
        local old_onequipfn = equippable.onequipfn;
        equippable.onequipfn = function(inst, owner, ...)
            if old_onequipfn then
                old_onequipfn(inst, owner, ...);
            end
            --API.runningOnWater(inst, owner);
            runningOnWater(inst, owner);
        end
        local old_onunequipfn = equippable.onunequipfn;
        equippable.onunequipfn = function(inst, owner, ...)
            if old_onunequipfn then
                old_onunequipfn(inst, owner, ...);
            end
            --API.runningOnWaterCancel(inst, owner);

            runningOnWaterCancel(inst, owner);
        end
    end

    -- 冬季保暖 180，夏季隔热 180
    inst:AddComponent("insulator");

    inst:DoTaskInTime(0, function(inst)
        if TheWorld.state.issummer then
            inst.components.insulator:SetInsulation(TUNING.INSULATION_MED_LARGE);
            inst.components.insulator:SetSummer();
        else
            inst.components.insulator:SetInsulation(TUNING.INSULATION_MED_LARGE);
            inst.components.insulator:SetWinter();
        end
    end)

    inst:WatchWorldState("season", function(inst, season)
        if not season then
            return ;
        end
        if season == "summer" then
            inst.components.insulator:SetInsulation(TUNING.INSULATION_MED_LARGE);
            inst.components.insulator:SetSummer();
        else
            inst.components.insulator:SetInsulation(TUNING.INSULATION_MED_LARGE);
            inst.components.insulator:SetWinter();
        end
    end)
end)