---
--- Created by zsh
--- DateTime: 2023/11/25 7:48
---

require("new_scripts.mod_a.main")
local TimeInterval = require("new_scripts.mod_a.class.time_interval")

local socket = require "socket"

local function receive(connection)
    connection:settimeout(0) -- 不阻塞
    local s, status, partial = connection:receive(2 ^ 10)
    if status == "timeout" then
        coroutine.yield(connection)
    end
    return s or partial, status
end

local function download (host, file)
    local c = assert(socket.connect(host, 80))
    local count = 0
    local request = string.format("GET %s HTTP/1.0\r\nhost:%s\r\n\r\n", file, host)
    c:send(request)
    while true do
        local s, status = receive(c)
        count = count + #s
        if status == "closed" then break end
    end
    c:close()
    morel_print_flush(file, count)
end

local tasks = { n = 0 }            -- 所有活跃任务的列表
local function get (host, file)
    local co = coroutine.wrap(function()
        download(host, file)
    end)
    table.insert(tasks, co)
    tasks.n = tasks.n + 1
end

local function dispatch()
    local time_interval = TimeInterval:new()
    time_interval:start()
    local i = 1
    local timedout = {}
    local cnt = 0
    local print_flag = false
    -- 模拟多线程，访问多个网站的时候，设置不阻塞，类似流水线工作方式，加快了速度。
    -- 如果只访问一个网站，那么时间是一样的。但是多个网站速度会有所提升。网站越多速度提升一般越多。
    while true do
        cnt = cnt + 1
        if tasks[i] == nil then
            if tasks.n == 0 then
                break
            end
            i = 1
            timedout = {}
        end
        local res = tasks[i]() -- 返回 yield 传递过来的信息。不同于 resume，还会返回状态码。
        if not res then
            table.remove(tasks, i)
            tasks.n = tasks.n - 1
        else
            i = i + 1
            timedout[#timedout + 1] = res
            if #timedout == #tasks then
                --if not print_flag then
                --    print_flag = true
                --    morel_print_table_deeply(timedout)
                --end
                socket.select(timedout)
            end
        end
    end
    time_interval:insert()
    morel_print_flush(cnt)
    morel_print_flush(time_interval:tostring())
end

get("www.lua.org", "/ftp/lua-5.3.2.tar.gz")
get("www.lua.org", "/ftp/lua-5.3.1.tar.gz")
get("www.lua.org", "/ftp/lua-5.3.0.tar.gz")
get("www.lua.org", "/ftp/lua-5.2.4.tar.gz")
get("www.lua.org", "/ftp/lua-5.2.3.tar.gz")
-- 一个大概 3 秒，而通过非阻塞的方式，五个速度才 5 秒。
dispatch()