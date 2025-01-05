---
--- @author zsh in 2023/2/27 10:22
---

--[[ 有待重写 ]]
-- 1、绝对圆形种植？！！！
-- 2、分类内外圈种植？
-- 3、多层种植？
-- 4、周围较小圈内设置成盲区！

-- 2023-02-27-10:22：目前就单纯地修改一下生效范围

-- 2023-04-18：简单重写一下

local config_data = TUNING.MONE_TUNING.GET_MOD_CONFIG_DATA;
config_data.arborist_light = true; -- 发光

local TEXT = require("languages.mone.loc");
local API = require("chang_mone.dsts.API");

-----------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------
local containers = require "containers";
local params = containers.params;

local StorageButton = API.StorageButton;
local storage_fn = StorageButton and StorageButton.storage_fn;
local storage_validfn = StorageButton and StorageButton.storage_validfn;

params.mone_arborist = {
    widget = {
        slotpos = {},
        animbank = "my_chest_ui_4x4",
        animbuild = "my_chest_ui_4x4",
        pos = Vector3(0, 200, 0),
        side_align_tip = 160,
        buttoninfo = {
            text = TEXT.TIDY,
            position = Vector3(0, -190, 0),
            fn = function(inst, doer)
                if inst.components.container ~= nil then
                    API.arrangeContainer(inst);
                elseif inst.replica.container ~= nil and not inst.replica.container:IsBusy() then
                    SendRPCToServer(RPC.DoWidgetButtonAction, nil, inst, nil)
                end
            end,
            validfn = function(inst)
                return inst.replica.container ~= nil and not inst.replica.container:IsEmpty()
            end
        },
        more_items_storage_buttoninfo = {
            text = "高级整理",
            position = Vector3(0, 185, 0),
            fn = storage_fn,
            validfn = storage_validfn
        };
    },
    type = "chest"
}

-- 这是硬编码！注意！
local SEEDS = {
    "pinecone", --松果
    "acorn", --桦栗果
    "twiggy_nut", --多枝树球果
    "marblebean", --大理石豆
    "palmcone_seed" -- 棕榈松果树芽
};

function params.mone_arborist.itemtestfn(container, item, slot)
    return table.contains(SEEDS, item.prefab)
end

for y = 2, -1, -1 do
    for x = -1, 2 do
        table.insert(params.mone_arborist.widget.slotpos, Vector3(80 * x - 40, 80 * y - 40, 0))
    end
end

