---
--- @author zsh in 2023/1/14 1:05
---


do
    -- 写到源码里了！感觉 WidgetSetup("xxx") 然后再 WidgetSetup("xxx")
    -- 永不妥协的龙鳞宝箱那里应该干了什么事情，导致这样覆盖不正常。
    return;
end

env.AddPrefabPostInit("mone_treasurechest", function(inst)
    if not TheWorld.ismastersim then
        local old_OnEntityReplicated = inst.OnEntityReplicated
        inst.OnEntityReplicated = function(inst)
            if old_OnEntityReplicated then
                old_OnEntityReplicated(inst)
            end
            if inst and inst.replica and inst.replica.container then
                inst.replica.container:WidgetSetup("mone_treasurechest");
            end
        end
        return inst;
    end

    if inst.components.container then
        inst.components.container:WidgetSetup("mone_treasurechest");
    end
end)

env.AddPrefabPostInit("mone_dragonflychest", function(inst)
    if not TheWorld.ismastersim then
        local old_OnEntityReplicated = inst.OnEntityReplicated
        inst.OnEntityReplicated = function(inst)
            if old_OnEntityReplicated then
                old_OnEntityReplicated(inst)
            end
            if inst and inst.replica and inst.replica.container then
                inst.replica.container:WidgetSetup("mone_dragonflychest");
            end
        end
        return inst;
    end

    if inst.components.container then
        inst.components.container:WidgetSetup("mone_dragonflychest");
    end
end)