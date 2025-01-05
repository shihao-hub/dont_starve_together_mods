local Widget = require "widgets/widget"
local Text = require "widgets/text"

local Tasks = Class(Widget, function(self, owner, attach)
    Widget._ctor(self, "Tasks")
    self.owner = owner
    self.attach = attach

    self:SetScaleMode(SCALEMODE_PROPORTIONAL)
    self:SetMaxPropUpscale(MAX_HUD_SCALE)

    self.root = self:AddChild(Widget("root"))
    --self.root:SetPosition(250, -50, 0)
    self.root:SetPosition(340, -30, 0)
    self.root:SetVAnchor(ANCHOR_TOP)
    self.root:SetHAnchor(ANCHOR_LEFT)

    self.root:Show()

    -- Scheduler:ExecutePeriodic(period, fn, limit, initialdelay, id, ...)
    self.updatetask = scheduler:ExecutePeriodic(1, self.UpdateItems, nil, 0, "updateitems", self)

end)

function Tasks:UpdateItems()
    if not (TheWorld and TheWorld.net) then
        return;
    end

    local tasks = TheWorld.net.replica.pytask and TheWorld.net.replica.pytask:GetTasks() or {}

    -- TEST
     --tasks = {
     --    --"找到海象",
     --    --"找到沼泽",
     --    --"找到猪王",
     --    --"找到峰后",
     --    --"找到曼德拉",
     --    --"找到龙蝇沙漠",
     --    --"找到绿洲沙漠",
     --    --"找到马赛克混合地区",
     --
     --    "找到海象",
     --    "找到沼泽",
     --    "找到猪王",
     --    "找到龙蝇",
     --    "找到绿洲",
     --}

    self.root:KillAllChildren()
    if #tasks > 0 then
        for i, v in pairs(tasks) do
            --self["item" .. i] = self.root:AddChild(Text(NUMBERFONT, 36, tostring(i) .. ". " .. v, { 252, 30, 30, 1 }))
            --self["item" .. i] = self.root:AddChild(Text(NUMBERFONT, 36, tostring(i) .. ". " .. v))
            self["item" .. i] = self.root:AddChild(Text(NUMBERFONT, 32, tostring(i) .. ". " .. v))
            self["item" .. i]:SetPosition(0, -30 * (i - 1))
            self["item" .. i]:SetRegionSize(350, 30)
            self["item" .. i]:SetHAlign(ANCHOR_LEFT)
        end
    end
end

return Tasks