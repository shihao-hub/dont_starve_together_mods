---
--- Created by zsh
--- DateTime: 2023/11/3 23:38
---

require("new_scripts.mod_a.main")

local function print_flush(...)
    print(...)
    io.flush()
end

local function get_file_memory(file)
    assert(file, "file is not existent.")
    local old_cur = file:seek("cur")
    local bytes = file:seek("end")
    file:seek("set", old_cur)
    return bytes
end

require("iuplua")

local iup_info_file_path = "new_scripts/test/iup_info.txt"
local iup_info_file = assert(io.open(iup_info_file_path, "r"))
if get_file_memory(iup_info_file) == 0 then
    iup_info_file:close()
    iup_info_file = assert(io.open(iup_info_file_path, "w"))
    print("------start writing file: " .. iup_info_file_path)
    -- pay attention: some items have been filtered out.
    -- 主要应该是 K_xxx，代表的是快捷键的对应值？
    iup_info_file:write(morel_print_table_deeply(iup, true, true, function(value)
        return not string.find(value, "%[\"K")
    end))
    iup_info_file:close()
    print("------file writing success.")
end

do
    local iup_info_file_path = "new_scripts/test/iup_key_info.txt"
    local iup_info_file = assert(io.open(iup_info_file_path, "w"))
    print("------start writing file: " .. iup_info_file_path)
    -- pay attention: some items have been filtered out.
    iup_info_file:write(morel_print_table_deeply(iup, true, true, function(value)
        return string.find(value, "%[\"K")
    end))
    iup_info_file:close()
    print("------file writing success.")
end

do return end

-- [tutorial](https://www.tecgraf.puc-rio.br/iup/)
require("iuplua")

--[[local iup = require("iuplua")

local label = iup.label { title = "Hello world from IUP." }
local dlg = iup.dialog {
    iup.vbox { label },
    title = "Hello World 2",
}

dlg:showxy(iup.CENTER, iup.CENTER)

--print(type(dlg))
--print(morel_print_table_deeply(dlg))]]


--[[multitext = iup.text{
    multiline = "YES",
    expand = "YES"
}
vbox = iup.vbox{
    multitext
}

dlg = iup.dialog{
    vbox,
    title = "Simple Notepad",
    size = "QUARTERxQUARTER"
}

dlg:showxy(iup.CENTER,iup.CENTER)
dlg.usersize = nil

-- to be able to run this script inside another context
if (iup.MainLoopLevel()==0) then
    iup.MainLoop()
    iup.Close()
end]]

-- ↓ 网站的模板，有个记事本的样子。感觉和之前简单了解 QT 一样，也是写个简单记事本。
require("iuplua")

function read_file(filename)
    local ifile = io.open(filename, "r")
    if (not ifile) then
        iup.Message("Error", "Can't open file: " .. filename)
        return nil
    end

    local str = ifile:read("*a")
    if (not str) then
        iup.Message("Error", "Fail when reading from file: " .. filename)
        return nil
    end

    ifile:close()
    return str
end

function write_file(filename, str)
    local ifile = io.open(filename, "w")
    if (not ifile) then
        iup.Message("Error", "Can't open file: " .. filename)
        return
    end

    if (not ifile:write(str)) then
        iup.Message("Error", "Fail when writing to file: " .. filename)
    end

    ifile:close()
end

multitext = iup.text {
    multiline = "YES",
    expand = "YES"
}

item_open = iup.item { title = "Open..." }
item_saveas = iup.item { title = "Save As..." }
item_font = iup.item { title = "Font..." }
item_about = iup.item { title = "About..." }
item_exit = iup.item { title = "Exit" }

function item_open:action()
    local filedlg = iup.filedlg {
        dialogtype = "OPEN",
        filter = "*.txt",
        filterinfo = "Text Files",
    }

    filedlg:popup(iup.CENTER, iup.CENTER)

    if (tonumber(filedlg.status) ~= -1) then
        local filename = filedlg.value
        local str = read_file(filename)
        if (str) then
            multitext.value = str
        end
    end
    filedlg:destroy()
end

function item_saveas:action()
    local filedlg = iup.filedlg {
        dialogtype = "SAVE",
        filter = "*.txt",
        filterinfo = "Text Files",
    }

    filedlg:popup(iup.CENTER, iup.CENTER)

    if (tonumber(filedlg.status) ~= -1) then
        local filename = filedlg.value
        write_file(filename, multitext.value)
    end
    filedlg:destroy()
end

function item_font:action()
    local font = multitext.font
    local fontdlg = iup.fontdlg { value = font }

    fontdlg:popup(iup.CENTER, iup.CENTER)

    if (tonumber(fontdlg.status) == 1) then
        multitext.font = fontdlg.value
    end

    fontdlg:destroy()
end

function item_about:action()
    iup.Message("About", "   Simple Notepad\n\nAuthors:\n   Gustavo Lyrio\n   Antonio Scuri")
end

function item_exit:action()
    return iup.CLOSE
end

file_menu = iup.menu { item_open, item_saveas, iup.separator {}, item_exit }
format_menu = iup.menu { item_font }
help_menu = iup.menu { item_about }
sub_menu_file = iup.submenu { file_menu, title = "File" }
sub_menu_format = iup.submenu { format_menu, title = "Format" }
sub_menu_help = iup.submenu { help_menu, title = "Help" }

menu = iup.menu {
    sub_menu_file,
    sub_menu_format,
    sub_menu_help
}

vbox = iup.vbox {
    multitext
}

dlg = iup.dialog {
    vbox,
    title = "Simple Notepad",
    size = "QUARTERxQUARTER",
    menu = menu
}

dlg:showxy(iup.CENTER, iup.CENTER)
dlg.usersize = nil

-- to be able to run this script inside another context
if (iup.MainLoopLevel() == 0) then
    iup.MainLoop()
    iup.Close()
end



--local label = iup.label { title = "Hello world from IUP." }
--local button = iup.button {
--    title = "OK",
--    -- onclick
--    action = function(self)
--        return iup.CLOSE
--    end
--}
--
--local vbox = iup.vbox {
--    label,
--    button,
--    alignment = "acenter",
--    gap = "10",
--    margin = "10x10"
--}
--
--local dlg = iup.dialog {
--    vbox,
--    title = "Hello World 5"
--}
--
--dlg:showxy(iup.CENTER, iup.CENTER)

--io.flush()
---- to be able to run this script inside another context
--if (iup.MainLoopLevel() == 0) then
--    iup.MainLoop()
--    iup.Close()
--end

