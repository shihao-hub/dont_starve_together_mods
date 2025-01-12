local base = require("moreitems.lib.shihao.base")

local commands = require("moreitems.commands.__init__")

local function run(command)
    xpcall(function()
        command() -- 解耦？还是多态？
    end, base.log.error)
end

if select("#", ...) == 0 then
    run(commands.test)
    --run(commands.release)
end