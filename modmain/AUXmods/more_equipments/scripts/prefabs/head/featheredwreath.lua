---
--- @author zsh in 2023/5/20 19:42
---

local name = "feathercrown"; -- 这里的名字是官方原版贴图的文件名的部分内容
local bank = name .. "hat";
local build = "hat_" .. name;

local prefab_name = "me_featheredwreath"; -- 这里的名字是我的物品名

local assets = { Asset("ANIM", "anim/" .. build .. ".zip") };

local onequipfn = ENV.HEAD.onequipfn({
    build = build;
    hidesymbols = nil; -- showsymbols = true;
}, function(inst, owner)
    owner:AddTag("me_featheredwreath_creature_friend");

    local attractor = owner.components.birdattractor
    if attractor then
        attractor.spawnmodifier:SetModifier(inst, TUNING.BIRD_SPAWN_MAXDELTA_FEATHERHAT, "maxbirds")
        attractor.spawnmodifier:SetModifier(inst, TUNING.BIRD_SPAWN_DELAYDELTA_FEATHERHAT.MIN, "mindelay")
        attractor.spawnmodifier:SetModifier(inst, TUNING.BIRD_SPAWN_DELAYDELTA_FEATHERHAT.MAX, "maxdelay")

        local birdspawner = TheWorld.components.birdspawner
        if birdspawner ~= nil then
            birdspawner:ToggleUpdate(true)
        end
    end
end);

local onunequipfn = ENV.HEAD.onunequipfn({
    hidesymbols = nil;
}, function(inst, owner)
    owner:RemoveTag("me_featheredwreath_creature_friend");

    local attractor = owner.components.birdattractor
    if attractor then
        attractor.spawnmodifier:RemoveModifier(inst)

        local birdspawner = TheWorld.components.birdspawner
        if birdspawner ~= nil then
            birdspawner:ToggleUpdate(true)
        end
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
    inst.components.equippable.walkspeedmult = 1.25;
    inst.components.equippable.dapperness = TUNING.DAPPERNESS_LARGE;

    inst:AddComponent("insulator")
    inst.components.insulator:SetInsulation(TUNING.INSULATION_MED)

    inst:AddComponent("fueled")
    inst.components.fueled.fueltype = FUELTYPE.USAGE
    inst.components.fueled:InitializeFuelLevel(TUNING.WALRUSHAT_PERISHTIME)
    inst.components.fueled:SetDepletedFn(inst.Remove)

    return inst;
end

return Prefab(prefab_name, fn, assets);

