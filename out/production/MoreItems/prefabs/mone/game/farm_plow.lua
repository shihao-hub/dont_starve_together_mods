---
--- @author zsh in 2023/6/9 22:23
---

require "prefabutil"

local assets = {
    Asset("ANIM", "anim/farm_plow.zip"),
    Asset("ANIM", "anim/farm_soil.zip"),
}

local assets_item = {
    Asset("ANIM", "anim/farm_plow.zip"),
}

local prefabs = {
    "farm_soil_debris",
    "farm_soil",
    "dirt_puff",
}

local prefabs_item = {
    "farm_plow",
    "farm_plow_item_placer",
    "tile_outline",
}

local function onhammered(inst)
    local x, y, z = inst.Transform:GetWorldPosition()

    local fx = SpawnPrefab("collapse_small")
    fx.Transform:SetPosition(x, y, z)

    if inst.deploy_item_save_record ~= nil then
        local item = SpawnSaveRecord(inst.deploy_item_save_record)
        item.Transform:SetPosition(x, y, z)
    end

    inst:Remove()
end

local function item_foldup_finished(inst)
    inst:RemoveEventCallback("animqueueover", item_foldup_finished)
    inst.AnimState:PlayAnimation("idle_packed")
    inst.components.inventoryitem.canbepickedup = true

    -- 自动归还
    local deployer = inst.mone_deployer;
    if deployer and deployer:IsValid()
            and inst:IsNear(deployer, 20) and deployer.components.inventory then
        deployer.components.inventory:GiveItem(inst, nil, inst:GetPosition());
        inst.mone_deployer = nil;
    end
end

local function Finished(inst, force_fx)
    local x, y, z = inst.Transform:GetWorldPosition()
    if inst.deploy_item_save_record ~= nil then
        local item = SpawnSaveRecord(inst.deploy_item_save_record)
        item.Transform:SetPosition(x, y, z)
        item.components.inventoryitem.canbepickedup = false

        item.mone_deployer = inst.mone_deployer;

        item.AnimState:PlayAnimation("collapse", false)
        item:ListenForEvent("animqueueover", item_foldup_finished)

        item.SoundEmitter:PlaySound("farming/common/farm/plow/collapse")

        SpawnPrefab("dirt_puff").Transform:SetPosition(x, y, z)
        item.SoundEmitter:PlaySound("farming/common/farm/plow/dirt_puff")
    else
        SpawnPrefab("collapse_small").Transform:SetPosition(x, y, z)
    end

    inst:PushEvent("finishplowing")
    inst:Remove()
end

local TILLSOIL_IGNORE_TAGS = {
    "NOBLOCK", "FX", "INLIMBO", "DECOR",
    "WALKABLEPLATFORM",
    "_inventoryitem",
    "player", "playerghost",
    "soil",
    "flying", "companion",
    "mone_farm_plow",
}
local function spawn_farm_soils(inst)
    local x, y, z = inst.Transform:GetWorldPosition();
    local cx, cy, cz = TheWorld.Map:GetTileCenterPoint(x, y, z);

    local _ents = TheWorld.Map:GetEntitiesOnTileAtPoint(cx, 0, cz);
    local ents = _ents;
    for _, v in ipairs(ents) do
        if v ~= inst then
            if v:HasTag("soil") then
                v:PushEvent("collapsesoil");
                --elseif v:HasTag("farm_debris") and v:HasTag("farm_plant_killjoy") then
                --    v:Remove();
            elseif v.prefab == "farm_soil_debris" then
                v:Remove();
            end
        end
    end

    -- 生成 9 个坑，10 个坑有点麻烦吧，需要获取相机视角。
    local spacing = 1.3;
    for i = -1, 1 do
        for j = -1, 1 do
            local nx = cx + spacing * i;
            local nz = cz + spacing * j;

            if TheWorld.Map:IsDeployPointClear(Vector3(nx, 0, nz), nil, GetFarmTillSpacing(), nil, nil, nil, TILLSOIL_IGNORE_TAGS) then
                local farm_soil = SpawnPrefab("farm_soil")
                farm_soil.Transform:SetPosition(nx, 0, nz)
            end
        end
    end
end

local function DoDrilling(inst)
    inst:RemoveEventCallback("animover", DoDrilling)

    inst.AnimState:PlayAnimation("drill_loop", true)
    inst.SoundEmitter:PlaySound("farming/common/farm/plow/LP", "loop")
    ------------

    if not inst.components.timer:TimerExists("drilling") then
        inst.components.timer:StartTimer("drilling", 1);
    end

    local x, y, z = inst.Transform:GetWorldPosition();
    if TheWorld.Map:GetTileAtPoint(x, 0, z) == GROUND.FARMING_SOIL then
        inst:DoTaskInTime(0.5, spawn_farm_soils);
    end
end

local function timerdone(inst, data)
    if data ~= nil and data.name == "drilling" then
        if inst.components.terraformer ~= nil then
            if not inst.components.terraformer:Terraform(inst:GetPosition()) then
                Finished(inst)
            end
        else
            Finished(inst)
        end
    end
