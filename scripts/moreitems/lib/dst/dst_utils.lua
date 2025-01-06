---
--- DateTime: 2025/1/6 15:47
---



local module = {}
local cache = {}

function module.is_valid(inst)
    return inst ~= nil and inst.IsValid and inst:IsValid()
end

function module.add_tags(inst, tags)
    if type(tags) == "string" then
        tags = { tags }
    end

    for _, tag in ipairs(tags) do
        if not inst:HasTag(tag) then
            inst:AddTag(tag)
        end
    end
end

local function _get_enabled_mods()
    local res = {}
    for _, dir in pairs(KnownModIndex:GetModsToLoad(true)) do
        local info = KnownModIndex:GetModInfo(dir)
        local name = info and info.name or "unknown"
        res[dir] = name
    end
    return res -- table<string:DirectoryName, string:ModInfoName>
end

local function _is_mod_enabled(name)
    -- 这个方式可以让 _get_enabled_mods 在函数被调用的时候才执行，即在 import module 时，不应该执行代码逻辑【个人看法】
    if cache.enabled_mods == nil then
        cache.enabled_mods = _get_enabled_mods()
    end
    for k, v in pairs(cache.enabled_mods) do
        if v and (k:match(name) or v:match(name)) then
            return true
        end
    end
    return false
end

---模组是否开启：name/id 均可
function module.is_mod_enabled(name)
    return _is_mod_enabled(name)
end

function module.oneof_mod_enabled(...)
    local args = { n = select("#", ...), ... }
    for i = 1, args.n do
        if _is_mod_enabled(args[i]) then
            return true
        end
    end
    return false
end

if select("#", ...) == 0 then
    local luafun = require("moreitems.lib.thirdparty.luafun.fun")
    local inspect = require("moreitems.lib.thirdparty.inspect.inspect")

    local utils = require("moreitems.lib.shihao.utils")

    local t = { 1, 2, nil, 2, 3, nil, nil, nil, 4, a = 1, b = 2 }
    local iter_t = luafun.iter(t)
    for i, v in luafun.iter(iter_t) do
        print(i, v)
    end
    print(inspect.inspect(luafun.totable(luafun.filter(function(e) return e >= 2 end, luafun.iter(t)))))
    print(inspect.inspect(luafun.tomap(luafun.filter(function(e) return e >= 2 end, luafun.iter(t)))))
    print(inspect.inspect(luafun.tomap(luafun.iter({ 1, 2 }))))

    --print(luafun.totable(luafun.iter({ 1, 2, 3, 4, 5 })))
    --for i, v in pairs(luafun.totable(luafun.iter({ 1, 2, 3, 4, 5 }))) do
    --    print(i, v)
    --end
    --print(inspect.inspect(luafun.totable(luafun.iter({ 1, 2, 3, 4, 5 }))))


end

return module
