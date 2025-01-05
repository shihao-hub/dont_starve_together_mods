setfenv(1, TUNING.MONE_TUNING.ENV)

local select, unpack = select, unpack
local function pack(...)
    return { n = select("#", ...), ... }
end
local function vararg(packed)
    return unpack(packed, 1, packed.n)
end

local import_cache = {}
local init_cache = {} -- This holds the functions that execute their files.

--local import_cache = package.loaded -- require's cache

local function ResolvePath(path)
    return MODROOT .. "scripts/" .. path .. ".lua"
end

--- Importer function.
-- @string path Path to the lua file to load (do not append .lua)
-- @treturn function
local function import(path)
    --path = "../mods/" .. modname .. "/" ..  path
    path = ResolvePath(path)

    -- as to behave like require
    if (import_cache[path]) then
        return vararg(import_cache[path])
    end

    local fn = kleiloadlua(path)

    if fn == nil then
        error("[ERR] File does not exist: " .. path)
    elseif type(fn) == "string" then
        error(string.format("[ERR] Error loading file \"%s\".\nError: %s", path, fn))
    else
        --[[
        setfenv(fn, _G.setmetatable({}, {
            __index = _G.Insight.env,
            __metatable = "yep"
        }))
        --]]
        setfenv(fn, TUNING.MONE_TUNING.ENV)

        init_cache[path] = fn
        import_cache[path] = pack(fn())
        return vararg(import_cache[path])
    end
end

local function clear_import(path)
    local real_path = ResolvePath(path)

    if import_cache[real_path] then
        import_cache[real_path] = nil
    else
        errorf("Attempt to clear not-loaded import: %q (%q)", path, real_path)
    end
end

local function has_loaded_import(path)
    local real_path = ResolvePath(path)

    return import_cache[real_path] ~= nil
end

local proxy = newproxy(true)
local mt = getmetatable(proxy)
mt.__index = {
    clear = clear_import,
    has_loaded = has_loaded_import,
    _init_cache = init_cache,
    ResolvePath = ResolvePath,
}

mt.__call = function(self, ...)
    return import(...)
end

return proxy