---
--- @author zsh in 2023/2/13 9:51
---

local name = "mone_storage_bag";

local storage_bag_auto_open = TUNING.MONE_TUNING.GET_MOD_CONFIG_DATA.storage_bag_auto_open;

local fns = {};

function fns.ondropped(inst)
    if inst.components.container then
        inst.components.container:Close()
    end
end

function fns.onpickupfn(inst, pickupguy, src_pos)
    if inst.components.container then
        inst.components.container:Open(pickupguy);
    end
end

function fns.onopenfn(inst)
    inst.SoundEmitter:PlaySound("dontstarve/wilson/chest_open")
end

function fns.onclosefn(inst)
    inst.SoundEmitter:PlaySound("dontstarve/wilson/chest_close")
end

local assets = {
    Asset("ANIM", "anim/swap_thatchpack.zip"),
}

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()
    inst.entity:AddSoundEmitter()

    MakeInventoryPhysics(inst)

    inst.entity:AddMiniMapEntity()
    inst.MiniMapEntity:SetIcon("thatchpack.tex")

    MakeInventoryFloatable(inst, "med")

    inst.AnimState:SetBank("thatchpack")
    inst.AnimState:SetBuild("swap_thatchpack")
    inst.AnimState:PlayAnimation("anim")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        local old_OnEntityReplicated = inst.OnEntityReplicated
        inst.OnEntityReplicated = function(inst)
            if old_OnEntityReplicated then
                old_OnEntityReplicated(inst)
            end
            if inst.replica.container then
                inst.replica.container:WidgetSetup("mone_storage_bag");
            end
        end
        return inst
    end

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "thatchpack"
    inst.components.inventoryitem.atlasname = "images/DLC0002/inventoryimages.xml"
    inst.components.inventoryitem:SetOnDroppedFn(fns.ondropped)
    --inst.components.inventoryitem:SetOnPickupFn(fns.onpickupfn) -- 由于永久保鲜，所以不必自动打开了。
    if storage_bag_auto_open then
        inst.components.inventoryitem:SetOnPickupFn(fns.onpickupfn);
    end

    inst:AddComponent("container")
    inst.components.container:WidgetSetup("mone_storage_bag");
    inst.components.container.onopenfn = fns.onopenfn;
    inst.components.container.onclosefn = fns.onclosefn;
    inst.components.container.skipclosesnd = true;
    inst.components.container.skipopensnd = true;

    inst:AddComponent("preserver")
    inst.components.preserver:SetPerishRateMultiplier(0);

    -- TEST：就先留着吧！2023-02-15-00:38
    --[[    local old_GiveItem = inst.components.container.GiveItem;
        function inst.components.container:GiveItem(item, slot, src_pos, drop_on_fail)
            local owner = item and item.components.inventoryitem and item.components.inventoryitem.owner;
            print("owner: " .. tostring(owner));
            if owner or true then
                self.inst:PushEvent("mie_itemget", { item = item, src_pos = src_pos, owner = owner });
            end

            return old_GiveItem and old_GiveItem(self, item, slot, src_pos, drop_on_fail);
        end
        inst:ListenForEvent("itemget", function(inst, data)
            local slot = data and data.in_slot;
            local item = data and data.item;
            local src_pos = data and data.src_pos;
            if item then

            end
        end);
        inst:ListenForEvent("mie_itemget",function(inst,data)
            print("enter listen for event: mie_itemget");
            data = data and {};
            for k, v in pairs(data) do
                print(tostring(k),tostring(v));
            end
        end);]]

    MakeHauntableLaunch(inst)

    return inst
end

return Prefab(name, fn, assets);