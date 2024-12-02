---
--- Created by zsh
--- DateTime: 2023/9/29 0:02
---

local DEBUG_MODE = false

setfenv(1, _G)
require("lib.shlib.env")

local MAX_FILE_MEMORY = 2 * 1024

if DEBUG_MODE then
    MAX_FILE_MEMORY = 300
end

local function check_file_memory(self)
    local file_mem

    local old_pos = self.file:seek()
    file_mem = self.file:seek("end")
    self.file:seek("set", old_pos)

    if file_mem > MAX_FILE_MEMORY and not self.is_clearing then
        self.is_clearing = true

        print(string.format("file memory = %f > %f MB, so clear it.", file_mem / 1024, MAX_FILE_MEMORY / 1024))
        io.flush()

        self.file:close()

        local file = io.open(self.file_path, "w")
        file:close()

        local start = os.clock()
        local co = coroutine.create(function()
            while os.clock() - start < 0.001 do

            end
            self.is_clearing = false
        end)
        coroutine.resume(co)

        self.file = io.open(self.file_path, "a")
        return false
    end
    return true
end

local function get_current_time()
    return os.date("%Y-%m-%d %H:%M:%S", os.time())
end

local function get_the_processed_call_file_path()
    local level = 4
    -- n S l u f L
    --[[
        n: name, namewhat
        S: source, short_src, what, linedefined, lastlinedefined
        l: currentline
        u: nups
        f: func
        L: activelines
    ]]
    local info = debug.getinfo(level, "S")
    local file_path = info.short_src

    local i, j = string.find(file_path, "/[^.]+%.lua$")
    if i == nil then
        return file_path
    end
    file_path = string.sub(file_path, i + 1, j)
    local MAX_LEN = 20
    if string.len(file_path) <= MAX_LEN then
        file_path = string.rep(" ", MAX_LEN - string.len(file_path)) .. file_path
    else
        file_path = string.sub(file_path, -MAX_LEN)
    end

    return file_path
end

local Logger = ShiHaoEnv.Class(function(self, root)
    root = root or ""
    self.file_path = root .. "lib/shlib/log.log"
    --self.pre_time = os.time()
    self.is_clearing = false

    -- tips: "w/a" 只会创建文件，不会创建文件夹
    -- 默认始终打开该文件
    self.file = io.open(self.file_path, "a")
    check_file_memory(self)
end)

-- Debug: 级别最低，可以随意的使用于任何觉得有利于在调试时更详细的了解系统运行状态
-- Info: 重要，输出信息：用来反馈系统的当前状态给最终用户的
-- Warning: 可修复，系统可继续运行下去
-- Error: 可修复性，但无法确定系统会正常的工作下去
-- Fatal: 相当严重，可以肯定这种错误已经无法修复，并且如果系统继续运行下去的话后果严重

local Level = { "  DEBUG", "   INFO", "WARNING", "  ERROR", "  FATAL" }

local function common_fn(self, msg, show_call_file_path, index)
    if not check_file_memory(self) then
        return
    end
    if show_call_file_path then
        self.file:write(string.format("%s  %s --- [%s]: %s\n", get_current_time(), Level[index], get_the_processed_call_file_path(), tostring(msg)))
    else
        self.file:write(string.format("%s  %s: %s\n", get_current_time(), Level[index], tostring(msg)))
    end
end

function Logger:Debug(msg, show_call_file_path)
    common_fn(self, msg, show_call_file_path, 1)
end

function Logger:Info(msg, show_call_file_path)
    common_fn(self, msg, show_call_file_path, 2)
end

function Logger:Warning(msg, show_call_file_path)
    common_fn(self, msg, show_call_file_path, 3)
end

function Logger:Error(msg, show_call_file_path)
    common_fn(self, msg, show_call_file_path, 4)
end

function Logger:Fatal(msg, show_call_file_path)
    common_fn(self, msg, show_call_file_path, 5)
end

return function(root)
    -- 单例模型
    ShiHaoEnv.Logger = Logger(root)
end
