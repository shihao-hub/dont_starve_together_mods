---
--- Created by zsh
--- DateTime: 2023/9/25 9:12
---

setfenv(1,_G)
require("lib.shlib.env")

require("lib.shlib.util")

local function reverse_next(t, index)
    if index > 0 then
        return index - 1, t[index]
    end
end
-- Equivalent of the ipairs() function on tables, but in reverse order.
ShiHaoEnv.ipairs_reverse = function(t)
    return reverse_next, t, #t
end

ShiHaoEnv.distsq = function(v1, v2, v3, v4)

    -- PLEASE FORGIVE US! WE NEVER MEANT FOR IT TO END THIS WAY!

    assert(v1, "Something is wrong: v1 is nil stale component reference?")
    assert(v2, "Something is wrong: v2 is nil stale component reference?")

    --special case for 2dvects passed in as numbers
    if v4 and v3 and v2 and v1 then
        local dx = v1 - v3
        local dy = v2 - v4
        return dx * dx + dy * dy
    end

    local dx = (v1.x or v1[1]) - (v2.x or v2[1])
    local dy = (v1.y or v1[2]) - (v2.y or v2[2])
    local dz = (v1.z or v1[3]) - (v2.z or v2[3])
    return dx * dx + dy * dy + dz * dz
end

