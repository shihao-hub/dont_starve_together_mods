---
--- Created by zsh
--- DateTime: 2023/11/7 6:08
---

require("new_scripts.mod_a.main")


morel_TrueFalseHandler.is_true_or_false(true).handler(function()
    print("True Branch")
end,function()
    print("False Branch")
end)
