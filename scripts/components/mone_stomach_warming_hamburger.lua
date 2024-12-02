---
--- @author zsh in 2023/3/2 10:24
---

local addnum = 1;

local SWH = Class(function(self, inst)
    self.inst = inst;

    self.save_currenthunger = nil;
    self.save_maxhunger = nil;

    self.eatnum = 0;
end)

function SWH:ForceUpdateHUD(overtime)
    self.inst.components.hunger:DoDelta(0, overtime, true);
end

function SWH:VitIncrease()
    local inst = self.inst;
    self.eatnum = self.eatnum + 1;
    if inst.components.hunger then
        inst.components.hunger.current = inst.components.hunger.current;
        inst.components.hunger.max = inst.components.hunger.max + addnum;
        -- 没有这个函数，但是 DoDelta 之后就可以刷新了。(health里面是这样的)
        --inst.components.hunger:ForceUpdateHUD(true) --force update HUD
        self:ForceUpdateHUD(true);

        if inst.components.talker then
            inst.components.talker:Say("当前最大饥饿度为： " .. inst.components.hunger.max)
        end
    end
end

function SWH:VitIncreaseOnLoad()
    local inst = self.inst;
    if inst.components.hunger and self.save_currenthunger and self.save_maxhunger then
        inst.components.hunger.current = self.save_currenthunger;
        inst.components.hunger.max = self.save_maxhunger;
        self:ForceUpdateHUD(true);
    end
end

function SWH:OnSave()
    return {
        eatnum = self.eatnum,
        save_currenthunger = self.save_currenthunger,
        save_maxhunger = self.save_maxhunger,
    };
end

function SWH:OnLoad(data)
    if data then
        if data.eatnum and data.save_currenthunger and data.save_maxhunger then
            self.eatnum = data.eatnum;
            self.save_currenthunger = data.save_currenthunger;
            self.save_maxhunger = data.save_maxhunger;
            -- 没吃过就不会失效。
            if data.eatnum ~= 0 then
                self:VitIncreaseOnLoad();
            end
        end
    end
end

return SWH;