---
--- Created by zsh
--- DateTime: 2023/12/10 15:49
---


--local MapWidget = require("widgets/mapwidget")
--local TEMPLATES = require "widgets/redux/templates"


local Screen = require "widgets/screen"
local Widget = require "widgets/widget"
local ImageButton = require "widgets/imagebutton"
local BookWidget = require "widgets/redux/more_instruction_book_widget"

local PopupScreen = Class(Screen, function(self, owner)
    self.owner = owner
    Screen._ctor(self, "MoreItemsPopupScreen")

    local black = self:AddChild(ImageButton("images/global.xml", "square.tex"))
    black.image:SetVRegPoint(ANCHOR_MIDDLE)
    black.image:SetHRegPoint(ANCHOR_MIDDLE)
    black.image:SetVAnchor(ANCHOR_MIDDLE)
    black.image:SetHAnchor(ANCHOR_MIDDLE)
    black.image:SetScaleMode(SCALEMODE_FILLSCREEN)
    black.image:SetTint(0, 0, 0, .5)
    black:SetOnClick(function() TheFrontEnd:PopScreen() end)
    black:SetHelpTextMessage("")

    local root = self:AddChild(Widget("root"))
    root:SetScaleMode(SCALEMODE_PROPORTIONAL)
    root:SetHAnchor(ANCHOR_MIDDLE)
    root:SetVAnchor(ANCHOR_MIDDLE)
    root:SetPosition(0, -25)

    self.book = root:AddChild(BookWidget(owner))

    self.default_focus = self.book

    SetAutopaused(true)
end)

function PopupScreen:OnDestroy()
    SetAutopaused(false)

    POPUPS.MORE_ITEMS_INSTRUCTION_BOOK:Close(self.owner)

    PopupScreen._base.OnDestroy(self)
end

function PopupScreen:OnBecomeInactive()
    PopupScreen._base.OnBecomeInactive(self)
end

function PopupScreen:OnBecomeActive()
    PopupScreen._base.OnBecomeActive(self)
end

function PopupScreen:OnControl(control, down)
    if PopupScreen._base.OnControl(self, control, down) then return true end

    if not down and (control == CONTROL_MAP or control == CONTROL_CANCEL) then
        TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_move")
        TheFrontEnd:PopScreen()
        return true
    end

    return false
end

function PopupScreen:GetHelpText()
    local controller_id = TheInput:GetControllerID()
    local t = {}

    table.insert(t, TheInput:GetLocalizedControl(controller_id, CONTROL_CANCEL) .. " " .. STRINGS.UI.HELP.BACK)

    return table.concat(t, " ")
end

return PopupScreen
