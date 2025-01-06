local utils = require("moreitems.main").shihao.utils


-- context, ctx, local, loc
local internal = {
    bool = utils.base.bool,

    invoke = utils.invoke,
    switch = utils.switch,
    all_null = utils.all_null,
    oneof_null = utils.oneof_null,
}

------------------------------------------------------------------------------------------------------------------------
local constants = require("more_items_constants")

local metadata = {
    name = constants.SINGLE_DOG__PREFAB_NAME,
    chinese_name = constants.SINGLE_DOG__PREFAB_CHINESE_NAME,
    assets = {
        Asset("ANIM", "anim/sand_castle.zip"),
    }
}

local function onhammered(inst, worker)
    if inst.components.lootdropper then
        inst.components.lootdropper:DropLoot()
    end

    local x, y, z = inst.Transform:GetWorldPosition()
    if x and y and z then
        local fx = SpawnPrefab("collapse_small")
        if fx then
            fx.Transform:SetPosition(x, y, z)
            fx:SetMaterial("wood")
        end
        inst:Remove()
    end
end

-- 这里的 invoke 体现的也是一种封装思想
local kill_dogs_periodic = internal.invoke(function()
    local function display_fx(dog)
        local x, y, z = dog.Transform:GetWorldPosition()
        if internal.oneof_null(x, y, z) then
            return
        end
    end

    local function percentage_bleeding(dog)
        local maxhealth = dog.components.health.maxhealth
        local percentage = constants.SINGLE_DOG__DETECTION__BLEEDING_PERCENTAGE
        dog.components.health:DoDelta(-maxhealth * percentage, nil, nil, nil, nil, true)
    end

    return function(inst, data)
        local x, y, z = inst.Transform:GetWorldPosition()
        if internal.oneof_null(x, y, z) then
            return
        end
        local dogs = TheSim:FindEntities(x, y, z,
                constants.SINGLE_DOG__DETECTION__RADIUS,
                constants.SINGLE_DOG__DETECTION__MUST_TAGS,
                constants.SINGLE_DOG__DETECTION__CANT_TAGS,
                constants.SINGLE_DOG__DETECTION__MUST_ONE_OF_TAGS)
        for dog in ipairs(dogs) do
            if dog.components.health then
                percentage_bleeding(dog)
                display_fx(dog)
            end
        end
    end
end)

-- TODO: 熔炉的源代码非常值得阅读，似乎是很标准的 OOP，虽然阅读困难，接手也慢，但是熟悉之后肯定能大大增加开发效率，降低开发成本
-- prefab 的 fn 中，最好不要出现匿名函数，建议在外面定义函数
local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()
    inst.entity:AddSoundEmitter()

    MakeObstaclePhysics(inst, constants.SINGLE_DOG__OBSTACLE_PHYSICS_HEIGHT)

    inst.AnimState:SetBank("sand_castle")
    inst.AnimState:SetBuild("sand_castle")
    inst.AnimState:PlayAnimation("full")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")

    inst:AddComponent("lootdropper")

    -- 这个 onhammered 函数显然是通用性极强的函数，为什么这么多重复代码
    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(constants.SINGLE_DOG__WORK_LEFT)
    inst.components.workable:SetOnFinishCallback(onhammered)

    inst:DoPeriodicTask(constants.SINGLE_DOG__DETECTION__CYCLE_LENGTH, kill_dogs_periodic)

    return inst
end

return Prefab(metadata.name, fn, metadata.assets),
MakePlacer(metadata.name .. "_placer", "sand_castle", "sand_castle", "full", nil, nil, nil)
