---
--- @author zsh in 2023/1/20 14:27
---

local addnum = 1;

local function oneatnum(self, eatnum)
    local inst = self.inst; -- player

    if inst.components.health and eatnum ~= 0 then
        inst.components.health:SetCurrentHealth(self.currenthealth);
        inst.components.health.maxhealth = self.maxhealth + eatnum * addnum;
        inst.components.health:ForceUpdateHUD(true) --force update HUD

        print("self.currenthealth:" .. tostring(self.currenthealth));
        print("self.maxhealth:" .. tostring(self.maxhealth));
        print("inst.components.health.maxhealth:" .. tostring(inst.components.health.maxhealth));

        if inst.components.talker then
            inst.components.talker:Say("当前最大生命值为： " .. inst.components.health.maxhealth)
        end
    end
end

local VB = Class(function(self, inst)
    self.inst = inst;

    self.save_currenthealth = nil;
    self.save_maxhealth = nil;

    self.eatnum = 0;
end, nil, {
    --eatnum = oneatnum; -- 这里初始化组件的时候就执行了。有点麻烦。换个写法。
});

function VB:HPIncrease()
    local inst = self.inst;
    self.eatnum = self.eatnum + 1;
    if inst.components.health then
        inst.components.health:SetCurrentHealth(inst.components.health.currenthealth);
        inst.components.health.maxhealth = inst.components.health.maxhealth + addnum;
        inst.components.health:ForceUpdateHUD(true) --force update HUD

        if inst.components.talker then
            inst.components.talker:Say("当前最大生命值为： " .. inst.components.health.maxhealth)
        end
    end
end

function VB:HPIncreaseOnLoad()
    local inst = self.inst;
    if inst.components.health and self.save_currenthealth and self.save_maxhealth then
        inst.components.health:SetCurrentHealth(self.save_currenthealth);
        inst.components.health.maxhealth = self.save_maxhealth;
        inst.components.health:ForceUpdateHUD(true) --force update HUD
    end
end

function VB:OnSave()
    return {
        eatnum = self.eatnum,
        save_currenthealth = self.save_currenthealth,
        save_maxhealth = self.save_maxhealth,
    };
end

function VB:OnLoad(data)
    if data then
        if data.eatnum and data.save_currenthealth and data.save_maxhealth then
            self.eatnum = data.eatnum;
            self.save_currenthealth = data.save_currenthealth;
            self.save_maxhealth = data.save_maxhealth;
            -- 没吃过就不会失效。
            if data.eatnum ~= 0 then
                self:HPIncreaseOnLoad();
            end
        end
    end
end

return VB;