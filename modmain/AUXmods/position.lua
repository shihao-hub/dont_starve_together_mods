---
--- @author zsh in 2023/2/14 11:41
---

local Widget = require "widgets/widget"
local Text = require "widgets/text"

-- 鼠标显示坐标。按道理本地模组就行了。
env.AddClassPostConstruct('screens/playerhud', function(self)
    -- chang: 安全模式下执行
    local state, msg = pcall(function(self)
        self.panel = self.root:AddChild(Widget("panel"))
        -- 设定锚定
        self.panel:SetHAnchor(1) -- x  1,0,2 代表：左中右
        self.panel:SetVAnchor(1)  -- y  1,0,2 代表：上中下

        self.pos = self.panel:AddChild(Text(NUMBERFONT, 20))

        -- 基于锚点的定位
        self.pos:SetPosition(20 + 20, -20, 0); -- 右+ 上+

        local onUpdate = self.OnUpdate
        self.OnUpdate = function(this, dt)
            local pos = TheInput:GetScreenPosition()
            -- 显示鼠标位置
            self.pos:SetString(string.format("%s,%s", pos.x, pos.y))
            onUpdate(this, dt)
        end
    end, self);
    if not state then
        print("ChangError: " .. tostring(msg));
    end
end)
