---
--- @author zsh in 2023/6/4 22:37
---

require "class"
local InvSlot = require "widgets/invslot"
local Widget = require "widgets/widget"
local Text = require "widgets/text"
local UIAnim = require "widgets/uianim"
local ImageButton = require "widgets/imagebutton"
local ItemTile = require "widgets/itemtile"

local function piggyback_button(params, self, container, doer,...)
    local widget = params.widget;
    if widget == nil then
        return ;
    end
    ------------

    if doer ~= nil and doer.components.playeractionpicker ~= nil then
        doer.components.playeractionpicker:RegisterContainer(container)
    end

    self.mi_piggyback_button = self:AddChild(ImageButton("images/ui.xml", "button_small.tex", "button_small_over.tex", "button_small_disabled.tex", nil, nil, { 1, 1 }, { 0, 0 }))
    self.mi_piggyback_button.image:SetScale(1.07)
    self.mi_piggyback_button.text:SetPosition(2, -2)
    self.mi_piggyback_button:SetPosition(widget.more_items_piggyback_buttoninfo.position)
    self.mi_piggyback_button:SetText(widget.more_items_piggyback_buttoninfo.text)
    if widget.more_items_piggyback_buttoninfo.fn ~= nil then
        self.mi_piggyback_button:SetOnClick(function()
            if doer ~= nil then
                if doer:HasTag("busy") then
                    return
                elseif doer.components.playercontroller ~= nil then
                    local iscontrolsenabled, ishudblocking = doer.components.playercontroller:IsEnabled()
                    if not (iscontrolsenabled or ishudblocking) then
                        return
                    end
                end
            end
            widget.more_items_piggyback_buttoninfo.fn(container, doer)
        end)
    end
    self.mi_piggyback_button:SetFont(BUTTONFONT)
    self.mi_piggyback_button:SetDisabledFont(BUTTONFONT)
    self.mi_piggyback_button:SetTextSize(33)
    self.mi_piggyback_button.text:SetVAlign(ANCHOR_MIDDLE)
    self.mi_piggyback_button.text:SetColour(0, 0, 0, 1)

    if widget.more_items_piggyback_buttoninfo.validfn ~= nil then
        if widget.more_items_piggyback_buttoninfo.validfn(container) then
            if self.mi_piggyback_button then
                self.mi_piggyback_button:Enable()
            end
        else
            if self.mi_piggyback_button then
                self.mi_piggyback_button:Disable()
            end
        end
    end

    if TheInput:ControllerAttached() then
        if self.mi_piggyback_button then
            self.mi_piggyback_button:Hide()
        end
    end

    self.mi_piggyback_button.inst:ListenForEvent("continuefrompause", function()
        if TheInput:ControllerAttached() then
            if self.mi_piggyback_button then
                self.mi_piggyback_button:Hide()
            end
        else
            if self.mi_piggyback_button then
                self.mi_piggyback_button:Show()
            end
        end
    end, TheWorld)
end

HookGeneralClass("widgets/containerwidget", function(self)
    local old_Open = self.Open;
    local old_Close = self.Close;

    if oneOfNull(2, old_Open, old_Close) then
        return ;
    end

    self.Open = function(self, container, doer, ...)
        old_Open(self, container, doer, ...);

        local widget = container.replica.container:GetWidget()
        if widget.more_items_piggyback_buttoninfo then
            piggyback_button({ widget = widget }, self, container, doer, ...);
        end

    end

    self.Close = function(self, container, doer, ...)
        if self.isopen then
            if self.mi_piggyback_button then
                self.mi_piggyback_button:Kill();
                self.mi_piggyback_button = nil;
            end
        end

        old_Close(self, ...);
    end
end)