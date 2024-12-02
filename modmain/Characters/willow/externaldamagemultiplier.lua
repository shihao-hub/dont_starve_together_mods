---
--- @author zsh in 2023/4/3 12:52
---


local WILLOW_TAG1 = "willow_externaldamagemultipliers_1.5";
local WILLOW_TAG2 = "willow_externaldamagemultipliers_2";

env.AddPrefabPostInit("willow", function(inst)
    if not TheWorld.ismastersim then
        return inst;
    end
    if inst.components.combat then
        inst.components.combat.externaldamagemultipliers:SetModifier(WILLOW_TAG1, 1.5);
    end
    inst:ListenForEvent("sanitydelta", function(inst, data)
        local multipliers = inst.components.combat and inst.components.combat.externaldamagemultipliers;
        if not (multipliers and multipliers._modifiers and inst.components.sanity) then
            return;
        end
        local _modifiers = multipliers._modifiers;
        if inst.components.sanity:IsCrazy() then
            if _modifiers[WILLOW_TAG1] then
                multipliers:RemoveModifier(WILLOW_TAG1);
            end
            if _modifiers[WILLOW_TAG2] == nil then
                multipliers:SetModifier(WILLOW_TAG2, 2);
            end
        else
            if _modifiers[WILLOW_TAG2] then
                multipliers:RemoveModifier(WILLOW_TAG2);
            end
            if _modifiers[WILLOW_TAG1] == nil then
                multipliers:SetModifier(WILLOW_TAG1, 1.5);
            end
        end
    end);
end)