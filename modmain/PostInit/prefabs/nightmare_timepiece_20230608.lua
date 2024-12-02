---
--- @author zsh in 2023/6/8 2:52
---

-- nightmare_timepiece
-- 当时的计划是，携带该物品的玩家可以在点击制作按钮的时候强制消耗周围容器中的材料...
-- 但是实现的时候发现，太麻烦和困难了，放弃了。

do
    return;
end

require "class"
local InvSlot = require "widgets/invslot"
local Widget = require "widgets/widget"
local Text = require "widgets/text"
local UIAnim = require "widgets/uianim"
local ImageButton = require "widgets/imagebutton"
local ItemTile = require "widgets/itemtile"

local function TrueCondition(crafting_menu_hud)
    local self = crafting_menu_hud;
    local craftingmenu = self.craftingmenu;
    local crafting_hud = craftingmenu and craftingmenu.crafting_hud;
    local details_root = craftingmenu and craftingmenu.details_root;
    if craftingmenu
            and crafting_hud and crafting_hud:IsCraftingOpen()
            and details_root and details_root.data and details_root.data.recipe and details_root.data.recipe.name
    then
        return true;
    end
end

AddModRPCHandler("more_items", "nightmare_timepiece_button_fn", function(player)
    local playercontroller = player.components.playercontroller
    if playercontroller ~= nil and playercontroller:IsEnabled() and not player.sg:HasStateTag("busy") then
        if player.nightmare_timepiece_button_fn then
            player.nightmare_timepiece_button_fn(player);
        end
    end
end)

local function forced_search(doer, craftingmenu_hud)
    if doer.nightmare_timepiece_button_busy then
        return ;
    end
    doer.nightmare_timepiece_button_busy = true;

    doer.components.talker:Say("尝试强制搜索材料！");

    --local x, y, z = doer.Transform:GetWorldPosition();
    --local _ents = TheSim:FindEntities(x, y, z, 30, { "_container" }, { "FX", "NOCLICK", "DECOR", "INLIMBO" });
    --
    --local ents = _ents;

    -- 添加新按钮这里是行不通的吧？除非找到相关按钮的位置，在那里添加按钮！


    -- TEST
    local details_root = craftingmenu_hud.craftingmenu and craftingmenu_hud.craftingmenu.details_root;
    if details_root then
        local DoRecipeClickParams = { details_root.owner, details_root.data.recipe, details_root.skins_spinner:GetItem() }
        -- button.SetOnClick
        local self = details_root;
        local already_buffered = self.owner.replica.builder:IsBuildBuffered(self.data.recipe.name)

        local DoRecipeClick = function(owner, recipe, skin, ...)
            local res = {};


            res = { DoRecipeClick(owner, recipe, skin, ...) };


            return unpack(res, 1, table.maxn(res));
        end;

        local stay_open = DoRecipeClick(unpack(DoRecipeClickParams, 1, table.maxn(DoRecipeClickParams)));
        if not stay_open and (already_buffered or Profile:GetCraftingMenuBufferedBuildAutoClose()) then
            self.owner.HUD:CloseCrafting()
        end
    end

    doer.nightmare_timepiece_button_busy = nil;
end

local function OnClick(doer, craftingmenu_hud)
    if TheNet:GetIsServer() then
        print("Server!!!");
        if doer.nightmare_timepiece_button_fn == nil then
            doer.nightmare_timepiece_button_fn = OnClick;
        end
        forced_search(doer, craftingmenu_hud);
    else
        print("Client!!!")
        SendModRPCToServer(MOD_RPC["more_items"]["nightmare_timepiece_button_fn"]);
    end
end

local function InitButton(craftingmenu_hud)
    local doer = craftingmenu_hud.owner;
    local button = craftingmenu_hud.nightmare_timepiece_button;

    if null(doer) or null(button) then
        return ;
    end

    button.image:SetScale(1.07)
    button.text:SetPosition(2, -2)
    button:SetPosition(Vector3(-105, -210, 0) + Vector3(100, -88, 0))
    button:SetText("强行制作")

    button:SetOnClick(function()
        if doer ~= nil then
            if doer:HasTag("busy") then
                --Ignore button click when doer is busy
                return
            elseif doer.components.playercontroller ~= nil then
                local iscontrolsenabled, ishudblocking = doer.components.playercontroller:IsEnabled()
                if not (iscontrolsenabled or ishudblocking) then
                    --Ignore button click when controls are disabled
                    --but not just because of the HUD blocking input
                    return
                end
            end
        end
        OnClick(doer, craftingmenu_hud);
    end)

    button:SetFont(BUTTONFONT)
    button:SetDisabledFont(BUTTONFONT)
    button:SetTextSize(33)
    button.text:SetVAlign(ANCHOR_MIDDLE)
    button.text:SetColour(0, 0, 0, 1)

    button:Enable();

    if TheInput:ControllerAttached() then
        button:Hide()
    end

    button.inst:ListenForEvent("continuefrompause", function()
        if TheInput:ControllerAttached() then
            if button then
                button:Hide()
            end
        else
            if button then
                button:Show()
            end
        end
    end, TheWorld)
end

HookGeneralClass("widgets/redux/craftingmenu_hud", function(self)
    local old_OnUpdate = self.OnUpdate;

    function self:OnUpdate(...)
        if self.craftingmenu ~= nil and self.nightmare_timepiece_button == nil then
            local doer = self.owner;
            if doer and doer.HasTag and doer:HasTag("player") then
                self.nightmare_timepiece_button = self.craftingmenu:AddChild(ImageButton("images/ui.xml", "button_small.tex", "button_small_over.tex", "button_small_disabled.tex", nil, nil, { 1, 1 }, { 0, 0 }));
                InitButton(self);
            end
        end

        if self.nightmare_timepiece_button then
            if TrueCondition(self) then
                self.nightmare_timepiece_button:Show();
            else
                self.nightmare_timepiece_button:Hide();
            end
        end

        old_OnUpdate(self, ...);
    end
end)