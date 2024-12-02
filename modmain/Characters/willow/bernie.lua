---
--- @author zsh in 2023/4/21 9:37
---

local bernie_aoe_splash = true;

if bernie_aoe_splash then
    local AREA_HIT_DAMAGE_PERCENT = 1;

    local function areahitcheck(target, inst)
        for _, tag in ipairs({ "INLIMBO", "NOCLICK", "FX", "player", "abigail", "companion", "shadowminion", "wall", "playerghost" }) do
            if target:HasTag(tag) then
                return false;
            end
        end
        return true;
    end

    env.AddPrefabPostInit("bernie_big", function(inst)
        if not TheWorld.ismastersim then
            return inst;
        end
        -- 暂时弃用吧，不需要
        --if inst.components.damagetyperesist == nil then
        --    inst:AddComponent("damagetyperesist");
        --end
        --inst.components.damagetyperesist:AddResist("shadowcreature", inst, 0.5, "mone_bernie_big_damagetyperesist");

        if inst.components.combat then
            inst.components.combat:SetAreaDamage(TUNING.BERNIE_BIG_ATTACK_RANGE, AREA_HIT_DAMAGE_PERCENT, areahitcheck);
        end
    end)
end