---
--- Created by zsh
--- DateTime: 2023/11/4 22:48
---

-- ****************************************************** Imports and dependencies
require("new_scripts.mod_a.main")

require("iuplua")
require("iupluaimglib")

-- ****************************************************** Utilities
local DEBUG_MODE = true

local utility
utility = morel_SingletonInstance(function(instance)
    utility = instance
    function utility.print_wall_flush(...)
        print(...)
        io.flush()
    end

    function utility.wall_flush()
        io.flush()
    end

    function utility.anonymous(anonymous_fn, ...)
        return anonymous_fn()(...)
    end

    function utility.debug_message(fn)
        if not DEBUG_MODE then return end
        local xpcall_on = false
        if type(fn) == "string" then
            fn = loadstring(fn)
            xpcall_on = true
        end
        assert(type(fn) == "function", [[not type(fn) == "function"]])
        if xpcall_on then
            xpcall(function() fn() end, function(msg)
                io.stderr:write(debug.traceback(msg), "\n")
                io.stderr:flush()
            end)
        else
            fn()
        end
    end
end)

local anonymous = utility.anonymous
local wall_flush = utility.wall_flush
local print_flush = utility.print_wall_flush
local debug_message = utility.debug_message


-- ****************************************************** Main (Part 1/2)
-- upvalues, which are declared in here for the purpose of creating closure.

-- Main Dialog
local main_dlg
local main_menu
local main_toolbar
local main_multitext
local main_statusbar
local main_timebar


-- ****************************************************** Callbacks
local common_fns, menu_deps

common_fns = morel_SingletonInstance(function(singleton_instance)
    common_fns = singleton_instance
    local instance = common_fns

    function instance.execute_lua_action(self)
        local str = main_multitext.value
        local result, err = loadstring(str)
        if type(result) == "string" then
            print(result)
            io.flush()
        elseif type(err) == "string" then
            iup.Message("Error", debug.traceback(err) .. "\n")
        else
            xpcall(function()
                result()
                io.flush()
            end, function(msg)
                iup.Message("Error", debug.traceback(msg) .. "\n")
            end)
        end
    end


    --function common_fns.get_execute_lua_action(self, _multitext)
    --    return function(_t)
    --        local str = _multitext.value
    --        local result = loadstring(str)
    --        if type(result) == "string" then
    --            print(result)
    --            io.flush()
    --        else
    --            xpcall(function()
    --                result()
    --                io.flush()
    --            end, function(msg)
    --                io.stderr:write(debug.traceback(msg), "\n")
    --                io.stderr:flush()
    --            end)
    --        end
    --    end
    --end
end)

