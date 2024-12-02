---
--- @author zsh in 2023/1/10 19:44
---

local config_data = TUNING.MONE_TUNING.GET_MOD_CONFIG_DATA;
local new_anim = config_data.mone_seasack_new_anim;

local assets = {
    Asset("ANIM", "anim/swap_seasack.zip"),
}

if new_anim then
    assets = {
        Asset("ANIM", "anim/backpack.zip"),
        Asset("ANIM", "anim/swap_krampus_sack.zip"),
        Asset("ANIM", "anim/ui_krampusbag_2x5.zip"),
    }
end

local function onequip(inst, owner)
    owner.AnimState:OverrideSymbol("swap_body", "swap_seasack", "backpack")
    owner.AnimState:OverrideSymbol("swap_body", "swap_seasack", "swap_body")

    if inst.components.container then
        inst.components.container:Open(owner)
    end
end

if new_anim then
    onequip = function(inst, owner)
        local skin_build = inst:GetSkinBuild()
        if skin_build ~= nil then
            owner:PushEvent("equipskinneditem", inst:GetSkinName())
            owner.AnimState:OverrideItemSkinSymbol("backpack", skin_build, "backpack", inst.GUID, "swap_krampus_sack" )
            owner.AnimState:OverrideItemSkinSymbol("swap_body", skin_build, "swap_body", inst.GUID, "swap_krampus_sack" )
        else
            owner.AnimState:OverrideSymbol("backpack", "swap_krampus_sack", "backpack")
            owner.AnimState:OverrideSymbol("swap_body", "swap_krampus_sack", "swap_body")
        end

        if inst.components.container then
            inst.components.container:Open(owner)
        end
    end
end

local function onunequip(inst, owner)
    owner.AnimState:ClearOverrideSymbol("swap_body")
    owner.AnimState:ClearOverrideSymbol("backpack")

    if inst.components.container then
        inst.components.container:Close(owner)
    end
end

if new_anim then
    onunequip = function(inst, owner)
        local skin_build = inst:GetSkinBuild()
        if skin_build ~= nil then
            owner:PushEvent("unequipskinneditem", inst:GetSkinName())
        end
        owner.AnimState:ClearOverrideSymbol("swap_body")
        owner.AnimState:ClearOverrideSymbol("backpack")

        if inst.components.container then
            inst.components.container:Close(owner)
        end
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()

    MakeInventoryPhysics(inst)

    if new_anim then
        inst.MiniMapEntity:SetIcon("krampus_sack.png");
    else
        local minimap = inst.entity:AddMiniMapEntity()
        minimap:SetIcon("seasack.tex")
    end

    MakeInventoryFloatable(inst);


    if new_anim then
        inst.AnimState:SetBank("backpack1")
        inst.AnimState:SetBuild("swap_krampus_sack")
        inst.AnimState:PlayAnimation("anim")

        inst.foleysound = "dontstarve/movement/foley/krampuspack"
    else
        inst.AnimState:SetBank("seasack")
        inst.AnimState:SetBuild("swap_seasack")
        inst.AnimState:PlayAnimation("anim")
    end

    inst:AddTag("backpack")

    inst.entity:SetPristine()

    -- Question
    -- 总结：不知道究竟哪里的问题，我必须要添加这个内容才不会出错。哎，明明有些官方都没添加啊。
    -- 2023-03-20：班花指导了一下，因为官方不知道为什么，默认 预制物名 和 widgetsetup 要一致，否则客户端就要这样注册一下。
    if not TheWorld.ismastersim then
        local old_OnEntityReplicated = inst.OnEntityReplicated
        inst.OnEntityReplicated = function(inst)
            if old_OnEntityReplicated then
                old_OnEntityReplicated(inst)
            end
            if inst and inst.replica and inst.replica.container then
                inst.replica.container:WidgetSetup("mone_seasack");
            end
        end
        return inst;
    end

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.cangoincontainer = false
    if new_anim then
        --inst.components.inventoryitem.imagename = "krampus_sack";
        --inst.components.inventoryitem.atlasname = "images/DLC/inventoryimages1.xml";
        inst.components.inventoryitem:ChangeImageName("krampus_sack");
    else
        inst.components.inventoryitem.foleysound = "dontstarve/movement/foley/backpack"

        inst.components.inventoryitem.imagename = "seasack";
        inst.components.inventoryitem.atlasname = "images/DLC0003/inventoryimages.xml"
    end

    inst:AddComponent("equippable")
    inst.components.equippable.equipslot = EQUIPSLOTS.BODY
    inst.components.equippable:SetOnEquip(onequip)
    inst.components.equippable:SetOnUnequip(onunequip)
    inst.components.equippable.walkspeedmult = 1.1;

    --inst:AddTag("fridge")
    --inst:AddTag("nocool")

    inst:AddComponent("container")
    inst.components.container:WidgetSetup("mone_seasack");
    inst.components.container.skipclosesnd = true
    inst.components.container.skipopensnd = true

    -- icehat
    -- 添加个新鲜度
    --inst:AddTag("show_spoilage")
    --inst:AddComponent("perishable")
    --inst.components.perishable:SetPerishTime(TUNING.PERISH_FASTISH)
    --inst.components.perishable:StartPerishing()
    --inst.components.perishable:SetOnPerishFn(function(inst)
    --    local owner = inst.components.inventoryitem.owner
    --    if owner ~= nil then
    --        if owner.components.moisture ~= nil then
    --            owner.components.moisture:DoDelta(30)
    --        elseif owner.components.inventoryitem ~= nil then
    --            owner.components.inventoryitem:AddMoisture(50)
    --        end
    --
    --        if inst.components.container then
    --            inst.components.container:DropEverything();
    --        end
    --    end
    --    inst:Remove()--generic_perish(inst)
    --end)

    inst:AddComponent("insulator")
    inst.components.insulator:SetInsulation(TUNING.INSULATION_LARGE / 2)
    inst.components.insulator:SetSummer()

    --inst.mone_repair_materials = { kelp = 0.125 };
    --inst:AddTag("mone_can_be_repaired");

    --MakeSmallBurnable(inst)
    --MakeSmallPropagator(inst)
    --inst.components.burnable:SetOnBurntFn(function()
    --    if inst.inventoryitemdata then
    --        inst.inventoryitemdata = nil
    --    end
    --
    --    if inst.components.container then
    --        inst.components.container:DropEverything()
    --        inst.components.container:Close()
    --        inst:RemoveComponent("container")
    --    end
    --
    --    local ash = SpawnPrefab("ash")
    --    ash.Transform:SetPosition(inst.Transform:GetWorldPosition())
    --
    --    inst:Remove()
    --end)

    return inst
end

return Prefab("mone_seasack", fn, assets)