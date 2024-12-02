---
--- @author zsh in 2023/3/27 21:31
---

local Widget = require "widgets/widget"
local Image = require "widgets/image"

local offset_x, offset_y = 0, -70;

local Tooltip = Class(Widget, function(self, owner)
    self.owner = owner
    Widget._ctor(self, "More Items Tooltip");

    --self.icon1 = self:AddChild(Image("images/inventoryimages1.xml", "bernie_cat.tex"))
    self.icon1 = self:AddChild(Image("images/hud2.xml", "tab_balloonomancy.tex"))

    self.icon1:SetPosition(300 + offset_x, 300 + offset_y, 0)
    self.icon1:SetScaleMode(0.01)
    self.icon1:SetScale(.9, .9, .9)

    --self.icon2 = self:AddChild(Image("images/inventoryimages1.xml", "bernie_cat.tex"))
    --
    --self.icon2:SetPosition(300 + offset_x, 300 + offset_y, 0)
    --self.icon2:SetScaleMode(0.01)
    --self.icon2:SetScale(.9, .9, .9)
    --
    --self.icon3 = self:AddChild(Image("images/inventoryimages1.xml", "bernie_cat.tex"))
    --
    --self.icon3:SetPosition(300 + offset_x, 300 + offset_y, 0)
    --self.icon3:SetScaleMode(0.01)
    --self.icon3:SetScale(.9, .9, .9)

    self:Hide()
    self:RefreshTooltips()
    self.item_tip = nil
    self.skins_spinner = nil
end)

function Tooltip:ShowTip()
    self:RefreshTooltips()
    self:Show()
end

function Tooltip:HideTip()
    self:RefreshTooltips()
    self:Hide()
end

function Tooltip:RefreshTooltips()
    if self.skins_spinner ~= nil then
        self.icon1:SetPosition(300 + offset_x, 300 + offset_y, 0)
        --self.icon2:SetPosition(300 + offset_x, 300 + offset_y, 0)
    else
        self.icon1:SetPosition(300 + offset_x, 245 + offset_y, 0)
        --self.icon2:SetPosition(300 + offset_x, 245 + offset_y, 0)
    end


    local more_items_tip = self.item_tip and STRINGS.MONE_STRINGS[self.item_tip:upper()]
            and STRINGS.MONE_STRINGS[self.item_tip:upper()] .. "\n" or "";

    local tooltip = more_items_tip;

    if self.item_tip ~= nil and false then
        self.icon3:SetTooltip(tooltip)

        self.icon3:Show()

        self.icon2:Hide()
        self.icon1:Hide()
    elseif self.item_tip ~= nil and false then
        self.icon2:SetTooltip(tooltip)

        self.icon2:Show()

        self.icon1:Hide()
        self.icon3:Hide()
    elseif self.item_tip ~= nil and more_items_tip ~= "" then
        self.icon1:SetTooltip(tooltip)
        self.icon1:Show()

        --self.icon2:Hide()
        --self.icon3:Hide()
    else
        self.icon1:Hide()
        --self.icon2:Hide()
        --self.icon3:Hide()
    end
end

return Tooltip;