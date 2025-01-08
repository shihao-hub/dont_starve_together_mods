---
--- Created by zsh
--- DateTime: 2023/10/30 1:06
---

-- 如果为了方便测试，那么我这个文件里在 main 块中除了声明和定义以外，不应该有其他执行用的代码

-- common_global.lua 本文件按理来说应该是几乎不依赖于其他文件的通用功能函数

setfenv(1, _G)

require("new_scripts.mod_a.class")

---@type env
local env = morel_env

if morel_BRANCH == "dev" then
    package.path = package.path .. ";D:\\programming_ablility\\ProgrammingLanguages\\LUA\\Lua\\5.1\\lua\\?.lua"
end

-- 先注释掉，之后用到的时候再修改已经变更的内容！
--if false then
--    local stl = require("moreitems.main").shihao.module.stl
--    local base = require("moreitems.main").shihao.base
--    local utils = require("moreitems.main").shihao.utils
--
--    morel_is_nil = base.is_nil
--    morel_is_boolean = base.is_boolean
--    morel_is_number = base.is_number
--    morel_is_string = base.is_string
--    morel_is_table = base.is_table
--    morel_is_function = base.is_function
--    morel_is_thread = base.is_thread
--    morel_is_userdata = base.is_userdata
--
--    morel_dummy = utils.dummy
--    morel_do_nothing = utils.do_nothing
--
--    morel_get_call_on_position = stl.debug.get_call_location
--    morel_contains_key = stl.table.contains_key
--    morel_contains_value = stl.table.contains_value
--end

-----------------------------------------------------------------------------
-- only depends on lua
-----------------------------------------------------------------------------
function morel_is_nil(v) return v == nil end
function morel_is_boolean(v) return v ~= nil and type(v) == "boolean" end
function morel_is_number(v) return v ~= nil and type(v) == "number" end
function morel_is_string(v) return v ~= nil and type(v) == "string" end
function morel_is_table(v) return v ~= nil and type(v) == "table" end
function morel_is_function(v) return v ~= nil and type(v) == "function" end
function morel_is_thread(v) return v ~= nil and type(v) == "thread" end
function morel_is_userdata(v) return v ~= nil and type(v) == "userdata" end
function morel_dummy() end
function morel_do_nothing() end
morel_tracked_assert = assert
morel_assert_anchor = "<assert anchor>"

function morel_assert_true(v, message)
    if v then
        assert(false, message)
    end
    return v
end

---@return string
function morel_get_call_on_position(level_incr)
    --[[
        -- debug.getinfo(thread, what), the below content refers to "what"
        -- S: source, short_src, linedefined, lastlinedefined, what
        -- l: currentline
        -- u: nups
        -- n: name, namewhat
        -- L: activelines
        -- f: func
    ]]

    -- level_incr, incr(增量)
    level_incr = level_incr and level_incr or 0
    -- It is better to provide a second param, because it can improve performance(改善性能). (maybe?)
    -- but I think this is meaningless.
    local info = debug.getinfo(2 + level_incr)
    if info and info.short_src and info.currentline then
        return string.gsub(string.format("[file %s, line %s]", info.short_src, info.currentline), "\\", "/")
    end
    return ""
end

function morel_contains_key(t, key)
    for i, v in pairs(t) do
        if i == key then
            return true
        end
    end
    return false
end

function morel_contains_value(t, value)
    for i, v in pairs(t) do
        if v == value then
            return true
        end
    end
    return false
end

function morel_get_file_memory(file)
    --if not file then return 0 end
    assert(file ~= nil, "file == nil error")
    local old_cur = file:seek("cur")
    local bytes = file:seek("end")
    file:seek("set", old_cur)
    return bytes
end

-- 如果文件被同时打开会发生什么？
function morel_create_file(filename)
    return io.open(filename, "w")
end

function morel_print_flush(...)
    print(...)
    io.flush()
end

-- ****************************************************** Minimum Set

