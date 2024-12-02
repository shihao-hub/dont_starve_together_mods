---
--- Created by zsh
--- DateTime: 2023/12/10 15:50
---


--local ImageButton = require "widgets/imagebutton"
--local Text = require "widgets/text"
--local Grid = require "widgets/grid"
--local Spinner = require "widgets/spinner"
--local TEMPLATES = require "widgets/redux/templates"

local Image = require "widgets/image"
local Widget = require "widgets/widget"

local BookPage = require "widgets/redux/more_instruction_book_page"

local cooking = require("cooking")

require("util")

local BookWidget = Class(Widget, function(self, parent)
    Widget._ctor(self, "MoreItemsBookWidget")

    self.root = self:AddChild(Widget("root"))

    local backdrop = self.root:AddChild(Image("images/quagmire_recipebook.xml", "quagmire_recipe_menu_bg.tex"))
    backdrop:ScaleToSize(900, 550)

    local base_size = .7

    self.panel = self.root:AddChild(BookPage(parent, "cookpot"))
end)

function BookWidget:OnControl(control, down)
    if BookWidget._base.OnControl(self, control, down) then return true end
end

function BookWidget:GetHelpText()
    local controller_id = TheInput:GetControllerID()
    local t = {}

    table.insert(t, TheInput:GetLocalizedControl(controller_id, CONTROL_OPEN_CRAFTING) .. "/" .. TheInput:GetLocalizedControl(controller_id, CONTROL_OPEN_INVENTORY) .. " " .. STRINGS.UI.HELP.CHANGE_TAB)

    return table.concat(t, " ")
end

return BookWidget
