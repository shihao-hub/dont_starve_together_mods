---
--- @author zsh in 2023/7/8 0:01
---

require "prefabutil"

local easing = require("easing")

local assets = {
    Asset("ANIM", "anim/poop_flingomatic.zip"),
    Asset("IMAGE", "minimap/poop_flingomatic.tex"),
    Asset("ATLAS", "minimap/poop_flingomatic.xml"),
    Asset("ANIM", "anim/ui_chest_3x3.zip"),
}

local prefabs = {
    "fertilizer_projectile",
    "collapse_small",
}

local FERTILIZATION_RANGE = 20
local N_MAX = 10
local T_MAX = 3
local CHECK_FERT_TIME = 5

local function LaunchProjectile(inst, target, item)
    local waittime = 0.15
    local x, y, z = inst.Transform:GetWorldPosition()

    local targetpos = target:GetPosition()

    inst:DoTaskInTime(waittime, function()

        local projectile = SpawnPrefab("fertilizer_projectile")
        projectile.Transform:SetPosition(x, y, z)
        projectile.AnimState:SetScale(0.5, 0.5)
        projectile.target = target
        projectile.item = item



        -- So, I need to pass to the projectile the item AnimState Bank and Build
        -- The only way I found to read these parameters is with the GetDebugString()
        -- https://forums.kleientertainment.com/forums/topic/66347-animstate/
        -- Thanks Aquaterion for your question and DarkXero for your answer!

        local dstring = item.GetDebugString and item:GetDebugString()
        if dstring then
            local bank, build, anim = string.match(dstring, "AnimState: bank: (.*) build: (.*) anim: (.*) anim")
            if bank and build and anim then
                if bank == "FROMNUM" then
                    bank = "birdegg" -- For some reason the birdegg get the wrong bank
                end
                projectile.AnimState:SetBank(bank)
                projectile.AnimState:SetBuild(build)
                projectile.AnimState:PlayAnimation(anim, false)
                projectile.AnimState:SetTime(projectile.AnimState:GetCurrentAnimationLength()) -- To stop dump animation
            end
        end

        local dx = targetpos.x - x
        local dz = targetpos.z - z
        local rangesq = dx * dx + dz * dz
        local maxrange = FERTILIZATION_RANGE
        local speed = easing.linear(rangesq, 20, 3, maxrange * maxrange)
        projectile.components.complexprojectile:SetHorizontalSpeed(speed)
        projectile.components.complexprojectile:SetGravity(-25)
        projectile.components.complexprojectile:Launch(targetpos, inst, inst)
    end)
end


----------------------

local function onopen(inst)
    if not inst:HasTag("burnt") then
        if inst.components.machine and inst.components.machine.ison == true then
            inst.AnimState:PlayAnimation("open")
            inst.SoundEmitter:PlaySound("dontstarve/common/together/portable/spicer/lid_open")
        end
        inst.isopen = true
    end
end

local function onclose(inst)
    if not inst:HasTag("burnt") then
        if inst.components.machine and inst.components.machine.ison == true then
            inst.AnimState:PlayAnimation("close")
            inst.AnimState:PushAnimation("idle", true)
            inst:DoTaskInTime(0.4, function()
                inst.SoundEmitter:PlaySound("dontstarve/common/together/portable/spicer/lid_close")
            end)
        end
        inst.isopen = false
    end
end

local function onturnon(inst)
    if not inst:HasTag("burnt") then
        if inst.isopen == false then
            inst.AnimState:PlayAnimation("close")
            inst.AnimState:PushAnimation("idle", true)
            inst:DoTaskInTime(0.4, function()
                inst.SoundEmitter:PlaySound("dontstarve/common/together/portable/spicer/lid_close")
            end)
        end
        inst.components.machine.ison = true
    end
end

local function onturnoff(inst)
    if not inst:HasTag("burnt") then
        if inst.isopen == false then
            inst.AnimState:PlayAnimation("open")
            inst.SoundEmitter:PlaySound("dontstarve/common/together/portable/spicer/lid_open")
        end
        inst.components.machine.ison = false
    end
end

local function OnBurnt(inst)
    DefaultBurntStructureFn(inst)
    inst:RemoveComponent("machine")
end

