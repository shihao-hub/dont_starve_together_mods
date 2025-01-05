---
--- @author zsh in 2023/4/26 22:23
---

local function dragonflyfurnace_projectile()
    local assets = {
        Asset("ANIM", "anim/firefighter_projectile.zip"),
    }

    local prefabs = {
        "dragonfurnace_smoke_fx",
    }

    local function OnHit(inst)
        local pt = inst:GetPosition()
        local leftovers = {}
        local hascaught = false
        local target = inst.components.complexprojectile.owningweapon
        local canpickup = (target ~= nil and target:IsValid())
                and (target.components.inventory ~= nil and target.components.inventory:IsOpenedBy(target))
                and (target.sg:HasStateTag("idle") and target:IsNear(inst, 0.5))

        for slot, item in pairs(inst.components.inventory.itemslots) do
            if canpickup and not item:HasTag("ashes") then
                hascaught = true
                if not target.components.inventory:GiveItem(item, nil, pt) then
                    table.insert(leftovers, item)
                end
            else
                table.insert(leftovers, item)
            end
        end

        for num, item in ipairs(leftovers) do
            item.components.inventoryitem:RemoveFromOwner(true)
            item.components.inventoryitem:OnDropped()
            item.components.inventoryitem:DoDropPhysics(pt.x, -0.75, pt.z, true, num == 1 and 0.3 or 0.6)
            if item.components.bloomer == nil and item.AnimState:GetBloomEffectHandle() then
                item:AddComponent("bloomer")
                item.components.bloomer:PushBloom(item, item.AnimState:GetBloomEffectHandle(), -999)
            end
            SpawnPrefab("deerclops_laserhit"):SetTarget(item)
        end

        if hascaught then
            target:AddDebuff(inst.prefab, "fireover", 5 * FRAMES)
            target:PushEvent("burnt")
            target.sg:GoToState("item_hat")
            target.sg:AddStateTag("notalking")
        else
            if inst:IsOnPassablePoint() then
                SpawnPrefab("deerclops_laserscorch").Transform:SetPosition(pt.x, 0, pt.z)
            end
            if leftovers[1] ~= nil then
                leftovers[1]:SpawnChild("dragonfurnace_smoke_fx")
            end
        end

        inst:Remove()
    end

    local function LaunchProjectile(inst, loot, pt, source, target)
        for item in pairs(loot) do
            inst.components.inventory:GiveItem(item)
        end
        local scale = Remap(inst.components.inventory:NumItems(), 1, 3, 1, 1.4)
        inst.AnimState:SetScale(scale, scale)
        inst.Transform:SetFromProxy(source.GUID)
        inst.components.complexprojectile:Launch(pt, source, target)
    end

    local function OnLoad(inst, data)
        inst.components.inventory:DropEverything()
        inst:DoTaskInTime(0, inst.Remove)
    end

    local function OnFireFXDirty(inst)
        local firefx = inst._firefx:value()
        firefx._light.Light:SetRadius(0.3)
    end

    local function fn()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddPhysics()
        inst.entity:AddAnimState()
        inst.entity:AddSoundEmitter()
        inst.entity:AddNetwork()

        inst.Physics:SetMass(1)
        inst.Physics:SetFriction(0)
        inst.Physics:SetDamping(0)
        inst.Physics:SetCollisionGroup(COLLISION.CHARACTERS)
        inst.Physics:ClearCollisionMask()
        inst.Physics:CollidesWith(COLLISION.GROUND)
        inst.Physics:SetCapsule(0, 0)
        inst.Physics:SetDontRemoveOnSleep(true)

        inst.AnimState:OverrideShade(0.15)
        inst.AnimState:SetLightOverride(0.4)
        inst.AnimState:SetAddColour(1, 0, 0, 1)
        inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
        inst.AnimState:SetBank("firefighter_projectile")
        inst.AnimState:SetBuild("firefighter_projectile")
        inst.AnimState:PlayAnimation("spin_loop", true)

        inst.SoundEmitter:PlaySound("dontstarve/common/staff_star_create", nil, 0.5)
        inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/dragonfly/firedup", "loop")

        inst:AddTag("NOCLICK")
        inst:AddTag("projectile")

        inst._firefx = net_entity(inst.GUID, "dragonflyfurnace_projectile._firefx", "firefxdirty")

        if not TheNet:IsDedicated() then
            inst:ListenForEvent("firefxdirty", OnFireFXDirty)
        end

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end

        inst.firefx = inst:SpawnChild("torchfire_rag")
        inst.firefx.SoundEmitter:SetMute(true)
        inst.firefx._light.Light:SetRadius(0.3)
        inst._firefx:set(inst.firefx)

        inst:AddComponent("complexprojectile")
        inst.components.complexprojectile:SetHorizontalSpeed(6)
        inst.components.complexprojectile:SetGravity(-25)
        inst.components.complexprojectile:SetLaunchOffset(Point(0, 0.5))
        inst.components.complexprojectile:SetOnHit(OnHit)

        inst:AddComponent("inventory")

        inst.LaunchProjectile = LaunchProjectile
        inst.OnLoad = OnLoad

        return inst
    end

    return Prefab("mone_dragonflyfurnace_projectile", fn, assets, prefabs);
end

