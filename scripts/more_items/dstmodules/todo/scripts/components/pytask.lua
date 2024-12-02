local function ontasks(self, tasks)
    if self.inst.replica.pytask then
        self.inst.replica.pytask:SyncData(json.encode(tasks))
    end
end

local Task = Class(function(self, inst)
    self.inst = inst
    self.tasks = {
        --"找到海象",
        --"找到沼泽",
        --"找到猪王",
        --"找到龙蝇",
        --"找到绿洲",
        --"蜂后、龙蝇、三基佬、克劳斯、巨鹿",
        --"驼鹿鹅、犀牛、织影者、蚁狮、熊大",
        --"邪天翁、犀牛、寄居蟹、巨鹿、天体、蟾蜍",
    }
end)

function Task:OnSave()
    return {
        tasks = self.tasks
    }
end

function Task:OnLoad(data)
    if data then
        if data.tasks ~= nil then
            self.tasks = data.tasks
        end
    end
    ontasks(self, self.tasks or {})
end

function Task:GetTasks()
    -- TEST
    --for i, v in pairs(self.tasks) do
    --    print(tostring(i), "-", tostring(v));
    --end
    return self.tasks
end

function Task:Add(content)
    if self.tasks == nil then
        self.tasks = {}
    end
    table.insert(self.tasks, content)
    ontasks(self, self.tasks)
end

function Task:Del(index)
    if self.tasks == nil then
        self.tasks = {}
        return
    end
    if index < 1 then
        return
    end
    if #self.tasks >= index then
        table.remove(self.tasks, index)
        ontasks(self, self.tasks)
    end
end

function Task:DelAll()
    self.tasks = {};
    ontasks(self, self.tasks)
end

--function Task:Hide()
--
--end

return Task