function morel_assert_no_throw(v, message, true_fn, false_fn, enable_logger)
    if morel_is_nil(enable_logger) and morel_is_boolean(true_fn) then
        enable_logger = true_fn
    end
    if not v and message then
        print("assert warning: " .. message)
        if enable_logger then
            morel_logger_print("assert warning: " .. message)
        end
        if morel_is_function(false_fn) then false_fn() end
        return v
    end
    if morel_is_function(true_fn) then true_fn() end
    return v
end

-- dst modifies io.write, so I can't write file in mod folder. May I can write in game root folder?
morel_logger_switch = (not morel_IS_DST_ENV) and true or false
morel_io_stdout = nil
function morel_logger_print(...)
    local debug_mode = false
    if not morel_logger_switch then
        print(string.format("[%s] ", os.date("%Y-%m-%d %H:%M:%S", os.time())), ...)
        return
    end
    local filename = morel_RELATIVE_SRC_PATH .. "mod_a/log.txt"
    if not morel_io_stdout then
        local file = io.open(filename, "r")
        if file then
            file:close()
            file = io.open(filename, "a")
        else
            -- create new file
            file = io.open(filename, "w")
        end
        morel_io_stdout = file
    end
    local upper_limit = debug_mode and 104 or 1048576
    if morel_io_stdout and morel_get_file_memory(morel_io_stdout) >= upper_limit then
        -- clear file
        morel_io_stdout:close()
        morel_io_stdout = io.open(filename, "w")
        print("morel_io_stdout hint: " .. filename .. " has been cleared.")
    end
    local n = select("#", ...)
    local args = { ... }
    local res = {}
    table.insert(res, string.format("[%s] ", os.date("%Y-%m-%d %H:%M:%S", os.time())))
    for i = 1, n do
        table.insert(res, tostring(args[i]))
    end
    table.insert(res, " -> " .. morel_get_call_on_position(1))
    table.insert(res, '\n')
    morel_io_stdout:write(table.concat(res))
    return true
end

function morel_common_msgh(msg)
    msg = string.gsub(msg, "\\", "/")
    print(msg)
    morel_logger_print(msg)
end


-- json.lua 有更好的实现，但是仍很脆弱。
-- 底层用 lua api 实现比较靠谱（记得某个一直使用 lua 并维护 lua 的项目实现了这些 require("table.isarray")）
-- 规则：存在空洞 nil 即不是数组
---@return boolean,number|boolean,nil
function morel_is_array(arr)
    if not morel_is_table(arr) then
        return false
    end

    local max_key = 0
    local cnt = 0
    for k, v in pairs(arr) do
        cnt = cnt + 1
        if type(k) == "number" then
            max_key = max_key < k and k or max_key
        end
    end
    if max_key ~= cnt then
        return false
    end

    --local n = table.maxn(arr)
    --for i = 1, n do
    --    if arr[i] == nil then
    --        return false
    --    end
    --end
    return true
end

function morel_all_array(n, ...)
    local args = { ... }
    for i = 1, n do
        if not morel_is_array(args[i]) then
            return false
        end
    end
    return true
end

-- 规则：联合所有数组中的不重复项
function morel_union_array(...)
    local n = select("#", ...)
    local args = { ... }
    local res = {}
    for i = 1, n do
        if morel_is_array(args[i]) then
            for j = 1, #args[i] do
                if not morel_contains_value(res, args[i][j]) then
                    table.insert(res, args[i][j])
                end
            end
        end
    end
    return res
end

-- 有何意义？
function morel_union_map(...)
    local n = select("#", ...)
    local args = { ... }
    local res = {}
    for i = 1, n do
        if morel_is_table(args[i]) then
            for k, v in pairs(args[i]) do
                res[k] = v
            end
        end
    end
    return res
end

function morel_all_null(n, ...)
    local args = { ... }
    for i = 1, n do
        if args[i] ~= nil then
            return false
        end
    end
    return true
end

