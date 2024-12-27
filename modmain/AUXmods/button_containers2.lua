---
--- @author zsh in 2023/3/30 12:53
---

require "class"
local InvSlot = require "widgets/invslot"
local Widget = require "widgets/widget"
local Text = require "widgets/text"
local UIAnim = require "widgets/uianim"
local ImageButton = require "widgets/imagebutton"
local ItemTile = require "widgets/itemtile"

local function modify_button(self, container, doer)
    local widget = container.replica.container:GetWidget();

    local image_scale = { x = widget.buttoninfo.image_scale_x or 1.07 / 10 * 4, y = widget.buttoninfo.image_scale_y or 1.07 };
    local text_position = widget.buttoninfo.text_position or Vector3(0, 3, 0);

    self.button.image:SetScale(image_scale.x, image_scale.y);
    self.button.text:SetPosition(text_position);
    self.button:SetPosition(widget.buttoninfo.position);
    self.button:SetText(widget.buttoninfo.text);

    if table.contains({
        "backpack", "spicepack", "krampus_sack", "piggyback", "seedpouch", "icepack",
        "mone_seasack", "mone_seedpouch", "mone_nightspace_cape",

        "mone_tool_bag",
        "mone_backpack", "mone_candybag", "mone_icepack",
        "mone_wathgrithr_box", "mone_wanda_box",

        "mone_skull_chest",
    }, container.prefab) then
        self.button:SetTooltip("一键整理");
    end

    self.button:SetFont(BUTTONFONT)
    self.button:SetDisabledFont(BUTTONFONT)
    self.button:SetTextSize(33)
    self.button.text:SetVAlign(ANCHOR_MIDDLE)
    self.button.text:SetColour(0, 0, 0, 1)
end

---注意，背包融合模式的时候，按钮没了，这个有机会可以处理一下。
local function backpack_arrange_button(self, container, doer, widget)
    if self.button and self.button.inst then
        local listener_fns = TheWorld
                and TheWorld.event_listeners
                and TheWorld.event_listeners["continuefrompause"]
                and TheWorld.event_listeners["continuefrompause"][self.button.inst];
        if listener_fns then
            table.insert(listener_fns, 1, function()
                if self.button then
                    print("Button exists！");
                    return ;
                else
                    print("Button no longer exists！");
                    -- 如果 button 不存在，则添加一个
                    if widget.buttoninfo ~= nil then
                        if doer ~= nil and doer.components.playeractionpicker ~= nil then
                            doer.components.playeractionpicker:RegisterContainer(container)
                        end

                        self.button = self:AddChild(ImageButton("images/ui.xml", "button_small.tex", "button_small_over.tex", "button_small_disabled.tex", nil, nil, { 1, 1 }, { 0, 0 }))

                        modify_button(self, container, doer);

                        if widget.buttoninfo.fn ~= nil then
                            self.button:SetOnClick(function()
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
                                widget.buttoninfo.fn(container, doer)
                            end)
                        end

                        if widget.buttoninfo.validfn ~= nil then
                            if widget.buttoninfo.validfn(container) then
                                self.button:Enable()
                            else
                                self.button:Disable()
                            end
                        end

                        if TheInput:ControllerAttached() then
                            self.button:Hide()
                        end

                        --self.button.inst:ListenForEvent("continuefrompause", function()
                        --    if TheInput:ControllerAttached() then
                        --        if self.button then
                        --            self.button:Hide()
                        --        end
                        --    else
                        --        if self.button then
                        --            self.button:Show()
                        --        end
                        --    end
                        --end, TheWorld)
                    end
                end
            end);
        end
    end
end

