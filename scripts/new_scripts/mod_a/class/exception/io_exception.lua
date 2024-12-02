---
--- Created by zsh
--- DateTime: 2023/11/28 23:18
---

require("new_scripts.mod_a.class")
local Exception = require("new_scripts.mod_a.class.exception.exception")

local IOException = morel_Class(Exception, function(self, message)
    morel_super(Exception, self, message) -- 需要执行一下基类的构造函数，而且必须首先执行。
    self:set_type("IOException")

end)

return IOException