menu_deps = morel_SingletonInstance(function(singleton_instance)
    menu_deps = singleton_instance
    local instance = menu_deps

    instance.file_menu = {}
    instance.format_menu = {}
    instance.edit_menu = {}
    instance.help_menu = {}
    instance.util_menu = {}

    --instance.util_menu = setmetatable({}, {
    --    __index = {
    --        -- fixme
    --        add = function(t, key, value)
    --            rawset(t, key, value)
    --        end
    --    }
    --})

    function instance.create_sub_menu_file()
        local current_file_path
        local members = {}
        function members.set_current_file_path(fp) current_file_path = fp end
        function members.get_current_file_path() return current_file_path end
        function members.clear_current_file_path() current_file_path = nil end

        local open, save, save_as, exit

        open = iup.item {
            title = "Open (Ctrl+O)",
            image = "IUP_FileOpen",
            action = function(self)
                members.clear_current_file_path()
                local filedlg = iup.filedlg {
                    dialogtype = "OPEN",
                    filter = "*.txt",
                    filterinfo = "Text Files",
                }
                filedlg:popup(iup.CENTER, iup.CENTER)
                if tonumber(filedlg.status) ~= -1 then
                    local str
                    ------------------------------------BEG Read File
                    local filepath = filedlg.value
                    members.set_current_file_path(filepath)
                    --print(filepath)
                    --wall_flush()
                    local in_file = io.open(filepath, "r")
                    if in_file then
                        -- todo: get file memory and determine whether should read the whole file content
                        str = in_file:read("*a")
                        if not str then
                            iup.Message("Error", "Fail when reading from file: " .. filepath)
                            return nil
                        end
                        in_file:close()
                    else
                        iup.Message("Error", "Can't open file: " .. filepath)
                        return nil
                    end
                    ------------------------------------END Read File
                    if str then
                        debug_message(function()
                            print(main_multitext.value)
                            wall_flush()
                        end)
                        main_multitext.value = str
                    end
                end
                filedlg:destroy()
            end
        }
        save = iup.item {
            title = "Save (Ctrl+S)",
            image = "IUP_FileSave",
            action = function(self)
                local messagedlg = iup.messagedlg {
                    title = ""
                }
                local filepath = members.get_current_file_path()
                if filepath then
                    ------------------------------------BEG Write File
                    local file = io.open(filepath, "r")
                    if not file then
                        return save_as:action()
                    else
                        file:close()
                        file = io.open(filepath, "w")
                    end
                    if file then
                        file:write(main_multitext.value)
                        file:close()
                        iup.Message("Success", "Save to " .. filepath .. " successfully!")
                    else
                        iup.Message("Error", "Can't open file: " .. filepath)
                        return nil
                    end
                    ------------------------------------END Write File
                else
                    return save_as:action()
                end
            end
        }
        save_as = iup.item {
            title = "Save As",
            action = function(self)
                local filedlg = iup.filedlg {
                    dialogtype = "SAVE",
                    filter = "*.txt",
                    filterinfo = "Text Files",
                }
                filedlg:popup(iup.CENTER, iup.CENTER)
                if tonumber(filedlg.status) ~= -1 then
                    ------------------------------------BEG Write File
                    local filepath = filedlg.value
                    local out_file = io.open(filepath, "w")
                    if not out_file then
                        iup.Message("Error", "Can't open file: " .. filepath)
                        return nil
                    else
                        out_file:write(main_multitext.value)
                        out_file:close()
                        iup.Message("Success", "Save to " .. filepath .. " successfully!")
                    end
                    ------------------------------------END Write File
                end
                filedlg:destroy()
            end
        }
        exit = iup.item {
            title = "Exit",
            action = function(self)
                return iup.CLOSE
            end
        }

        local sub_menu = iup.submenu {
            title = "File",
            iup.menu { open, save, save_as, iup.separator {}, exit }
        }

        instance.file_menu.open = open
        instance.file_menu.save = save
        instance.file_menu.save_as = save_as
        instance.file_menu.exit = exit
        return sub_menu
    end

    function instance.create_sub_menu_format()
        local font
        font = iup.item {
            title = "Font",
            action = function(self)
                local font = main_multitext.font
                local fontdlg = iup.fontdlg { value = font }
                -- fixme: ↓ this line code will crash the process when it is executed.
                --fontdlg:popup(iup.CENTER, iup.CENTER)
                --if tonumber(fontdlg.status) == 1 then
                --    main_multitext.font = fontdlg.value
                --end
                --fontdlg:destroy()
            end
        }
        local sub_menu = iup.submenu {
            title = "Format",
            iup.menu { font }
        }
        instance.format_menu.font = font
        return sub_menu
    end

    function instance.create_sub_menu_help()
        local about
        about = iup.item {
            title = "About",
            action = function(self)
                iup.Message("About", "   Simple Notepad\n\nAuthor:\n   ZhangShiHao")
            end
        }

        local sub_menu = iup.submenu {
            title = "Help",
            iup.menu { about }
        }
        instance.help_menu.about = about
        return sub_menu
    end

    function instance.create_sub_menu_edit()
        local cut, copy, paste, delete, select_all
        local find
        find = iup.item {
            title = "Find (Ctrl+F)",
            -- 这个示例代码实现的不够好，还有 bug。此处暂时是示例代码，我还没自己写。
            action = function(self)
                -- todo: Come From Example
                local find_dlg = self.find_dialog
                if not find_dlg then
                    local function str_find(str, str_to_find, casesensitive, start)
                        if not casesensitive then
                            return str_find(string.lower(str), string.lower(str_to_find), true, start)
                        end

                        return string.find(str, str_to_find, start, true)
                    end

                    local find_txt = iup.text { visiblecolumns = "20" }
                    local find_case = iup.toggle { title = "Case Sensitive" }
                    local bt_find_next = iup.button { title = "Find Next", padding = "10x2" }
                    local bt_find_close = iup.button { title = "Close", padding = "10x2" }

                    -- 有 string.find 的存在导致实现起来非常方便
                    function bt_find_next:action()
                        local find_pos = tonumber(find_dlg.find_pos)
                        local str_to_find = find_txt.value

                        local casesensitive = (find_case.value == "ON")

                        -- test again, because it can be called from the hot key
                        if (not str_to_find or str_to_find:len() == 0) then
                            return
                        end

                        if (not find_pos) then
                            find_pos = 1
                        end

                        local str = main_multitext.value

                        local pos, end_pos = str_find(str, str_to_find, casesensitive, find_pos)
                        -- 如果找不到了，就从头开始找
                        if (not pos) then
                            pos, end_pos = str_find(str, str_to_find, casesensitive, 1)  -- try again from the start
                        end

                        if (pos) and (pos > 0) then
                            pos = pos - 1
                            find_dlg.find_pos = end_pos

                            -- 设置焦点，妙啊
                            iup.SetFocus(main_multitext)
                            main_multitext.selectionpos = pos .. ":" .. end_pos

                            local lin, col = iup.TextConvertPosToLinCol(main_multitext, pos)
                            local pos = iup.TextConvertLinColToPos(main_multitext, lin, 0)  -- position at col=0, just scroll lines
                            main_multitext.scrolltopos = pos
                        else
                            find_dlg.find_pos = nil
                            iup.Message("Warning", "Text not found.")
                        end
                    end

                    function bt_find_close:action()
                        -- 因此这个框内容都会保存起来...
                        iup.Hide(iup.GetDialog(self))  -- do not destroy, just hide
                    end

                    local box = iup.vbox {
                        iup.label { title = "Find What:" },
                        find_txt,
                        find_case,
                        iup.hbox {
                            iup.fill {}, -- 这应该是个空白格
                            bt_find_next,
                            bt_find_close,
                            normalizesize = "HORIZONTAL",
                        },
                        margin = "10x10",
                        gap = "5",
                    }

                    find_dlg = iup.dialog {
                        box,
                        title = "Find",
                        dialogframe = "Yes",
                        defaultenter = bt_find_next,
                        defaultesc = bt_find_close,
                        parentdialog = iup.GetDialog(self)
                    }

                    -- Save the dialog to reuse it
                    self.find_dialog = find_dlg -- from the main dialog */
                end

                -- centerparent first time, next time reuse the last position
                find_dlg:showxy(iup.CURRENT, iup.CURRENT)
            end
        }

        cut = iup.item {
            title = "Cut (Ctrl+X)",
            action = function(self)
                -- PAY ATTENTION: this clipboard is associated to the computer clipboard
                local clipboard = iup.clipboard { text = main_multitext.selectedtext }
                main_multitext.selectedtext = ""
                --clipboard:destroy() -- Why this function is existent?
            end
        }
        copy = iup.item {
            title = "Copy (Ctrl+C)",
            action = function(self)
                local clipboard = iup.clipboard { text = main_multitext.selectedtext }
                --clipboard:destroy() -- Why this function is existent?
                --return iup.IGNORE  -- !!! avoid system processing for hot keys, to correctly parse line feed
            end
        }
        paste = iup.item {
            title = "Paste (Ctrl+V)",
            action = function(self)
                local clipboard = iup.clipboard {}
                main_multitext.insert = clipboard.text
                --clipboard:destroy() -- Why this function is existent?
                return iup.IGNORE  -- !!! avoid system processing for hot keys, to correctly parse line feed
            end
        }
        delete = iup.item {
            title = "Delete (Ctrl+D)",
            action = function(self)
                main_multitext.selectedtext = ""
            end
        }
        select_all = iup.item {
            title = "Select All (Ctrl+A)",
            action = function(self)
                iup.SetFocus(main_multitext)
                main_multitext.selection = "ALL"
            end
        }

        local sub_menu = iup.submenu {
            title = "Edit",
            iup.menu {
                cut, copy, paste, delete, select_all, iup.separator {}, find,
                open_cb = function(self)
                    local clipboard = iup.clipboard {}
                    if not clipboard.textavailable then
                        paste.active = "NO"
                    else
                        paste.active = "YES"
                    end
                    if not main_multitext.selectedtext then
                        cut.active = "NO"
                        copy.active = "NO"
                        delete.active = "NO"
                    else
                        cut.active = "YES"
                        copy.active = "YES"
                        delete.active = "YES"
                    end
                    --clipboard:destroy()
                end
            },
            -- when this menu is opened, this callback will be invoked.
        }
        instance.edit_menu.cut = cut
        instance.edit_menu.copy = copy
        instance.edit_menu.paste = paste
        instance.edit_menu.delete = delete
        instance.edit_menu.select_all = select_all
        instance.edit_menu.find = find
        return sub_menu
    end

    function instance.create_sub_menu_util()
        local count, execute_lua, lua_console
        count = iup.item {
            title = "Count",
            action = function(self)
                local function get_lines(str)
                    local cnt = 0
                    local i, j = string.find(str, "\n")
                    if i ~= nil then
                        cnt = cnt + 1
                    end
                    while i ~= nil do
                        cnt = cnt + 1
                        i, j = string.find(str, "\n", i + 1)
                    end
                    return cnt
                end
                local value = main_multitext.value
                iup.Message("Information", string.format("Lines %d, Chars %d", get_lines(value), string.len(value)))
            end
        }
        execute_lua = iup.item {
            title = "Lua Executor (Ctrl+E)",
            action = function(self)
                local str = main_multitext.value
                local result, err = loadstring(str)
                local multitext = instance.util_menu.lua_console_data.multitext
                local function console_multitext_append(content)
                    if not multitext then return end
                    multitext.value = multitext.value .. content
                end
                if type(result) == "string" then
                    print(result)
                    io.flush()
                elseif type(err) == "string" then
                    local msg = debug.traceback(err) .. "\n"
                    console_multitext_append(msg)
                    iup.Message("Error", msg)
                else
                    xpcall(function()
                        setfenv(result, setmetatable({
                            print = function(...)
                                local n = select("#", ...)
                                local args = { ... }
                                local res = {}
                                for i = 1, n do
                                    table.insert(res, i ~= n and tostring(args[i]) or tostring(args[i]) .. "\n")
                                end
                                local msg = table.concat(res, "\t")
                                console_multitext_append(msg)
                                print(...)
                            end
                        }, { __index = _G }))
                        result()
                        io.flush()
                    end, function(msg)
                        local message = debug.traceback(msg) .. "\n"
                        console_multitext_append(message)
                        iup.Message("Error", message)
                    end)
                end
            end
        }
        lua_console = iup.item {
            title = "Open Lua Console (Ctrl+O)",
            action = function(self)
                if not self._console_dlg then
                    local multitext = iup.text {
                        multiline = "YES",
                        expand = "YES",
                    }
                    instance.util_menu.lua_console_data.multitext = multitext
                    self._console_dlg = iup.dialog {
                        title = "Lua Console",
                        rastersize = "300x300",
                        parentdialog = iup.GetDialog(self),
                        iup.vbox {
                            iup.hbox {
                                iup.button {
                                    title = "close",
                                    action = function(sel)
                                        self.snl_show = false
                                        iup.Hide(iup.GetDialog(sel))
                                    end
                                },
                                iup.button {
                                    title = "clear",
                                    action = function(sel)
                                        multitext.value = ""
                                    end
                                }
                            },
                            multitext
                        }
                    }
                end
                if not self.snl_show then
                    self.snl_show = true
                    self._console_dlg:showxy(iup.LEFT, iup.CENTER)
                else
                    self.snl_show = false
                    iup.Hide(self._console_dlg)
                end
            end
        }
        local sub_menu = iup.submenu {
            title = "Util",
            iup.menu { count, execute_lua, lua_console }
        }
        instance.util_menu.count = count
        instance.util_menu.execute_lua = execute_lua
        instance.util_menu.lua_console = lua_console
        instance.util_menu.lua_console_data = {}
        return sub_menu
    end
end)

