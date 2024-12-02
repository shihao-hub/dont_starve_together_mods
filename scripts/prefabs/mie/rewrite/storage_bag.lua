---
--- @author zsh in 2023/2/13 9:51
---

local name = "mone_storage_bag";

local containers = require "containers";
local params = containers.params;

local function isIcebox(container, item, slot)
    if item:HasTag("icebox_valid") then
        return true
    end

    --Perishable
    if not (item:HasTag("fresh") or item:HasTag("stale") or item:HasTag("spoiled")) then
        return false
    end

    if item:HasTag("smallcreature") then
        return false
    end

    --Edible
    for k, v in pairs(FOODTYPE) do
        if item:HasTag("edible_" .. v) then
            return true
        end
    end

    return false
end

local function isSaltbox(container, item, slot)
    return ((item:HasTag("fresh") or item:HasTag("stale") or item:HasTag("spoiled"))
            and item:HasTag("cookable")
            and not item:HasTag("deployable")
            and not item:HasTag("smallcreature")
            and item.replica.health == nil)
            or item:HasTag("saltbox_valid")
end

--[[params.mone_storage_bag = {
    widget = {
        slotpos = {},
        animbank = "ui_tacklecontainer_3x2",
        animbuild = "ui_tacklecontainer_3x2",
        pos = Vector3(0, 200, 0),
        side_align_tip = 160
    },
    type = "chest",
    itemtestfn = function(container, item, slot)
        if item.prefab == "heatrock" then
            return false;
        end
        return isIcebox(container, item, slot) or isSaltbox(container, item, slot);
    end
}

for y = 1, 0, -1 do
    for x = 0, 2 do
        table.insert(params.mone_storage_bag.widget.slotpos, Vector3(80 * x - 80 * 2 + 80, 80 * y - 80 * 2 + 120, 0))
    end
end]]

--[[params.mone_storage_bag = {
    widget = {
        slotpos = {
            Vector3(0, 64 + 8, 0),
            Vector3(0, 0, 0),
            Vector3(0, -(64 + 8), 0),
        },
        animbank = "quagmire_ui_pot_1x3",
        animbuild = "quagmire_ui_pot_1x3",
        pos = Vector3(200, 0, 0),
        side_align_tip = 100,
    },
    type = "chest",
    itemtestfn = function(container, item, slot)
        if item.prefab == "heatrock" then
            return false;
        end
        return isIcebox(container, item, slot) or isSaltbox(container, item, slot);
    end
}]]

--[[params.mone_storage_bag = {
    widget = {
        slotpos = {
            Vector3(0, 64 + 32 + 8 + 4, 0),
            Vector3(0, 32 + 4, 0),
            Vector3(0, -(32 + 4), 0),
            Vector3(0, -(64 + 32 + 8 + 4), 0),
        },
        animbank = "ui_lamp_1x4",
        animbuild = "ui_lamp_1x4",
        --pos = Vector3(200 - 350, 0, 0),
        --side_align_tip = 100,
        --pos = Vector3(275 + 100 + 150 + 150 + 5 + 2 - 30 + 35 + 2 - 200 + 10 + 2, -60 - 10 + 3 + 3 - 5 - 2 + 2 + 2 + 1, 0),
        pos = Vector3(0, 0, 0),
        side_align_tip = 160,
    },
    type = "chest",
    itemtestfn = function(container, item, slot)
        if item.prefab == "heatrock" then
            return false;
        end
        return isIcebox(container, item, slot) or isSaltbox(container, item, slot);
    end
}]]

--[[if params.mone_storage_bag then
    -- 算了，我抽空解决一下，让 shift+左键 优先进入锅而不是我的保鲜袋吧！ 已解决。
    --if not TUNING.MIE_TUNING.MOD_CONFIG_DATA.storage_bag_chest_open_simultaneously then
    --    params.mone_storage_bag.widget.pos = Vector3(0, 150, 0);
    --    params.mone_storage_bag.widget.pos = Vector3(0 + 600 - 250 + 50, 150 - 450 + 10 + 30, 0);
    --    params.mone_storage_bag.type = "chest";
    --end
end]]

--for _, v in pairs(params) do
--    containers.MAXITEMSLOTS = math.max(containers.MAXITEMSLOTS, v.widget.slotpos ~= nil and #v.widget.slotpos or 0)
--end

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
    inst.components.inventoryitem:SetOnPickupFn(fns.onpickupfn)

    inst:AddComponent("container")
    inst.components.container:WidgetSetup("mone_storage_bag");
    inst.components.container.onopenfn = fns.onopenfn;
    inst.components.container.onclosefn = fns.onclosefn;

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