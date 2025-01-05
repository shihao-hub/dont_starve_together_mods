---
--- @author zsh in 2023/1/22 22:51
---

-- 202301222256
-- 算了，先不写了。可以，但没必要。我又不是特别需要这个功能，我为什么要自己写一个呢？

local Screen = require "widgets/screen";

local NamePanel = Class(Screen, function(self, owner, target)
    Screen._ctor(self, "mone_NamePanel");

    self.owner = owner or ThePlayer
    self.target = target
    self.isopen = false
    self._scrnw, self._scrnh = TheSim:GetScreenSize()

    self:SetScaleMode(SCALEMODE_PROPORTIONAL)
    self:SetMaxPropUpscale(MAX_HUD_SCALE)
    self:SetPosition(0, 0, 0)
    self:SetVAnchor(ANCHOR_MIDDLE)
    self:SetHAnchor(ANCHOR_MIDDLE)

    self.scalingroot = self:AddChild(Widget("mone_namepanelwidgetscalingroot"))
    self.scalingroot:SetScale(TheFrontEnd:GetHUDScale())
    self.root = self.scalingroot:AddChild(Widget("mone_namepanelwidgetroot"))

    self.black = self.root:AddChild(Image("images/global.xml", "square.tex"))
    self.black:SetVRegPoint(ANCHOR_MIDDLE)
    self.black:SetHRegPoint(ANCHOR_MIDDLE)
    self.black:SetVAnchor(ANCHOR_MIDDLE)
    self.black:SetHAnchor(ANCHOR_MIDDLE)
    self.black:SetScaleMode(SCALEMODE_FILLSCREEN)
    self.black:SetTint(0, 0, 0, 0)
    self.black.OnMouseButton = function()
        self:OnClose()
    end

    self.nametextedit = self.root:AddChild(TEMPLATES.StandardSingleLineTextEntry(nil, 300, 80, nil, 45))
    self.confirmbutton = self.root:AddChild(TEMPLATES.StandardButton(function()
        self:Confirm()
    end, "OK", { 80, 80 }))
    self.confirmbutton:SetPosition(200, 0, 0)

    local centerx = math.floor(self._scrnw / 2 + 0.5)
    local centery = math.floor(self._scrnh / 2 + 0.5)
    TheInputProxy:SetOSCursorPos(centerx, centery)
end)

function NamePanel:Confirm()
    local str = self.nametextedit.textbox:GetString()
    if self.target then
        self.owner.HUD.NameItem(self.target, str)
    end
    self:OnClose()
end

function NamePanel:OnClose()
    self.owner.HUD:CloseNamePanel()
end

function NamePanel:Close()
    self.isopen = false
    self.black:Kill()
    self.inst:DoTaskInTime(.2, function()
        TheFrontEnd:PopScreen(self)
    end)
end

return NamePanel;