-- ****************************************************** Main (Part 2/2)
local function save_check_before_do_anything_else(component)
    local dlg = iup.GetDialog(component)
    --local multitext = dlg.multitext
    --if multitext.dirty then
    --    local resp = iup.Alarm("Warning", "File not saved! Save it now?", "Yes", "No", "Cancel")
    --    if resp == 1 then
    --        -- save the changes and continue
    --        save_file(multitext)
    --    elseif resp == 3 then
    --        -- cancel
    --        return false
    --    else -- ignore the changes and continue
    --    end
    --end
    return true -- Temp
end

main_menu = iup.menu {
    menu_deps.create_sub_menu_file(),
    menu_deps.create_sub_menu_edit(),
    menu_deps.create_sub_menu_format(),
    menu_deps.create_sub_menu_util(),
    menu_deps.create_sub_menu_help(),
}

main_toolbar = anonymous(function()
    local open, save, find, execute_lua
    open = menu_deps.file_menu.open
    save = menu_deps.file_menu.save
    find = menu_deps.edit_menu.find
    execute_lua = menu_deps.util_menu.execute_lua
    return function()
        -- 这里有很多组件值得试试！
        -- [iup image](https://www.tecgraf.puc-rio.br/iup/en/elem/iupimage.html)
        -- [iup image examples](https://www.tecgraf.puc-rio.br/iup/examples/)
        local toolbar = iup.hbox {
            iup.button { image = "IUP_FileOpen", flat = "Yes", action = open.action, canfocus = "No", tip = "Open (Ctrl+O)" },
            iup.button { image = "IUP_FileSave", flat = "Yes", action = save.action, canfocus = "No", tip = "Save (Ctrl+S)" },
            iup.button { image = "IUP_EditFind", flat = "Yes", action = find.action, canfocus = "No", tip = "Find (Ctrl+F)" },
            --iup.label { separator = "HORIZONTAL" },
            --iup.label { separator = "VERTICAL" },
            --iup.label {title = "    "},
            iup.button { image = "IUP_ZoomActualSize", flat = "Yes", action = execute_lua.action, canfocus = "No", tip = "Execute (Ctrl+E)" },
            margin = "5x5",
            gap = 2,
        }
        return toolbar
    end
end)

--iup.SetGlobal("UTF8MODE","YES")
main_multitext = iup.text {
    multiline = "YES",
    expand = "YES",
    value = table.concat({
        [[--Simple NotePad Lua Sample Code]],
        [[print("Simple NotePad Startup...")]],
    }, "\n"),
    --font = "Microsoft YaHei UI,  12",
    font = "Consolas,  11",
    caret_cb = function(self, line, col)
        main_statusbar.title = "Line " .. line .. ", Col " .. col
    end,
    -- this callback implements a function(功能) about dragging and dropping files
    dropfiles_cb = function(self, filepath)
        if save_check_before_do_anything_else(self) then
            local in_file = io.open(filepath)
            if not in_file then
                iup.Message("Error", "Can't open file: " .. filepath)
            else
                local function process_filepath(fpath)
                    local reverse_fpath = string.reverse(fpath)
                    local i = string.find(reverse_fpath, "[/\\]")
                    if not i then
                        iup.Message("Error", "processing filepath program had a error " .. morel_get_call_on_position())
                        return "ERROR"
                    else
                        return string.sub(fpath, -i + 1, -1)
                    end
                end
                local str = in_file:read("*a")
                in_file:close()
                local dlg = iup.GetDialog(self)
                local multitext = dlg.multitext
                dlg.title = process_filepath(filepath) .. " - Simple Notepad"
                multitext.value = str
            end
        end
    end
}

-- test
--print_flush(type(main_multitext))
--print_flush(main_multitext.a)
--main_multitext.a = "a"
--print_flush(main_multitext.a)
--print_flush(main_multitext.__index)
--print_flush(main_multitext.__newindex)

main_statusbar = iup.label { title = "Line 1, Col 1", expand = "HORIZONTAL", padding = "10x5" }
main_timebar = anonymous(function()
    local function get_current_time()
        return os.date("%Y-%m-%d %H:%M:%S", os.time())
    end
    local function get_dlg_x_and_y(dlg)
        local rastersize = main_dlg.rastersize
        local x = tonumber(string.sub(rastersize, 1, string.find(rastersize, "x") - 1))
        local y = tonumber(string.sub(rastersize, string.find(rastersize, "x") + 1, -1))
        if not x then assert(false, "not x") end
        if not y then assert(false, "not y") end
        return x, y
    end
    return function()
        local timebar = iup.label {
            title = get_current_time(),
            expand = "HORIZONTAL",
            padding = "265x5",
            --position = "400,0",
            --fgcolor = "0 0 0",
            --bgcolor = "255 0 128"
        }
        local timer = iup.timer {
            time = "1000",
            action_cb = function(self)
                --print_flush(iup.GetDialog(timebar).rastersize)
                --local x, y = get_dlg_x_and_y(main_dlg)
                --if x and y and x > 500 and y > 500 then
                --    timebar.padding = "920x5"
                --end
                timebar.title = get_current_time()
                return iup.DEFAULT
            end
        }
        timer.run = "YES"
        return timebar
    end
end)

--morel_print_table_deeply(_G)

-- https://www.tecgraf.puc-rio.br/iup/ 这里还有很多内容呢，最终实现了一个较为完整的 NotePad，值得试试。
-- [Keyboard Codes](https://www.tecgraf.puc-rio.br/iup/en/attrib/key.html)
main_dlg = iup.dialog {
    rastersize = "500x500", -- old: 400x400
    title = "Simple Notepad",
    k_any = function(self, c)
        morel_Switch.execute(c, {
            [iup.K_cO] = function()
                menu_deps.file_menu.open:action()
            end,
            [iup.K_cS] = function()
                menu_deps.file_menu.save:action()
            end,
            [iup.K_cF] = function()
                menu_deps.edit_menu.find:action()
            end,
            [iup.K_cG] = function()
                -- todo: goto
            end,
            [iup.K_cE] = function()
                menu_deps.util_menu.execute_lua:action()
            end,
            [iup.K_cO] = function()
                menu_deps.util_menu.lua_console:action()
            end,
        })

        --if c == iup.K_cO then
        --    menu_deps.file_menu.open:action()
        --elseif c == iup.K_cS then
        --    menu_deps.file_menu.save:action()
        --elseif c == iup.K_cF then
        --    menu_deps.edit_menu.find:action()
        --elseif c == iup.K_cG then
        --    -- todo: goto
        --elseif c == iup.K_cE then
        --    menu_deps.util_menu.execute_lua:action()
        --end
    end,
    multitext = main_multitext, -- Bind this multitext
    --font = "Microsoft YaHei UI,  12",
    menu = main_menu,
    -- this is main vbox
    iup.vbox {
        main_toolbar,
        iup.hbox {
            main_multitext,
            --button_lua -- todo: remove it
        },
        iup.hbox {
            main_statusbar,
            main_timebar
        }
    },
}

local function test()
    local util = {}
    function util.hook(fn)
        return fn()
    end

    local mt = getmetatable(main_dlg)
    print_flush("mt: ", mt)
    print_flush("mt meta: ", getmetatable(mt))
    morel_print_table_deeply(getmetatable(main_dlg))

    mt.__index = util.hook(function()
        local old = mt.__index
        return function(t, k)
            print_flush("__index:", k)
            return old(t, k)
        end
    end)

    mt.__newindex = util.hook(function()
        local old = mt.__newindex
        return function(t, k, v)
            print_flush("__newindex:", k, v)
            return old(t, k, v)
        end
    end)
    --print_flush(main_dlg.menu)
    io.flush()
end
--test()

local function test1()
    print_flush(iup, type(iup), getmetatable(iup))
    print_flush(main_dlg, type(main_dlg), getmetatable(main_dlg))
    morel_print_table_deeply(getmetatable(main_dlg))
    print_flush(main_multitext, type(main_multitext), getmetatable(main_multitext))
    morel_print_table_deeply(getmetatable(main_multitext))
end
--test1()

-- parent for pre-defined dialogs in closed functions (IupMessage)
iup.SetGlobal("PARENTDIALOG", iup.SetHandleName(main_dlg))

--print(main_dlg.font)
--print(main_dlg.RASTERSIZE)
--utility.print_wall_flush(iup.Version())
--utility.print_wall_flush(iup.config)


main_dlg:showxy(iup.CENTER, iup.CENTER)
main_dlg.usersize = nil

--debug_message(function() wall_flush() end)
debug_message(function() wall_flush() end)
-- to be able to run this script inside another context
if (iup.MainLoopLevel() == 0) then
    iup.MainLoop()
    iup.Close()
end