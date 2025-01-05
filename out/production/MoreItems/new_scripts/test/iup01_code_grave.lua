


-- todo: remove it
local button_lua = anonymous(function()
    -- upvalues
    local uvs = {
        lua_console_show = nil,
        lua_console_dialog = nil,
        lua_console_multitext = nil,
        click_num = nil,
    }
    -- ???
    --local uvs = setmetatable({
    --    lua_console_show = nil,
    --    lua_console_dialog = nil,
    --    lua_console_multitext = nil,
    --    click_num = nil,
    --}, { __mode = "v" })
    return function()
        local button = iup.button {
            title = "Lua",
            action = function(self)
                local base = self
                --print(lua_console_dialog)
                if true then
                    --lua_console_show = true
                    if not uvs.lua_console_dialog then
                        uvs.lua_console_multitext = iup.text {
                            multiline = "YES",
                            expand = "YES",
                        }
                        local close_button = iup.button {
                            title = "close",
                            action = function(self)
                                uvs.lua_console_show = false
                                iup.Hide(iup.GetDialog(self))
                            end
                        }
                        uvs.lua_console_dialog = iup.dialog {
                            rastersize = "300x300",
                            parentdialog = iup.GetDialog(self),
                            defaultesc = close_button,
                            iup.hbox {
                                uvs.lua_console_multitext,
                                iup.vbox {
                                    close_button,
                                    iup.button {
                                        title = "clear",
                                        action = function(self)
                                            uvs.lua_console_multitext.value = ""
                                        end
                                    }
                                }
                            }
                        }
                    end
                    uvs.lua_console_dialog:showxy(iup.LEFT, iup.CENTER)
                end

                if not uvs.click_num then uvs.click_num = 0 end
                uvs.click_num = uvs.click_num + 1
                if uvs.click_num % 2 == 0 then
                    uvs.click_num = 0
                    self.title = "Lua"
                else
                    self.title = "LUA"
                end

                local str = main_multitext.value
                local result, err = loadstring(str)
                if type(result) == "string" then
                    print(result)
                    io.flush()
                elseif type(err) == "string" then
                    --iup.Message("Error", debug.traceback(err) .. "\n")
                    uvs.lua_console_multitext.value = uvs.lua_console_multitext.value .. (debug.traceback(err) .. "\n")
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
                                uvs.lua_console_multitext.value = uvs.lua_console_multitext.value .. table.concat(res, "\t")
                            end
                        }, { __index = _G }))
                        --local pre_msg = table.concat({
                        --    "os lib import\n",
                        --    "math lib import\n",
                        --})
                        --lua_console_multitext.value = lua_console_multitext.value .. pre_msg
                        result()
                        io.flush()
                    end, function(msg)
                        --iup.Message("Error", debug.traceback(msg) .. "\n")
                        uvs.lua_console_multitext.value = uvs.lua_console_multitext.value .. (debug.traceback(msg) .. "\n")
                    end)
                end
            end
        }
        return button
    end
end)