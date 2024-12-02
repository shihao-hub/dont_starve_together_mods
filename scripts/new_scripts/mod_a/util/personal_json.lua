---
--- Created by zsh
--- DateTime: 2023/11/14 3:03
---

require("new_scripts.mod_a.common_global")

local json_encode_util
json_encode_util = morel_SingletonInstance(function(instance)
    json_encode_util = instance
    local ins = json_encode_util

    function ins.encode_string_value(s)
        s = string.gsub(s, '\\', '\\\\')
        s = string.gsub(s, '"', '\\"')
        s = string.gsub(s, "'", "\\'")
        s = string.gsub(s, '\n', '\\n')
        s = string.gsub(s, '\t', '\\t')
        s = string.gsub(s, '\r', '\\r')
        return s
    end

    function ins.is_encodable(v)
        local vtype = type(v)
        return vtype == "nil" or vtype == "boolean" or vtype == "number" or vtype == "string" or vtype == "table"
    end

    -- 规则：表中可编码的 value 对应的 key 是 1..n，除此以外没有其他内容或只有不可编码的 value
    -- 但是这个函数相当脆弱，很难判断出来，但是又没有其他好办法
    function ins.is_encodable_array(arr)
        local max_index = 0
        for k, v in pairs(arr) do
            -- It doesn't seem very readable in here
            --if k == "n" and table.getn(arr) ~= v then
            --    return false
            --end
            if morel_is_number(k) and math.floor(k) == k and k >= 1 then
                if not self:is_encodable(v) then return false end
                max_index = math.max(max_index, k)
            else
                -- It makes for good readability
                if k == "n" then
                    -- "table.getn" supposed to find the length of the first "v,nil" up to
                    if table.getn(arr) ~= v then return false end
                else
                    --print("--1--",v)
                    if self:is_encodable(v) then return false end
                end
            end
        end
        return true, max_index
    end
end)

-- 暂未好好测试
function morel_json_encode(v)
    if morel_is_nil(v) or morel_is_function(v) then
        return "null"
    end
    -- only string is "abc". nil -> null, boolean -> true/false, number -> 1/1.0/.5/1e-3
    if morel_is_string(v) then
        return "\"" .. json_encode_util.encode_string_value(v) .. "\""
    end
    if morel_is_number(v) or morel_is_boolean(v) then
        return tostring(v)
    end
    if morel_is_table(v) then
        local rval = {}
        -- Consider arrays separately
        local b_array, max_count = json_encode_util.is_encodable_array(v)
        if b_array then
            for i = 1, max_count do
                table.insert(rval, morel_json_encode(v[i]))
            end
        else
            for key, val in pairs(v) do
                if json_encode_util.is_encodable(key) and json_encode_util.is_encodable(val) then
                    -- 不可，json 格式的话，key 肯定不能是 table
                    --table.insert(rval, "" .. morel_json_encode(key) .. ":" .. morel_json_encode(val))
                    -- 注意，如果 json 的格式不正确，递归会导致栈溢出
                    local t = v
                    if val ~= t then
                        --print(key,val)
                        --io.flush()
                        table.insert(rval, "" .. tostring(key) .. ":" .. morel_json_encode(val))
                    end
                end
            end
        end
        if b_array then
            return "[" .. table.concat(rval, ",") .. "]"
        else
            return "{" .. table.concat(rval, ",") .. "}"
        end
    end

    if not false then
        morel_tracked_assert(false, "encode attempt to encode unsupported type " .. tostring(type(v) .. ":" .. tostring(v)))
    end
end

local json_decode_util
json_decode_util = morel_SingletonInstance(function(instance)
    json_decode_util = instance
    local ins = json_decode_util
    -- using "json_decode_util" instead of "self" makes emmylua plug misleading so that
    -- it can insert these function into its detection(检测).
    function ins.scan_array(s, start_pos)

    end

    function ins.scan_comment_return_pos(s, start_pos)
        if not string.sub(s, start_pos, start_pos + 1) == "/*" then
            morel_tracked_assert(false, "decode:scan_comment_return_pos called but comment does not start at position " .. start_pos)
        end

        local end_pos = string.find(s, "*/", start_pos + 2)
        if not end_pos ~= nil then
            morel_tracked_assert(false, "decode:scan_comment_return_pos called but comment does not end with */")
        end
        return end_pos + 2
    end

    function ins.scan_constant(s, start_pos)

    end

    function ins.scan_number(s, start_pos)

    end

    function ins.scan_object(s, start_pos)

    end

    function ins.scan_string(s, start_pos)

    end

    -- 这个实现过程有指针的一些味道在里面
    function ins.scan_whitespace_return_pos(s, start_pos)
        local whitespace = " \n\r\t"
        local len = string.len(s)
        -- string.find(s, pattern, init, plain)
        -- Note that if `plain` is given, then `init` must be given as well.
        while string.find(whitespace, string.sub(s, start_pos, start_pos), 1, true) and start_pos <= len do
            start_pos = start_pos + 1
        end
        return start_pos
    end
end)


-- 这个解码有点麻烦。不，是超级麻烦。
-- todo: incomplete
function morel_json_decode(s, start_pos)
    if not morel_is_string(s) then
        print("warning: ", morel_get_call_on_position())
        return ""
    end
    -- this is special, although "start_pos or 1" can also get correct result,
    -- but I reckon that "start_pos and start_pos or 1" is more standard.
    start_pos = start_pos and start_pos or 1
    start_pos = json_decode_util.scan_whitespace_return_pos(s, start_pos)

    if not start_pos <= string.len(s) then
        morel_tracked_assert(false, "Unterminated JSON encoded object found at position [" .. tostring(start_pos) .. "] in [" .. s .. "]")
    end

    local cursor_char = string.sub(s, start_pos, start_pos)
    -- remove comment: the form of a json comment is only "/* ... */"
    if string.sub(s, start_pos, start_pos + 1) == '/*' then
        return morel_json_decode(s, json_decode_util.scan_comment_return_pos(s, start_pos))
    end
    -- object
    if cursor_char == "{" then
        return json_decode_util.scan_object(s, start_pos)
    end
    -- array
    if cursor_char == "[" then
        return json_decode_util.scan_array(s, start_pos)
    end
    -- number
    if string.find("+-0123456789.e", cursor_char, 1, true) then
        return json_decode_util.scan_number(s, start_pos)
    end
    -- string
    if cursor_char == [["]] or cursor_char == [[']] then
        return json_decode_util.scan_string(s, start_pos)
    end
    -- otherwise, it must be a constant
    return json_decode_util.scan_constant(s, start_pos)
end