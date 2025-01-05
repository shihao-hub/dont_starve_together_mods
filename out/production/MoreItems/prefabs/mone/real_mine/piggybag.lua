---
--- @author zsh in 2023/1/16 20:43
---

local internal = {}

function internal.if_present(value, consumer_action)
    if value ~= nil then
        consumer_action(value)
    end
end

function internal.if_present_or_else(value, consumer_action, empty_action)
    if value ~= nil then
        consumer_action(value)
    else
        empty_action()
    end
end

------------------------------------------------------------------------------------------------------------------------
local change_image_enable = true

local assets

if change_image_enable then
    assets = {
        Asset("ANIM", "anim/piggyback.zip"),
        Asset("ANIM", "anim/swap_piggyback.zip"),
        Asset("ANIM", "anim/ui_piggyback_2x6.zip"),
    }
else
    assets = {
        Asset("ANIM", "anim/mone_piggybag.zip"),
        Asset("IMAGE", "images/inventoryimages/mone_piggybag.tex"),
        Asset("ATLAS", "images/inventoryimages/mone_piggybag.xml")
    }
end

local tool_bag_auto_open = TUNING.MONE_TUNING.GET_MOD_CONFIG_DATA.tool_bag_auto_open;
local storage_bag_auto_open = TUNING.MONE_TUNING.GET_MOD_CONFIG_DATA.storage_bag_auto_open;

local function auto(inst, pickupguy)
    if inst.components.container and pickupguy then
        local numslots = inst.components.container:GetNumSlots();
        local find_backpack = false;
        local find_storage = true; -- 取消，不需要自动打开功能了！
        --local find_piggyback = false;
        local find_wanda_box = false;
        local find_candybag = false;
        local find_tool_bag = false;
        local find_storage_bag = false;
        for i = 1, numslots do
            local item = inst.components.container:GetItemInSlot(i)
            if not find_backpack and item and item.prefab == "mone_backpack" and item.components.container then
                find_backpack = true;
                item.components.container:Open(pickupguy);
            end
            if not find_storage and item and item.prefab == "mone_storage_bag" and item.components.container then
                find_storage = true;
                item.components.container:Open(pickupguy);
            end
            if not find_candybag and item and item.prefab == "mone_candybag" and item.components.container then
                find_candybag = true;
                item.components.container:Open(pickupguy);
            end
            if tool_bag_auto_open and not find_tool_bag and item and item.prefab == "mone_tool_bag" and item.components.container then
                find_tool_bag = true;
                item.components.container:Open(pickupguy);
            end
            if storage_bag_auto_open and not find_storage_bag and item and item.prefab == "mone_storage_bag" and item.components.container then
                find_storage_bag = true;
                item.components.container:Open(pickupguy);
            end
            -- 太大了，没必要自动打开。
            --if not find_piggyback and item and item.prefab == "mone_piggyback" and item.components.container then
            --    find_piggyback = true;
            --    item.components.container:Open(pickupguy);
            --end
            -- 只允许放在身上
            --if not find_wanda_box and item and item.prefab == "mone_wanda_box" and item.components.container then
            --    find_wanda_box = true;
            --    item.components.container:Open(pickupguy);
            --end
        end
    end
end

local function onpickupfn(inst, pickupguy, src_pos)
    --重载游戏时，会执行该函数（注意，这个前提是我必须限制只能带在身上！因为在口袋里才会执行！）
    if inst.components.container then
        inst.components.container:Open(pickupguy);
        -- 由于重载游戏时，会执行一下此处的函数。所以遍历一下，打开第一个找到的某些指定容器
        auto(inst, pickupguy);
    end
end

local function ondroppedfn(inst)
    if inst.components.container then
        inst.components.container:Close()
    end
    -- chang
    if inst.components.container then
        local old_slots = inst.components.container.slots
        for _, v in pairs(old_slots) do
            if v.components.container and v.components.container:IsOpen() then
                v.components.container:Close()
            end
        end
    end
end

local function onopenfn(inst, data)
    inst.SoundEmitter:PlaySound("dontstarve/wilson/chest_open")

    auto(inst, data and data.doer);
end

local function onclosefn(inst, data)
    inst.SoundEmitter:PlaySound("dontstarve/wilson/chest_close")
    -- chang
    if inst.components.container then
        local old_slots = inst.components.container.slots
        for _, v in pairs(old_slots) do
            if v.components.container and v.components.container:IsOpen() then
                v.components.container:Close()
            end
        end
    end
end

local function tool_bag_auto_open__onitemget(inst, data)
    local item = data and data.item;
    if item and item.prefab == "mone_tool_bag" then
        if not item.components.container:IsOpen() then
            local owner = inst.components.inventoryitem:GetGrandOwner();
            if owner and owner:HasTag("player") then
                item.components.container:Open(owner);
            end
        end
    end
end

local function storage_bag_auto_open__onitemget(inst, data)
    local item = data and data.item;
    if item and item.prefab == "mone_storage_bag" then
        if not item.components.container:IsOpen() then
            local owner = inst.components.inventoryitem:GetGrandOwner();
            if owner and owner:HasTag("player") then
                item.components.container:Open(owner);
            end
        end
    end
end

local function SetEntityReplicated(inst, widgetsetup_params)
    local old_OnEntityReplicated = inst.OnEntityReplicated

    inst.OnEntityReplicated = function(inst)
        if old_OnEntityReplicated then
            old_OnEntityReplicated(inst)
        end
        if inst and inst.replica and inst.replica.container then
            inst.replica.container:WidgetSetup(widgetsetup_params[1])
        end
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    if change_image_enable then
        inst.AnimState:SetBank("piggyback")
        inst.AnimState:SetBuild("swap_piggyback")
        inst.AnimState:PlayAnimation("anim")

        inst.MiniMapEntity:SetIcon("piggyback.png")
    else
        inst.AnimState:SetBank("mone_piggybag")
        inst.AnimState:SetBuild("mone_piggybag")
        inst.AnimState:PlayAnimation("idle")

        inst.MiniMapEntity:SetIcon("mone_piggybag.tex")
    end

    inst:AddTag("nosteal")

    MakeInventoryFloatable(inst)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        SetEntityReplicated(inst, { "mone_piggybag" })
        return inst
    end

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")

    if change_image_enable then
        inst.components.inventoryitem:ChangeImageName("piggyback")
    else
        inst.components.inventoryitem.imagename = "mone_piggybag"
        inst.components.inventoryitem.atlasname = "images/inventoryimages/mone_piggybag.xml"
    end

    inst.components.inventoryitem.canonlygoinpocket = true
    inst.components.inventoryitem:SetOnPickupFn(onpickupfn)
    inst.components.inventoryitem:SetOnDroppedFn(ondroppedfn)

    inst:AddComponent("container")
    inst.components.container:WidgetSetup("mone_piggybag")
    inst.components.container.onopenfn = onopenfn
    inst.components.container.onclosefn = onclosefn
    inst.components.container.skipclosesnd = true;
    inst.components.container.skipopensnd = true;

    -- 呃，就用这种方法解决吧...
    if tool_bag_auto_open then
        inst:ListenForEvent("itemget", tool_bag_auto_open__onitemget)
    end

    if storage_bag_auto_open then
        inst:ListenForEvent("itemget", storage_bag_auto_open__onitemget)
    end

    MakeHauntableLaunchAndDropFirstItem(inst)

    return inst
end

return Prefab("mone_piggybag", fn, assets)
