---
--- @author zsh in 2023/1/26 19:32
---

--[[ 小型简单备忘录 ]]


do
    -- 需要修改！！！
    return;
end

-- !!!
require("definitions.mone.debugcommands");

--- !!!
AddReplicableComponent("pytask");

AddClassPostConstruct("screens/consolescreen", function(self)
    if self.console_edit then
        local commands = { "taskadd", "taskdel", "taskclear","taskhide","taskshow" }
        local dictionary = self.console_edit.prediction_widget.word_predictor.dictionaries[3]
        for k, word in pairs(commands) do
            table.insert(dictionary.words, word)
        end
    end
end)

-- !!!
local Tasks = require("more_items.dstmodules.todo.scripts.widgets.pytasks")

local task_widget;
AddClassPostConstruct("screens/playerhud", function(self, owner)
    self.task_widget = self:AddChild(Tasks(owner))
    task_widget = self.task_widget;
    -- local old_CreateOverlays = self.CreateOverlays
    -- function self:CreateOverlays(owner)
    --     old_CreateOverlays(self, owner)

    --     self.task_widget = self.overlayroot:AddChild(Tasks(owner))
    -- end
end)

-- !!!
AddModRPCHandler("py_task", "add", function(player, content)
    if TheWorld.net.components.pytask then
        TheWorld.net.components.pytask:Add(content)
    end
end)

AddModRPCHandler("py_task", "del", function(player, index)
    if TheWorld.net.components.pytask then
        TheWorld.net.components.pytask:Del(index)
    end
end)

AddModRPCHandler("py_task", "delall", function(player, index)
    if TheWorld.net.components.pytask then
        TheWorld.net.components.pytask:DelAll()
    end
end)

AddModRPCHandler("py_task", "hide", function(player, index)
    if task_widget then
        task_widget:Hide();
    end
end)

AddModRPCHandler("py_task", "show", function(player, index)
    if task_widget then
        task_widget:Show();
    end
end)

-- !!!
local worldnetwork = { "forest_network", "cave_network" }
for k, v in pairs(worldnetwork) do
    AddPrefabPostInit(v, function(inst)
        if not TheWorld.ismastersim then
            return inst
        end
        if not inst.components.pytask then
            inst:AddComponent("pytask")
        end
    end)
end