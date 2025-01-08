local module = {}

---获得调用该函数的文件路径
function module.get_call_filepath()
    local info = debug.getinfo(2, "S")
    return info.source:gsub("/", "."):sub(2, -5) -- @ ~ .lua，切除首尾的 @ 和 .lua
end

---@param level_incr number|nil nullable
---@return string
function module.get_call_location(level_incr)
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
    local info = debug.getinfo(2 + level_incr) -- 1 代表当前栈，2 代表调用当前函数的栈帧
    if info and info.short_src and info.currentline then
        return (string.gsub(string.format("[file %s, line %s]", info.short_src, info.currentline), "\\", "/"))
    end
    return ""
end

return module
