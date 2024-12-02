---
--- @author zsh in 2023/4/26 1:37
---

local ENV = TUNING.MONE_TUNING.MY_MODULES.WATHGRITHR_EXCLUSIVE_EQUIPMENTS;
setfenv(1, ENV);

MODULE_ROOT = env.MODROOT .. "scripts/more_items/dstmodules/wathgrithr_exclusive_equipments/";

function haomodimport(modulename, environment)
    environment = environment or ENV;
    -- install our crazy loader!
    print("My-Modules-haomodimport: " .. MODULE_ROOT .. modulename)
    if string.sub(modulename, #modulename - 3, #modulename) ~= ".lua" then
        modulename = modulename .. ".lua"
    end
    local result = kleiloadlua(MODULE_ROOT .. modulename)
    if result == nil then
        error("Error in My-Modules-haomodimport: " .. modulename .. " not found!")
    elseif type(result) == "string" then
        error("Error in My-Modules-haomodimport: " .. ModInfoname(modname) .. " importing " .. modulename .. "!\n" .. result)
    else
        setfenv(result, environment)
        result()
    end
end

-- TODO:
function AddPrefabFiles(path)
    path = "" .. path;
    table.insert(env.PrefabFiles, path);
end

-- TODO: 注意学习一下懒炉的结构
function AddAssets(assets)

end

-- 2451165360

