---
--- Created by zsh
--- DateTime: 2023/11/28 23:17
---

require("new_scripts.mod_a.class")

local Exception = morel_Class(function(self, message)
    morel_super()
    self:set_type("Exception")

    self.message = message or ""
end)

function Exception:get_detail_message()
    if self.message ~= "" then
        return "" .. self._classname .. ": " .. self.message
    else
        return self._classname
    end
end

function morel_throw_exception(exception)
    assert(exception and exception.is_a and exception:is_a(Exception), "expected Exception object of #1")
    --if make_crush then
    --    error(exception:get_detail_message(), 2)
    --else
    --    io.stderr:write(exception:get_detail_message(), '\n', debug.traceback())
    --end
    error(exception:get_detail_message(), 2)
end

return Exception