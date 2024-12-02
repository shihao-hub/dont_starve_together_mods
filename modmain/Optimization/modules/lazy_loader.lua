---
--- @author zsh in 2023/4/23 23:25
---

-- for speed optimization? I don't think it's much use.
local GLOBAL = GLOBAL or _G;
local KEYS = { "coroutine", "debug", "io", "math", "os", "package", "string", "table", "assert", "collectgarbage", "dofile", "error", "_G", "getmetatable", "getfenv", "ipairs", "load", "loadstring", "loadfile", "module", "next", "pairs", "pcall", "print", "rawequal", "rawget", "rawset", "require", "select", "setfenv", "setmetatable", "tonumber", "tostring", "type", "unpack", "_VERSION", "xpcall", };
local ENV = {};
for _, KEY in ipairs(KEYS) do
    ENV[KEY] = GLOBAL:rawget(KEY);
end
GLOBAL.setmetatable(ENV, {
    __index = function(_, k)
        local print, string, tostring = GLOBAL.print, GLOBAL.string, GLOBAL.tostring;
        print(string.format("ENV[%q] doesn't exist, try to search _G.", tostring(k)));
        return GLOBAL.rawget(GLOBAL, k);
    end
});
_G.setfenv(1, ENV);

--[[
1 Introduction
In 2014, NSimplex[1] has provided a mod named “memspikefix” for Reign of Giants DLC of Don’t Starve to mitigating the problem of “out of memory” while client is loading large mods at the time of players entering or migrating the game worlds. The nice mod works well and reduces the frequency of crash significantly. Yet there is no any version that is really compatible, stable and considerate for Don’t Starve Together (DST). Because of that, I propose this mod and share it with you after I have checked the DST scripts[2] and tuned the “memspikefix”.
2 Discussion
I have tested this mod on my dedicated server for several months. It is well-behaved and alleviates the suffering of “out of memory” dramatically. Some mods may not be suitable for this mod such as "workshop%-1115709310". In this case, the mods' “Assets”, for instance, "IMAGE" and "ANIM", that should have been loaded in their custom UI do not run sometimes.
If you encounter this phenomenon, you could add the file names of the mods which are not worked with this mod to “ModDirFilter” in “lazy_loader.lua” to avoid loading them lazily. Please note that “%” should be added before the “-” because of LUA string functions.
References
[1] NSimplex. memspikefix. https://forums.kleientertainment.com/files/file/775-memspikefix/.
[2] Klei. Don’t Starve Together. \Don't Starve Together\data\databundles\scripts.
]]


-- Some mods' UI will not show correctly.
local ModDirFilter = {
    "workshop%-1115709310",
}

--[[
-- Receives a Prefab object, and tweaks its entity constructor ("fn") to
-- make the prefab be loaded before it is spawned.
--]]
local function MakeLazyLoader(prefab)
    if not prefab.fn then
        ---- some player mod's prefab skins have no fn. CreatePrefabSkin(...).
        print(string.format("      Warning: %s has no fn. It will be loaded directly", prefab.name))
        --_G.TheSim:UnloadPrefabs { prefab.name }
        return _G.TheSim:LoadPrefabs { prefab.name }
    end

    local fn = assert(prefab.fn)
    --local info = debug.getinfo(prefab.fn, "LnS")
    --print(string.format("      Dumping: %s.fn = function - %s", prefab.name, info.source .. ":" .. tostring(info.linedefined)))
    local current_fn
    local function new_fn(...)
        --_G.TheSim:UnloadPrefabs { prefab.name }
        _G.TheSim:LoadPrefabs { prefab.name }
        -- Ensures this only runs once, for efficiency.
        current_fn = fn
        return fn(...)
    end
    current_fn = new_fn
    --[[
    -- This extra layer of indirection ensures greater mod friendliness.
    --
    -- If we just set prefab.fn to new_fn, and later back to fn, we could
    -- end up overriding an fn patch done by another mod. By switching between
    -- the two internally, via the current_fn upvalue, we preserve any such
    -- patching.
    --]]
    prefab.fn = function(...)
        return current_fn(...)
    end
end


------------------------------------------------------------------------


local memfix_modfilter

local function generic_modfilter(modwrangler_object, moddir)
    return modwrangler_object:GetMod(moddir) ~= nil
end

local function selfish_modfilter(modwrangler_object, moddir)
    print("ERROR: Actually this line should not be run. ModName: " .. modname)
    return moddir == modname
end

-- it will be changed in modmain.lua
memfix_modfilter = selfish_modfilter

function ApplyMemFixGlobally()
    memfix_modfilter = generic_modfilter
