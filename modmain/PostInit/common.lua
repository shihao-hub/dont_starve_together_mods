---
--- @author zsh in 2023/6/9 13:36
---

-- 麦克斯韦读暗影秘典
--HookComponent("inventory", function(self)
--    local old_CloseAllChestContainers = self.CloseAllChestContainers;
--    function self:CloseAllChestContainers(...)
--        old_CloseAllChestContainers(self, ...);
--
--        if self.inst.prefab == "waxwell" or self.inst:HasTag("shadowmagic") then
--            print("close!");
--            -- 阅读的时候已经被关掉了？神奇...但是实际只是ui被隐藏了啊...
--            for k in pairs(self.opencontainers) do
--                if table.contains({
--                    "mone_backpack"
--                }, k.components.container.prefab) then
--                    print("close!!!");
--                    k.components.container:Close(self.inst)
--                end
--            end
--        end
--    end
--end)