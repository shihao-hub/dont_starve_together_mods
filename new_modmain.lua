---
--- Created by zsh
--- DateTime: 2023/10/22 20:33
---


------------------------------------------------ 23/10/29 BEGIN NEW WORLD

morel_add_PrefabFiles({ "new_prefabs/more_items_instruction_book" })
env.modimport("modmain/newworld/postinit/more_items_instruction_book.lua")

-- Add new prefabs, but they are still incomplete.
morel_add_PrefabFiles({ "new_prefabs/prefabs_inspiration_1" })
env.modimport("modmain/newworld/postinit/prefabs_inspiration_1.lua")
------------------------------------------------ 23/10/29 END NEW WORLD