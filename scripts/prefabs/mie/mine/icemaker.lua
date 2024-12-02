---
--- @author zsh in 2023/2/10 11:01
---

require "prefabutil"

local assets = {
    Asset("ANIM", "anim/icemachine.zip"),
    Asset("ATLAS", "images/inventoryimages/icemaker.xml"),
    Asset("IMAGE", "images/inventoryimages/icemaker.tex"),
    --Asset("MINIMAP_IMAGE", "icemaker"),
}

local prefabs = {
    "collapse_small",
    "ice",
}

local MACHINESTATES = {
    ON = "_on",
    OFF = "_off",
}

-- 18 个， 3 次

local TASK_ICE_NUMBER = 1;
local TASK_TIME = 15 * TASK_ICE_NUMBER;

-- TEST
--do
--    TASK_TIME = 5;
--end

local function spawnoneice(inst)
    local ice = SpawnPrefab("ice")
    local pt = Vector3(inst.Transform:GetWorldPosition()) + Vector3(0, 2, 0)
    ice.Transform:SetPosition(pt:Get())
    local down = TheCamera:GetDownVec()
    local angle = math.atan2(down.z, down.x) + (math.random() * 60) * DEGREES
    local sp = 3 + math.random()
    ice.Physics:SetVel(sp * math.cos(angle), math.random() * 2 + 8, sp * math.sin(angle))

    -- 自动转移到冰箱里
    ice:DoTaskInTime(1.5, function(ice)
        local owner = ice.components.inventoryitem and ice.components.inventoryitem.owner or nil;
        if owner then
            -- DoNothing
        else
            local x, y, z = ice.Transform:GetWorldPosition();
            if x and y and z then
                -- CANT_TAGS 要不要呢？冰包也有 fridge 标签
                local ents = TheSim:FindEntities(x, y, z, 20, nil, { "FX", "INLIMBO", "NOCLICK" }, { "fridge", "more_items_fridge","mie_bear_skin_cabinet" });
                for _, v in ipairs(ents) do
                    if v and v.components.container and v.components.container:GiveItem(ice) then
                        -- sand_puff,1  collapse_small,0.5
                        local fx1, scale1 = SpawnPrefab("sand_puff"), 0.5;
                        fx1.Transform:SetScale(scale1, scale1, scale1);
                        fx1.Transform:SetPosition(x, y, z);

                        local fx2, scale2 = SpawnPrefab("sand_puff"), 0.5;
                        fx2.Transform:SetScale(scale2, scale2, scale2);
                        fx2.Transform:SetPosition(v.Transform:GetWorldPosition());

                        break ;
                    else
                        ice.Transform:SetPosition(x, y, z);
                    end
                end
            end
        end

    end);

    -- 特效声音太吵了！
    --SpawnPrefab("collapse_small").Transform:SetPosition(inst.Transform:GetWorldPosition())
    --local fx, scale = SpawnPrefab("sand_puff_large_front"), 1.5;
    --fx.Transform:SetScale(scale, scale, scale);
    --fx.Transform:SetPosition(inst.Transform:GetWorldPosition());
end

local function spawnice(inst)
    if not inst:IsAsleep() then
        inst:RemoveEventCallback("animover", spawnice)
    end

    for i = 1, TASK_ICE_NUMBER do
        spawnoneice(inst);
    end

    --Machine should only ever be on after spawning an ice
    inst.components.fueled:StartConsuming()
    if not inst:IsAsleep() then
        inst.AnimState:PlayAnimation("idle_on", true)
    end
end

local function onhammered(inst, worked)
    if inst.components.burnable ~= nil and inst.components.burnable:IsBurning() then
        inst.components.burnable:Extinguish()
    end
    if inst.components.lootdropper then
        inst.components.lootdropper:DropLoot()
    end
    SpawnPrefab("collapse_small").Transform:SetPosition(inst.Transform:GetWorldPosition())
    inst.SoundEmitter:PlaySound("dontstarve/common/destroy_metal")

    inst:Remove()
end

--local function spawnice1(inst)
--    spawnice(inst);
--end

--local count = 0;

-- inst.fueltask = inst:DoPeriodicTask(30, fueltaskfn)
-- 每隔 30 秒执行一次动画
local function fueltaskfn(inst)
    inst.AnimState:PlayAnimation("use")
    --inst.SoundEmitter:PlaySound("dontstarve_DLC002/common/icemachine_start")
    inst.components.fueled:StopConsuming() --temp pause fuel so we don't run out in the animation.

    --count = count + 1;
    if inst:IsAsleep() then
        --print("制冰机休眠！不播放动画！---" .. tostring(count));
        --inst.not_asleep_task = inst:DoTaskInTime(1.5, spawnice);
        spawnice(inst);
    else
        --if inst.not_asleep_task then
        --    inst.not_asleep_task:Cancel();
        --    inst.not_asleep_task = nil;
        --end
        --print("制冰机未休眠！播放动画！---" .. tostring(count));
        inst:ListenForEvent("animover", spawnice);
    end