-- only use on indexed tables!
function ShiHaoEnv.GetFlattenedSparse(tab)
    local keys = {}
    for index, value in pairs(tab) do keys[#keys + 1] = index end
    table.sort(keys)

    local ret = {}
    for _, oidx in ipairs(keys) do
        ret[#ret + 1] = tab[oidx]
    end
    return ret
end

-- RemoveByValue only applies to array-type tables
-- Removes all instances of the value from the table
-- See table.removearrayvalue above
function ShiHaoEnv.RemoveByValue(t, value)
    if t ~= nil then
        for i = #t, 1, -1 do
            if t[i] == value then
                table.remove(t, i)
            end
        end
    end
end


-- Count the number of keys/values. Like #t for map-type tables.
function ShiHaoEnv.GetTableSize(table)
    local numItems = 0
    if table ~= nil then
        for k, v in pairs(table) do
            numItems = numItems + 1
        end
    end
    return numItems
end

function ShiHaoEnv.GetRandomItem(choices)
    local numChoices = ShiHaoEnv.GetTableSize(choices)

    if numChoices < 1 then
        return
    end

    local choice = math.random(numChoices) - 1

    local picked = nil
    for k, v in pairs(choices) do
        picked = v
        if choice <= 0 then
            break
        end
        choice = choice - 1
    end
    assert(picked ~= nil)
    return picked
end

-- This is actually GetRandomItemWithKey
function ShiHaoEnv.GetRandomItemWithIndex(choices)
    local choice = math.random(ShiHaoEnv.GetTableSize(choices)) - 1

    local idx = nil
    local item = nil

    for k, v in pairs(choices) do
        idx = k
        item = v
        if choice <= 0 then
            break
        end
        choice = choice - 1
    end
    assert(idx ~= nil and item ~= nil)
    return idx, item
end

-- Made to work with (And return) array-style tables
-- This function does not preserve the original table
function ShiHaoEnv.PickSome(num, choices)
    local l_choices = choices
    local ret = {}
    for i = 1, num do
        local choice = math.random(#l_choices)
        table.insert(ret, l_choices[choice])
        table.remove(l_choices, choice)
    end
    return ret
end

function ShiHaoEnv.PickSomeWithDups(num, choices)
    local l_choices = choices
    local ret = {}
    for i = 1, num do
        local choice = math.random(#l_choices)
        table.insert(ret, l_choices[choice])
    end
    return ret
end

-- Appends array-style tables to the first one passed in
function ShiHaoEnv.ConcatArrays(ret, ...)
    for i, array in ipairs({ ... }) do
        for j, val in ipairs(array) do
            table.insert(ret, val)
        end
    end
    return ret
end


-- concatenate two or more array-style tables
function ShiHaoEnv.JoinArrays(...)
    local ret = {}
    for i, array in ipairs({ ... }) do
        for j, val in ipairs(array) do
            table.insert(ret, val)
        end
    end
    return ret
end

-- returns a new array with the difference between the two provided arrays
function ShiHaoEnv.ExceptionArrays(tSource, tException)
    local ret = {}
    ret = ShiHaoEnv.JoinArrays(ret, tSource)
    for i, val in ipairs(tException) do
        if table.contains(ret, val) then
            ShiHaoEnv.RemoveByValue(ret, val)
        end
    end
    return ret
end

-- merge two array-style tables, only allowing each value once
function ShiHaoEnv.ArrayUnion(...)
    local ret = {}
    for i, array in ipairs({ ... }) do
        for j, val in ipairs(array) do
            if not table.contains(ret, val) then
                table.insert(ret, val)
            end
        end
    end
    return ret
end

-- return only values found in all arrays
function ShiHaoEnv.ArrayIntersection(...)
    local arg = { n = select('#', ...), ... }
    local ret = {}
    for i, val in ipairs(arg[1]) do
        local good = true
        for i = 2, #arg do
            if not table.contains(arg[i], val) then
                good = false
                break
            end
        end
        if good then
            table.insert(ret, val)
        end
    end
    return ret
end

-- merge two map-style tables, overwriting duplicate keys with the latter map's value
function ShiHaoEnv.MergeMaps(...)
    local ret = {}
    for i, map in ipairs({ ... }) do
        for k, v in pairs(map) do
            ret[k] = v
        end
    end
    return ret
end

-- merge two map-style tables, overwriting duplicate keys with the latter map's value
-- subtables are recursed into
function ShiHaoEnv.MergeMapsDeep(...)
    local keys = {}
    for i, map in ipairs({ ... }) do
        for k, v in pairs(map) do
            if keys[k] == nil then
                keys[k] = type(v)
            else
                assert(keys[k] == type(v), "Attempting to merge incompatible tables.")
            end
        end
    end

    local ret = {}
    for k, t in pairs(keys) do
        if t == "table" then
            local subtables = {}
            for i, map in ipairs({ ... }) do
                if map[k] ~= nil then
                    table.insert(subtables, map[k])
                end
            end
            ret[k] = ShiHaoEnv.MergeMapsDeep(unpack(subtables))
        else
            for i, map in ipairs({ ... }) do
                if map[k] ~= nil then
                    ret[k] = map[k]
                end
            end
        end
    end

    return ret
end

-- merges two lists of this form (used in e.g. our customization stuff)
-- {
--      { "key", "value" },
--      { "key2", "value2" },
-- }
-- overwrites duplicate "keys" with the latter list's value
function ShiHaoEnv.MergeKeyValueList(...)
    local ret = {}
    for i, list in ipairs({ ... }) do
        for i, map in ipairs(list) do
            local found = false
            for i2, savedmap in ipairs(ret) do
                if map[1] == savedmap[1] then
                    found = true
                    savedmap[2] = map[2]
                    break
                end
            end
            if not found then
                table.insert(ret, map)
            end
        end
    end
    return ret
end

function ShiHaoEnv.SubtractMapKeys(base, subtract)
    local ret = {}
    for k, v in pairs(base) do
        local subtract_v = subtract[k]
        if subtract_v == nil then
            --no subtract entry => keep key+value in ret table
            ret[k] = v
        elseif type(subtract_v) == "table" and type(v) == "table" then
            local subtable = ShiHaoEnv.SubtractMapKeys(v, subtract_v)
            if next(subtable) ~= nil then
                ret[k] = subtable
            end
        end
        --otherwise, subtract entry exists => drop key+value from ret table
    end
    return ret
end

-- Adds 'addition' to the end of 'orig', 'mult' times.
-- ExtendedArray({"one"}, {"two","three"}, 2) == {"one", "two", "three", "two", "three" }
function ShiHaoEnv.ExtendedArray(orig, addition, mult)
    local ret = {}
    for k, v in pairs(orig) do
        ret[k] = v
    end
    mult = mult or 1
    for i = 1, mult do
        table.insert(ret, addition)
    end
    return ret
end

local function _FlattenTree(tree, ret, exclude, unique)
    for k, v in pairs(tree) do
        if type(v) == "table" then
            _FlattenTree(v, ret, exclude, unique)
        elseif not exclude[v] then
            table.insert(ret, v)
            exclude[v] = unique
        end
    end
    return ret
end

function ShiHaoEnv.FlattenTree(tree, unique)
    return _FlattenTree(tree, {}, {}, unique)
end

function ShiHaoEnv.GetRandomKey(choices)
    local choice = math.random(ShiHaoEnv.GetTableSize(choices)) - 1

    local picked = nil
    for k, v in pairs(choices) do
        picked = k
        if choice <= 0 then
            break
        end
        choice = choice - 1
    end
    assert(picked)
    return picked
end

function ShiHaoEnv.GetRandomWithVariance(baseval, randomval)
    return baseval + (math.random() * 2 * randomval - randomval)
end

function ShiHaoEnv.GetRandomMinMax(min, max)
    return min + math.random() * (max - min)
end


-------------------------MEMREPORT

-- 这里的代码有点迷糊人啊，这在干嘛？绕来绕去的，还搞好几个函数

local global_type_table = nil

local function type_name(o)
    if global_type_table == nil then
        global_type_table = {}
        for k, v in pairs(_G) do
            global_type_table[v] = k
        end
        global_type_table[0] = "table"
    end
    local mt = getmetatable(o)
    if mt then
        return global_type_table[mt] or "table"
    else
        return type(o) --"Unknown"
    end
end

local function count_all(f)
    local seen = {}
    local count_table
    count_table = function(t)
        if seen[t] then return end
        f(t)
        seen[t] = true
        for k, v in pairs(t) do
            if type(v) == "table" then
                count_table(v)
            else
                f(v)
            end
        end
    end
    count_table(_G)
end

function ShiHaoEnv.isnan(x) return x ~= x end
math.sh_inf = 1 / 0
function ShiHaoEnv.isinf(x) return x == math.sh_inf or x == -math.sh_inf end
function ShiHaoEnv.isbadnumber(x) return ShiHaoEnv.isinf(x) or ShiHaoEnv.isnan(x) end

local function type_count()
    local counts = {}
    local enumerate = function(o)
        local t = type_name(o)
        counts[t] = (counts[t] or 0) + 1
    end
    count_all(enumerate)
    return counts
end

function ShiHaoEnv.mem_report()
    local tmp = {}

    for k, v in pairs(type_count()) do
        table.insert(tmp, { num = v, name = k })
    end
    table.sort(tmp, function(a, b) return a.num > b.num end)
    local tmp2 = { "MEM REPORT:\n" }
    for k, v in ipairs(tmp) do
        table.insert(tmp2, tostring(v.num) .. "\t" .. tostring(v.name))
    end

    print(table.concat(tmp2, "\n"))
end

-------------------------MEMREPORT



function ShiHaoEnv.weighted_random_choice(choices)

    local function weighted_total(choices)
        local total = 0
        for choice, weight in pairs(choices) do
            total = total + weight
        end
        return total
    end

    local threshold = math.random() * weighted_total(choices)

    local last_choice
    for choice, weight in pairs(choices) do
        threshold = threshold - weight
        if threshold <= 0 then return choice end
        last_choice = choice
    end

    return last_choice
end

function ShiHaoEnv.weighted_random_choices(choices, num_choices)

    local function weighted_total(choices)
        local total = 0
        for choice, weight in pairs(choices) do
            total = total + weight
        end
        return total
    end

    local picks = {}
    for i = 1, num_choices do
        local pick
        local threshold = math.random() * weighted_total(choices)
        for choice, weight in pairs(choices) do
            threshold = threshold - weight
            pick = choice
            if threshold <= 0 then
                break
            end
        end

        table.insert(picks, pick)
    end

    return picks
end

function ShiHaoEnv.PrintTable(tab)
    local str = {}

    local function internal(tab, str, indent)
        for k, v in pairs(tab) do
            if type(v) == "table" then
                if #v > 0 then
                    table.insert(str, indent .. tostring(k) .. " = \n")
                    internal(v, str, indent .. '    ')
                else
                    table.insert(str, indent .. tostring(k) .. " = [empty]" .. tostring(v) .. "\n")
                end
            else
                table.insert(str, indent .. tostring(k) .. " = " .. tostring(v) .. "\n")
            end
        end
    end

    internal(tab, str, '')
    return table.concat(str, '')
end


-- make environment
local env = {  -- add functions you know are safe here
    loadstring = loadstring -- functions can get serialized to text, this is required to turn them back into functions
}

function ShiHaoEnv.RunInEnvironment(fn, fnenv)
    setfenv(fn, fnenv)
    return xpcall(fn, debug.traceback)
end

--[[function ShiHaoEnv.RunInEnvironmentSafe(fn, fnenv)
    setfenv(fn, fnenv)
    return xpcall(fn, function(msg)
        print(msg)
        StackTraceToLog()
        print(debugstack())
        return ""
    end)
end]]

-- run code under environment [Lua 5.1]
function ShiHaoEnv.RunInSandbox(untrusted_code)
    if untrusted_code:byte(1) == 27 then return nil, "binary bytecode prohibited" end
    local untrusted_function, message = loadstring(untrusted_code)
    if not untrusted_function then return nil, message end
    return ShiHaoEnv.RunInEnvironment(untrusted_function, env)
end

-- RunInSandboxSafe uses an empty environement
-- By default this function does not assert
-- If you wish to run in a safe sandbox, with normal assertions:
-- RunInSandboxSafe( untrusted_code, debug.traceback )
function ShiHaoEnv.RunInSandboxSafe(untrusted_code, error_handler)
    if untrusted_code:byte(1) == 27 then return nil, "binary bytecode prohibited" end
    local untrusted_function, message = loadstring(untrusted_code)
    if not untrusted_function then return nil, message end
    setfenv(untrusted_function, {})
    return xpcall(untrusted_function, error_handler or function() end)
end

--same as above, but catches infinite loops
--[[function RunInSandboxSafeCatchInfiniteLoops(untrusted_code, error_handler)
    if DEBUGGER_ENABLED then
        --The debugger makes use of debug.sethook, so it conflicts with this function
        --We'll rely on the debugger to catch infinite loops instead, so in this case, just fallback
        return RunInSandboxSafe(untrusted_code, error_handler)
    end

    if untrusted_code:byte(1) == 27 then return nil, "binary bytecode prohibited" end
    local untrusted_function, message = loadstring(untrusted_code)
    if not untrusted_function then return nil, message end
    setfenv(untrusted_function, {})

    local co = coroutine.create(function()
        coroutine.yield(xpcall(untrusted_function, error_handler or function() end))
    end)
    debug.sethook(co, function() error("infinite loop detected") end, "", 20000)
    --clear out all entries to the metatable of string, since that can be accessed even by doing local string = "" string.whatever()
    local string_backup = deepcopy(string)
    cleartable(string)
    local result = { coroutine.resume(co) }
    shallowcopy(string_backup, string)
    debug.sethook(co)
    return unpack(result, 2)
end]]

--[[function GetTickForTime(target_time)
    return math.floor(target_time / GetTickTime())
end

function GetTimeForTick(target_tick)
    return target_tick * GetTickTime()
end

--only works for tasks created from scheduler, not from staticScheduler
function GetTaskRemaining(task)
    return (task == nil and -1)
            or (task:NextTime() == nil and -1)
            or (task:NextTime() < GetTime() and -1)
            or task:NextTime() - GetTime()
end

function GetTaskTime(task)
    return (task == nil and -1)
            or (task:NextTime() == nil and -1)
            or (task:NextTime())
end]]

function ShiHaoEnv.shuffleArray(array)
    local arrayCount = #array
    for i = arrayCount, 2, -1 do
        local j = math.random(1, i)
        array[i], array[j] = array[j], array[i]
    end
    return array
end

function ShiHaoEnv.shuffledKeys(dict)
    local keys = {}
    for k, v in pairs(dict) do
        table.insert(keys, k)
    end
    return ShiHaoEnv.shuffleArray(keys)
end

function ShiHaoEnv.sortedKeys(dict)
    local keys = {}
    for k, v in pairs(dict) do
        table.insert(keys, k)
    end
    table.sort(keys)
    return keys
end

function ShiHaoEnv.TrackedAssert(tracking_data, function_ptr, function_data)
    --print("TrackedAssert", tracking_data, function_ptr, function_data)
    _G['tracked_assert'] = function(pass, reason)
        --print("Tracked:Assert", tracking_data, pass, reason)
        assert(pass, tracking_data .. " --> " .. reason)
    end

    local result = function_ptr(function_data)

    _G['tracked_assert'] = _G.assert

    return result
end

function ShiHaoEnv.deepcopy(object)
    local lookup_table = {}
    local function _copy(object)
        if type(object) ~= "table" then
            return object
        elseif lookup_table[object] then
            return lookup_table[object]
        end
        local new_table = {}
        lookup_table[object] = new_table
        for index, value in pairs(object) do
            new_table[_copy(index)] = _copy(value)
        end
        return setmetatable(new_table, getmetatable(object))
    end
    return _copy(object)
end

local function _copynometa(object, lookup_table)
    if type(object) ~= "table" then
        return object
    elseif getmetatable(object) ~= nil then
        return tostring(object)
    elseif lookup_table[object] then
        return lookup_table[object]
    end

    local new_table = {}
    lookup_table[object] = new_table
    for k, v in pairs(object) do
        new_table[_copynometa(k, lookup_table)] = _copynometa(v, lookup_table)
    end
    return new_table
end

function ShiHaoEnv.deepcopynometa(object)
    return _copynometa(object, {})
end

-- http://lua-users.org/wiki/CopyTable
function ShiHaoEnv.shallowcopy(orig, dest)
    local copy
    if type(orig) == 'table' then
        copy = dest or {}
        for k, v in pairs(orig) do
            copy[k] = v
        end
    else
        -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

function ShiHaoEnv.cleartable(object)
    if type(object) == "table" then
        for k, v in pairs(object) do
            object[k] = nil
        end
    end
end

-- if next(table) == nil, then the table is empty
function ShiHaoEnv.IsTableEmpty(t)
    -- https://stackoverflow.com/a/1252776/79125
    return next(t) == nil
end

function ShiHaoEnv.fastdump(value)
    local tostring = tostring
    local string = string
    local table = table
    local items = { "return " }
    local type = type

    local function printtable(in_table)
        table.insert(items, "{")

        for k, v in pairs(in_table) do
            local t = type(v)
            local comma = true
            if type(k) == "number" then
                if t == "number" then
                    table.insert(items, string.format("%s", tostring(v)))
                elseif t == "string" then
                    table.insert(items, string.format("[%q]", v))
                elseif t == "boolean" then
                    table.insert(items, string.format("%s", tostring(v)))
                elseif type(v) == "table" then
                    printtable(v)
                end
            elseif type(k) == "string" then
                local key = tostring(k)
                if t == "number" then
                    table.insert(items, string.format("%s=%s", key, tostring(v)))
                elseif t == "string" then
                    table.insert(items, string.format("%s=%q", key, v))
                elseif t == "boolean" then
                    table.insert(items, string.format("%s=%s", key, tostring(v)))
                elseif type(v) == "table" then
                    if next(v) then
                        table.insert(items, string.format("%s=", key))
                        printtable(v)
                    else
                        comma = false
                    end
                end
            else
                assert(false, "trying to save invalid data type")
            end
            if comma and next(in_table, k) then
                table.insert(items, ",")
            end
        end

        table.insert(items, "}")
        collectgarbage("step")
    end
    printtable(value)
    return table.concat(items)
end

-- Get a table index as if the table were circular.
--
-- You probably want circular_index instead.
-- Due to Lua's 1-based arrays, this is more complex than usual.
function ShiHaoEnv.circular_index_number(count, index)
    local zb_current = index - 1
    local zb_result = zb_current
    zb_result = zb_result % count
    return zb_result + 1
end

-- Index a table as if it were circular.
-- Use like this:
--      next_item = circular_index(item_list, index + 1)
function ShiHaoEnv.circular_index(t, index)
    return t[ShiHaoEnv.circular_index_number(#t, index)]
end

--[[ Data Structures --]]

-----------------------------------------------------------------

------------------------------
-- Class DynamicPosition (a position that is relative to a moveable platform)
-- DynamicPosition is for handling a point in the world that should follow a moving walkable_platform.
-- pt is in world space, walkable_platform is optional, if nil, the constructor will search for a platform at pt.
-- GetPosition() will return nil if a platform was being tracked but no longer exists.
--[[DynamicPosition = Class(function(self, pt, walkable_platform)
    if pt ~= nil then
        self.walkable_platform = walkable_platform or TheWorld.Map:GetPlatformAtPoint(pt.x, pt.z)
        if self.walkable_platform ~= nil then
            self.local_pt = Vector3(self.walkable_platform.entity:WorldToLocalSpace(pt:Get()))
        else
            --V2C: Make copy, saving ref to input Vector can be error prone
            self.local_pt = Vector3(pt:Get())
        end
    end
end)

function DynamicPosition:__eq(rhs)
    return self.walkable_platform == rhs.walkable_platform and self.local_pt.x == rhs.local_pt.x and self.local_pt.z == rhs.local_pt.z
end

function DynamicPosition:__tostring()
    local pt = self:GetPosition()
    return pt ~= nil
            and string.format("%2.2f, %2.2f on %s", pt.x, pt.z, tostring(self.walkable_platform))
            or "nil"
end

function DynamicPosition:GetPosition()
    if self.walkable_platform ~= nil then
        if self.walkable_platform:IsValid() then
            return Vector3(self.walkable_platform.entity:LocalToWorldSpace(self.local_pt:Get()))
        end
        self.walkable_platform = nil
        self.local_pt = nil
    end
    return self.local_pt
end]]

--[[function TrackMem()
    collectgarbage()
    collectgarbage("stop")
    TheSim:SetMemoryTracking(true)
end

function DumpMem()
    TheSim:DumpMemoryStats()
    mem_report()
    collectgarbage("restart")
    TheSim:SetMemoryTracking(false)
end]]

-- 这里应该是饥荒底层提供的
--[[function checkbit(x, b)
    return bit.band(x, b) > 0
end

function setbit(x, b)
    return bit.bor(x, b)
end

function clearbit(x, b)
    return bit.bxor(bit.bor(x, b), b)
end]]

-- Width is the total width of the region we are interested in, in radians.
-- Returns true if testPos is within .5*width of forward on either side
-- Forward is a vector, position and testPos are both locations, all are represented as Vector3s
--[[function ShiHaoEnv.IsWithinAngle(position, forward, width, testPos)

    -- Get vector from position to testpos (testVec)
    local testVec = testPos - position

    -- Test angle from forward to testVec (testAngle)
    testVec = testVec:GetNormalized()
    forward = forward:GetNormalized()
    local testAngle = math.acos(testVec:Dot(forward))

    -- Return true if testAngle is <= +/- .5*width
    if math.abs(testAngle) <= .5 * math.abs(width) then
        return true
    else
        return false
    end
end]]

-- Given a number of segments, circle radius, circle center point, and point to snap, returns a snapped position and angle on a circle's edge.
--[[function GetCircleEdgeSnapTransform(segments, radius, base_pt, pt, angle)
    local segmentangle = (segments > 0 and 360 / segments or 360)
    local snap_point = base_pt + Vector3(1, 0, 0) * radius
    local snap_angle = 0
    local start = angle or 0

    for midangle = -start, 360 - start, segmentangle do
        local facing = Vector3(math.cos(midangle / RADIANS), 0, math.sin(midangle / RADIANS))
        if IsWithinAngle(base_pt, facing, segmentangle / RADIANS, pt) then
            snap_point = base_pt + facing * radius
            snap_angle = midangle
            break
        end
    end
    return snap_point, snap_angle
end]]

--[[function SnapToBoatEdge(inst, boat, override_pt)
    if boat == nil then
        return
    end

    local pt = override_pt or inst:GetPosition()
    local boatpos = boat:GetPosition()
    local radius = boat.components.boatringdata and boat.components.boatringdata:GetRadius() - 0.1 or 0
    local boatsegments = boat.components.boatringdata and boat.components.boatringdata:GetNumSegments() or 0
    local boatangle = boat.Transform:GetRotation()

    local snap_point, snap_angle = GetCircleEdgeSnapTransform(boatsegments, radius, boatpos, pt, boatangle)
    if snap_point ~= nil then
        inst.Transform:SetPosition(snap_point.x, 0, snap_point.z)
        inst.Transform:SetRotation(-snap_angle + 90) -- Need to offset snap_angle here to make the object show in the correct orientation
    else
        -- point is outside of radius; set original position
        inst.Transform:SetPosition(pt:Get())
    end
end]]

-- Returns the angle from the boat's position to (x, z), in radians
--[[function GetAngleFromBoat(boat, x, z)
    if boat == nil then
        return
    end
    local boatpos = boat:GetPosition()
    return math.atan2(z - boatpos.z, x - boatpos.x)
end]]


--utf8substr(str, start, end)
--start: 1-based start position (can be negative to count from end)
--end: 1-based end position (optional, can be negative to count from end)
--returns a new string
--[[if APP_VERSION ~= "MAPGEN" then
    string.utf8char = utf8char
    string.utf8sub = utf8substr
    string.utf8len = utf8strlen
    string.utf8upper = utf8strtoupper
    string.utf8lower = utf8strtolower
end

-- Returns the 0 - 255 color of a hex code
function HexToRGB(hex)
    hex = hex:gsub("#", "")
    return tonumber("0x" .. hex:sub(1, 2)), tonumber("0x" .. hex:sub(3, 4)), tonumber("0x" .. hex:sub(5, 6))
end

-- Returns the 0.0 - 1.0 color from r, g, b parameters
function RGBToPercentColor(r, g, b)
    return r / 255, g / 255, b / 255
end

-- Returns the 0.0 - 1.0 color from a hex parameter
function HexToPercentColor(hex)
    return RGBToPercentColor(HexToRGB(hex))
end]]

function ShiHaoEnv.CalcDiminishingReturns(current, basedelta)
    local dampen = 3 * basedelta / (current + 3 * basedelta)
    local dcharge = dampen * basedelta * .5 * (1 + math.random() * dampen)
    return current + dcharge
end

function ShiHaoEnv.Dist2dSq(p1, p2)
    local dx = p1.x - p2.x
    local dy = p1.y - p2.y
    return dx * dx + dy * dy
end

function ShiHaoEnv.DistPointToSegmentXYSq(p, v1, v2)
    local l2 = ShiHaoEnv.Dist2dSq(v1, v2)
    if (l2 == 0) then
        return ShiHaoEnv.Dist2dSq(p, v1)
    end
    local t = ((p.x - v1.x) * (v2.x - v1.x) + (p.y - v1.y) * (v2.y - v1.y)) / l2
    if (t < 0) then
        return ShiHaoEnv.Dist2dSq(p, v1)
    end
    if (t > 1) then
        return ShiHaoEnv.Dist2dSq(p, v2)
    end
    return ShiHaoEnv.Dist2dSq(p, { x = v1.x + t * (v2.x - v1.x), y = v1.y + t * (v2.y - v1.y) });
end


-- helpers for orderedPairs
function ShiHaoEnv.__genOrderedIndex(t)
    local orderedIndex = {}
    for key in pairs(t) do
        table.insert(orderedIndex, key)
    end
    table.sort(orderedIndex)
    return orderedIndex
end

function ShiHaoEnv.orderedNext(t, state)
    -- Equivalent of the next function, but returns the keys in the alphabetic
    -- order. We use a temporary ordered key table that is stored in the
    -- table being iterated.

    local key = nil
    --print("orderedNext: state = "..tostring(state) )
    if state == nil then
        -- the first time, generate the index
        t.__orderedIndex = __genOrderedIndex(t)
        key = t.__orderedIndex[1]
    else
        -- fetch the next value
        for i = 1, table.getn(t.__orderedIndex) do
            if t.__orderedIndex[i] == state then
                key = t.__orderedIndex[i + 1]
            end
        end
    end

    if key then
        return key, t[key]
    end

    -- no more value to return, cleanup
    t.__orderedIndex = nil
    return
end

-- iterate over a list in sorted order
function ShiHaoEnv.orderedPairs(t)
    -- Equivalent of the pairs() function on tables. Allows to iterate
    -- in order
    return ShiHaoEnv.orderedNext, t, nil
end

--Zachary: add a lua 5.2 feature, metatables for pairs ipairs and next
function ShiHaoEnv.metanext(t, k, ...)
    local m = debug.getmetatable(t)
    local n = m and m.__next or next
    return n(t, k, ...)
end

function ShiHaoEnv.metapairs(t, ...)
    local m = debug.getmetatable(t)
    local p = m and m.__pairs or pairs
    return p(t, ...)
end

function ShiHaoEnv.metaipairs(t, ...)
    local m = debug.getmetatable(t)
    local i = m and m.__ipairs or ipairs
    return i(t, ...)
end

function ShiHaoEnv.metarawset(t, k, v)
    local mt = getmetatable(t)
    mt._[k] = v
end

function ShiHaoEnv.metarawget(t, k)
    local mt = getmetatable(t)
    return mt._[k] or mt.c[k]
end

--[[function ZipAndEncodeString(data)
    return TheSim:ZipAndEncodeString(DataDumper(data, nil, true))
end

function ZipAndEncodeSaveData(data)
    return { str = ZipAndEncodeString(data) }
end]]

--[[function DecodeAndUnzipString(str)
    if type(str) == "string" then
        local success, savedata = RunInSandbox(TheSim:DecodeAndUnzipString(str))
        if success then
            return savedata
        else
            return {}
        end
    end
end

function DecodeAndUnzipSaveData(data)
    return DecodeAndUnzipString(data and data.str or nil)
end]]

function ShiHaoEnv.FunctionOrValue(func_or_val, ...)
    if type(func_or_val) == "function" then
        return func_or_val(...)
    end
    return func_or_val
end

--[[function ApplyLocalWordFilter(text, text_filter_context, net_id)
    if text_filter_context ~= TEXT_FILTER_CTX_GAME --We filter everything but game strings
            and (Profile:GetProfanityFilterChatEnabled() or TheSim:IsSteamChinaClient())
    then

        text = TheSim:ApplyLocalWordFilter(text, text_filter_context, net_id) or text
    end

    return text
end]]

--jcheng taken from griftlands
--START--
function ShiHaoEnv.rawstring(t)
    if type(t) == "table" then
        local mt = getmetatable(t)
        if mt then
            -- Seriously, is there any better way to bypass the tostring metamethod?
            setmetatable(t, nil)
            local s = tostring(t)
            setmetatable(t, mt)
            return s
        end
    end

    return tostring(t)
end

local function StringSort(a, b)
    if type(a) == "number" and type(b) == "number" then
        return a < b
    else
        return tostring(a) < tostring(b)
    end
end

local function SortedKeysIter(state, i)
    i = next(state.sorted_keys, i)
    if i then
        local key = state.sorted_keys[i]
        return i, key, state.t[key]
    end
end

function ShiHaoEnv.sorted_pairs(t, fn)
    local sorted_keys = {}
    for k, v in pairs(t) do
        table.insert(sorted_keys, k)
    end
    table.sort(sorted_keys, fn or StringSort)
    return SortedKeysIter, { sorted_keys = sorted_keys, t = t }
end

--[[function generic_error(err)
    return tostring(err) .. "\n" .. debugstack()
end]]

--END--