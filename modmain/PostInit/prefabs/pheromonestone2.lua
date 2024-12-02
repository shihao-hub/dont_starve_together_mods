---
--- @author zsh in 2023/3/29 10:11
---

env.AddComponentPostInit("container", function(self)
    if self.inst.components.mone_pheromonestone_eternity == nil then
        self.inst:AddComponent("mone_pheromonestone_eternity");
    end
end)
