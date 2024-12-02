---
--- Created by zsh
--- DateTime: 2023/11/5 1:32
---

local iup = require("iuplua")

local hbox = iup.hbox {
    iup.ColorDlg { title = "color dlg" }
}

-- ??
--local color_dlg = iup.ColorDlg { title = "color dlg" }

local main_dlg = iup.dialog {
    rastersize = "400x400",
    title = "iup 02",
    hbox,
}


main_dlg:showxy(iup.CENTER, iup.CENTER)

io.flush()
-- to be able to run this script inside another context
if (iup.MainLoopLevel() == 0) then
    iup.MainLoop()
    iup.Close()
end