---
--- DateTime: 2025/1/8 9:58
---

local inspect = require("moreitems.lib.thirdparty.inspect.inspect")
local luafun = require("moreitems.lib.thirdparty.luafun.fun")

local base = require("moreitems.lib.shihao.base")

-- Question: 这算什么设计模式 or 重构思想？组合替代继承？facade?
local function _log()
    local module = {}
    local static = { flush_switch = false }

    function module.enable_flush()
        static.flush_switch = true
    end

    function module.disable_flush()
        static.flush_switch = false
    end

    local function _flush()
        if static.flush_switch then
            base.log.flush()
        end
    end

    function module.debug(...)
        base.log.debug(...)
        _flush()
    end

    function module.info(...)
        base.log.info(...)
        _flush()
    end

    function module.warning(...)
        base.log.warning(...)
        _flush()
    end

    function module.error(...)
        base.log.error(...)
        _flush()
    end

    return module
end
local log = _log()

------------------------------------------------------------------------------------------------------------------------
local module = {}

--[[
    NOTE:
        生成器，不需要 coroutine，因为闭包就可以实现生成器，不再是迭代器了。
        提到闭包实现生成器，Java 的对象也可以实现生成器，闭包不过是共享变量直接属于函数罢了，Java 对象实例的属性也是共享变量呀！
]]
---生成器
function module.range(start, stop, step)
    -- 默认步长为 1
    step = step or 1
    if start ~= nil and stop == nil then
        stop = start
        start = 1
    end
    -- 当前值，初始化为 start
    local current = start
    -- 返回迭代器函数
    return function()
        -- 如果 step > 0 且 current <= stop，或者 step < 0 且 current >= stop
        if (step > 0 and current <= stop) or (step < 0 and current >= stop) then
            local value = current
            current = current + step -- 更新当前值
            return value
        end
    end
end

--function module.range(start, stop, step)
--    if start ~= nil and stop == nil and step == nil then
--        stop = start
--        start = 1
--        step = 1
--    end
--    return function()
--        if start > stop then
--            return nil
--        end
--        return start + step
--    end
--end












------------------------------------------------------------------------------------------------------------------------

local function test_a()
    local tasks = {}

    -- 注意，这个切换可以理解为，两个函数调用可以互相切换

    local task1 = coroutine.create(function()
        print("Task 1: Start")

        -- 切换到 task2
        print("Task 1: ", coroutine.resume(tasks[2]))

        print("Task 1: Resume")

        -- 再次切换到 task2
        print("Task 1: ", coroutine.resume(tasks[2]))

        print("Task 1: End")
    end)
    table.insert(tasks, task1)

    local task2 = coroutine.create(function()
        print("Task 2: Start")

        -- 切换到 task1
        print("Task 2: ", coroutine.resume(tasks[1]))

        print("Task 2: Resume")

        -- 再次切换到 task1
        print("Task 2: ", coroutine.resume(tasks[1]))

        print("Task 2: End")
    end)
    table.insert(tasks, task2)

    coroutine.resume(task1)
end

