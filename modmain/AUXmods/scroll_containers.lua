---
--- @author zsh in 2023/3/23 15:28
---

-- !!!!!!
env.AddClassPostConstruct("widgets/containerwidget", function(self)
    local Widget = require "widgets/widget"
    local TEMPLATES = require "widgets/redux/templates"
    local ImageButton = require "widgets/imagebutton"

    local old_Open = self.Open;
    self.Open = function(self, container, doer)
        old_Open(self, container, doer)

        local widget = container.replica.container:GetWidget()

        -- 添加我的小按钮，在最后执行！
        if widget.buttoninfo == nil and widget.more_items_buttoninfo then
            widget.buttoninfo = widget.more_items_buttoninfo;
            if doer ~= nil and doer.components.playeractionpicker ~= nil then
                doer.components.playeractionpicker:RegisterContainer(container)
            end

            self.button = self:AddChild(ImageButton("images/ui.xml", "button_small.tex", "button_small_over.tex", "button_small_disabled.tex", nil, nil, { 1, 1 }, { 0, 0 }))
            self.button.image:SetScale(1.07 / 10 * 4, 1.07)
            self.button.text:SetPosition(0, 2)
            self.button:SetPosition(widget.buttoninfo.position)
            self.button:SetText(widget.buttoninfo.text)
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
            self.button:SetFont(BUTTONFONT)
            self.button:SetDisabledFont(BUTTONFONT)
            self.button:SetTextSize(33)
            self.button.text:SetVAlign(ANCHOR_MIDDLE)
            self.button.text:SetColour(0, 0, 0, 1)

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

            self.button.inst:ListenForEvent("continuefrompause", function()
                if TheInput:ControllerAttached() then
                    self.button:Hide()
                else
                    self.button:Show()
                end
            end, TheWorld)
        end

        -- 判断是否采用滚轮模式
        if widget.more_items_scroll then
            local num_visible_rows = widget.more_items_scroll.num_visible_rows;
            local num_columns = widget.more_items_scroll.num_columns;

            if not (num_visible_rows and num_columns) then
                print("num_visible_rows or num_columns == nil");
                return ;
            end

            local scroll_data = widget.more_items_scroll.scroll_data;

            if not (scroll_data) then
                print("scroll_data == nil");
                return ;
            end

            -- 移除之前加载的 InvSlot，并重置坐标。
            for k, v in pairs(self.inv) do
                self:RemoveChild(v);
                v:SetPosition(Vector3(0, 0, 0));
                v:Hide();
            end

            local NUM_SLOTS = 0;

            -- function TEMPLATES.ScrollingGrid(items, opts)
            self.options_scroll_list = self:AddChild(TEMPLATES.ScrollingGrid(self.inv, {
                scroll_context = {},
                widget_width = scroll_data.widget_width or 75,
                widget_height = scroll_data.widget_height or 75,
                num_visible_rows = num_visible_rows,
                num_columns = num_columns,
                item_ctor_fn = function(context, index)
                    -- item_ctor_fn
                    local scroll_option = Widget("option" .. index);
                    if self.inv[index] then
                        scroll_option:AddChild(self.inv[index]);
                        scroll_option.inv = self.inv[index];
                        scroll_option.inv:Show();
                    end
                    return scroll_option;
                end,
                apply_fn = function(context, widget_to_update, item_data, index)
                    -- update_fn
                    -- 此处 item_data 就是格子，self.inv
                    if item_data then
                        local inv = widget_to_update.inv;
                        if inv then
                            inv:ClearFocus();
                        end
                        widget_to_update:AddChild(item_data);
                        widget_to_update.inv = item_data;
                        widget_to_update.inv:Show();

                        -- 刷新函数的话，那就判断一下容器内的物品数量
                        ---- 不行。第一次没条件栈炸了，第二次还是有点问题的。但是我感觉能实现的。但是目前没必要。
                        ------ 得出个结论-前期：理论学习 65% 实践 35%，后期：理论学习 30% 实践 70%
                        --print("NUM_SLOTS: "..tostring(NUM_SLOTS));
                        --print("container.replica.container:GetNumSlots(): "..tostring(container.replica.container:GetNumSlots()));
                        --if NUM_SLOTS ~= container.replica.container:GetNumSlots() then
                        --    NUM_SLOTS = container.replica.container:GetNumSlots();
                        --    if self.options_scroll_list then -- ?????????
                        --        print("----1")
                        --        print("math.ceil(NUM_SLOTS / num_columns): "..tostring(math.ceil(NUM_SLOTS / num_columns)));
                        --        self.options_scroll_list:ScrollToScrollPos(math.ceil(NUM_SLOTS / num_columns));
                        --    end
                        --end
                    end
                end,
                scrollbar_offset = scroll_data.scrollbar_offset or 10, -- scrollbar 距离默认位置的偏移量
                scrollbar_height_offset = scroll_data.scrollbar_height_offset or -60 -- scrollbar 高度
            }))

            -- TEST: 没意义。
            --if self.options_scroll_list.scroll_bar_container then
            --    if self.options_scroll_list.scroll_bar_container.Hide then
            --        self.options_scroll_list.scroll_bar_container:Hide();
            --    end
            --end

            if scroll_data.pos then
                self.options_scroll_list:SetPosition(scroll_data.pos);
            end
            -- 解决屏幕左下角会显示格子的问题
            ---- 咋突然又解决不了了？
            --print("#widget.slotpos: " .. tostring(#widget.slotpos));
            --print("#widget.slotpos / num_columns: "..tostring(#widget.slotpos / num_columns))
            --self.options_scroll_list:ScrollToScrollPos(math.floor(#widget.slotpos / num_columns));
            --self.options_scroll_list:ResetScroll();

            -- 去掉 w s 也会滚动
            local old_OnFocusMove = self.options_scroll_list.OnFocusMove
            function self.options_scroll_list:OnFocusMove(dir, down)
                if dir == MOVE_UP or dir == MOVE_DOWN then
                    return false;
                end
                return old_OnFocusMove(self, dir, down);
            end

            -- !!! 感谢 @不笑猫 大佬
            -- 防止滚动容器的同时，相机也跟着缩放，重写 control 方法，容器滚动的同时刷新相机缩放时间，让相机以为缩放了，实际没缩放。
            if ThePlayer and ThePlayer.components and ThePlayer.components.playercontroller then
                local old_OnControl = self.options_scroll_list.OnControl;
                function self.options_scroll_list:OnControl(control, down)
                    local time = GetStaticTime();
                    local result = old_OnControl(self, control, down);
                    if down and (self.focus or FunctionOrValue(self.custom_focus_check)) and self.scroll_bar:IsVisible() then
                        if control == self.control_up then
                            ThePlayer.components.playercontroller.lastzoomtime = time
                        elseif control == self.control_down then
                            ThePlayer.components.playercontroller.lastzoomtime = time
                        end
                    end
                    return result
                end
            end

            -- 防止物品的图片超出格子显示出来以及其他内容
            self.more_items_onitemgetfn = function(inst, data)
                if self.options_scroll_list then
                    self.options_scroll_list:RefreshView()
                end
                -- ScrollToScrollPos...有点碍事。。
                ---- itemget 的时候，没有 slot 好像。
                --local slot = data and data.slot;
                --if slot then
                --    self.options_scroll_list:ScrollToScrollPos(math.floor(slot / num_columns));
                --end
            end
            --self.more_items_ongotnewitemfn = function(inst,data)
            --    if self.options_scroll_list then
            --        self.options_scroll_list:RefreshView()
            --    end
            --    -- ScrollToScrollPos
            --    local slot = data and data.slot;
            --    if slot then
            --        self.options_scroll_list:ScrollToScrollPos(math.floor(slot / num_columns));
            --    end
            --end
            -- 为什么是 self.inst, source == container ???
            self.inst:ListenForEvent("itemget", self.more_items_onitemgetfn, container);
            --self.inst:ListenForEvent("gotnewitem", self.more_items_ongotnewitemfn, container);
        end
    end

    local old_Close = self.Close;
    self.Close = function(self)
        if self.isopen then
            if self.options_scroll_list then
                self.options_scroll_list:Kill();
                self.options_scroll_list = nil;
            end

            if self.container then
                if self.more_items_onitemgetfn then
                    self.inst:RemoveEventCallback("itemget", self.more_items_onitemgetfn, self.container);
                    self.more_items_onitemgetfn = nil;
                end
            end
        end
        old_Close(self);
    end
end)