local function wardrobe_button(self, container, doer, widget)
    if doer ~= nil and doer.components.playeractionpicker ~= nil then
        doer.components.playeractionpicker:RegisterContainer(container)
    end

    self.mi_wardrobe_button = self:AddChild(ImageButton("images/ui.xml", "button_small.tex", "button_small_over.tex", "button_small_disabled.tex", nil, nil, { 1, 1 }, { 0, 0 }))
    self.mi_wardrobe_button.image:SetScale(1.07)
    self.mi_wardrobe_button.text:SetPosition(2, -2)
    self.mi_wardrobe_button:SetPosition(widget.more_items_wardrobe_buttoninfo.position)
    self.mi_wardrobe_button:SetText(widget.more_items_wardrobe_buttoninfo.text)
    if widget.more_items_wardrobe_buttoninfo.fn ~= nil then
        self.mi_wardrobe_button:SetOnClick(function()
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
            widget.more_items_wardrobe_buttoninfo.fn(container, doer)
        end)
    end
    self.mi_wardrobe_button:SetFont(BUTTONFONT)
    self.mi_wardrobe_button:SetDisabledFont(BUTTONFONT)
    self.mi_wardrobe_button:SetTextSize(33)
    self.mi_wardrobe_button.text:SetVAlign(ANCHOR_MIDDLE)
    self.mi_wardrobe_button.text:SetColour(0, 0, 0, 1)

    if widget.more_items_wardrobe_buttoninfo.validfn ~= nil then
        if widget.more_items_wardrobe_buttoninfo.validfn(container) then
            if self.mi_wardrobe_button then
                self.mi_wardrobe_button:Enable()
            end
        else
            if self.mi_wardrobe_button then
                self.mi_wardrobe_button:Disable()
            end
        end
    end

    if TheInput:ControllerAttached() then
        if self.mi_wardrobe_button then
            self.mi_wardrobe_button:Hide()
        end
    end

    self.mi_wardrobe_button.inst:ListenForEvent("continuefrompause", function()
        if TheInput:ControllerAttached() then
            if self.mi_wardrobe_button then
                self.mi_wardrobe_button:Hide()
            end
        else
            if self.mi_wardrobe_button then
                self.mi_wardrobe_button:Show()
            end
        end
    end, TheWorld)
end

local function storage_button(self, container, doer, widget)
    if doer ~= nil and doer.components.playeractionpicker ~= nil then
        doer.components.playeractionpicker:RegisterContainer(container)
    end

    self.mi_storage_button = self:AddChild(ImageButton("images/ui.xml", "button_small.tex", "button_small_over.tex", "button_small_disabled.tex", nil, nil, { 1, 1 }, { 0, 0 }))
    self.mi_storage_button.image:SetScale(1.07)
    self.mi_storage_button.text:SetPosition(2, -2)
    self.mi_storage_button:SetPosition(widget.more_items_storage_buttoninfo.position)
    self.mi_storage_button:SetText(widget.more_items_storage_buttoninfo.text)

    -- 描述文本
    self.mi_storage_button:SetTooltip([[
    假如当前容器可以保鲜，则会尝试捡起地上有新鲜度的物品
    将半径7.5格地皮上的该容器内的部分同名物品收纳进来
    将半径7.5格地皮内的其他同名容器中的同名物品收纳进来
    ]]);

    if container.prefab == "mone_skull_chest" then
        self.mi_storage_button:SetTooltip([[
        将半径7.5格地皮上大部分可以放入本容器的物品收纳进来！
        将半径7.5格地皮内部分容器内可以放入本容器的物品收纳进来！
        ]]);
    end

    if widget.more_items_storage_buttoninfo.fn ~= nil then
        self.mi_storage_button:SetOnClick(function()
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
            widget.more_items_storage_buttoninfo.fn(container, doer)
        end)
    end
    self.mi_storage_button:SetFont(BUTTONFONT)
    self.mi_storage_button:SetDisabledFont(BUTTONFONT)
    self.mi_storage_button:SetTextSize(33)
    self.mi_storage_button.text:SetVAlign(ANCHOR_MIDDLE)
    self.mi_storage_button.text:SetColour(0, 0, 0, 1)

    if widget.more_items_storage_buttoninfo.validfn ~= nil then
        if widget.more_items_storage_buttoninfo.validfn(container) then
            if self.mi_storage_button then
                self.mi_storage_button:Enable()
            end
        else
            if self.mi_storage_button then
                self.mi_storage_button:Disable()
            end
        end
    end

    if TheInput:ControllerAttached() then
        if self.mi_storage_button then
            self.mi_storage_button:Hide()
        end
    end

    self.mi_storage_button.inst:ListenForEvent("continuefrompause", function()
        if TheInput:ControllerAttached() then
            if self.mi_storage_button then
                self.mi_storage_button:Hide()
            end
        else
            if self.mi_storage_button then
                self.mi_storage_button:Show()
            end
        end
    end, TheWorld)
end