local function fireover()
    local function PushFireOverlay(inst, target)
        if target.components.health ~= nil then
            target.components.health:DoFireDamage(0, nil, true)
        end
    end

    local function OnAttached(inst, target, symbol, offset, time)
        if not inst.components.timer:TimerExists("fireover") then
            inst.components.timer:StartTimer("fireover", time or 1)
        end
        inst:DoPeriodicTask(0, PushFireOverlay, nil, target)
        PushFireOverlay(inst, target)
    end

    local function OnExtended(inst, target, symbol, offset, time)
        inst.components.timer:SetTimeLeft("fireover", time or 1)
    end

    local function fn()
        local inst = CreateEntity()

        inst.entity:AddTransform()

        inst:AddTag("CLASSIFIED")

        inst:AddComponent("debuff")
        inst.components.debuff:SetAttachedFn(OnAttached)
        inst.components.debuff:SetExtendedFn(OnExtended)
        inst.components.debuff:SetDetachedFn(inst.Remove)

        inst:AddComponent("timer")
        inst:ListenForEvent("timerdone", inst.Remove)

        inst.persists = false

        return inst
    end

    return Prefab("mone_fireover", fn);
end

require "prefabutil"

local prefabs = {
    "collapse_big",
}

local assets = {
    Asset("ANIM", "anim/dragonfly_furnace.zip"),
    Asset("MINIMAP_IMAGE", "dragonfly_furnace"),
}

local function getstatus(inst)
    return "HIGH"
end

local function onworkfinished(inst)
    inst.components.lootdropper:DropLoot()
    local fx = SpawnPrefab("collapse_big")
    fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
    fx:SetMaterial("metal")
    inst:Remove()
end

local function onworked(inst)
    if inst._task2 ~= nil then
        inst._task2:Cancel()
        inst._task2 = nil

        inst.SoundEmitter:PlaySound("dontstarve/common/together/dragonfly_furnace/fire_LP", "loop")

        if inst._task1 ~= nil then
            inst._task1:Cancel()
            inst._task1 = nil
        end
    end
    inst.AnimState:PlayAnimation("hi_hit")
    inst.AnimState:PushAnimation("hi")
end

local function BuiltTimeLine1(inst)
    inst._task1 = nil
    inst.SoundEmitter:PlaySound("dontstarve/common/fireAddFuel")
end

local function BuiltTimeLine2(inst)
    inst._task2 = nil
    inst.SoundEmitter:PlaySound("dontstarve/common/together/dragonfly_furnace/light")
    inst.SoundEmitter:PlaySound("dontstarve/common/together/dragonfly_furnace/fire_LP", "loop")
end

local function onbuilt(inst)
    inst.AnimState:PlayAnimation("place")
    inst.AnimState:PushAnimation("hi_pre", false)
    inst.AnimState:PushAnimation("hi")
    inst.SoundEmitter:KillSound("loop")
    inst.SoundEmitter:PlaySound("dontstarve/common/together/dragonfly_furnace/place")
    if inst._task2 ~= nil then
        inst._task2:Cancel()
        if inst._task1 ~= nil then
            inst._task1:Cancel()
        end
    end
    inst._task1 = inst:DoTaskInTime(30 * FRAMES, BuiltTimeLine1)
    inst._task2 = inst:DoTaskInTime(40 * FRAMES, BuiltTimeLine2)
end

local function onsavesalad(inst, data)
    data.salad = true
end

local function makesalad(inst)
    inst.AnimState:SetMultColour(.1, 1, .1, 1)

    inst:AddComponent("named")
    inst.components.named:SetName("Salad Furnace")

    inst.OnSave = onsavesalad
end

local function onload(inst, data)
    if data ~= nil and data.salad then
        makesalad(inst)
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddLight()
    inst.entity:AddNetwork()

    MakeObstaclePhysics(inst, .5)

    inst.MiniMapEntity:SetIcon("dragonfly_furnace.png")

    inst.Light:Enable(true)
    inst.Light:SetRadius(1.0)
    inst.Light:SetFalloff(.9)
    inst.Light:SetIntensity(0.5)
    inst.Light:SetColour(235 / 255, 121 / 255, 12 / 255)

    inst.AnimState:SetBank("dragonfly_furnace")
    inst.AnimState:SetBuild("dragonfly_furnace")
    inst.AnimState:PlayAnimation("hi", true)
    inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
    inst.AnimState:SetLightOverride(0.4)

    -- 变色
    --inst.AnimState:SetMultColour(.1, 1, .1, 1)

    inst:AddTag("structure")
    inst:AddTag("wildfireprotected")

    --cooker (from cooker component) added to pristine state for optimization
    inst:AddTag("cooker")

    --HASHEATER (from heater component) added to pristine state for optimization
    inst:AddTag("HASHEATER")

    inst.SoundEmitter:PlaySound("dontstarve/common/together/dragonfly_furnace/fire_LP", "loop")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    -----------------------
    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(6)
    inst.components.workable:SetOnFinishCallback(onworkfinished)
    inst.components.workable:SetOnWorkCallback(onworked)

    -----------------------
    inst:AddComponent("cooker")
    inst:AddComponent("lootdropper")

    -----------------------
    inst:AddComponent("inspectable")
    inst.components.inspectable.getstatus = getstatus

    -----------------------
    inst:AddComponent("heater")
    inst.components.heater.heat = 135 -- 115
    --inst.components.heater.heat = 115

    -----------------------
    MakeHauntableWork(inst)

    inst:ListenForEvent("onbuilt", onbuilt)
    inst.OnLoad = onload

    return inst
end

local function saladfurnacefn()
    local inst = fn()

    inst:SetPrefabName("mone_dragonflyfurnace")

    if not TheWorld.ismastersim then
        return inst
    end

    makesalad(inst)

    return inst
end

return Prefab("mone_dragonflyfurnace", fn, assets, prefabs),
--Prefab("mone_saladfurnace", saladfurnacefn, assets, prefabs),
MakePlacer("mone_dragonflyfurnace_placer", "dragonfly_furnace", "dragonfly_furnace", "idle"),
dragonflyfurnace_projectile(), fireover()
