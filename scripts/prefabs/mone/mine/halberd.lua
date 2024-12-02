---
--- @author zsh in 2023/1/12 23:33
---


local assets = {
    Asset("ANIM", "anim/halberd.zip"),
    Asset("ANIM", "anim/swap_halberd.zip"),
}

local function DoToolWork(act, workaction)
    if act.target.components.workable ~= nil and
            act.target.components.workable:CanBeWorked() and
            act.target.components.workable:GetWorkAction() == workaction then

        local numworks = ((act.invobject ~= nil and
                act.invobject.components.tool ~= nil and
                act.invobject.components.tool:GetEffectiveness(workaction)
        ) or
                (act.doer ~= nil and
                        act.doer.components.worker ~= nil and
                        act.doer.components.worker:GetEffectiveness(workaction)
                ) or
                1
        ) *
                (act.doer.components.workmultiplier ~= nil and
                        act.doer.components.workmultiplier:GetMultiplier(workaction) or
                        1
                )

        --local recoil
        --recoil, numworks = act.target.components.workable:ShouldRecoil(act.doer, act.invobject, numworks)
        --if recoil and act.doer.sg ~= nil and act.doer.sg.statemem.recoilstate ~= nil then
        --    act.doer.sg:GoToState(act.doer.sg.statemem.recoilstate, { target = act.target })
        --    if numworks == 0 then
        --        act.doer:PushEvent("tooltooweak", { workaction = workaction })
        --    end
        --end
        --if numworks == 0 then
        --    act.doer:PushEvent("tooltooweak", { workaction = workaction })
        --end
        --print("--3");
        numworks = 999; -- ... 加个这个吧，刚刚测试发现大力士（不止...）为什么没有把树根铲除啊...懒得管了。

        act.target.components.workable:WorkedBy(act.doer, numworks)
        return true
    end
    return false
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)
    MakeInventoryFloatable(inst);

    inst.AnimState:SetBank("halberd")
    inst.AnimState:SetBuild("halberd")
    inst.AnimState:PlayAnimation("idle")

    inst:AddTag("sharp")
    inst:AddTag("tool")
    inst:AddTag("weapon")
    inst:AddTag("hammer")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")

    inst:AddComponent("equippable")
    inst.components.equippable:SetOnEquip(function(inst, owner)
        owner.AnimState:OverrideSymbol("swap_object", "swap_halberd", "swap_halberd")
        owner.AnimState:Show("ARM_carry")
        owner.AnimState:Hide("ARM_normal")
    end)
    inst.components.equippable:SetOnUnequip(function(inst, owner)
        owner.AnimState:Hide("ARM_carry")
        owner.AnimState:Show("ARM_normal")
    end)

    inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(14)

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "halberd"
    inst.components.inventoryitem.atlasname = "images/DLC0003/inventoryimages.xml"

    inst:AddComponent("tool")
    inst.components.tool:SetAction(ACTIONS.CHOP, 1 * 2.5)
    inst.components.tool:SetAction(ACTIONS.MINE, 1 * 2.5)
    inst.components.tool:SetAction(ACTIONS.HAMMER, 1 * 2.5)
    --inst.components.tool:SetAction(ACTIONS.DIG, 1)

    inst:AddComponent("finiteuses")
    inst.components.finiteuses:SetMaxUses(1080) -- 720
    inst.components.finiteuses:SetUses(1080)
    inst.components.finiteuses:SetOnFinished(inst.Remove)

    inst.components.finiteuses:SetConsumption(ACTIONS.CHOP, 1)
    inst.components.finiteuses:SetConsumption(ACTIONS.MINE, 1)
    inst.components.finiteuses:SetConsumption(ACTIONS.HAMMER, 1)
    --inst.components.finiteuses:SetConsumption(ACTIONS.DIG, 0.6)

    -- 砍树的时候自动出树根
    local finiteuses = inst.components.finiteuses;
    local old_OnUsedAsItem = finiteuses.OnUsedAsItem;
    function finiteuses:OnUsedAsItem(action, doer, target, ...)
        old_OnUsedAsItem(self, action, doer, target, ...);
        --print("--1");
        --print("target:"..tostring(target));
        --print("doer:"..tostring(doer));
        self.inst:DoTaskInTime(0.3, function()
            if not (self.inst and self.inst.IsValid and self.inst:IsValid()) then
                return;
            end

            if target and target.IsValid and target:IsValid() and target:HasTag("stump")
                    and doer and doer.IsValid and doer:IsValid() and doer:HasTag("player")
            then
                --print("--2");
                DoToolWork({
                    target = target,
                    invobject = self.inst,
                    doer = doer
                }, ACTIONS.DIG)
            end
        end)
    end

    MakeHauntableLaunch(inst)
    return inst;
end

return Prefab("mone_halberd", fn, assets);