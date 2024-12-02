---
--- Created by zsh
--- DateTime: 2023/11/23 3:52
---

require("new_scripts.mod_a.class")

-- 呃，Lua 没有模板呀，实现这些东西感觉毫无意义。

local pair = morel_Class(function()
    self.data = {}
end)

function pair:new()
    return pair()
end

function pair:get_value()

end


return pair