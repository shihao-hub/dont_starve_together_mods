---
--- @author zsh in 2023/5/20 19:42
---


local name = "eyecirclet"; -- 这里的名字是官方原版贴图的文件名的部分内容
local bank = name .. "hat";
local build = "hat_" .. name;

local prefab_name = "me_clairvoyantcrown"; -- 这里的名字是我的物品名

local assets = { Asset("ANIM", "anim/" .. build .. ".zip") };

local MAX_HEALTH_PERCENT = 0.6;

local function healowner1(inst, owner)
    if owner.deathcause then
        return ;
    end
    if owner.components.health and owner.components.health:IsHurt()
            and owner.components.health:GetPercent() < MAX_HEALTH_PERCENT
            and not owner.components.oldager then
        owner.components.health:DoDelta(3, false, prefab_name)
    end
end

local function healowner2(inst, owner)
    if owner.deathcause then
        return ;
    end
    if owner.components.health and owner.components.health:IsHurt()
            and owner.components.health:GetPercent() >= MAX_HEALTH_PERCENT
            and not owner.components.oldager then
        owner.components.health:DoDelta(1, false, prefab_name)
    end
end

-- TODO LIST: 效果对旺达也生效

local onequipfn = ENV.HEAD.onequipfn({
    build = build;
    hidesymbols = nil;
}, function(inst, owner)
    if inst.heal_task1 ~= nil then
        inst.heal_task1:Cancel()
        inst.heal_task1 = nil
    end
    if inst.heal_task2 ~= nil then
        inst.heal_task2:Cancel()
        inst.heal_task2 = nil
    end
    inst.heal_task1 = inst:DoPeriodicTask(1, healowner1, nil, owner)
    inst.heal_task2 = inst:DoPeriodicTask(6, healowner2, nil, owner)
end);

local onunequipfn = ENV.HEAD.onunequipfn({
    hidesymbols = nil;
}, function(inst, owner)
    if inst.heal_task1 ~= nil then
        inst.heal_task1:Cancel()
        inst.heal_task1 = nil
    end
    if inst.heal_task2 ~= nil then
        inst.heal_task2:Cancel()
        inst.heal_task2 = nil
    end
end);

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
    inst.components.equippable:SetOnEquip(onequipfn)
    inst.components.equippable:SetOnUnequip(onunequipfn)
    inst.components.equippable.walkspeedmult = 1.1;

    return inst;
end

return Prefab(prefab_name, fn, assets);