end

local function ontakefuelfn(inst)
    inst.SoundEmitter:PlaySound("dontstarve/common/fireAddFuel")
    inst.components.fueled:StartConsuming()
end

local function fuelupdatefn(inst, dt)
    -- TODO: summer season rate adjustment?
    inst.components.fueled.rate = 1
end

local function onhit(inst, worker)
    inst.AnimState:PlayAnimation("hit" .. inst.machinestate)
    inst.AnimState:PushAnimation("idle" .. inst.machinestate, true)
    inst:RemoveEventCallback("animover", spawnice)
    if inst.machinestate == MACHINESTATES.ON then
        inst.components.fueled:StartConsuming() --resume fuel consumption incase you were interrupted from fueltaskfn
    end
end

local function fuelsectioncallback(new, old, inst)
    if new == 0 and old > 0 then
        inst.machinestate = MACHINESTATES.OFF
        inst.AnimState:PlayAnimation("turn" .. inst.machinestate)
        inst.AnimState:PushAnimation("idle" .. inst.machinestate, true)
        inst.SoundEmitter:KillSound("loop")
        if inst.fueltask ~= nil then
            inst.fueltask:Cancel()
            inst.fueltask = nil
        end
    elseif new > 0 and old == 0 then
        inst.machinestate = MACHINESTATES.ON
        inst.AnimState:PlayAnimation("turn" .. inst.machinestate)
        inst.AnimState:PushAnimation("idle" .. inst.machinestate, true)
        if not inst.SoundEmitter:PlayingSound("loop") then
            --inst.SoundEmitter:PlaySound("dontstarve_DLC002/common/icemachine_lp", "loop")
        end
        if inst.fueltask == nil then
            inst.fueltask = inst:DoPeriodicTask(TASK_TIME, fueltaskfn)
        end
    end
end

local function getstatus(inst)
    local sec = inst.components.fueled:GetCurrentSection()
    if sec == 0 then
        return "OUT"
    elseif sec <= 4 then
        local t = { "VERYLOW", "LOW", "NORMAL", "HIGH" }
        return t[sec]
    end
end

local function onbuilt(inst)
    inst.AnimState:PlayAnimation("place")
    inst.AnimState:PushAnimation("idle" .. inst.machinestate)
    --inst.SoundEmitter:PlaySound("dontstarve_DLC002/common/icemaker_place")
    inst.SoundEmitter:PlaySound("dontstarve/common/researchmachine_place")
end

local function onFloodedStart(inst)
    if inst.components.fueled then
        inst.components.fueled.accepting = false
    end
end

local function onFloodedEnd(inst)
    if inst.components.fueled then
        inst.components.fueled.accepting = true
    end
end

local function fn(Sim)
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    local minimap = inst.entity:AddMiniMapEntity()
    minimap:SetIcon("icemaker.tex")

    inst.AnimState:SetBank("icemachine")
    inst.AnimState:SetBuild("icemachine")

    MakeObstaclePhysics(inst, .4)

    inst:AddTag("structure")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst;
    end

    inst:AddComponent("lootdropper")

    inst:AddComponent("fueled")

    local multiple = 2.25;
    inst.components.fueled.maxfuel = TUNING.CAMPFIRE_FUEL_MAX * multiple -- 270 * x
    inst.components.fueled.accepting = true
    inst.components.fueled:SetSections(4)
    inst.components.fueled.ontakefuelfn = ontakefuelfn
    inst.components.fueled:SetUpdateFn(fuelupdatefn)
    inst.components.fueled:SetSectionCallback(fuelsectioncallback)
    inst.components.fueled:InitializeFuelLevel(TUNING.CAMPFIRE_FUEL_START * multiple)
    inst.components.fueled:StartConsuming()

    inst:AddComponent("inspectable")
    inst.components.inspectable.getstatus = getstatus

    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(4)
    inst.components.workable:SetOnFinishCallback(onhammered)
    --inst.components.workable:SetOnWorkCallback(onhit) -- 贴图有问题！所以不要 onhit 了

    inst.machinestate = MACHINESTATES.ON
    inst:ListenForEvent("onbuilt", onbuilt)

    return inst
end

return Prefab("mie_icemaker", fn, assets, prefabs),
MakePlacer("mie_icemaker_placer", "icemachine", "icemachine", "idle_off")
