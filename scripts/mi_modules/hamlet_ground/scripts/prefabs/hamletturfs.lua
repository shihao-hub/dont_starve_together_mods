-- local GroundTiles = require("worldtiledefs")

local turfs = {
    { name = "pigruins", anim = "pig_ruins", tile = GROUND.PIGRUINS },
    { name = "rainforest", anim = "rainforest", tile = GROUND.RAINFOREST },
    { name = "deeprainforest", anim = "deepjungle", tile = GROUND.DEEPRAINFOREST },
    { name = "lawn", anim = "checkeredlawn", tile = GROUND.LAWN },
    { name = "gasjungle", anim = "gasjungle", tile = GROUND.GASJUNGLE },
    { name = "moss", anim = "mossy_blossom", tile = GROUND.SUBURB },
    { name = "fields", anim = "farmland", tile = GROUND.FIELDS },
    { name = "foundation", anim = "fanstone", tile = GROUND.FOUNDATION },
    { name = "cobbleroad", anim = "cobbleroad", tile = GROUND.COBBLEROAD }
}

local assets = {
    Asset("ANIM", "anim/turf_1.zip")
}

local prefabs = {
    "gridplacer"
}

local function make_turf(data)
    local function ondeploy(inst, pt, deployer)
        if deployer ~= nil and deployer.SoundEmitter ~= nil then
            deployer.SoundEmitter:PlaySound("dontstarve/wilson/dig")
        end

        local map = TheWorld.Map
        local original_tile_type = map:GetTileAtPoint(pt:Get())
        local x, y = map:GetTileCoordsAtPoint(pt:Get())
        if x ~= nil and y ~= nil then
            map:SetTile(x, y, data.tile)
            map:RebuildLayer(original_tile_type, x, y)
            map:RebuildLayer(data.tile, x, y)
        end

        local minimap = TheWorld.minimap.MiniMap
        minimap:RebuildLayer(original_tile_type, x, y)
        minimap:RebuildLayer(data.tile, x, y)

        inst.components.stackable:Get():Remove()
    end

    local function fn()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddNetwork()

        MakeInventoryPhysics(inst)

        inst.AnimState:SetBank("turf")
        inst.AnimState:SetBuild("turf_1")
        inst.AnimState:PlayAnimation(data.anim)

        inst:AddTag("groundtile")
        inst:AddTag("molebait")

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end

        inst:AddComponent("stackable")
        inst.components.stackable.maxsize = TUNING.STACK_SIZE_MEDITEM

        inst:AddComponent("inspectable")
        inst:AddComponent("inventoryitem")
        inst.components.inventoryitem.imagename = "turf_" .. data.name;
        inst.components.inventoryitem.atlasname = "scripts/mi_modules/hamlet_ground/images/inventoryimages/hamletturfs.xml"

        inst:AddComponent("bait")

        inst:AddComponent("fuel")
        inst.components.fuel.fuelvalue = TUNING.MED_FUEL
        MakeMediumBurnable(inst, TUNING.MED_BURNTIME)
        MakeSmallPropagator(inst)
        MakeHauntableLaunchAndIgnite(inst)

        inst:AddComponent("deployable")
        inst.components.deployable:SetDeployMode(DEPLOYMODE.TURF)
        inst.components.deployable.ondeploy = ondeploy
        inst.components.deployable:SetUseGridPlacer(true)

        ---------------------
        return inst
    end

    return Prefab("mone_turf_" .. data.name, fn, assets, prefabs)
end

local ret = {}
for _, v in ipairs(turfs) do
    table.insert(ret, make_turf(v))
end

return function()
    return unpack(ret);
end
