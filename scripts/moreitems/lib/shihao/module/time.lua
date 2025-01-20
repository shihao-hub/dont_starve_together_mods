local module = {}

---获得当前的结构化时间
---@overload fun()
---@param format string
function module.get_cur_asctime(format)
    format = format or "%Y-%m-%d %H:%M:%S"
    local asctime = os.date(format)
    return asctime
end

return module