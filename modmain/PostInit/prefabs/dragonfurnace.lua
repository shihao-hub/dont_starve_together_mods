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

HookComponent("cooker", function(self)

end)

env.AddPrefabPostInit("mone_dragonflyfurnace", function(inst)
    if not TheWorld.ismastersim then
        local old_OnEntityReplicated = inst.OnEntityReplicated
        inst.OnEntityReplicated = function(inst)
            if old_OnEntityReplicated then
                old_OnEntityReplicated(inst)
            end
            if inst.replica.container then
                inst.replica.container:WidgetSetup("mone_dragonflyfurnace");
            end
        end
        return inst;
    end

    if NULL(inst.components.cooker) then
        return inst;
    end

    SimulatedHookComponent("cooker", inst, function(self, inst)

    end)

    inst:AddComponent("container");
    inst.components.container:WidgetSetup("mone_dragonflyfurnace");
    inst.components.container.onopenfn = fns.onopenfn;
    inst.components.container.onclosefn = fns.onclosefn;
    inst.components.container.skipclosesnd = true;
    inst.components.container.skipopensnd = true;

end)

-- 成组烹饪
if ACTIONS and ACTIONS.COOK and ACTIONS.COOK.fn and false --[[鸡肋功能，暂时舍弃]] then
    local old_fn = ACTIONS.COOK.fn;
    ACTIONS.COOK.fn = function(act, ...)
        local args = { ... }; -- ... 无法传入闭包
        if act.target and act.target:IsValid() and act.target.prefab == "mone_dragonflyfurnace"
                and act.invobject and act.invobject:IsValid()
                and act.doer and act.doer:IsValid() and act.doer.components.inventory then
            local count = act.invobject.components.stackable and act.invobject.components.stackable:StackSize() or 1;

            local res = {};

            if old_fn then
                res = { old_fn(act, ...) };
            end

            StartThread(function()
                while count > 1 do
                    count = count - 1;
                    Sleep((0.1) * 0.001);
                    if act.invobject ~= act.doer.components.inventory:GetActiveItem() then
                        break;
                    end
                    if old_fn and act.invobject and act.invobject:IsValid() then
                        old_fn(act, unpack(args, 1, table.maxn(args)));
                    end
                end
            end, tostring({}));

            return unpack(res, 1, table.maxn(res));
        else
            if old_fn then
                return old_fn(act, ...);
            end
        end
    end
end