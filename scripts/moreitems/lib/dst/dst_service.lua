---
--- DateTime: 2025/1/6 18:50
---

-- dst service logic utils
-- 即此处的函数与业务逻辑强相关，比如和 prefab fn 强相关

local log = require("moreitems.lib.shihao.module.log")
local base = require("moreitems.lib.shihao.base")

local module = {}
local cache = {}

function module.SetOnEntityReplicated(inst, prefab, data)
    -- function Container:WidgetSetup(prefab, data)

    local function Local()
        local obj = {}

        -- NOTE: obj.x <==> static, obj:x <==> instance

        function obj.GetOnEntityReplicated(inst, prefab, data)
            local old_OnEntityReplicated = inst.OnEntityReplicated

            return function(inst)
                if old_OnEntityReplicated then
                    old_OnEntityReplicated(inst)
                end
                if inst ~= nil and inst.replica and inst.replica.container then
                    inst.replica.container:WidgetSetup(prefab, data)
                end
            end
        end

        return obj
    end

    local loc = Local()

    local key = base.string_format("{{ prefab }}_OnEntityReplicated", { prefab = inst.prefab })
    -- NOTE: 此处缓存的目的是，让 fun-prefab 一对一关系变成一对多关系。
    if cache[key] == nil then
        cache[key] = loc.GetOnEntityReplicated(inst, prefab, data)
    end
    log.info(base.string_format("{{ key }}:{{ fn }}", { key = key, fn = cache[key] }))
    inst.OnEntityReplicated = cache[key]
end

---@param atlasname string|nil atlasname == nil 时，将调用 ChangeImageName 方法
function module.inventoryitem__set_imagename(inst, imagename, atlasname)
    -- inventoryitem__set_imagename, __ 作为命名空间分隔符，说实话我挺喜欢这样的，但是似乎不符合规范呢，可能是项目太小
    if atlasname == nil then
        inst.components.inventoryitem:ChangeImageName(imagename)
        return
    end

    -- NOTE: 直接修改 imagename 有个好处，因为饥荒存在 onimagename 回调，imagename 被修改时会调用它，类似 Java 的 setImageName 封装
    inst.components.inventoryitem.imagename = imagename
    inst.components.inventoryitem.atlasname = atlasname
end

return module
