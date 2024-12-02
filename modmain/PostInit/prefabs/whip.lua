---
--- @author zsh in 2023/8/1 20:46
---

local Telekinesis = string.upper("Telekinesis");
local Spellcaster = string.upper("Spellcaster");

local MONE_WHIP = Action({ mount_valid = true, distance = 12 })
MONE_WHIP.id = "MONE_WHIP"
MONE_WHIP.strfn = function(act)
    return act.target ~= nil and act.target:HasTag("_inventoryitem") and Telekinesis or Spellcaster;
end

MONE_WHIP.fn = function(act)
    if act.invobject and act.invobject.components.mone_whip_spell and act.target then
        act.invobject.components.mone_whip_spell:CastSpell(act.doer, act.target);
        return true;
    end
end
AddAction(MONE_WHIP);

AddComponentAction("EQUIPPED", "mone_whip_spell", function(inst, doer, target, actions, right)
    if right and inst:HasTag("mone_can_spell_whip")
            and target and target ~= doer
            and (target:HasTag("_combat") or target:HasTag("_inventoryitem")) then
        table.insert(actions, ACTIONS.MONE_WHIP);
    end
end)

AddStategraphActionHandler("wilson", ActionHandler(MONE_WHIP, function(inst)
    return "dojostleaction";
end))
AddStategraphActionHandler("wilson_client", ActionHandler(MONE_WHIP, function(inst)
    return "dojostleaction";
end))

STRINGS.ACTIONS.MONE_WHIP = {
    [Telekinesis] = "隔空取物";
    [Spellcaster] = "施法";
}