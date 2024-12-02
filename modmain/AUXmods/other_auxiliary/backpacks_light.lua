---
--- @author zsh in 2023/1/24 16:45
---

--[[ 所有背包都能发光 ]]
-- local prefabs = { "mone_lighth_fx" };

for _, p in ipairs({
    -- 原版
    "backpack", "piggyback", "icepack", "spicepack", "seedpouch", "candybag", "krampus_sack",
    -- 本模组
    "mone_seedpouch", "mone_seasack", "mone_nightspace_cape",
    -- 其他模组？
}) do
    env.AddPrefabPostInit(p, function(inst)
        if not TheWorld.ismastersim then
            return inst;
        end

        if inst.components.equippable then
            local old_onequipfn = inst.components.equippable.onequipfn;
            inst.components.equippable.onequipfn = function(inst, owner, ...)
                if old_onequipfn then
                    old_onequipfn(inst, owner, ...);
                end

                inst._mone_light_fx = inst._mone_light_fx or SpawnPrefab("mone_light_fx");
                if inst._mone_light_fx then
                    inst._mone_light_fx._backpack = inst;
                    inst._mone_light_fx.entity:SetParent(inst.entity);
                end
            end

            local old_onunequipfn = inst.components.equippable.onunequipfn;
            inst.components.equippable.onunequipfn = function(inst, owner, ...)
                if old_onunequipfn then
                    old_onunequipfn(inst, owner, ...);
                end

                if inst._mone_light_fx then
                    inst._mone_light_fx:Remove();
                    inst._mone_light_fx = nil;
                end
            end
        end
    end);
end