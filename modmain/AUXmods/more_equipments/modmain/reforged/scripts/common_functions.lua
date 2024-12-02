---
--- @author zsh in 2023/5/21 13:50
---

---@class COMMON_FNS
local COMMON_FNS = {};

-- Reforged: scripts/_common_functions.lua
local PLAYER_EXCLUDE_TAGS = { "player", "companion", "ally" };

function COMMON_FNS.GetPlayerExcludeTags(inst, force_player_tags)
    return (not TheNet:GetPVPEnabled() or force_player_tags) and PLAYER_EXCLUDE_TAGS or {}
end

function COMMON_FNS.ApplyMultiBuild(inst, symbols, build, alt)
    if symbols and build then
        for pt = 1, #symbols do
            --print(pt)
            for i, v in ipairs(symbols[pt]) do
                inst.AnimState:OverrideSymbol(v, alt and build or build .. "_pt" .. pt, v)
            end
        end
    end
end

local ApplyMultiBuild = COMMON_FNS.ApplyMultiBuild;
function COMMON_FNS.ApplyBuild(inst, build)
    if build and type(build) == "table" then
        inst.AnimState:SetBuild(build.base)
        ApplyMultiBuild(inst, build.symbols, build.name)
    else
        inst.AnimState:SetBuild(build)
    end
end

-- 涉及 scaler组件、AddReplicableComponent("scaler") 相关，需要处理
function COMMON_FNS.CreateFX(prefab, target, source, opts)
    local opts = opts or {} -- 我想测试个东西，就是传进来的参数是不是也是引用
    local fx = SpawnPrefab(prefab)
    local source = source or target

    -- 判空一下
    if fx == nil then
        return ;
    end

    -- 暂时先不要这个，有空去看一下这是啥再说。
    --if source and source.components.scaler then
    --    if not fx.components.scaler then
    --        fx:AddComponent("scaler")
    --    end
    --    fx.components.scaler:SetBaseScale(opts.scale)
    --    fx.components.scaler:SetSource(source)
    --end

    if opts.position then
        fx.Transform:SetPosition(opts.position:Get())
    end

    if opts.OnSpawn then
        opts.OnSpawn(fx)
    end

    if fx.OnSpawn then
        fx:OnSpawn({ target = target, source = source or target })
    end

    return fx
end

function COMMON_FNS.AddTags(inst, ...)
    for _, tag in pairs({ ... }) do
        inst:AddTag(tag)
    end
end


--------
-- FX --
--------
local AddTags = COMMON_FNS.AddTags;
--bank, build, anim, remove_fn, noanimover, noanim, anim_loop
function COMMON_FNS.FXEntityInit(bank, build, anim, opts)
    local options = {
        anim = anim,
        anim_loop = false,
    }
    ReForged.G.MergeTable(options, opts or {}, true)
    ------------

    local pristine_fn = options.pristine_fn
    options.pristine_fn = function(inst)
        AddTags(inst, "FX", "NOCLICK")

        if pristine_fn then
            pristine_fn(inst)
        end
    end
    ------------

    local inst = ReForged.COMMON_FNS.EQUIPMENT.BasicEntityInit(bank, build, options.anim, options)

    if not TheWorld.ismastersim then
        return inst
    end
    ------------

    inst:AddComponent("scaler")
    ------------

    if not options.noanimover then
        inst:ListenForEvent("animover", options.remove_fn or inst.Remove)
    end
    ------------

    return inst
end

local TEMP = {
    -- Other
    AddDependenciesToPrefab = AddDependenciesToPrefab,
    ReturnToGround = ReturnToGround,
    LaunchItems = LaunchItems,
    FindDouble = FindDouble,
    SetupBossFade = SetupBossFade,
    FadeOut = FadeOut,
    GetHealingCircle = GetHealingCircle,
    GetHealAuras = GetHealAuras,
    CommonExcludeTags = CommonExcludeTags,
    GetAllyTags = GetAllyTags,
    GetEnemyTags = GetEnemyTags,
    GetAllyAndEnemyTags = GetAllyAndEnemyTags,
    GetPlayerExcludeTags = GetPlayerExcludeTags,
    SwitchTeamTag = SwitchTeamTag,
    GetTeamTag = GetTeamTag,
    IsAlly = IsAlly,
    IsTargetInRange = IsTargetInRange,
    DoAOE = DoAOE,
    GetTargetsWithinRange = GetTargetsWithinRange,
    Knockback = Knockback,
    KnockbackOnHit = KnockbackOnHit,
    OnCollideDestroyObject = OnCollideDestroyObject,
    JumpToPosition = JumpToPosition,
    SpawnWarningShadow = SpawnWarningShadow,
    SpawnEntsInCircle = SpawnEntsInCircle,
    CreateTrail = CreateTrail,
    SlamTrail = SlamTrail,
    ResetWorld = ResetWorld,
    CreateFX = CreateFX,
    RemoveFX = RemoveFX,
    IsScripter = IsScripter,
    AddStateToStategraph = AddStateToStategraph,
    AddStatesToStategraph = AddStatesToStategraph,
    ApplyStategraphPostInits = ApplyStategraphPostInits,
    ForceTaunt = ForceTaunt,
    MakeComplexProjectilePhysics = MakeComplexProjectilePhysics,
    SpreadShot = SpreadShot,
    DropItem = DropItem,
    IsEventActive = IsEventActive,
    CheckCommand = CheckCommand,
    --CreateFXNetwork = CreateFXNetwork,
    -- Entities
    AddTags = AddTags,
    ApplyMultiBuild = ApplyMultiBuild,
    ApplyBuild = ApplyBuild,
    SetBuild = SetBuild,
    HideSymbols = HideSymbols,
    BasicEntityInit = BasicEntityInit,
    LoadDifficulty = LoadDifficulty,
    LoadMutators = LoadMutators,
    GetEntityCollisions = GetEntityCollisions,
    -- Mob
    AddSymbolFollowers = AddSymbolFollowers,
    AddBasicCombatComponent = AddBasicCombatComponent,
    AddCommonMobComponents = AddCommonMobComponents,
    AddScalerComponent = AddScalerComponent,
    CommonMobFN = CommonMobFN,
    MobEntityInit = MobEntityInit,
    ForgeMobTrackerInit = ForgeMobTrackerInit,
    MobTrackerInit = MobTrackerInit,
    GetMobWeight = GetMobWeight,
    SpawnMob = SpawnMob,
    -- Pet
    AddCommonPetComponents = AddCommonPetComponents,
    PetStatTrackerInit = PetStatTrackerInit,
    CommonPetFN = CommonPetFN,
    PetEntityInit = PetEntityInit,
    SpawnPet = SpawnPet,
    -- Structure
    StructureEntityInit = StructureEntityInit,
    AddCommonStructureComponents = AddCommonStructureComponents,
    CommonStructureFN = CommonStructureFN,
    -- Summon
    Summon = Summon,
    -- FX
    FXEntityInit = FXEntityInit,
    CreateProjectileAnim = CreateProjectileAnim,
    -- Map
    MapPreInit = MapPreInit,
    MapPostInit = MapPostInit,
    MapMasterPostInit = MapMasterPostInit,
    -- Network
    NetworkInit = NetworkInit,
    NetworkSetup = NetworkSetup,
    --Boarlord
    OnTalk = OnTalk,
    GetDialogueStrings = GetDialogueStrings,
    GetBanterID = GetBanterID,
}

return COMMON_FNS;