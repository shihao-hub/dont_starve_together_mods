local assets = {
    Asset("ANIM", "anim/walking_stick.zip"),
    Asset("ANIM", "anim/swap_walking_stick.zip"),
}

local function onequip(inst, owner)
    owner.AnimState:OverrideSymbol("swap_object", "swap_walking_stick", "swap_object")

    owner.AnimState:Show("ARM_carry")
    owner.AnimState:Hide("ARM_normal")

    if inst.components.fueled ~= nil then
        inst.components.fueled:StartConsuming()
    end
end

local function onunequip(inst, owner)
    owner.AnimState:Hide("ARM_carry")
    owner.AnimState:Show("ARM_normal")

    if inst.components.fueled ~= nil then
        inst.components.fueled:StopConsuming()
    end
end

local function onfuelchange(newsection, oldsection, inst)
    if newsection <= 0 then
        --local equippable = inst.components.equippable
        --if equippable ~= nil and equippable:IsEquipped() then
        --    local owner = inst.components.inventoryitem ~= nil and inst.components.inventoryitem.owner or nil
        --    if owner ~= nil then
        --        local data =
        --        {
        --            prefab = inst.prefab,
        --            equipslot = equippable.equipslot,
        --            announce = "ANNOUNCE_TORCH_OUT",
        --        }
        --        inst:Remove()
        --        owner:PushEvent("itemranout", data)
        --        return
        --    end
        --end
        inst:Remove()
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("mone_cane")
    inst.AnimState:SetBuild("walking_stick")
    inst.AnimState:PlayAnimation("idle")

    --weapon (from weapon component) added to pristine state for optimization
    inst:AddTag("weapon")

    --local swap_data = { sym_build = "walking_stick"} --, anim = "idle_water" }
    --MakeInventoryFloatable(inst, "med", 0.05, { 0.85, 0.45, 0.85 }, true, 1, swap_data)
    MakeInventoryFloatable(inst)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(TUNING.CANE_DAMAGE)

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "walkingstick";
    inst.components.inventoryitem.atlasname = "images/DLC0003/inventoryimages_2.xml"

    inst:AddComponent("equippable")
    inst.components.equippable:SetOnEquip(onequip)
    inst.components.equippable:SetOnUnequip(onunequip)
    inst.components.equippable.walkspeedmult = 1.6

    inst:AddComponent("fueled")
    inst.components.fueled:SetSectionCallback(onfuelchange)
    inst.components.fueled:InitializeFuelLevel(TUNING.TORCH_FUEL * 3)
    inst.components.fueled:SetDepletedFn(inst.Remove)
    --inst.components.fueled:SetFirstPeriod(TUNING.TURNON_FUELED_CONSUMPTION, TUNING.TURNON_FULL_FUELED_CONSUMPTION)

    MakeHauntableLaunch(inst)

    return inst
end

return Prefab("mone_walking_stick", fn, assets)
