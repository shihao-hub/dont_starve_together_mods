---
--- @author zsh in 2023/5/20 19:42
---

local name = "recharger"; -- 这里的名字是官方原版贴图的文件名的部分内容
local bank = name .. "hat";
local build = "hat_" .. name;

local prefab_name = "me_crystaltiara"; -- 这里的名字是我的物品名

local assets = { Asset("ANIM", "anim/" .. build .. ".zip") };

local onequipfn = ENV.HEAD.onequipfn({
    build = build;
    hidesymbols = nil; -- showsymbols = true;
}, function(inst, owner)
    inst:ListenForEvent("onattackother", inst._onattackother, owner);
    if owner.components.combat then
        owner.components.combat.externaldamagemultipliers:SetModifier(prefab_name .. "_ak", 1.1)
    end
end);

local onunequipfn = ENV.HEAD.onunequipfn({
    hidesymbols = nil;
}, function(inst, owner)
    inst:RemoveEventCallback("onattackother", inst._onattackother, owner);
    if owner.components.combat then
        owner.components.combat.externaldamagemultipliers:RemoveModifier(prefab_name .. "_ak")
    end
end);

local function OnAttackOther(owner, data, inst)
    local target = data and data.target;
    if target ~= nil and target:IsValid() then
        if target.components.sleeper ~= nil and target.components.sleeper:IsAsleep() then
            target.components.sleeper:WakeUp()
        end

        if target.components.burnable ~= nil then
            if target.components.burnable:IsBurning() then
                target.components.burnable:Extinguish()
            elseif target.components.burnable:IsSmoldering() then
                target.components.burnable:SmotherSmolder()
            end
        end
        if target.components.freezable ~= nil then
            print("目标施加冰冻效果：" .. tostring(target));

            local success = 0;
            if target.components.freezable:IsFrozen() then
                success = 1;
            end

            target.components.freezable:AddColdness(2);

            if success == 0 and target.components.freezable:IsFrozen() then
                success = 2;
            end
            if success == 2 then
                --target.components.freezable:SpawnShatterFX();
            end
        end
    end
end

local function fn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank(bank)
    inst.AnimState:SetBuild(build)
    inst.AnimState:PlayAnimation("anim")

    inst:AddTag("hat")
    inst:AddTag(prefab_name);

    MakeInventoryFloatable(inst)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst;
    end

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "lavaarena_" .. name .. "hat";
    inst.components.inventoryitem.atalsname = "images/inventoryimages.xml";

    inst:AddComponent("equippable")
    inst.components.equippable.equipslot = EQUIPSLOTS.HEAD;
    inst.components.equippable:SetOnEquip(onequipfn);
    inst.components.equippable:SetOnUnequip(onunequipfn);
    inst.components.equippable.dapperness = TUNING.DAPPERNESS_LARGE;

    inst._onattackother = function(owner, data)
        OnAttackOther(owner, data, inst);
    end

    return inst;
end

return Prefab(prefab_name, fn, assets);