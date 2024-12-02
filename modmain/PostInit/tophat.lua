---
--- @author zsh in 2023/3/4 16:11
---


env.AddPrefabPostInit("wolfgang", function(inst)
    if not TheWorld.ismastersim then
        return inst;
    end
    if inst.components.mightiness then
        local old_DoDelta = inst.components.mightiness.DoDelta;
        function inst.components.mightiness:DoDelta(delta, ...)
            if self.inst:HasTag("mie_tophat_wolfgang") then
                if delta < 0 then
                    delta = 0;
                end
            end
            old_DoDelta(self, delta, ...);
        end
    end
end)