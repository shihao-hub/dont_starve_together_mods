---
--- Created by zsh
--- DateTime: 2023/11/26 2:47
---

require("new_scripts.mod_a.main")

-- 简单的异步事件库，所有操作都先压入队列，然后在runloop中统一处理
-- 以此模拟异步的效果
local cmdQueue = {}
local lib = {}
-- 从流中读取一行，读取成功后触发callback事件
function lib.readline(stream, callback)
    local nextCmd = function()
        callback(stream:read())
    end
    table.insert(cmdQueue, nextCmd)
end
-- 向流写一行，写完成后触发callback事件
function lib.writeline(stream, line, callback)
    local nextCmd = function()
        callback(stream:write(line))
    end
    table.insert(cmdQueue, nextCmd)
end
-- 停止
function lib.stop()
    table.insert(cmdQueue, 'stop')
end
function lib.runloop()
    while true do
        local nextCmd = table.remove(cmdQueue, 1)
        if nextCmd == 'stop' then
            break
        else
            nextCmd()
        end
    end
end

local function main()
    lib.writeline(io.stdout, "write -> ", function(success)
        if success then
            print("success!")
        end
    end)
    lib.writeline(io.stdout, "write2 -> ", function(success)
        if success then
            print("success!")
        end
    end)
    lib.stop()
    lib.runloop()
end
--main()

local StringBuilder = require("new_scripts.mod_a.class.string_builder")
local sb  = StringBuilder:new()
print(sb:type())


return lib