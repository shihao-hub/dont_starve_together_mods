---
--- @author zsh in 2023/1/8 18:43
---

local config_data = TUNING.MONE_TUNING.GET_MOD_CONFIG_DATA;

-- 导入官方的不用括号，导入自己的用括号。标记一下！
local Widget = require "widgets/widget";
local Text = require 'widgets/text';

local Agency = {
    ["TextTime"] = setmetatable({
        font = NUMBERFONT, -- fonts.lua
        size = 20, -- 18 感觉小了点，24 太大了
        text = "00:00:00",
        colour = { 255, 255, 255, 1 }
    }, {
        __call = function(t)
            return t.font, t.size, t.text, t.colour
        end
    })
}

---@class CurrentDate
local CurrentDate = Class(Widget, function(self, owner)
    Widget._ctor(self, 'mone_CurrentDate'); -- 调用父类的初始化函数，super(...)

    self:SetScale(2, 2);

    self.timeText = self:AddChild(Text(Agency.TextTime()));
end);

local function getHMS()
    return os.date("%H"), os.date("%M"), os.date("%S");
end

function CurrentDate:OnUpdate()
    local h, m, s = getHMS();
    self.timeText:SetString(h .. ' : ' .. m .. ' : ' .. s);
end

env.AddClassPostConstruct('widgets/controls', function(self, owner)
    self.mone_currentdate = self:AddChild(CurrentDate(owner));

    do
        local currentdate = self.mone_currentdate;

        currentdate:SetHAnchor(0); -- x  1,0,2 代表：左中右
        currentdate:SetVAnchor(1); -- y  1,0,2 代表：上中下
        --currentdate:SetPosition(150, -200);
        currentdate:SetPosition(0, -20);

        if config_data.current_date == 1 then
            --currentdate:SetPosition(-1200, -20); -- 偏移到左上角
            currentdate:SetHAnchor(1);
            currentdate:SetVAnchor(1);
            currentdate:SetPosition(100, -50);
        end

        currentdate:Show();

        local emptyEntity = CreateEntity();
        emptyEntity:DoPeriodicTask(1, function()
            currentdate:OnUpdate();
        end);
    end

    --self.mone_currentdate_updata_task = scheduler:ExecutePeriodic(1, function(self)
    --
    --end, nil, 0, "", self);

end)