-- 第二个参数为 true 的时候，勉强可以将这个函数视为拥有 dump table 的功能
function morel_print_table_deeply(t, only_return, no_format, filter_fn)
    -- only_return added in 23/11/01, just for test
    local base = _G
    if base.type(t) ~= "table" then
        print(string.format("Warning: invalid #1 param, expected type 'table'."))
        return
    end
    local buffer = { "{\n" }
    local block = string.rep(" ", 4)
    local dblock = string.rep(" ", 8)
    if only_return and not no_format then
        block = ""
        dblock = ""
    end

    local isnil = morel_is_nil
    local isboolean = morel_is_boolean
    local isnumber = morel_is_number
    local isstring = morel_is_string
    local istable = morel_is_table
    local isfunction = morel_is_function
    local isthread = morel_is_thread
    local isuserdata = morel_is_userdata

    local old_sh_format = string.sh_format
    string.sh_format = function(formatstring, ...)
        local n = select("#", ...)
        local args = { ... }
        for i = 1, n do
            local elem = args[i];
            if isnil(elem) or isboolean(elem) or isfunction(elem) or istable(elem) or isthread(elem) or isuserdata(elem) then
                args[i] = tostring(elem)
            end
        end
        return string.format(formatstring, unpack(args, 1, n))
    end

    local old_insert = table.insert
    table.insert = filter_fn and function(list, ...)
        local n = select("#", ...)
        if n == 1 then
            local value = select(1, ...)
            if not filter_fn(value) then
                return
            end
            return old_insert(list, value)
        else
            return old_insert(list, ...)
        end
    end or old_insert

    for i, v in pairs(t) do
        if v ~= nil then
            -- todo: this function shouldn't be put in here.
            local function print_table(t, i)
                if isnumber(i) then
                    table.insert(buffer, string.sh_format(block .. "[%d] = {\n", i))
                elseif isstring(i) then
                    table.insert(buffer, string.sh_format(block .. "[%q] = {\n", i))
                elseif istable(i) or isboolean(i) or isfunction(i) or istable(i) or isuserdata(i) then
                    table.insert(buffer, string.sh_format(block .. "[%s] = {\n", i))
                end

                for i1, v1 in pairs(t) do
                    if isnumber(i1) then
                        if isstring(v1) then
                            table.insert(buffer, string.sh_format(dblock .. "[%d] = %q,\n", i1, v1))
                        else
                            table.insert(buffer, string.sh_format(dblock .. "[%d] = %s,\n", i1, v1))
                        end
                    elseif isstring(i1) then
                        if isstring(v1) then
                            table.insert(buffer, string.sh_format(dblock .. "[%q] = %q,\n", i1, v1))
                        else
                            table.insert(buffer, string.sh_format(dblock .. "[%q] = %s,\n", i1, v1))
                        end
                    elseif istable(i1) or isboolean(i1) or isfunction(i1) or isthread(i1) or isuserdata(i1) then
                        if isstring(v1) then
                            table.insert(buffer, string.sh_format(dblock .. "[%s] = %q,\n", i1, v1))
                        else
                            table.insert(buffer, string.sh_format(dblock .. "[%s] = %s,\n", i1, v1))
                        end
                    end
                end
                if #buffer > 1 then
                    local last = buffer[#buffer]
                    buffer[#buffer] = string.sub(last, 1, #last - 2) .. "\n"
                end
                table.insert(buffer, block .. "},\n")
            end

            if istable(v) then
                print_table(v, i)
            else
                if isnumber(i) then
                    if isstring(v) then
                        table.insert(buffer, string.sh_format(block .. "[%d] = %q,\n", i, v))
                    else
                        table.insert(buffer, string.sh_format(block .. "[%d] = %s,\n", i, v))
                    end
                elseif isstring(i) then
                    if isstring(v) then
                        table.insert(buffer, string.sh_format(block .. "[%q] = %q,\n", i, v))
                    else
                        table.insert(buffer, string.sh_format(block .. "[%q] = %s,\n", i, v))
                    end
                elseif istable(i) or isboolean(i) or isfunction(i) or isthread(i) or isuserdata(i) then
                    if isstring(v) then
                        table.insert(buffer, string.sh_format(block .. "[%s] = %q,\n", i, v))
                    else
                        table.insert(buffer, string.sh_format(block .. "[%s] = %s,\n", i, v))
                    end
                end
            end
        end
    end
    if #buffer > 1 then
        local last = buffer[#buffer]
        buffer[#buffer] = string.sub(last, 1, #last - 2) .. "\n"
    end
    table.insert(buffer, "}")
    if only_return and not no_format then
        for i, v in ipairs(buffer) do
            buffer[i] = string.gsub(v, "\n", "")
        end
    end
    local out_text = table.concat(buffer, "")
    if not only_return then
        print(out_text)
    end

    string.sh_format = old_sh_format
    table.insert = old_insert

    return only_return and out_text or nil
end

-- 这个有问题的，不可打印太长呀
-- fixme
function morel_print(...)
    local function encode_string_value(s)
        s = string.gsub(s, '\\', '\\\\')
        s = string.gsub(s, '"', '\\"')
        s = string.gsub(s, "'", "\\'")
        s = string.gsub(s, '\n', '\\n')
        s = string.gsub(s, '\t', '\\t')
        s = string.gsub(s, '\r', '\\r')
        return s
    end
    local StringBuilder = require("new_scripts.mod_a.class.string_builder")
    local n = select("#", ...)
    local args = { ... }
    for i = 1, n do
        local string_builder = StringBuilder:new()
        local e = args[i]
        if morel_is_nil(e) or morel_is_number(e) or morel_is_boolean(e) then
            string_builder:append(tostring(e))
        elseif morel_is_string(e) then
            string_builder:append(encode_string_value(e))
        elseif morel_is_table(e) then
            --if morel_is_array(e) then
            --
            --    string_builder:append("["):append("]")
            --else
            --
            --end
            --local temp = {}
            --for k, v in pairs(e) do
            --    local ktype, vtype = type(k), type(v)
            --    if (ktype == "boolean" or ktype == "number" or ktype == "string")
            --            and (vtype == "nil" or vtype == "boolean" or
            --            vtype == "number" or vtype == "string") then
            --        temp[k] = v
            --    end
            --end
            --string_builder:append(morel_json_encode(temp))
            --string_builder:append(morel_json_encode(e))
            string_builder:append(morel_print_table_deeply(e, true))
        else
            string_builder:append(tostring(e))
        end
        string_builder:append("\t")
        args[i] = string_builder:tostring()
    end
    print(unpack(args))
end


-----------------------------------------------------------------------------
-- not only depends on lua, but also depends on dst
-----------------------------------------------------------------------------
function morel_is_valid(inst) return inst ~= nil and inst.IsValid and inst:IsValid() end
function morel_get_modname() return env.modname end
function morel_get_mymod_root() return env.MODROOT .. env.modname .. "/" end

---@overload fun(arr:table[])
function morel_add_Assets(arr)
    if not morel_is_table(arr) then
        return
    end
    for i, asset in ipairs(arr) do
        if morel_is_table(asset) and asset.is_a and asset:is_a(Asset) then
            table.insert(env.Assets, asset)
        end
    end
end


-- todo: 这里需要测试一下，尤其 string.sub(s,-a,-b)
function morel_add_PrefabFiles(arr)
    if not morel_is_table(arr) then
        print("warning: ", morel_get_call_on_position())
        return
    end
    for i, file_path in ipairs(arr) do
        if morel_is_string(file_path) then
            if string.sub(file_path, -4, -1) == ".lua" then
                file_path = string.sub(file_path, 1, -5)
            end
            table.insert(env.PrefabFiles, file_path)
        end
    end
end

-- fixme: this function hasn't finished.
function morel_mod_import_safe(modulename)
    print("morel_mod_import_safe: " .. env.MODROOT .. modulename)
    if string.sub(modulename, #modulename - 3, #modulename) ~= ".lua" then
        modulename = modulename .. ".lua"
    end
    local result = kleiloadlua(env.MODROOT .. modulename)
    if result == nil then
        print("Error in morel_mod_import_safe: " .. modulename .. " not found!")
    elseif type(result) == "string" then
        print("Error in morel_mod_import_safe: " .. ModInfoname(env.modname) .. " importing " .. modulename .. "!\n" .. result)
    else
        setfenv(result, env.env)
        result()
    end
end

function morel_hook_fn(fn)
    return fn()
end
