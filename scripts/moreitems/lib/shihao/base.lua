---
--- DateTime: 2024/12/3 21:00
---


local module = {}

---将形如 {{ a }} {{ b }} 等格式的字符串全部替换为 tostring(a) 和 tostring(b)
function module.string_format(str, context)
    return (string.gsub(str, "{{ ?([a-zA-Z_]+) ?}}", function(matched)
        return tostring(context[matched])
    end))
end

function module.bool(val)
    if val == nil or val == false then
        return false
    end
    return true
end


if select("#", ...) == 0 then
    print(module.string_format("{{name}}", {
        name = 1
    }))
end

return module