local function candybag_button(self, container, doer, widget)
    do
        return ; -- 暂未去实现
    end

    if doer ~= nil and doer.components.playeractionpicker ~= nil then
        doer.components.playeractionpicker:RegisterContainer(container)
    end

    self.mi_candybag_button = self:AddChild(ImageButton("images/ui.xml", "button_small.tex", "button_small_over.tex", "button_small_disabled.tex", nil, nil, { 1, 1 }, { 0, 0 }))
    self.mi_candybag_button.image:SetScale(1.07)
    self.mi_candybag_button.text:SetPosition(Vector3(0, 1, 0))
    self.mi_candybag_button:SetPosition(Vector3(0, -107, 0))
    self.mi_candybag_button:SetText("󰀘")

    self.mi_candybag_button:SetOnClick(function()
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

        -- 除了这个按钮，全部隐藏
        local function fn(inst, doer)
            if inst.mi_candybag_button_hide then
                inst.mi_candybag_button_hide = nil;
            else
                inst.mi_candybag_button_hide = true;
            end
            if inst.components.container ~= nil then
                local slots = inst.components.slots;


            elseif inst.replica.container ~= nil and not inst.replica.container:IsBusy() then
                SendRPCToServer(RPC.DoWidgetButtonAction, nil, inst, nil)
            end
        end

        fn(container, doer);
    end)

    self.mi_candybag_button:SetFont(BUTTONFONT)
    self.mi_candybag_button:SetDisabledFont(BUTTONFONT)
    self.mi_candybag_button:SetTextSize(33)
    self.mi_candybag_button.text:SetVAlign(ANCHOR_MIDDLE)
    self.mi_candybag_button.text:SetColour(0, 0, 0, 1)

    if self.mi_candybag_button then
        self.mi_candybag_button:Enable()
    end

    if TheInput:ControllerAttached() then
        if self.mi_candybag_button then
            self.mi_candybag_button:Hide()
        end
    end

    self.mi_candybag_button.inst:ListenForEvent("continuefrompause", function()
        if TheInput:ControllerAttached() then
            if self.mi_candybag_button then
                self.mi_candybag_button:Hide()
            end
        else
            if self.mi_candybag_button then
                self.mi_candybag_button:Show()
            end
        end
    end, TheWorld)
end

if TUNING.MONE_TUNING.NEW_BUTTON_NEW --[[注意，必定为 true，false域是留作备份的而已]] then
    env.AddClassPostConstruct("widgets/containerwidget", function(self)
        local old_Open = self.Open;
        self.Open = function(self, container, doer,...)
            local widget = container.replica.container:GetWidget()

            old_Open(self, container, doer,...)

            -- 有点瑕疵的自定义按钮，注意 TUNING.MONE_TUNING.NEW_BUTTON_NEW 必定为 true！！！
            if widget.more_items_buttoninfo then
                -- 修改小按钮的内容
                if widget.buttoninfo then
                    modify_button(self, container, doer);
                end

                if widget.more_items_backpack_arrange_button_tag then
                    backpack_arrange_button(self, container, doer, widget);
                end
            end

            -- 添加一键收纳按钮
            if widget.more_items_storage_buttoninfo then
                storage_button(self, container, doer, widget);
            end

            -- 按钮上方浮现提示文本
            if self.button and widget.buttoninfo and widget.buttoninfo.more_items_button_help_text then
                self.button:SetTooltip(widget.buttoninfo.more_items_button_help_text);
            end

            -- 材料袋添加新按钮
            if container and container.inst and container.inst.prefab == "mone_candybag" then
                candybag_button(self, container, doer, widget)
            end

            -- 装备柜添加换装按钮
            if widget.more_items_wardrobe_buttoninfo then
                wardrobe_button(self, container, doer, widget);
            end
        end

        local old_Close = self.Close;
        self.Close = function(self,...)
            if self.isopen then
                if self.mi_wardrobe_button then
                    self.mi_wardrobe_button:Kill();
                    self.mi_wardrobe_button = nil;
                end
                if self.mi_storage_button then
                    self.mi_storage_button:Kill();
                    self.mi_storage_button = nil;
                end
                if self.mi_candybag_button then
                    self.mi_candybag_button:Kill();
                    self.mi_candybag_button = nil;
                end
            end

            old_Close(self,...);
        end
    end)
end