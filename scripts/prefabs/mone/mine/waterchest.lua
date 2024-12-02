---
--- @author zsh in 2023/1/17 21:07
---

--[[
    有人反馈身上有这个箱子就无法部署耕地机。。。这？我也没写什么东西啊。
]]

local name_structure = "mone_waterchest";
local name_inventoryitem = "mone_waterchest_inv";

local API = require("chang_mone.dsts.API");

local function ondropped(inst)
    if inst.components.container then
        inst.components.container:Close()
    end
end

--local function onbuilt(inst)
--    inst.AnimState:PlayAnimation("place")
--    inst.AnimState:PushAnimation("closed", true)
--    inst.SoundEmitter:PlaySound("dontstarve/common/craftable/chest")
--end

local function ondeploy(inst, pt, deployer)
    local chest = SpawnPrefab(name_structure);
    chest.Transform:SetPosition(pt:Get())

    chest.AnimState:PlayAnimation("place")
    chest.AnimState:PushAnimation("closed", true)
    --chest.SoundEmitter:PlaySound("dontstarve/common/craftable/chest")
    chest.SoundEmitter:PlaySound("dontstarve/common/dragonfly_chest_craft")

    API.transferContainerAllItems(inst, chest);
    inst:Remove()
end

local function onhammered(inst, worker)
    local item = inst.components.lootdropper:SpawnLootPrefab(name_inventoryitem);
    API.transferContainerAllItems(inst, item);

    item.AnimState:PlayAnimation("place")
    item.AnimState:PushAnimation("closed", true)
    item.SoundEmitter:PlaySound("dontstarve/common/dragonfly_chest_craft")

    inst:Remove()
end

local assets = {
    Asset("ANIM", "anim/water_chest.zip"),
    Asset("IMAGE", "images/inventoryimages/mone_wc_open.tex"),
    Asset("ATLAS", "images/inventoryimages/mone_wc_open.xml"),
    Asset("IMAGE", "images/inventoryimages/mone_wc_close.tex"),
    Asset("ATLAS", "images/inventoryimages/mone_wc_close.xml"),
}

local function commonfn()

    local inst = CreateEntity();

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()
    inst.entity:AddSoundEmitter()

    local minimap = inst.entity:AddMiniMapEntity()
    minimap:SetIcon("waterchest.tex")

    inst.AnimState:SetBank("water_chest")
    inst.AnimState:SetBuild("water_chest")
    inst.AnimState:PlayAnimation("closed", true)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        local old_OnEntityReplicated = inst.OnEntityReplicated

        inst.OnEntityReplicated = function(inst)

            if old_OnEntityReplicated then
                old_OnEntityReplicated(inst)
            end
            if inst.replica.container then
                inst.replica.container:WidgetSetup("mone_waterchest");
            end
        end
        return inst
    end

    inst.onhammered = onhammered;

    ----兼容智能小木牌
    --if TUNING.SMART_SIGN_DRAW_ENABLE then
    --    SMART_SIGN_DRAW(inst);
    --end

    inst:AddComponent("inspectable")

    inst:AddComponent("container")
    inst.components.container:WidgetSetup("mone_waterchest");
    inst.components.container.skipclosesnd = true;
    inst.components.container.skipopensnd = true;

    return inst;
end

local structure_scale = 1.5;
structure_scale = 1;

local function structure()
    local inst = commonfn();

    inst:AddTag("structure")
    inst:AddTag("chest")
    inst:AddTag("mone_waterchest_structure")

    local scale = structure_scale;
    inst.Transform:SetScale(scale, scale, scale);

    if not TheWorld.ismastersim then
        return inst
    end

    inst.components.container.onopenfn = function(inst)
        inst.AnimState:PlayAnimation("open")
        inst.AnimState:PushAnimation("opened", true)
        inst.SoundEmitter:PlaySound("dontstarve/wilson/chest_open")
    end
    inst.components.container.onclosefn = function(inst)
        inst.AnimState:PlayAnimation("close")
        inst.AnimState:PushAnimation("closed", true)
        inst.SoundEmitter:PlaySound("dontstarve/wilson/chest_close")
    end

    inst:AddComponent("lootdropper")
    inst:AddComponent("mone_waterchest_structure")
    --inst:AddComponent("workable")
    --inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    --inst.components.workable:SetWorkLeft(2)
    --inst.components.workable:SetOnFinishCallback(onhammered)
    ----inst.components.workable:SetOnWorkCallback(onhit)
    --
    --if inst.components.workable then
    --    local old_Destroy = inst.components.workable.Destroy
    --    function inst.components.workable:Destroy(destroyer)
    --        -- playercontroller: 玩家
    --        if destroyer.components.playercontroller == nil then
    --            return
    --        end
    --        return old_Destroy(self, destroyer)
    --    end
    --end

    --inst:ListenForEvent("onbuilt", onbuilt)
    MakeSnowCovered(inst, .01)

    return inst;
end

local function inventoryitem()

    local inst = commonfn();

    MakeInventoryPhysics(inst)

    if not TheWorld.ismastersim then
        return inst
    end

    inst.components.container.onopenfn = function(inst)
        inst.AnimState:PlayAnimation("open")
        inst.AnimState:PushAnimation("opened", true)
        inst.SoundEmitter:PlaySound("dontstarve/wilson/chest_open")

        if inst.components.inventoryitem then
            inst.components.inventoryitem.atlasname = "images/inventoryimages/mone_wc_open.xml"
            inst.components.inventoryitem:ChangeImageName("mone_wc_open")
        end
    end
    inst.components.container.onclosefn = function(inst)
        inst.AnimState:PlayAnimation("close")
        inst.AnimState:PushAnimation("closed", true)
        inst.SoundEmitter:PlaySound("dontstarve/wilson/chest_close")

        if inst.components.inventoryitem then
            inst.components.inventoryitem.atlasname = "images/inventoryimages/mone_wc_close.xml"
            inst.components.inventoryitem:ChangeImageName("mone_wc_close")
        end
    end

    inst:AddComponent("inventoryitem")
    --inst.components.inventoryitem.canonlygoinpocket = true;
    inst.components.inventoryitem.atlasname = "images/inventoryimages/mone_wc_close.xml"
    inst.components.inventoryitem:ChangeImageName("mone_wc_close")

    inst.components.inventoryitem:SetOnDroppedFn(ondropped)

    inst:AddComponent("deployable")
    inst.components.deployable.ondeploy = ondeploy
    inst.components.deployable:SetDeploySpacing(DEPLOYSPACING.DEFAULT)

    MakeHauntableLaunch(inst)

    return inst;
end

return Prefab(name_structure, structure, assets), Prefab(name_inventoryitem, inventoryitem, assets),
MakePlacer(name_inventoryitem .. "_placer", "water_chest", "water_chest", "closed", nil, nil, nil, nil);