end


------------------------------------------------------------------------

--local function FixModRecipe_placer(rec)
--    local placer_name = rec.placer or (rec.name .. "_placer")
--    local placer_prefab = _G.Prefabs[placer_name]
--    if not placer_prefab then
--        return
--    end
--
--    placer_prefab.deps = placer_prefab.deps or {}
--    table.insert(placer_prefab.deps, rec.name)
--
--    print("FixModRecipe:" .. placer_prefab.name)
--    for k, v in pairs(placer_prefab.deps) do
--        print("FixModRecipe:" .. k .. "->" .. v)
--    end
--end

-- Modified
---- ingredients in recipe.lua
local function FixModRecipe(index_pre, rec, mod_prefabnames, prefab)
    local unique_deps = {}
    -- self
    -- print(string.format("Finding: %s is in AllRecipes", mod_prefabnames[index_pre]))
    unique_deps[mod_prefabnames[index_pre]] = true
    table.remove(mod_prefabnames, index_pre)
    -- table.remove() will change the index, so we need use while instead
    local index = 1
    while index <= #mod_prefabnames do
        local flag = true
        for _, ingredient in pairs(rec.ingredients) do
            if mod_prefabnames[index] == ingredient.type then
                -- print(string.format("Finding: %s is in ingredients", mod_prefabnames[index]))
                unique_deps[mod_prefabnames[index]] = true
                table.remove(mod_prefabnames, index)
                flag = false
            end
        end
        if flag == true then
            index = index + 1
        end
    end

    local index = 1
    while index <= #mod_prefabnames do
        local flag = true
        for _, ingredient in pairs(rec.character_ingredients) do
            if mod_prefabnames[index] == ingredient.type then
                -- print(string.format("Finding: %s is in character_ingredients", mod_prefabnames[index]))
                unique_deps[mod_prefabnames[index]] = true
                table.remove(mod_prefabnames, index)
                flag = false
            end
        end
        if flag == true then
            index = index + 1
        end
    end

    local index = 1
    while index <= #mod_prefabnames do
        local flag = true
        for _, ingredient in pairs(rec.tech_ingredients) do
            if mod_prefabnames[index] == ingredient.type then
                -- print(string.format("Finding: %s is in tech_ingredients", mod_prefabnames[index]))
                unique_deps[mod_prefabnames[index]] = true
                table.remove(mod_prefabnames, index)
                flag = false
            end
        end
        if flag == true then
            index = index + 1
        end
    end

    for prefabname, bool in pairs(unique_deps) do
        if bool then
            table.insert(prefab.deps, prefabname)
        end
    end
    unique_deps = nil
end

---- recipes in cooking.lua
local function FixModRecipe_cookerrecipes(index_pre, mod_prefabnames, prefab)
    local unique_deps = {}
    -- self
    --print(string.format("Finding: %s is in cooking recipes", mod_prefabnames[index_pre]))
    unique_deps[mod_prefabnames[index_pre]] = true
    table.remove(mod_prefabnames, index_pre)

    for prefabname, bool in pairs(unique_deps) do
        if bool then
            table.insert(prefab.deps, prefabname)
        end
    end
    unique_deps = nil
end


------------------------------------------------------------------------

