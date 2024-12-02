---
--- Created by zsh
--- DateTime: 2023/10/30 14:51
---


require("new_scripts.mod_a.common_global")

--print(morel_is_array({ 1, 2, 3 }))
--print(morel_is_array({ [1] = 1, [2] = 2, [3] = 4 }))
--
--print(morel_json_encode({ 1, 2, 3, { [true] = 1, ["string"] = "string" } }))
--
--print(morel_get_call_on_position())
--
--print(debug.getinfo(print))
--print(debug.getinfo(print))
--
--print(morel_add_PrefabFiles({"new_prefabs/prefabs_inspiration_1.lua"}))

--print(morel_mod_import_safe("123"))

--print(string.byte("#"))


require("lib.shlib.main")
local function getdebugstack()

end

local function DoStackTrace()
    getdebugstack()
end

local function StackTrace()
    xpcall(function() DoStackTrace() end, morel_common_msgh)
end

local function StackTraceToLog()
    StackTrace()
end

local function RunInEnvironmentSafe()
    local function fn()
        return nil .. 1
    end
    setfenv(fn, _G)
    xpcall(fn, function() StackTraceToLog() end, morel_common_msgh)
end

local old_getdebugstack = getdebugstack
function getdebugstack()
    for i = 1, math.huge do
        local info = debug.getinfo(i)
        if info then
            ShiHaoEnv.PrintTableDeep(debug.getinfo(i))
        else
            break
        end
    end
end

--RunInEnvironmentSafe() -- need to test again, incompletely

--[[
{
    -- can be encoded to json format
    [boolean|number|string] = nil|boolean|number|string
    -- can't be encoded to json format
    [table|function|thread|userdata] = table|function|thread|userdata
}
]]

local dummy_fn = function() end
local dummy_thread = coroutine.create(function() end)
local dummy_userdata = newproxy(true)

--local function generate_tmp_t(t, n)
--    if n <= 0 then
--        return
--    end
--    t["a"] = {}
--    generate_tmp_t(t.a, n - 1)
--end
--
--local tmp_t = {}
--generate_tmp_t(tmp_t,100000)

morel_print(nil, true, 1, "abc", {
    [true] = 1,
    [1.0] = 1,
    ["abc"] = 1,
    [dummy_fn] = 1,
    [dummy_thread] = 1,
    [dummy_userdata] = 1,
}, dummy_fn, dummy_thread, dummy_userdata)

--morel_print({
--    a = tmp_t
--})

--ShiHaoEnv.PrintTableDeep(_G)

--morel_print(1,"abc")
