---
--- @author zsh in 2023/1/20 20:11
---


local name = "mone_wathgrithr_box";

local assets = {
    Asset("ANIM", "anim/wathgrithr_box.zip"),
    Asset("IMAGE", "images/inventoryimages/mone_wathgrithr_box.tex"),
    Asset("ATLAS", "images/inventoryimages/mone_wathgrithr_box.xml"),
};

local function ondropped(inst)
    if inst.components.container then
        inst.components.container:Close()
    end
end

local function onpickupfn(inst, pickupguy, src_pos)
    --重载游戏时，会执行该函数
    if not (inst and inst.prefab and inst.components.container and pickupguy) then
        return
    end
    inst.components.container:Open(pickupguy)
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.MiniMapEntity:SetIcon("mone_wathgrithr_box.tex")

    inst.AnimState:SetBank("wathgrithr_box") -- 动画问题。。导致飘逸现象等等。
    inst.AnimState:SetBuild("wathgrithr_box")
    inst.AnimState:PlayAnimation("idle")


    MakeInventoryFloatable(inst);

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        local old_OnEntityReplicated = inst.OnEntityReplicated
        inst.OnEntityReplicated = function(inst)
            if old_OnEntityReplicated then
                old_OnEntityReplicated(inst)
            end
            if inst and inst.replica and inst.replica.container then
                inst.replica.container:WidgetSetup("mone_wathgrithr_box");
            end
        end
        return inst
    end

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "mone_wathgrithr_box"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/mone_wathgrithr_box.xml"
    inst.components.inventoryitem:SetOnDroppedFn(ondropped);
    --inst.components.inventoryitem:SetOnPickupFn(onpickupfn); -- 没必要！

    inst:AddComponent("container")
    inst.components.container:WidgetSetup("mone_wathgrithr_box");
    inst.components.container.onopenfn = function(inst)
        inst.SoundEmitter:PlaySound("dontstarve/wilson/chest_open")
    end
    inst.components.container.onclosefn = function(inst)
        inst.SoundEmitter:PlaySound("dontstarve/wilson/chest_close")
    end

    MakeHauntableLaunch(inst);
    return inst;
end

return Prefab(name, fn, assets);