for k, v in pairs(params) do
    containers.MAXITEMSLOTS = math.max(containers.MAXITEMSLOTS, v.widget.slotpos ~= nil and #v.widget.slotpos or 0)
end
-----------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------
local fns = {};

local assets = {
    Asset("ANIM", "anim/sand_castle.zip"),
}

function fns.onhammered(inst, worker)
    if inst.components.lootdropper then
        inst.components.lootdropper:DropLoot()
    end

    if inst.components.container then
        inst.components.container:DropEverything();
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

function fns.onbuilt(inst)
    inst.SoundEmitter:PlaySound("dontstarve_DLC001/common/firesupressor_craft")
end

function fns.onopenfn(inst)
    inst.SoundEmitter:PlaySound("dontstarve/wilson/chest_open");
end

function fns.onclosefn(inst)
    inst.SoundEmitter:PlaySound("dontstarve/wilson/chest_close");
end

-----------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------

local PLACER_SCALE = 1.38;
local PERIODIC_TIME = 1;
local MIN_RADIUS = 4;
local MAX_RADIUS = 11;
local SCALE = 1;

local function SpawnPositionalPrefab(prefabname, x, y, z)
    if not (x and y and z) then
        return ;
    end
    local sapling = SpawnPrefab(prefabname);
    if sapling == nil then
        return ;
    end
    sapling.Transform:SetPosition(x, y, z);
    return sapling;
end

local function GetSpawnPoint(startPt, radius, seed, arborist)
    local x, y, z = startPt:Get()

    if arborist == nil or seed == nil or not seed:IsValid() or not seed.components.deployable then
        print("GetSpawnPoint: it is impossible!");
        return ;
    end

    if not (x and y and z and TheWorld and TheWorld.Map) then
        return ;
    end

    -- 判断 arborist 是否在陆地上
    if not TheWorld.Map:IsAboveGroundAtPoint(x, y, z, false) then
        startPt = FindNearbyLand(startPt) or startPt;
    end

    local offset = FindWalkableOffset(startPt, math.random() * TWOPI, radius, 12, true, nil, nil, nil);
    if offset then
        offset.x = offset.x + startPt.x;
        offset.z = offset.z + startPt.z;
    end

    -- 避免在虚空中放置的时候崩溃...
    if offset == nil then
        offset = startPt;
    end

    if seed.components.deployable:CanDeploy(offset, nil, arborist, nil) then
        --print("1-可以种植");
        return offset;
    else
        -- 如果不能种植，就从大到小重新更小角度搜索
        for r = radius, MIN_RADIUS, -1 do
            offset = FindWalkableOffset(startPt, math.random() * TWOPI, r, 50, true, nil, nil, nil);
            if offset then
                offset.x = offset.x + startPt.x;
                offset.z = offset.z + startPt.z;
            end
            if seed.components.deployable:CanDeploy(offset, nil, arborist, nil) then
                --print("2-可以种植");
                return offset;
            end
        end
    end
    --print("实在找不到...");
    return offset; -- 实在找不到的话就返回吧...
end

local function getSeedSaplingName(seed)
    if seed.prefab == "palmcone_seed" then
        return "palmcone" .. "_sapling";
    end
    return seed.prefab .. "_sapling";
end

function fns.PlantTrees(inst)
    if not (inst and inst.components.container) then
        return ;
    end

    local seed = inst.components.container:FindItem(function(item)
        return table.contains(SEEDS, item.prefab);
    end)

    if not (seed and seed.prefab and seed.components.deployable) then
        return
    end

    for radius = MIN_RADIUS, MAX_RADIUS do
        local pt = GetSpawnPoint(inst:GetPosition(), radius, seed, inst);
        if pt then
            local can_deploy = seed.components.deployable:CanDeploy(pt, nil, inst, nil);
            if can_deploy --[[这个 CanDeploy 绝对有问题，有些情况间隔太小了。。]] then
                local sapling = SpawnPositionalPrefab(getSeedSaplingName(seed), pt.x, pt.y, pt.z);
                if sapling then
                    sapling:StartGrowing();
                    inst.SoundEmitter:PlaySound("dontstarve/wilson/plant_tree");
                    if seed.components.stackable then
                        seed.components.stackable:Get():Remove();
                    else
                        seed:Remove();
                    end
                    local isplant = sapling:HasTag("deployedplant");
                    if isplant then
                        TheWorld:PushEvent("itemplanted", { doer = inst, pos = sapling:GetPosition() });
                    end
                    break ;
                end
            end
        end

        -- 本意是用 Deploy 函数，但是有 bug
        --if pt and false --[[有些为什么隐藏了？明明种下去了]] then
        --    local single_seed;
        --    if seed.components.stackable then
        --        single_seed = seed.components.stackable:Get();
        --    else
        --        single_seed = seed;
        --    end
        --    single_seed.components.deployable:Deploy(pt, inst, nil);
        --    break ;
        --end
    end
end

function fns.ExtinguishFire(inst)
    if inst:IsAsleep() then
        return ;
    end

    local x, y, z = inst.Transform:GetWorldPosition()
    if not (x and y and z) then
        return ;
    end
    local MUST_TAGS = {};
    local CANT_TAGS = {};
    local ONEOF_TAGS = {};

    local ents = TheSim:FindEntities(x, y, z, MAX_RADIUS + 4, MUST_TAGS, CANT_TAGS, ONEOF_TAGS);

    for _, v in ipairs(ents) do
        if v and v:IsValid() and v.components.burnable then
            if v.components.burnable:IsSmoldering() then
                v.components.burnable:SmotherSmolder();
            end
            if v.components.burnable:IsBurning() then
                v.components.burnable:Extinguish();
            end
        end
    end
end

-----------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------
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

            inst.helper.AnimState:SetBank("firefighter_placement")
            inst.helper.AnimState:SetBuild("firefighter_placement")
            inst.helper.AnimState:PlayAnimation("idle")
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

local function func()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()
    inst.entity:AddSoundEmitter()

    inst.entity:AddMiniMapEntity()
    inst.MiniMapEntity:SetIcon("sand_castle.tex")

    MakeObstaclePhysics(inst, 0.3);

    inst.Transform:SetScale(SCALE, SCALE, SCALE);

    inst.AnimState:SetBank("sand_castle")
    inst.AnimState:SetBuild("sand_castle")
    inst.AnimState:PlayAnimation("full")

    --inst:AddTag("structure"); -- 巨鹿不会攻击

    --Dedicated server does not need deployhelper
    if not TheNet:IsDedicated() then
        inst:AddComponent("deployhelper")
        inst.components.deployhelper.onenablehelper = OnEnableHelper;
    end

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        local old_OnEntityReplicated = inst.OnEntityReplicated
        inst.OnEntityReplicated = function(inst)
            if old_OnEntityReplicated then
                old_OnEntityReplicated(inst)
            end
            if inst and inst.replica and inst.replica.container then
                inst.replica.container:WidgetSetup("mone_arborist");
            end
        end
        return inst
    end

    inst:AddComponent("inspectable")

    inst:AddComponent("container")
    inst.components.container:WidgetSetup("mone_arborist");
    inst.components.container.onopenfn = fns.onopenfn;
    inst.components.container.onclosefn = fns.onclosefn;

    inst:AddComponent("lootdropper")

    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(3)
    inst.components.workable:SetOnFinishCallback(fns.onhammered)

    --local old_Destroy = inst.components.workable.Destroy;
    --function inst.components.workable:Destroy(destroyer)
    --    if not destroyer:HasTag("player") or destroyer.components.playercontroller == nil then
    --        return ;
    --    end
    --    return old_Destroy(self, destroyer);
    --end

    if inst.components.workable then
        local old_Destroy = inst.components.workable.Destroy
        function inst.components.workable:Destroy(destroyer)
            if destroyer.components.playercontroller == nil then
                -- DoNothing
                return ;
            end
            return old_Destroy(self, destroyer)
        end
    end

    inst:AddComponent("preserver")
    inst.components.preserver:SetPerishRateMultiplier(0)

    if config_data.arborist_light then
        inst:DoTaskInTime(0.1, function(inst)
            inst._mone_light_fx = inst._mone_light_fx or SpawnPrefab("mone_light_fx");
            inst._mone_light_fx.Light:SetRadius(MAX_RADIUS - 2);
            inst._mone_light_fx.Light:SetIntensity(0.4);
            inst._mone_light_fx._mone_arborist = inst;
            inst._mone_light_fx.entity:SetParent(inst.entity);
        end);
    end

    inst:ListenForEvent("onbuilt", fns.onbuilt);

    inst:DoPeriodicTask(PERIODIC_TIME, fns.PlantTrees);
    inst:DoPeriodicTask(PERIODIC_TIME * 5, fns.ExtinguishFire);

    return inst;
end

return Prefab("mone_arborist", func, assets),
MakePlacer("mone_arborist_placer", "sand_castle", "sand_castle", "full", nil, nil, nil, SCALE)