----------------------

local function onhammered(inst, worker)
    if inst.components.burnable ~= nil and inst.components.burnable:IsBurning() then
        inst.components.burnable:Extinguish()
    end
    inst.SoundEmitter:KillSound("firesuppressor_idle")
    inst.components.lootdropper:DropLoot()
    local fx = SpawnPrefab("collapse_small")
    fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
    fx:SetMaterial("wood")
    inst:Remove()
end

local function onhit(inst, worker)
    if not inst:HasTag("burnt") then
        inst.components.container:Close()
        inst.AnimState:PlayAnimation("hit")
        inst.components.container:DropEverything()
        inst.components.machine.ison = true
        -- TODO: A hit animation for it when its closed and when its open, but not now
    end
end

local function onsave(inst, data)
    if inst:HasTag("burnt") or (inst.components.burnable ~= nil and inst.components.burnable:IsBurning()) then
        data.burnt = true
    end
end

local function onload(inst, data)
    if data ~= nil and data.burnt and inst.components.burnable ~= nil and inst.components.burnable.onburnt ~= nil then
        inst.components.burnable.onburnt(inst)
    end
end

local function onbuilt(inst)
    inst.SoundEmitter:PlaySound("dontstarve_DLC001/common/firesupressor_craft")
    inst.AnimState:PlayAnimation("place")
    inst.AnimState:PushAnimation("idle", true)
end

local function return_item(inst)
    -- Ok, maybe this is dumb, but I need to return first non-empty elemnt of the table without using breaks
    for k, v in pairs(inst.components.container.slots) do
        if v then
            return v
        end
    end
end

local function CheckForFertilization(inst)
    if not inst:HasTag("burnt") and inst.components.machine then
        local x, y, z = inst.Transform:GetWorldPosition()
        local n = 0
        local item
        local projectile_item
        if inst.isopen == false and inst.components.machine.ison == true then
            for k, v in ipairs(TheSim:FindEntities(x, y, z, inst.fertilization_range)) do
                if (v.components.pickable and v.components.pickable:IsBarren()) or
                        (v.components.grower and v.components.grower.cycles_left == 0) then
                    n = n + 1
                    --TheNet:SystemMessage(v.prefab, false)
                    if n <= N_MAX then
                        inst:DoTaskInTime(n * T_MAX / N_MAX, function()
                            if not inst:HasTag("burnt") and inst.components.machine and
                                    inst.components.machine.ison == true and inst.isopen == false then
                                -- Double check due to the DoTaskInTime
                                item = return_item(inst)
                                inst.AnimState:PlayAnimation("firing")
                                if item and item.components.fertilizer then
                                    -- Well, I know that this container can only allow fertilizers inside, but an extra check is always a good thing
                                    if item.prefab == "fertilizer" then
                                        item.components.finiteuses:Use()
                                        projectile_item = SpawnPrefab("poop")
                                    elseif item.components.stackable then
                                        projectile_item = SpawnPrefab(item.prefab) -- So here I'm duplicating the item prefab because the Fertilize function of the projectile will consume it
                                        if item.components.stackable.stacksize > 1 then
                                            item.components.stackable:SetStackSize(item.components.stackable.stacksize - 1)
                                        else
                                            inst.components.container:RemoveItem(item, true):Remove()
                                        end
                                    else
                                        projectile_item = SpawnPrefab("poop")
                                    end
                                    inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/dragonfly/buttstomp") --perfect
                                    LaunchProjectile(inst, v, projectile_item)
                                else
                                    inst.SoundEmitter:PlaySound("dontstarve/creatures/together/bee_queen/beeguard/puff")
                                end
                            end
                        end)
                    end
                end
            end
        end
    end
end

--------------------------------------------------------------------------
local PLACER_SCALE = 1.77

