---
--- @author zsh in 2023/4/26 22:31
---

local fns = {};

function fns.onopenfn(inst)
    inst.SoundEmitter:PlaySound("dontstarve/wilson/chest_open")
end

function fns.onclosefn(inst)
    inst.SoundEmitter:PlaySound("dontstarve/wilson/chest_close")
end


env.AddPrefabPostInit("mone_moondial", function(inst)
    if not TheWorld.ismastersim then
        local old_OnEntityReplicated = inst.OnEntityReplicated
        inst.OnEntityReplicated = function(inst)
            if old_OnEntityReplicated then
                old_OnEntityReplicated(inst)
            end
            if inst.replica.container then
                inst.replica.container:WidgetSetup("mone_moondial");
            end
        end
        return inst;
    end

    inst:AddComponent("container");
    inst.components.container:WidgetSetup("mone_moondial");
    inst.components.container.onopenfn = fns.onopenfn;
    inst.components.container.onclosefn = fns.onclosefn;
    inst.components.container.skipclosesnd = true;
    inst.components.container.skipopensnd = true;

end)