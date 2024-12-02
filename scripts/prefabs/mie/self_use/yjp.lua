---
--- @author zsh in 2023/3/1 12:19
---

local function MakePrefab(name, data)
    local fns = {};

    local function spawanfxs(x, y, z, prefab, rad, need, max, nottag)
        local max = max or 50
        local num = 0
        local map = TheWorld.Map
        for k = 1, max do
            local offset = FindValidPositionByFan(
                    math.random() * 2 * PI,
                    math.random(rad),
                    20,
                    function(offset)
                        local pt = Vector3(x + offset.x, 0, z + offset.z)
                        return map:IsPassableAtPoint(pt.x, 0, pt.z, false, true)
                                and not map:IsPointNearHole(pt)
                                and #TheSim:FindEntities(pt.x, 0, pt.z, 1, nottag) <= 0
                    end
            )
            if offset ~= nil then
                SpawnPrefab(prefab).Transform:SetPosition(x + offset.x, 0, z + offset.z)
                num = num + 1
            end
            if num >= need then
                break
            end
        end
    end
    --DebugSpawn"myth_yjp".components.finiteuses:SetPercent(1)
    local function shifei(inst, doer)
        inst.components.finiteuses:Use(20)
        inst.components.rechargeable:StartRecharging()

        local x, y, z = doer.Transform:GetWorldPosition()
        spawanfxs(x, y, z, "mie_yjp_flower", 4, 30, 60, "mie_yjp_flower")
        local ents = TheSim:FindEntities(x, y, z, 28, nil, { "FX", "DECOR", "INLIMBO", "burnt" })
        for i, v in ipairs(ents) do
            if v.components.burnable ~= nil then
                if v.components.witherable ~= nil then
                    v.components.witherable:Protect(TUNING.FIRESUPPRESSOR_PROTECTION_TIME)
                end
                if v.components.burnable then
                    if v.components.burnable:IsBurning() then
                        v.components.burnable:Extinguish(true, TUNING.WATERINGCAN_EXTINGUISH_HEAT_PERCENT)
                    elseif v.components.burnable:IsSmoldering() then
                        v.components.burnable:Extinguish(true)
                    end
                end
            end
            if v.components.temperature ~= nil then
                v.components.temperature:SetTemperature(v.components.temperature:GetCurrent() - TUNING.WATERINGCAN_TEMP_REDUCTION)
            end
            if v.components.moisture ~= nil then
                local waterproofness = v.components.inventory and math.min(v.components.inventory:GetWaterproofness(), 1) or 0
                v.components.moisture:DoDelta(TUNING.PREMIUMWATERINGCAN_WATER_AMOUNT * (1 - waterproofness))
            end
        end

        for k1 = -28, 28, 4 do
            for k2 = -28, 28, 4 do
                local tile = TheWorld.Map:GetTileAtPoint(x + k1, 0, z + k2)
                if tile == GROUND.FARMING_SOIL then
                    TheWorld.components.farming_manager:AddSoilMoistureAtPoint(x + k1, 0, z + k2, 100)
                    local tile_x, tile_z = TheWorld.Map:GetTileCoordsAtPoint(x + k1, 0, z + k2)
                    TheWorld.components.farming_manager:AddTileNutrients(tile_x, tile_z, 100, 100, 100)
                end
            end
        end
        return true
    end

    local function Oncheck(inst)
        local y = inst:GetPosition().y
        inst.Physics:SetMotorVel(0, (5.3 - y) * 32, 0)
    end

    function fns.onuse(inst, doer)
        local item = doer.components.inventory:RemoveItem(inst)
        if item then
            doer.components.sanity:DoDelta(-10)
            item.components.inventoryitem.canbepickedup = false
            local x, y, z = doer.Transform:GetWorldPosition()
            item.Transform:SetPosition(x, 1.5, z)
            item.Physics:SetMotorVel(0, 5, 0)
            item:DoTaskInTime(1, function(item, inst)
                item.Physics:Stop()
                item.jugaogao = item:DoPeriodicTask(0, Oncheck)
                if inst.components.finiteuses.current < 20 then
                    inst.wantdrop = true
                    if TheWorld.state.israining then
                        inst.components.finiteuses:SetPercent(1)
                        TheWorld:PushEvent("ms_forceprecipitation", false)
                    end
                else
                    inst.wantdrop = false
                    item.AnimState:PlayAnimation("water_pre")
                    item.AnimState:PushAnimation("water_idle", false)
                end
            end, inst)
            item:DoTaskInTime(1.2, function(item, inst)
                if inst.wantdrop then
                    if item.jugaogao then
                        item.jugaogao:Cancel()
                        item.jugaogao = nil
                    end
                    item.Physics:Stop()
                    item.components.inventoryitem.canbepickedup = true
                end
            end, inst)

            item:DoTaskInTime(2.4, function(item, doer)
                if not inst.wantdrop then
                    shifei(item, doer)
                    item.AnimState:PlayAnimation("water_back")
                    item.AnimState:PushAnimation("idle", false)
                end
            end, item, doer)
            item:DoTaskInTime(2.65, function(item, inst)
                if not inst.wantdrop then
                    if item.jugaogao then
                        item.jugaogao:Cancel()
                        item.jugaogao = nil
                    end
                    item.Physics:Stop()
                    item.components.inventoryitem.canbepickedup = true
                end
            end, inst)
        end
        return true
    end

    local function percentusedchange(inst)
        if inst.components.finiteuses.current > 0 and not inst.components.rechargeable.recharging then
            inst.components.mie_use_inventory.canuse = true
        else
            inst.components.mie_use_inventory.canuse = false
        end
    end

    function fns.OnSave(inst, data)
        data.uses = inst.components.finiteuses.current
    end

    function fns.OnLoad(inst, data)
        if data ~= nil and data.uses ~= nil then
            inst.components.finiteuses:SetUses(data.uses)
        end
    end
    function fns.addfiniteuses(inst)
        local owner = inst.components.inventoryitem.owner
        if not owner and TheWorld.state.israining and inst.components.finiteuses:GetPercent() < 1 then
            inst.components.finiteuses:Use(-1)
        end
    end

    function fns.onrechargingfn(inst)
        inst.components.mie_use_inventory.canuse = false
    end

    function fns.onstoprechargfn(inst)
        inst.components.mie_use_inventory.canuse = true
    end

    local function fn()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddSoundEmitter()
        inst.entity:AddNetwork()

        inst.entity:AddMiniMapEntity()
        inst.MiniMapEntity:SetIcon(data.minimap);
        -- 这两个函数做了什么？
        --inst.MiniMapEntity:SetIsProxy(true)
        --inst.MiniMapEntity:SetDrawOverFogOfWar(true)

        MakeInventoryPhysics(inst)

        inst.AnimState:SetBank(data.animstate[1])
        inst.AnimState:SetBuild(data.animstate[2])
        inst.AnimState:PlayAnimation(data.animstate[3])

        if data.tags then
            for _, v in ipairs(data.tags) do
                inst:AddTag(v);
            end
        end

        MakeInventoryFloatable(inst)

        inst.onusesgname = "mie_useyjp"

        if not TheWorld.ismastersim then
            return inst;
        end

        inst:AddComponent("inspectable")

        inst:AddComponent("inventoryitem")
        --inst.components.inventoryitem:SetSinks(true); -- 不允许下沉
        inst.components.inventoryitem.imagename = "myth_yjp";
        inst.components.inventoryitem.atlasname = "images/inventoryimages/self_use/inventoryimages/myth_yjp.xml"

        inst:AddComponent("finiteuses")
        inst.components.finiteuses:SetMaxUses(100)
        --inst.components.finiteuses:SetUses(0)
        -- TEST
        inst.components.finiteuses:SetUses(100)

        inst:AddComponent("mie_use_inventory")
        inst.components.mie_use_inventory.canuse = true
        inst.components.mie_use_inventory:SetOnUseFn(fns.onuse)

        inst:AddComponent("mie_rechargeable")
        inst.components.rechargeable = inst.components.mie_rechargeable
        inst.components.rechargeable:SetRechargeTime(5)
        inst.components.rechargeable.rechargingfn = fns.onrechargingfn
        inst.components.rechargeable.stoprechargfn = fns.onstoprechargfn
        inst:RegisterComponentActions("rechargeable")

        inst:DoPeriodicTask(5, fns.addfiniteuses, 5)

        inst:AddComponent("mie_yjp")

        inst.OnSave = fns.OnSave
        inst.OnLoad = fns.OnLoad

        return inst;
    end
    return Prefab(name, fn, data.assets);
