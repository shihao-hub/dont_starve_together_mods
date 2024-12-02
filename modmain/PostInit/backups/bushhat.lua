---
--- @author zsh in 2023/1/31 14:42
---


local function consume(owner, finiteuses_amount, sanity_amount)
    finiteuses_amount = finiteuses_amount or 10;
    sanity_amount = sanity_amount or 10;

    local bushhat = owner.mone_bushhat_prefab;

    if owner and bushhat then
        if bushhat.components.finiteuses and bushhat.components.finiteuses:GetPercent() > 0 then
            bushhat.components.finiteuses:Use(finiteuses_amount);

            if owner.components.sanity then
                owner.components.sanity:DoDelta(-sanity_amount);
            end
        end

    end
end

env.AddPrefabPostInitAny(function(inst)
    if not TheWorld.ismastersim then
        return inst;
    end

    if not inst.components.combat then
        return inst;
    end

    -- 直接这样
    -- FIXME:!!!!!!这种大范围修改物品内容的，要小心！居然有预制物中途移除了combat组件？？？
    -- FIXME:还是说其他原因？反正要小心了！！！
    inst:DoPeriodicTask(1, function(inst)
        if inst.components.combat then
            local target = inst.components.combat.target;
            --print(tostring(target));
            if target and target:HasTag("mone_notarget") then
                --print("√√√ 3: target:HasTag(\"mone_notarget\")");
                if inst.components.health then
                    local maxhealth = inst.components.health.maxhealth;
                    if maxhealth <= 100 then
                        consume(target, 1, 2);
                    elseif maxhealth <= 500 then
                        consume(target, 2, 4);
                    elseif maxhealth <= 1000 then
                        consume(target, 5, 10);
                    else
                        consume(target, 10, 20);
                    end
                end
                inst.components.combat:SetTarget(nil);
            end
        end
    end);

    do
        return inst;
    end

    -- 下面这部分掉入了一个误区。我总是想着尽可能少的修改原版内容，然后达到我的目标。。。这是个误区！！！
    local possibility = 0.5;

    if inst.components.combat.targetfn then
        print("[" .. tostring(inst.prefab) .. "]: targetfn √");
        -- 重新设置 target
        local old_TryRetarget = inst.components.combat.TryRetarget;
        inst.components.combat.TryRetarget = function(self)
            if old_TryRetarget then
                old_TryRetarget(self);
            end

            if self.targetfn ~= nil
                    and not (self.inst.components.health ~= nil and
                    self.inst.components.health:IsDead())
                    and not (self.inst.components.sleeper ~= nil and
                    self.inst.components.sleeper:IsInDeepSleep()) then

                if self.target and self.target:HasTag("mone_notarget") then
                    print("1: target:HasTag(\"mone_notarget\")");
                    consume(self.target);
                    self:SetTarget(nil);
                end
            end
        end
    else
        print("[" .. tostring(inst.prefab) .. "]: targetfn ×");
        if inst.components.combat.keeptargetfn then
            --print("[" .. tostring(inst.prefab) .. "]: keeptargetfn √");
            local old_keeptargetfn = inst.components.combat.keeptargetfn;
            inst.components.combat.keeptargetfn = function(inst, target)
                if target:HasTag("mone_notarget") then
                    print("2: target:HasTag(\"mone_notarget\")");
                    consume(target);
                    return false;
                end
                return old_keeptargetfn(inst, target);
            end
        else
            print("[" .. tostring(inst.prefab) .. "]: keeptargetfn ×");

            inst:DoPeriodicTask(3, function(inst)
                local target = inst.components.combat.target;
                if target and target:HasTag("mone_notarget") then
                    print("3: target:HasTag(\"mone_notarget\")");
                    consume(target);
                    inst.components.combat:SetTarget(nil);
                end
            end);

        end
    end
end)