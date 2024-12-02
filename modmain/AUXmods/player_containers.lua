---
--- @author zsh in 2023/1/24 21:10
---

-- TEST 拓展：所有人共享一个容器？但是地上地下怎么办呢？
--[[ 人物身上捆绑一个容器，快捷键即可打开 ]]
local CONTAINER; -- 这个需要用个组件和指定的保存预制体的函数才行！
env.AddPlayerPostInit(function(inst)
    if not TheWorld.ismastersim then
        return inst;
    end

end)

-- Question: 如果写客户端的话，我肯定可以熟练知道快捷键如何使用。抽空我需要去了解了解。
TheInput:AddKeyHandler(function(key, down)
    if down then
        if key == 278 then
            local inst = CONTAINER;
            if inst and inst.components.container then

            end
        end
    end
end)