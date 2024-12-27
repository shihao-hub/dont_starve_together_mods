---
--- DateTime: 2024/12/3 21:00
---


local module = {}

function module.string_format(str, context)
    return (string.gsub(str, "{{ ?([a-zA-Z_]+) ?}}", function(matched)
        return tostring(context[matched])
    end))
end

if select("#", ...) == 0 then
    print(module.string_format("{{name}}", {
        name = 1
    }))
end

return module
