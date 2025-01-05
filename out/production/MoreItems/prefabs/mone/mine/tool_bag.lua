---
--- @author zsh in 2023/3/6 23:37
---

local name = "mone_tool_bag";

local assets = {
    Asset("ANIM", "anim/swap_mandrake_backpack.zip"),
    Asset("IMAGE", "images/inventoryimages/mandrake_backpack.tex"),
    Asset("ATLAS", "images/inventoryimages/mandrake_backpack.xml"),
}

local function ondropped(inst)
    if inst.components.container then
        inst.components.container:Close()
    end
end

local function onpickupfn(inst, pickupguy, src_pos)
    if inst and inst.prefab and inst.components.container and pickupguy then
        inst.components.container:Open(pickupguy);
    end
end


local tool_bag_auto_open = TUNING.MONE_TUNING.GET_MOD_CONFIG_DATA.tool_bag_auto_open;

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.entity:AddMiniMapEntity()
    inst.MiniMapEntity:SetIcon("mandrake_backpack.tex")

    inst.AnimState:SetBank("swap_mandrake_backpack")
    inst.AnimState:SetBuild("swap_mandrake_backpack")
    inst.AnimState:PlayAnimation("anim")

    MakeInventoryFloatable(inst, "small");

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        local old_OnEntityReplicated = inst.OnEntityReplicated
        inst.OnEntityReplicated = function(inst)
            if old_OnEntityReplicated then
                old_OnEntityReplicated(inst)
            end
            if inst and inst.replica and inst.replica.container then
                inst.replica.container:WidgetSetup("mone_tool_bag");
            end
        end
        return inst
    end

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.canonlygoinpocket = false;
    inst.components.inventoryitem.imagename = "mandrake_backpack";
    inst.components.inventoryitem.atlasname = "images/inventoryimages/mandrake_backpack.xml";
    inst.components.inventoryitem:SetOnDroppedFn(ondropped);
    if tool_bag_auto_open then
        inst.components.inventoryitem:SetOnPickupFn(onpickupfn);
    end

    inst:AddComponent("container")
    inst.components.container:WidgetSetup("mone_tool_bag");
    inst.components.container.skipclosesnd = true
    inst.components.container.skipopensnd = true
    inst.components.container.onopenfn = function(inst)
        inst.SoundEmitter:PlaySound("dontstarve/wilson/chest_open")
    end
    inst.components.container.onclosefn = function(inst)
        inst.SoundEmitter:PlaySound("dontstarve/wilson/chest_close")
    end

    MakeHauntableLaunchAndDropFirstItem(inst)

    return inst
end

return Prefab(name, fn, assets)
