---
--- DateTime: 2024/12/5 16:38
---

local inspect = require("moreitems.lib.thirdparty.inspect.inspect")

local class = require("moreitems.lib.thirdparty.middleclass.middleclass")
local guard = require("moreitems.lib.shihao.module.guard")
local utils = require("moreitems.lib.shihao.utils")

-- TODO: DSTUtils 改成 DSTModEnvUtils/DSTModEnvService（指每个函数都需要用到 mod env）
-- TODO: 请区分 utils 和 service 的区别！
---@class DSTUtils
local DSTUtils = class("DSTUtils")

---需要用到 env 的函数将封装到此处
---@param env env
function DSTUtils:initialize(env)
    print(inspect(env))
    guard.require_not_nil(env)
    self.env = env
end

local function _add_upgrader_component()
    -- TODO: 记得查看 tresurechest.lua 和 dragonfly_chest.lua
    local function getstatus(inst, viewer)
        return inst._chestupgrade_stacksize and "UPGRADED_STACKSIZE" or nil
    end

    local function DoUpgradeVisuals(inst)
        -- DoNothing
    end

    local function OnUpgrade(inst, performer, upgraded_from_item)
        local numupgrades = inst.components.upgradeable.numupgrades
        if numupgrades == 1 then
            inst._chestupgrade_stacksize = true
            if inst.components.container ~= nil then -- NOTES(JBK): The container component goes away in the burnt load but we still want to apply builds.
                inst.components.container:Close()
                inst.components.container:EnableInfiniteStackSize(true)
                inst.components.inspectable.getstatus = getstatus
            end
            if upgraded_from_item then
                -- Spawn FX from an item upgrade not from loads.
                local x, y, z = inst.Transform:GetWorldPosition()
                local fx = SpawnPrefab("chestupgrade_stacksize_taller_fx")
                fx.Transform:SetPosition(x, y, z)
                -- Delay chest visual changes to match fx.
                local total_hide_frames = 6 -- NOTES(JBK): Keep in sync with fx.lua! [CUHIDERFRAMES]
                inst:DoTaskInTime(total_hide_frames * FRAMES, DoUpgradeVisuals)
            else
                DoUpgradeVisuals(inst)
            end
        end
        inst.components.upgradeable.upgradetype = nil

        if inst.components.lootdropper ~= nil then
            inst.components.lootdropper:SetLoot({ "alterguardianhatshard" })
        end
        -- 2025-01-13-23:30：不需要
        --inst.components.workable:SetOnWorkCallback(upgrade_onhit)
        --inst.components.workable:SetOnFinishCallback(upgrade_onhammered)
        --inst:ListenForEvent("restoredfromcollapsed", OnRestoredFromCollapsed)
    end

    local function OnLoad(inst, data, newents)
        if inst.components.upgradeable ~= nil and inst.components.upgradeable.numupgrades > 0 then
            OnUpgrade(inst)
        end
    end

    return function(self, prefab)
        self.env.AddPrefabPostInit(prefab, function(inst)
            if not TheWorld.ismastersim then
                return
            end

            utils.if_present(inst.components.container, function(container)
                local upgradeable = inst:AddComponent("upgradeable")
                upgradeable.upgradetype = UPGRADETYPES.CHEST
                upgradeable:SetOnUpgradeFn(OnUpgrade)
                -- This chest cannot burn.
                inst.OnLoad = OnLoad
            end)
        end)
    end
end

---设置弹性空间制造器通用函数
DSTUtils.add_upgrader_component = _add_upgrader_component()

---@param modulename string
---@return table
function DSTUtils:modimport(modulename)
    local env = self.env

    print("modimport: " .. env.MODROOT .. modulename)
    if string.sub(modulename, #modulename - 3, #modulename) ~= ".lua" then
        modulename = modulename .. ".lua"
    end
    local result = kleiloadlua(env.MODROOT .. modulename)
    if result == nil then
        error("Error in modimport: " .. modulename .. " not found!")
    elseif type(result) == "string" then
        error("Error in modimport: " .. ModInfoname(modname) .. " importing " .. modulename .. "!\n" .. result)
    else
        setfenv(result, env.env)
        -- 2024-12-05：复制于 modimport 函数，修改其返回值
        return result()
    end
end

function DSTUtils:is_debug()
    local env = self.env
    return env.GetModConfigData("debug") == true and env.modname == morel_DEBUG_DIR_NAME
end

function DSTUtils:get_mod_root()
    local env = self.env
    return MODS_ROOT .. env.modname .. "/";
end

function DSTUtils:add_assets(assets)
    local env = self.env

    -- 有可能出现没有传递 { Asset, Asset, ... } 而是传递 Asset 的情况
    if assets.is_a and assets:is_a(Asset) then
        assets = { assets }
    end

    for _, asset in ipairs(assets) do
        table.insert(env.Assets, asset);
    end
end
function DSTUtils:add_prefab_files(prefabfiles)
    local function Local()
        local obj = {}

        function obj:delete_path_lua_suffix(path)
            local i, j = string.find(path, "%.lua$");
            if i ~= nil then
                path = string.sub(path, 1, i - 1);
            end
            return path
        end

        return obj
    end
    -- 很像 Python 呀，没有 new 好舒服
    local loc = Local()

    local env = self.env

    for _, path in ipairs(prefabfiles) do
        path = loc:delete_path_lua_suffix(path)
        table.insert(env.PrefabFiles, path);
    end
end

---@return any module file 的返回值，一般是 return {}
function DSTUtils:import_module(modulename, environment)
    local env = self.env

    environment = environment or env;

    --install our crazy loader!
    print("import_module: " .. env.MODROOT .. modulename)
    if string.sub(modulename, #modulename - 3, #modulename) ~= ".lua" then
        modulename = modulename .. ".lua"
    end
    local result = kleiloadlua(env.MODROOT .. modulename)
    if result == nil then
        error("Error in import_module: " .. modulename .. " not found!")
    elseif type(result) == "string" then
        error("Error in import_module: " .. ModInfoname(env.modname) .. " importing " .. modulename .. "!\n" .. result)
    else
        setfenv(result, environment);
        return result();
    end
end

return DSTUtils
