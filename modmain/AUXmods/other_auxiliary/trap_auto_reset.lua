---
--- @author zsh in 2023/1/21 12:58
---

env.AddPrefabPostInit("trap_teeth", function(inst)
    inst:AddTag("mone_trap_auto_reset");
    if not TheWorld.ismastersim then
        return inst;
    end
    if inst.components.mine then
        local old_onexplode = inst.components.mine.onexplode;
        inst.components.mine.onexplode = function(inst, target, ...)
            if old_onexplode then
                old_onexplode(inst, target, ...)
            end
            inst:DoTaskInTime(3, function(inst)
                -- 为什么 mine 会被移除？哪个 mod 干的？emm，好像是要判断有效性？
                if inst and inst:IsValid() and inst.components.mine then
                    inst.components.mine:Reset()
                end
            end)
        end
    end
end)

-- 荆棘陷阱和海星呢？