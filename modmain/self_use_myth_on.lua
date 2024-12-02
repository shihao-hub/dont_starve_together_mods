---
--- @author zsh in 2023/3/1 12:58
---

--右键使用的动作(包括两种 一种是在物品栏 一种是地上的)
local MIE_USE_INVENTORY = Action({ priority = 1, mount_valid = true, encumbered_valid = true })
MIE_USE_INVENTORY.id = "MIE_USE_INVENTORY"
MIE_USE_INVENTORY.strfn = function(act)
    local target = act.invobject or act.target
    return target and target.MIE_USE_TYPE or "USE"
end
MIE_USE_INVENTORY.fn = function(act)
    local obj = act.invobject or act.target
    if obj then
        if obj.components.mie_use_inventory then
            return obj.components.mie_use_inventory:OnUse(act.doer)
        end
    end
end
env.AddAction(MIE_USE_INVENTORY)

env.AddComponentAction("INVENTORY", "mie_use_inventory", function(inst, doer, actions)
    if doer and inst:HasTag("canuseininv_mie") then
        table.insert(actions, ACTIONS.MIE_USE_INVENTORY)
    end
end)

env.AddComponentAction("SCENE", "mie_use_inventory", function(inst, doer, actions, right)
    if right and inst:HasTag("canuseinscene_mie") then
        table.insert(actions, ACTIONS.MIE_USE_INVENTORY)
    end
end)

env.AddStategraphActionHandler("wilson", ActionHandler(ACTIONS.MIE_USE_INVENTORY, function(inst, action)
    local target = action.target or action.invobject
    if target then
        if target.onusesgname ~= nil then
            return target.onusesgname
        end
    end
    return "give"
end))

env.AddStategraphActionHandler("wilson_client", ActionHandler(ACTIONS.MIE_USE_INVENTORY, function(inst, action)
    local target = action.target or action.invobject
    if target then
        if target.onusesgname ~= nil then
            return target.onusesgname
        end
    end
    return "give"
end))

STRINGS.MIE_USE_INVENTORY = "使用";

STRINGS.ACTIONS.MIE_USE_INVENTORY = {
    USE = STRINGS.MIE_USE_INVENTORY,
}
