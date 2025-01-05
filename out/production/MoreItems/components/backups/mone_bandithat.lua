---
--- @author zsh in 2023/1/17 21:41
---


local Bandit = Class(function(self, inst)
    self.inst = inst;
    self.items = {};
    self.equip_status = false;
end);

function Bandit:SetEquipStatus(status)
    self.equip_status = status;
    if status then
        self.inst:StartUpdatingComponent(self);
    else
        self.inst:StopUpdatingComponent(self);
    end
end

function Bandit:GetEquipStatus()
    return self.equip_status;
end

--[[ 主客机通用 ！！！非常重要的写法！！！组件刷新！2023-01-17-22:26 需要找到源代码好好阅读！ ]]
function Bandit:OnUpdate(dt)
    -- dt 好像是klei默认的时间间隔？
    -- TEMP ??? 为什么没有生效？ 202301172256 再说吧，不想 debug
    if self:GetEquipStatus() then
        local x, y, z = self.inst.Transform:GetWorldPosition();
        local DIST = 32;
        local MUST_TAGS = { "_combat", "_health" };
        local CANT_TAGS = { "INLIMBO", "player"--[[, "epic"]]};
        local ents = TheSim:FindEntities(x, y, z, DIST, MUST_TAGS, CANT_TAGS);
        local current_items = {}; -- 当前查询到的所有满足条件的预制物列表（临时变量/缓存），即当前生效的预制物列表
        local items = self.items; -- 真正生效的预制物列表
        for _, p in ipairs(ents) do
            if p and current_items[p] == nil then
                p.mone_bandit_near = true; -- 添加标签，确定该生物在佩戴着旁边
                current_items[p] = true;
                self.items[p] = true;
            end
        end
        -- 更新真正生效的预制物列表
        for p, _ in pairs(self.items) do
            -- p.components.combat:DropTarget() 用于丢失仇恨
            if p and current_items[p] == nil then
                self.items[p] = nil;
                p.mone_bandit_near = nil;
            end
        end
        -- 简单来说，就是比较上一次和当前这次，得到交集，或者说是让其差集失效！d
    end
end

return Bandit;