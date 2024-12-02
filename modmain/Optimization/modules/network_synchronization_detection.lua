---
--- @author zsh in 2023/4/30 6:03
---

-- 此处尝试让以下错误出现的时候立即报错！便于知道是哪个模组的问题。
-- 本地和服务器实体不同步时，往往并不会立刻导致客户端崩溃，而是会在一段时间之后产生一个极为难以溯源的错误。

-- 2023-04-30：暂未完善，而且好像是需要在客户端执行。

do
    return ;
end


GLOBAL.RemoveEntity = function(guid)
    local inst = GLOBAL.Ents[guid]
    if inst then
        inst:RemoveFromServer()
    end
end

local old_SpawnPrefab = GLOBAL.SpawnPrefab
GLOBAL.SpawnPrefab = function(...)
    local inst = old_SpawnPrefab(...)
    inst.Remove = inst.RemoveFromServer
    return inst
end

AddGlobalClassPostConstruct("entityscript", "EntityScript", function(es)
    if es.RemoveFromServer ~= nil then
        return
    end

    local old_Remove = es.Remove
    function es:Remove()
        if self.Network ~= nil and self.Network:GetNetworkID() ~= -1 then
            print(self)
            TheNet:Announce("本地和服务器实体不同步，该实体为：" .. tostring(self));
            GLOBAL.assert(nil, "侦测到您有一个模组存在写法不规范的问题，请您禁用！")
        end
        old_Remove(self)
    end

    es.RemoveFromServer = old_Remove
end)