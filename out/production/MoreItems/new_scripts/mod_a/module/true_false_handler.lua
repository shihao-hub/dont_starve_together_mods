---
--- Created by zsh
--- DateTime: 2023/11/7 6:04
---

require("new_scripts.mod_a.class")

local TrueFalseHandler = morel_Module()

-- 太丑陋了，毕竟没有语法糖
function TrueFalseHandler.is_true_or_false(b)
    return {
        handler = function(true_handler, false_handler)
            if b then true_handler() else false_handler() end
        end
    }
end

return TrueFalseHandler