end

local function fxfn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    inst.AnimState:SetBank("lavaarena_heal_flowers")
    inst.AnimState:SetBuild("lavaarena_heal_flowers_fx")
    inst.AnimState:Hide("buffed_hide_layer")

    --inst.AnimState:PlayAnimation("in_"..inst.variation)

    inst:AddTag("FX")
    inst:AddTag("NOCLICK")
    inst:AddTag("mie_yjp_flower")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.num = math.random(6)

    inst.AnimState:PlayAnimation("in_" .. inst.num)
    inst.AnimState:PushAnimation("idle_" .. inst.num)

    inst:DoTaskInTime(4 + math.random(), function(inst)
        inst.AnimState:PlayAnimation("out_" .. inst.num)
        inst:ListenForEvent("animover", inst.Remove)
    end, inst)

    inst.persists = false

    return inst
end

return MakePrefab("mie_yjp", {
    assets = {
        Asset("ANIM", "anim/myth_yjp.zip"),
        Asset("ATLAS", "images/inventoryimages/self_use/inventoryimages/myth_yjp.xml"),
        Asset("IMAGE", "images/inventoryimages/self_use/inventoryimages/myth_yjp.tex"),
        Asset("ANIM", "anim/lavaarena_heal_flowers_fx.zip"),
    },
    tags = { "rechargeable", "mie_yjp" },
    minimap = "myth_yjp.tex",
    animstate = { "myth_yjp", "myth_yjp", "idle" },
}), Prefab("mie_yjp_flower", fxfn);