local ModWrangler = assert(_G.ModManager)
ModWrangler.RegisterPrefabs = (function()
    local ModRegisterPrefabs = assert(ModWrangler.RegisterPrefabs)

    return function(self, ...)
        -- functions
        local MainRegisterPrefabs = assert(_G.RegisterPrefabs)
        local Prefab = assert(_G.Prefab)
        -- tables
        local Prefabs = assert(_G.Prefabs)
        local AllRecipes = assert(_G.AllRecipes)
        local cooking = assert(require("cooking"))

        local mod_prefabnames = {}

        _G.RegisterPrefabs = function(...)
            for _, prefab in ipairs { ... } do
                -- ModDirFilter
                for _, value in pairs(ModDirFilter) do
                    if prefab.name:find(value) then
                        print("Note: MEMORY FIXING passed over " .. prefab.name)
                        return MainRegisterPrefabs(...)
                    end
                end

                local moddir = prefab.name:match("^MOD_(.+)$")

                if moddir and memfix_modfilter(self, moddir) then
                    local mod = self:GetMod(moddir)

                    if mod then
                        mod.modinfo = mod.modinfo ~= nil and mod.modinfo or {}
                        if mod.modinfo.client_only_mod then
                            print("Note: MEMORY FIXING passed over a client only mod " .. prefab.name)
                            return MainRegisterPrefabs(...)
                        end
                        if not mod.modinfo.memfixed then
                            mod.modinfo.memfixed = true
                            print("Note: MEMORY FIXING run for " .. moddir)
                            for _, prefabname in ipairs(prefab.deps) do
                                -- this prefabname is a prefab name in MOD_XXXXX
                                -- print(prefabname)
                                table.insert(mod_prefabnames, prefabname)
                            end

                            ---- crack #1
                            -- TheSim:RegisterPrefab(prefab.name, prefab.assets, prefab.deps)
                            -- called in RegisterPrefabsImpl(prefab, resolve_fn)
                            -- called in RegisterPrefabs(...)
                            prefab.deps = {}
                            print("Note: Purged deps from " .. prefab.name)

                            -- Modified
                            -- Filter the prefab in AllRecipes
                            -- First, do a pass over AllRecipes to extend dependencies if need be.
                            -- table.remove() will change the index, so we need use while instead
                            local index_pre = 1
                            while index_pre <= #mod_prefabnames do
                                local rec = AllRecipes[mod_prefabnames[index_pre]]
                                if rec then
                                    FixModRecipe(index_pre, rec, mod_prefabnames, prefab)
                                else
                                    index_pre = index_pre + 1
                                end
                            end

                            -- Filter the prefab in cooking.recipes
                            local index_pre = 1
                            while index_pre <= #mod_prefabnames do
                                local rec = cooking.recipes.cookpot[mod_prefabnames[index_pre]]
                                if rec then
                                    FixModRecipe_cookerrecipes(index_pre, mod_prefabnames, prefab)
                                else
                                    index_pre = index_pre + 1
                                end
                            end
                            print("Note: Rebuilt deps from " .. prefab.name)
                        end
                    end
                end
            end
            return MainRegisterPrefabs(...)
        end


        -- Modified
        ---- Here the last lines in ModWrangler.RegisterPrefabs are the follows.
        -- RegisterPrefabs( Prefab("MOD_"..mod.modname, nil, mod.Assets, prefabnames, true) )
        -- local modname = "MOD_"..mod.modname
        -- TheSim:LoadPrefabs({modname})
        -- table.insert(self.loadedprefabs, modname)

        ModRegisterPrefabs(self, ...)

        _G.RegisterPrefabs = MainRegisterPrefabs

        -- First, do a pass over AllRecipes to extend dependencies if need be.
        --for _, prefabname in ipairs(mod_prefabnames) do
        --    local rec = AllRecipes[prefabname]
        --    if rec then
        --        FixModRecipe_placer(rec)
        --    end
        --end

        for _, prefabname in ipairs(mod_prefabnames) do

            local prefab = assert(Prefabs[prefabname])

            -- Modified
            -- Call RegisterPrefabs again to register prefabs not in deps
            -- The idea is to divide MOD prefab batches into single prefab

            -- This line can also work, but sometimes game crashes without tips.
            -- Because the registered table has the same name with prefab.name ?
            --MainRegisterPrefabs(prefab)

            -- This idea using fn does not work,
            -- If _G.TheSim:LoadPrefabs({ registered_name }) is not called in rear lines, { prefabname }  will not be loaded.
            --local registered_name = "LazyLoaderByBear_" .. prefab.name
            --local fn = function(...)
            --    _G.TheSim:LoadPrefabs({ registered_name })
            --end

            print(string.format("Checking: Running MainRegisterPrefabs for %s", prefab.name))
            MainRegisterPrefabs(Prefab("LazyLoaderByBear_" .. prefab.name, nil, nil, { prefabname }, true))

            print(string.format("Checking: Running MakeLazyLoader for %s", prefab.name))
            MakeLazyLoader(prefab)

            -- This line will cause out of memory even if fn idea is used
            -- So use MakeLazyLoader(prefab) instead of  this line
            --_G.TheSim:LoadPrefabs({ registered_name })

            -- Modified
            -- self.loadedprefabs in original ModWrangler.RegisterPrefabs contains "MOD_"..mod.modname
            -- However, here prefabname is just a single prefab name

            -- This also takes care of the unloading, so there's no need to patch ModWrangler:UnloadPrefabs.
            print(string.format("Checking: Inserting loadedprefabs for %s", prefab.name))
            local registered_name = "LazyLoaderByBear_" .. prefab.name
            table.insert(self.loadedprefabs, registered_name)

            -- we need use tostring() to transform bool value to string.
            -- Otherwise it will be wrong on Linux Lua 5.1. However it works on Windows Lua JIT.
            print(string.format("Checking: Succeed! Name equal: %s", _G.tostring(prefab.name == prefabname)))
        end
        mod_prefabnames = nil
    end
end)()