local function OnEnableHelper(inst, enabled)
    if enabled then
        if inst.helper == nil then
            inst.helper = CreateEntity()

            --[[Non-networked entity]]
            inst.helper.entity:SetCanSleep(false)
            inst.helper.persists = false

            inst.helper.entity:AddTransform()
            inst.helper.entity:AddAnimState()

            inst.helper:AddTag("CLASSIFIED")
            inst.helper:AddTag("NOCLICK")
            inst.helper:AddTag("placer")

            inst.helper.Transform:SetScale(PLACER_SCALE, PLACER_SCALE, PLACER_SCALE)

            inst.helper.AnimState:SetBank("poop_flingomatic")
            inst.helper.AnimState:SetBuild("poop_flingomatic")
            inst.helper.AnimState:PlayAnimation("placer")
            inst.helper.AnimState:SetLightOverride(1)
            inst.helper.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
            inst.helper.AnimState:SetLayer(LAYER_BACKGROUND)
            inst.helper.AnimState:SetSortOrder(1)
            inst.helper.AnimState:SetAddColour(0, .2, .5, 0)

            inst.helper.entity:SetParent(inst.entity)
        end
    elseif inst.helper ~= nil then
        inst.helper:Remove()
        inst.helper = nil
    end
end

--------------------------------------------------------------------------

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddLight()
    inst.entity:AddNetwork()

    local minimap = inst.entity:AddMiniMapEntity()
    minimap:SetIcon("poop_flingomatic.tex")

    MakeObstaclePhysics(inst, 0.5)

    inst.AnimState:SetBank("poop_flingomatic")
    inst.AnimState:SetBuild("poop_flingomatic")
    inst.AnimState:PlayAnimation("idle", true)
    --    inst.AnimState:OverrideSymbol("swap_meter", "firefighter_meter", "10")

    inst:AddTag("structure")


    --Dedicated server does not need deployhelper
    if not TheNet:IsDedicated() then
        inst:AddComponent("deployhelper")
        inst.components.deployhelper.onenablehelper = OnEnableHelper
    end

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.isopen = false

    inst:ListenForEvent("onbuilt", onbuilt)

    inst:AddComponent("inspectable")
    --  inst.components.inspectable.getstatus = getstatus

    inst:AddComponent("container")
    inst.components.container:WidgetSetup("poop_flingomatic")
    inst.components.container.onopenfn = onopen
    inst.components.container.onclosefn = onclose

    inst:AddComponent("machine")
    inst.components.machine.turnonfn = onturnon
    inst.components.machine.turnofffn = onturnoff
    inst.components.machine.cooldowntime = 0.5
    inst.components.machine.ison = true

    inst:AddComponent("lootdropper")
    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(4)
    inst.components.workable:SetOnFinishCallback(onhammered)
    inst.components.workable:SetOnWorkCallback(onhit)

    MakeMediumBurnable(inst, nil, nil, true)
    MakeMediumPropagator(inst)
    inst.components.burnable:SetOnBurntFn(OnBurnt)

    inst.fertilization_range = FERTILIZATION_RANGE
    inst._isupdating = inst:DoPeriodicTask(CHECK_FERT_TIME, CheckForFertilization, 5)

    inst.LaunchProjectile = LaunchProjectile

    inst.OnSave = onsave
    inst.OnLoad = onload
    --inst.OnLoadPostPass = OnLoadPostPass

    inst.components.machine:TurnOn()

    MakeHauntableWork(inst)

    return inst
end

local function placer_postinit_fn(inst)
    --Show the flingo placer on top of the flingo range ground placer

    local placer2 = CreateEntity()

    --[[Non-networked entity]]
    placer2.entity:SetCanSleep(false)
    placer2.persists = false

    placer2.entity:AddTransform()
    placer2.entity:AddAnimState()

    placer2:AddTag("CLASSIFIED")
    placer2:AddTag("NOCLICK")
    placer2:AddTag("placer")

    local s = 1 / PLACER_SCALE
    placer2.Transform:SetScale(s, s, s)

    placer2.AnimState:SetBank("poop_flingomatic")
    placer2.AnimState:SetBuild("poop_flingomatic")
    placer2.AnimState:PlayAnimation("idle", false)
    placer2.AnimState:SetLightOverride(1)

    placer2.entity:SetParent(inst.entity)

    inst.components.placer:LinkEntity(placer2)
end

return Prefab("poop_flingomatic", fn, assets, prefabs),
MakePlacer("poop_flingomatic_placer", "poop_flingomatic", "poop_flingomatic", "placer", true, nil, nil, PLACER_SCALE, nil, nil, placer_postinit_fn)
