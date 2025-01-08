local checker = require("moreitems.main").shihao.module.checker

------------------------------------------------------------------------------------------------------------------------

local internal = {}

function internal.switch(condition)
    --[[
        形如 jdk17：
        return switch(week) {
            case null -> 1;
            case MONDAY -> 2;
            case TUESDAY -> 3;
            default -> 4;
        };
        Lua switch 可以这样使用：

    ]]
    return function(t)
        local branch = t[condition]
        if branch == nil then
            branch = function() end
        end
        checker.check_function(branch)
        return branch()
    end
end
------------------------------------------------------------------------------------------------------------------------

local res = internal.switch(1) {
    a = function()
        return 1
    end,
    [1] = function()
        return 22
    end
}

print(res)