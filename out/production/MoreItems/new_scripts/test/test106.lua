---
--- Created by zsh
--- DateTime: 2023/11/5 6:10
---

--print(tonumber("a"))

require("new_scripts.mod_a.main")

TimeEvent = morel_Class(
        function(self, time, fn)
            -- #1 当前函数 f1
            -- #2 调用 f1 的函数 f2
            -- #3 调用 f2 的函数 f3
            --[[
                local function f1()

                end

                local function f2()
                    f1()
                end

                local function f3()
                    f2()
                end
            ]]
            --local info = debug.getinfo(3)
            local info = debug.getinfo(3, "Sl")
            self.defline = string.format("%s:%d", info.short_src, info.currentline)
            morel_print_table_deeply(info)
            assert (type(time) == "number")
            assert (type(fn) == "function")
            self.time = time
            self.fn = fn
        end)

function FrameEvent(frame, fn)
    TimeEvent(frame * FRAMES, fn)
end

function f3()
    FrameEvent(1,function()  end)
end

FRAMES = 1/30

f3()

