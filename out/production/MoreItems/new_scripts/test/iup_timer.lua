---
--- Created by zsh
--- DateTime: 2023/11/7 23:37
---

require("iuplua")

local main_dialog

local timer1 = iup.timer {
    time = 1000,
    action_cb = function(self)
        print("timer 1 called")
        io.flush()
        return iup.DEFAULT
    end
}

timer1.run = "YES"

main_dialog = iup.dialog {
    rastersize = "300x300",
    title = "Timer example",
    iup.label { title = "Wait..." }
}
main_dialog:showxy(iup.CENTER,iup.CENTER)

if (iup.MainLoopLevel() == 0) then
    iup.MainLoop()
end