local function test_scheduler()
    local inspect = require("moreitems.lib.thirdparty.inspect.inspect")

    ---@return Task
    local function Task(task)
        ---@class Task
        local this = {}

        -- 疑问，class() 返回值是什么？table 是吧，那 Task 算什么呢？是函数不是类啊？那 js 的构造函数算什么呢？
        -- class() 返回值虽然是 table，但是它的元表有 __call 元函数...
        -- 好吧，得思考一下，class() 返回的 table 和当前的 Task 函数直接的区别和联系
        -- Task() <==> new Task() 啊，每次都是 instance...

        this._task = task
        this.dead = false -- 不要用 is deleted 命名

        function this:resume()
            return coroutine.resume(self._task)
        end

        return this
    end

    ---@param tasks Task[]
    local function scheduler(tasks)
        ---@param array table[]
        ---@param indexs number[]
        ---@return table[]
        local function delete_array_indexs(array, indexs)
            table.sort(indexs, function(o1, o2) return o2 - o1 end)
            -- 倒序删除
            for _, index in ipairs(indexs) do
                table.remove(array, index)
            end
            return array
        end

        return coroutine.create(function()
            --print(#tasks)
            while #tasks ~= 0 do
                local deleted_elemenet_indexs = {}
                for i = 1, #tasks do
                    local task = tasks[i]

                    -- 协程内出错不会让主线程崩溃，除非通过 resume 函数返回值处理，否则没有任何信息！
                    assert(not base.bool(task.dead))

                    local status, result = task:resume()
                    if not status then
                        task.dead = true
                        table.insert(deleted_elemenet_indexs, i)
                        print(base.string_format("Task{{i}} end, result: {{result}}", { i = i, result = result }))
                        --print(inspect.inspect(tasks))
                        --print("#tasks:", #tasks)
                    end
                end
                --print(inspect.inspect(deleted_elemenet_indexs))

                -- 运行完，删除执行完的协程任务（从后往前删）
                tasks = delete_array_indexs(tasks, deleted_elemenet_indexs)
            end
        end)
    end

    local task1 = coroutine.create(function()
        for i = 1, 3 do
            print(base.string_format("Task 1: {{i}}", { i = i }))
            coroutine.yield()
        end
    end)

    local task2 = coroutine.create(function()
        for i = 1, 3 do
            print(base.string_format("Task 2: {{i}}", { i = i }))
            coroutine.yield()
        end
    end)



    -- status == true, result == nil, any situation?
    -- status == false, result == `error message`
    local scheduler_co = scheduler({ Task(task1), Task(task2) })
    local status, result = coroutine.resume(scheduler_co)
    if not status then
        io.stderr.write(result, "\n")
    end
end

local function simple_async_framework_design()
    local function _async_utils()
        local module = {}

        -- 函数内部使用了 yield，意味着该函数必须在 thread(coroutine) 中使用！
        local function _sleep(duration)
            local co = coroutine.running() -- 获取当前运行的协程
            local timer = os.clock() + duration -- 注意，os.clock() 获得 cpu 运行时间

            local request_finished = function()
                return os.clock() >= timer
            end

            while not request_finished() do
                coroutine.yield()
            end
        end

        module.sleep = _sleep

        function module.read_file(filename, callback)
            -- 模拟文件读取操作
            --[[
                我认为的一种设计方法：（线程辅助实现）

                此处应该是个轮询
                1. 设置一个共享结构体，shared(shard__{uuid}) =  { finished = false, data = nil }
                2. 将 read_file 任务交给底层的 io_thread
                3. 文件读取完毕后，设置共享结构体为 shared(shard__{uuid}) = { finished = true, data = {data} }

                ```lua
                    -- 轮询结果
                    while not shared.finished then
                        coroutine.yield()
                    end
                    -- 返回结果
                    return shared.data
                ```
            ]]
            _sleep(1) -- 假装模拟 io 操作耗时

            local data = base.string_format("{{filename}}_DATA", { filename = filename })
            callback(data)
            --return data -- return 的是 Promise 吧？ Promise().then().then().~~~.catch() 最终返回值是最终结果！解决了回调地狱这个问题。 
        end

        return module
    end
    local async_utils = _async_utils()

    local function get_thread_address(co)
        assert(base.is_thread(co))
        return tostring(co):gsub("thread: ", "", 1)
    end

    local print = log.info
    local sleep = async_utils.sleep
    --------------------------------------------------------------------------------------------------------------------


    --[[ shared struct ]]
    local read_file_shared = {
        task1 = {
            data = nil
        }
    }

    ---@param tasks thread[]
    local function scheduler(tasks)
        local function Local()
            local this = {}

            ---@param array table[]
            ---@param indexs number[]
            ---@return table[]
            local function _delete_array_indexs(array, indexs)
                table.sort(indexs, function(o1, o2) return o2 - o1 end)
                -- 倒序删除
                for _, index in ipairs(indexs) do
                    table.remove(array, index)
                end
                return array
            end

            this.delete_array_indexs = _delete_array_indexs

            function this.handle_non_blocking_tasks(tasks)
                local function task_exist()
                    return #tasks ~= 0 -- tasks 是共享内存空间
                end

                while task_exist() do
                    local deleted_elemenet_indexs = {}
                    --print(#tasks)
                    for i = 1, #tasks do
                        local task = tasks[i]

                        if coroutine.status(task) ~= "dead" then
                            coroutine.resume(task)
                        else
                            table.insert(deleted_elemenet_indexs, i)
                            print(base.string_format("Task-{{task}} end", { task = get_thread_address(task) }))
                        end

                        --local status, result = coroutine.resume(task)
                        --if not status then
                        --    table.insert(deleted_elemenet_indexs, i)
                        --    print(base.string_format("Task-{{task}} end, result: {{result}}", { task = get_thread_address(task), result = result }))
                        --    io.stdout:flush()
                        --end

                    end
                    -- 运行完，删除执行完的协程任务（从后往前删）
                    tasks = _delete_array_indexs(tasks, deleted_elemenet_indexs)
                    --print(inspect.inspect(tasks), #tasks)
                end
                --print(inspect.inspect(tasks), #tasks)

            end

            ---每次调用该函数时，会按顺序执行
            local function _do_non_blocking_things()
                local function _dummy()

                end

                local shared_queue = { _dummy }

                return function()
                    for _, something in ipairs(shared_queue) do
                        something()
                    end
                end
            end

            this.do_non_blocking_things = _do_non_blocking_things

            return this
        end

        local loc = Local()

        return coroutine.create(function()
            --[[
                ### 注意事项
                1. 协程内出错不会让主线程崩溃，除非通过判断 `resume` 函数的返回值，否则没有任何信息！
            ]]

            local tmp_render_cnt = 0

            -- 主线程（Lua 是单线程语言）
            while true do
                -- 处理 tasks(thread[]) 这个共享任务队列中的任务。
                -- NOTE: 我认为，tasks 需要一个任务队列线程的帮助，假设那个线程是 arrange_task_real_thread
                loc.handle_non_blocking_tasks(tasks)

                -- 主线程做一些其他事情
                -- NOTE: 我认为，主线程也需要一个另外的其他事情队列，假设那个线程是 arrange_thing_real_thread
                loc.do_non_blocking_things()

                -- ATTENTION: 涉及多线程时，显然要考虑同步问题。底层可以做一些事情：Lua 层访问可变共享内存时，需要获得锁？

                --[[ Test Code ]]
                -- 测试一下，按道理一个是某个线程的任务？
                -- 比如 read_file 执行完会调用回调函数，修改了某个数据，这个数据修改了之后，某个渲染线程会将改变渲染出来
                -- 根据上面的思考内容，我认为多任务（多进程、多线程）是现代计算机的基础（单任务执行时代能做的事情肯定很局限）
                if tmp_render_cnt < 1 then
                    local function render_text()
                        print("------------------ render begin")
                        print(read_file_shared.task1.data)
                        print("------------------ render   end")
                    end
                    render_text()
                    tmp_render_cnt = 1
                end
            end
        end)
    end

    --------------------------------------------------------------------------------------------------------------------
    local function _async_task(name, duration)
        print(name .. " 开始执行")
        io.stdout:flush()
        local start_time = os.clock()
        sleep(duration)
        print(name .. " 执行完毕。到执行完毕为主，整个程序的 cpu 运行时间为：" .. tostring(os.clock() - start_time))
        io.stdout:flush()
    end

    local scheduler_co = scheduler({
        coroutine.create(function()
            -- read_file
            async_utils.read_file("./coroutine.lua", function(data)
                read_file_shared.task1.data = data
            end)
        end),
        coroutine.create(function() _async_task("Task-" .. get_thread_address(coroutine.running()), 1) end),
        coroutine.create(function() _async_task("Task-" .. get_thread_address(coroutine.running()), 2) end),
        coroutine.create(function() _async_task("Task-" .. get_thread_address(coroutine.running()), 3) end),
    })

    -- 启动调度器
    local status, result = coroutine.resume(scheduler_co)
    if not status then
        io.stderr:write(result, "\n")
    end


end

if select("#", ...) == 0 then
    --test_a()
    --test_scheduler()

    --log.enable_flush()
    --simple_async_framework_design()
    --log.disable_flush()

    --[[ range ]]
    xpcall(function()
        for i in module.range(10) do
            print(i)
        end
    end, print)
end

return module
