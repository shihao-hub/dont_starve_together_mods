---
--- @author zsh in 2023/5/20 19:42
---


local name = "healinggarland"; -- 这里的名字是官方原版贴图的文件名的部分内容
local bank = name .. "hat";
local build = "hat_" .. name;

local prefab_name = "me_blossomedwreath"; -- 这里的名字是我的物品名

local assets = { Asset("ANIM", "anim/" .. build .. ".zip") };

-- 呃...
---- 1. 佩戴后，光环失效
---- 2. 卸下后，即使修改了值，show me 显示却没有变化


local onequipfn = ENV.HEAD.onequipfn({
    build = build;
    hidesymbols = nil;
}, function(inst, owner)
    if inst.components.sanityaura then
        inst.components.sanityaura.aura = 60 / 60;
    end
end);

local onunequipfn = ENV.HEAD.onunequipfn({
    hidesymbols = nil;
}, function(inst, owner)
    if inst.components.sanityaura then
        inst.components.sanityaura.aura = 0;
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

    inst:AddComponent("sanityaura")
    inst.components.sanityaura.aura = 0;

    return inst;
end

return Prefab(prefab_name, fn, assets);