---
--- Created by zsh
--- DateTime: 2023/11/25 7:19
---

require("new_scripts.mod_a.main")
local TimeInterval = require("new_scripts.mod_a.class.time_interval")

local CRLF = "\r\n"
local CRLF2 = "\r\n\r\n" -- 为什么末尾要两个 CRLF ？因为头和体中间还需要一个空行
local config = {
    [1] = {
        host = "www.lua.org",
        file = "/manual/5.3/manual.html",
        port = 80,
        to_file = morel_RELATIVE_SRC_PATH .. "test/" .. "manual_5_3_manual.html",
    },
    -- error: <p>The plain HTTP request was sent to HTTPS port.<hr/>Powered by Tengine</body>
    [2] = {
        host = "www.juejin.cn",
        file = "/post/6907898286968373262",
        port = 80,
        to_file = morel_RELATIVE_SRC_PATH .. "test/" .. "post_6907898286968373262.html",
    },
}

local socket = require "socket"

local time_interval = TimeInterval:new()
time_interval:start()

morel_print_flush("wait for receiving message...")
for i = 1, #config do
    local config_elem = config[i]
    local cnt = 0
    local conn = assert(socket.connect(config_elem.host, config_elem.port))
    local file = io.open(config_elem.to_file, "w")

    repeat
        local request = string.format("GET %s HTTP/1.0" .. CRLF .. "host: %s" .. CRLF2, config_elem.file, config_elem.host)
        conn:send(request)
        --conn:settimeout(0.1) -- 不阻塞
        local s, status, partial = conn:receive(1024)
        if status then
            morel_print_flush("status: ", status)
        end
        s = s or partial
        cnt = cnt + s:len()
        file:write(s)
    until status == "closed"

    file:close()
    conn:close()
    morel_print_flush(config_elem.host .. config_elem.file, string.format("%.3f KB", cnt / 1024))
    time_interval:insert()
end
morel_print_flush("receiving message success")

--time_interval:insert()
print(time_interval:tostring())
--print("get_span: " .. tostring(time_interval:get_span()))
