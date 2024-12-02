
local function ondatadirty(self)
    local _tasks = self._tasks:value()
    if _tasks == nil then
        return
    end
    self.tasks = json.decode(_tasks)
end

local Task = Class(function(self, inst)
    self.inst = inst
    self._tasks = net_string(inst.GUID, "tasks.data", "ondatadirty")

    inst:ListenForEvent("ondatadirty", function() ondatadirty(self) end)
end)

function Task:SyncData(data)
    if data == nil then
        return
    end
    self._tasks:set(data)
end

function Task:GetTasks()
    if self.inst.components.pytask then
        return self.inst.components.pytask:GetTasks()
    else
        return self.tasks
    end
end

return Task