end

local function StartUp(inst)
    inst.AnimState:PlayAnimation("drill_pre")
    inst:ListenForEvent("animover", DoDrilling)
    inst.SoundEmitter:PlaySound("farming/common/farm/plow/drill_pre")

    inst.startup_task = nil
end

local function OnSave(inst, data)
    data.deploy_item = inst.deploy_item_save_record
end

local function OnLoadPostPass(inst, newents, data)
    if data ~= nil then
        inst.deploy_item_save_record = data.deploy_item
    end

    if inst.components.timer:TimerExists("drilling") then
        if inst.startup_task ~= nil then
            inst.startup_task:Cancel()
            inst.startup_task = nil
        end
        DoDrilling(inst)
    end
end

local function main_fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()
    inst.entity:AddSoundEmitter()

    MakeObstaclePhysics(inst, 0.5)

    inst.AnimState:SetBank("farm_plow")
    inst.AnimState:SetBuild("farm_plow")
    inst.AnimState:OverrideSymbol("soil01", "farm_soil", "soil01")

    inst:AddTag("scarytoprey")

    inst:AddTag("mone_farm_plow")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")

    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(1)
    inst.components.workable:SetOnFinishCallback(onhammered)

    inst:AddComponent("timer")

    --MakeMediumBurnable(inst, nil, nil, true)
    --MakeLargePropagator(inst)

    inst.deploy_item_save_record = nil

    inst.startup_task = inst:DoTaskInTime(0, StartUp)

    inst:ListenForEvent("timerdone", timerdone)

    inst.OnSave = OnSave
    inst.OnLoadPostPass = OnLoadPostPass

    return inst
end

local function item_ondeploy(inst, pt, deployer)
    local cx, cy, cz = TheWorld.Map:GetTileCenterPoint(pt:Get())

    local obj = SpawnPrefab("mone_farm_plow")
    obj.Transform:SetPosition(cx, cy, cz)

    inst.components.finiteuses:Use(1)
    if inst:IsValid() then
        obj.deploy_item_save_record = inst:GetSaveRecord()
        obj.mone_deployer = deployer;
        inst:Remove()
    end
end

local function can_plow_tile(inst, pt, mouseover, deployer)
    local x, z = pt.x, pt.z

    -- 仅耕作土地类型可以放置！
    if TheWorld.Map:GetTileAtPoint(x, 0, z) == GROUND.FARMING_SOIL then
        return true;
    end

    return false;
end

local function item_fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()
    inst.entity:AddSoundEmitter()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("farm_plow")
    inst.AnimState:SetBuild("farm_plow")
    inst.AnimState:PlayAnimation("idle_packed")

    inst:AddTag("usedeploystring")
    inst:AddTag("tile_deploy")

    inst:AddTag("pheromonestone_target")
    inst:AddTag("mone_auto_sorter_exclude_prefabs")

    MakeInventoryFloatable(inst, "small", 0.1, 0.8)

    inst._custom_candeploy_fn = can_plow_tile -- for DEPLOYMODE.CUSTOM

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "farm_plow_item";
    inst.components.inventoryitem.atlasname = "images/inventoryimages1.xml";

    inst:AddComponent("deployable")
    inst.components.deployable:SetDeployMode(DEPLOYMODE.CUSTOM)
    inst.components.deployable.ondeploy = item_ondeploy

    inst:AddComponent("finiteuses")
    inst.components.finiteuses:SetOnFinished(inst.Remove)
    inst.components.finiteuses:SetMaxUses(20)
    inst.components.finiteuses:SetUses(20)

    --MakeSmallBurnable(inst)
    --MakeSmallPropagator(inst)

    MakeHauntableLaunch(inst)

    return inst
end

local function placer_invalid_fn(player, placer)
    if player and player.components.talker then
        player.components.talker:Say(GetString(player, "ANNOUNCE_CANTBUILDHERE_THRONE"))
    end
end

local function placer_fn()
    local inst = CreateEntity()

    inst:AddTag("CLASSIFIED")
    inst:AddTag("NOCLICK")
    inst:AddTag("placer")
    --[[Non-networked entity]]
    inst.entity:SetCanSleep(false)
    inst.persists = false

    inst.entity:AddTransform()
    inst.entity:AddAnimState()

    inst.AnimState:SetBank("farm_plow")
    inst.AnimState:SetBuild("farm_plow")
    inst.AnimState:PlayAnimation("idle_place")
    inst.AnimState:SetLightOverride(1)

    inst:AddComponent("placer")
    inst.components.placer.snap_to_tile = true

    inst.outline = SpawnPrefab("tile_outline")
    inst.outline.entity:SetParent(inst.entity)

    inst.components.placer:LinkEntity(inst.outline)

    return inst
end

return Prefab("mone_farm_plow", main_fn, assets, prefabs),
Prefab("mone_farm_plow_item", item_fn, assets_item, prefabs_item),
Prefab("mone_farm_plow_item_placer", placer_fn)

