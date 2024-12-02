---
--- Created by zsh
--- DateTime: 2023/11/26 2:02
---

require("new_scripts.mod_a.class")

local task_guid = 0
local Task = morel_Class(function(self, fn, id, param)
    self.guid = task_guid
    task_guid = task_guid + 1
    self.param = param
    self.id = id
    self.fn = fn
    self.co = coroutine.create(fn)
    self.list = nil
end)

function Task:__tostring()
    return string.format("TASK %s:", tostring(self.id))
end

function Task:set_list(list)
    if self.list then
        self.list[self.guid] = nil
    end
    if list then
        list[self.guid] = self
    end
    self.list = list
end
-----------------------------------------------------------------------------

local Periodic = morel_Class(function(self, fn, period, limit, id, next_tick, ...)
    self.fn = fn
    self.id = id
    self.period = period
    self.limit = limit
    self.next_tick = next_tick
    self.list = nil
    self.on_finish = nil
    self.args = { ... } -- 这个里面的参数是传给 on_finish 函数的
end)

function Periodic:__tostring()
    return string.format("PERIODIC %s: %f", tostring(self.id), self.period)
end

function Periodic:cancel()
    self.limit = 0
    if self.list then
        self.list[self] = nil
        self.list = nil
    end

    if self.on_finish then
        if self.args then
            self.on_finish(self, false, unpack(self.args))
        else
            self.on_finish(self, false)
        end
        self.on_finish = nil
    end

    self.fn = nil
    self.args = nil
    self.next_tick = nil
end

function Periodic:next_time()
    return self.next_tick and self:_get_time_for_tick(self.next_tick) or nil
end

function Periodic:clean_up()
    self.limit = 0

    if self.list then
        self.list[self] = nil
        self.list = nil
    end

    self.on_finish = nil

    self.fn = nil
    self.args = nil
    self.next_tick = nil
end

function Periodic:_get_time_for_tick(target_tick)
    return target_tick * os.clock()
end
-----------------------------------------------------------------------------

local List_Recycler = {}
local function get_new_list()
    local list
    local num_rec = #List_Recycler
    if num_rec > 0 then
        list = List_Recycler[num_rec]
        table.remove(List_Recycler)
    else
        list = {}
    end
    return list
end

local Scheduler = morel_Class(function(self, is_static)
    self.tasks = {}
    self.running = {}
    self.waiting_for_tick = {}
    self.waking = {}
    self.hibernating = {}
    self.at_time = {}
    self.is_static = is_static or nil
end)

function Scheduler:__tostring()
    local num_run = 0
    local num_tasks = 0
    for k, v in pairs(self.running) do
        num_run = num_run + 1
    end
    for k, v in pairs(self.tasks) do
        num_tasks = num_tasks + 1
    end
    local str = string.format("Running Tasks: %d/%d", num_run, num_tasks)
    return str
end

function Scheduler:kill_task(task)
    task:set_list(nil)
    if task.co then
        self.tasks[task.co] = nil
        task.co = nil
    end
end

function Scheduler:add_task(fn, id, param)
    local task = Task:new(fn, id, param)
    if task.co == nil then
        print("task.co is nil!")
        for k, v in pairs(task) do
            print(k, v)
        end
    end
    self.tasks[task.co] = task
    task:set_list(self.running)
    return task
end

function Scheduler:on_tick(tick)
    for k, v in pairs(self.waiting_for_tick) do
        assert(k >= tick, "NOT -> k >= tick")
    end

    if self.waiting_for_tick[tick] then
        for k, v in pairs(self.waiting_for_tick[tick]) do
            v:set_list(self.waking)
        end
        local list = self.waiting_for_tick[tick]
        table.insert(List_Recycler, list)
        self.waiting_for_tick[tick] = nil
    end

    -- do our at time callbacks!
    if self.at_time[tick] ~= nil then
        for k, v in pairs(self.at_time[tick]) do
            if v then
                local already_dead = k.limit and k.limit == 0

                if not already_dead and k.fn then
                    if k.args then
                        k.fn(unpack(k.args))
                    else
                        k.fn()
                    end
                end

                if k.limit then
                    k.limit = k.limit - 1
                end

                if not k.limit or k.limit > 0 then
                    local list, next_tick = self:GetListForTimeFromNow(k.period)
                    list[k] = true
                    k.list = list
                    k.next_tick = next_tick
                else
                    if k.on_finish and not already_dead then
                        if k.args then
                            k.on_finish(k, true, unpack(k.args))
                        else
                            k.on_finish(k, true)
                        end
                        k.on_finish = nil
                    end
                    k:clean_up()
                end
            end
        end
        self.at_time[tick] = nil
    end
end

-- ???
function Scheduler:GetListForTimeFromNow(dt)
    local nowtick = GetSchedulerTick(self.isstatic)
    local wakeuptick = math.ceil((GetSchedulerTime(self.isstatic) + dt) / GetTickTime() - 0.0001) --epsilon for floating point error when used with FRAMES
    if wakeuptick <= nowtick then
        wakeuptick = nowtick+1
    end

    local list = self.attime[wakeuptick]
    if not list then
        list = {}
        self.attime[wakeuptick] = list
    end
    return list, wakeuptick
end

-----------------------------------------------------------------------------