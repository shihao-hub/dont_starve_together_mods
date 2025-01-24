---
--- DateTime: 2025/1/6 15:47
---

local inspect = require("moreitems.lib.thirdparty.inspect.inspect")

local base = require("moreitems.lib.shihao.base")
local log = base.log

local module = {}
local cache = {}
local static = {}

function module.is_valid(inst)
    return inst ~= nil and inst.IsValid and inst:IsValid()
end

function module.get_mod_config_data(key)
    return TUNING.MONE_TUNING.GET_MOD_CONFIG_DATA[key]
end

function module.get_persistent_data(filename)
    base.log.info("call get_persistent_data", "filename: " .. filename)
    local res
    TheSim:GetPersistentString(filename, function(load_success, data)
        if not load_success or data == nil then
            base.log.info("not load_success or data == nil")
            return
        end
        local success, saved_data = RunInSandbox(data)
        if not success then
            base.log.info("not success")
            return
        end
        res = saved_data
    end)
    return res
end

---@param filename string
---@param data table
function module.set_persist_data(filename, data)
    base.log.info("call set_persist_data", "filename: " .. filename)
    -- DataDumper(filters, nil, false)
    --  fastmode 为 false，表示禁用快速模式，生成的 Lua 代码会更加详细和完整。
    --  astmode 为 true，表示启用快速模式，生成的 Lua 代码会更加简洁，但可能会丢失一些细节。
    local str = DataDumper(data, nil, true)
    TheSim:SetPersistentString(filename, str, false)
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

local function _generate_hook_fn()
    local cache = {}

    ---@param old_fn function 原函数
    ---@param generate_present_fn fun(old_fn:function) 生成现函数的函数
    ---@param unique_key string 唯一键值对
    local function hook_fn(old_fn, generate_present_fn, unique_key)
        local function Local()
            local obj = {}

            function obj.generate_unique_key(old_fn, unique_key)
                if not base.is_function(old_fn) then
                    return unique_key
                end
                -- 需要以 old_fn 为键来缓存
                return tostring(old_fn):sub(11, -1) .. "|" .. unique_key
            end

            return obj
        end
        local loc = Local()

        unique_key = loc.generate_unique_key(old_fn, unique_key)

        if unique_key == nil then
            return generate_present_fn(old_fn)
        end
        if cache[unique_key] == nil then
            cache[unique_key] = generate_present_fn(old_fn)
            log.info(base.string_format("cache misses, cached data: `{{key}} -> {{value}}`", { key = unique_key, value = cache[unique_key] }))
        else
            log.info(base.string_format("cached data: `{{key}} -> {{value}}`", { key = unique_key, value = cache[unique_key] }))
        end
        return cache[unique_key]
    end

    return hook_fn
end

--[[---@param old_fn function 原函数
---@param generate_present_fn fun(old_fn:function) 生成现函数的函数
function module.hook(old_fn, generate_present_fn)
    return generate_present_fn(old_fn)
end]]
module.hook_fn = _generate_hook_fn()

if select("#", ...) == 0 then
    local assertion = require("moreitems.lib.shihao.assertion")

    --[[ hook ]]
    xpcall(function()
        local fn1 = function() end
        local new_fn1_1 = function() end
        local new_fn1_2 = function() end
        local new_fn1_3 = function() end
        --print("      fn1:", fn1)
        --print("new_fn1_1:", new_fn1_1)
        --print("new_fn1_2:", new_fn1_2)
        --print("new_fn1_3:", new_fn1_3)
        local _new_fn1_1 = module.hook_fn(fn1, function(old_fn)
            return new_fn1_1
        end, "fn1")

        local _new_fn1_2 = module.hook_fn(fn1, function(old_fn)
            return new_fn1_2
        end, "fn1")

        local _new_fn1_3 = module.hook_fn(fn1, function(old_fn)
            return new_fn1_3
        end, "fn1")

        assertion.assert_true(new_fn1_1 == _new_fn1_1)
        assertion.assert_true(new_fn1_1 == _new_fn1_2)
        assertion.assert_true(new_fn1_1 == _new_fn1_3)
    end, log.error)

    local function test()
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
    --test()

end

return module
