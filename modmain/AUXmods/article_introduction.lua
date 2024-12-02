---
--- @author zsh in 2023/3/30 12:57
---

env.AddClassPostConstruct("widgets/controls", function(self, inst)
    local owner = self.owner;
    if owner == nil then
        return ;
    end

    local more_items_tooltip = require("widgets.more_items_tooltip");
    self.more_items_tooltip = self:AddChild(more_items_tooltip(owner));
    self.more_items_tooltip:MoveToBack();
end)

local MoreItemsTooltip = require("widgets.more_items_tooltip");
env.AddClassPostConstruct("widgets/craftslot", function(self)
    local old_ShowRecipe = self.ShowRecipe;
    local old_OnControl = self.OnControl;
    local old_HideRecipe = self.HideRecipe;

    function self:ShowRecipe(...)
        if self.more_items_tooltip ~= nil then
            self.more_items_tooltip.item_tip = nil
            self.more_items_tooltip.skins_spinner = nil
            self.more_items_tooltip:HideTip()
        end

        self.more_items_tooltip = self:AddChild(MoreItemsTooltip())

        if self.more_items_tooltip ~= nil
                and self.recipe ~= nil
                and self.recipepopup ~= nil
                and self.recipe.name
                and (STRINGS.MONE_STRINGS[string.upper(self.recipe.name)] ~= nil)
        then
            self.more_items_tooltip.item_tip = self.recipe.name
            self.more_items_tooltip.skins_spinner = self.recipepopup.skins_spinner or nil
            self.more_items_tooltip:ShowTip()
        end

        old_ShowRecipe(self, ...)
    end

    function self:OnControl(...)
        if self.more_items_tooltip ~= nil then
            self.more_items_tooltip.item_tip = nil
            self.more_items_tooltip.skins_spinner = nil
            self.more_items_tooltip:HideTip()
        end

        self.more_items_tooltip = self:AddChild(MoreItemsTooltip())

        if self.more_items_tooltip ~= nil
                and self.recipe ~= nil
                and self.recipepopup ~= nil
                and self.recipe.name
                and (STRINGS.MONE_STRINGS[string.upper(self.recipe.name)] ~= nil)
        then
            self.more_items_tooltip.item_tip = self.recipe.name
            self.more_items_tooltip.skins_spinner = self.recipepopup.skins_spinner or nil
            self.more_items_tooltip:ShowTip()
        end

        old_OnControl(self, ...)
    end

    function self:HideRecipe(...)
        if self.more_items_tooltip ~= nil then
            self.more_items_tooltip.item_tip = nil
            self.more_items_tooltip.skins_spinner = nil
            self.more_items_tooltip:HideTip()
        end

        old_HideRecipe(self, ...)
    end
end)

env.AddClassPostConstruct("widgets/redux/craftingmenu_hud", function(self)
    local old_OnUpdate = self.OnUpdate;

    function self:OnUpdate(...)
        if self.craftingmenu ~= nil and self.more_items_tooltip == nil then
            self.more_items_tooltip = self.craftingmenu:AddChild(MoreItemsTooltip())
            self.more_items_tooltip:SetPosition(-105, -210)
            self.more_items_tooltip:SetScale(0.35)
        end

        if self.craftingmenu ~= nil
                and self.craftingmenu.crafting_hud ~= nil
                and self.craftingmenu.crafting_hud:IsCraftingOpen()
                and self.more_items_tooltip ~= nil
                and self.craftingmenu.details_root ~= nil
                and self.craftingmenu.details_root.data
                and self.craftingmenu.details_root.data.recipe ~= nil
                and self.craftingmenu.details_root.data.recipe.name
                and (STRINGS.MONE_STRINGS[string.upper(self.craftingmenu.details_root.data.recipe.name)] ~= nil)
        then
            self.more_items_tooltip.item_tip = self.craftingmenu.details_root.data.recipe.name
            self.more_items_tooltip.skins_spinner = self.craftingmenu.details_root.skins_spinner or nil
            self.more_items_tooltip:ShowTip()
        elseif self.more_items_tooltip ~= nil then
            self.more_items_tooltip.item_tip = nil
            self.more_items_tooltip.skins_spinner = nil
            self.more_items_tooltip:HideTip()
        end

        old_OnUpdate(self, ...)
    end
end)