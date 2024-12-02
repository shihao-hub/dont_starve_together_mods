---
--- @author zsh in 2023/2/10 12:30
---

-- 避免换皮报错，换皮肤的函数里面涉及了这个函数。2023-02-10-14:38：先算了，有点麻烦。先不换皮了。
local function UpdateInventoryImage(inst)
    local suffix = inst.suffix or "_small"
    if variations ~= nil then
        if inst.variation == nil then
            inst.variation = math.random(variations)
        end
        suffix = suffix .. tostring(inst.variation)

        local skin_name = inst:GetSkinName()
        if skin_name ~= nil then
            inst.components.inventoryitem:ChangeImageName(skin_name .. (onesize and tostring(inst.variation) or suffix))
        else
            inst.components.inventoryitem:ChangeImageName(name .. (onesize and tostring(inst.variation) or suffix))
        end
    elseif not onesize then
        local skin_name = inst:GetSkinName()
        if skin_name ~= nil then
            inst.components.inventoryitem:ChangeImageName(skin_name .. suffix)
        else
            inst.components.inventoryitem:ChangeImageName(name .. suffix)
        end
    end
end

local function state1()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst.entity:AddMiniMapEntity();
    inst.MiniMapEntity:SetIcon("bundlewrap.tex");

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("bundle")
    inst.AnimState:SetBuild("bundle")
    inst.AnimState:PlayAnimation("idle")

    inst:AddTag("mie_bundle_state1");

    --inst:AddTag("irreplaceable")
    --inst:AddTag("nonpotatable")

    MakeInventoryFloatable(inst, "med")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "bundlewrap"
    inst.components.inventoryitem.atlasname = "images/inventoryimages.xml"

    inst:AddComponent("mie_bundle_action")

    return inst
end

local function ondeployfn(inst, pt, deployer)
    inst.components.mie_bundle:Deploy(pt);
    if deployer and deployer.components.inventory then
        deployer.components.inventory:GiveItem(SpawnPrefab("mie_bundle_state1", inst.linked_skinname, inst.skin_id));
    end
    inst:Remove()
end

local function state2()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst.entity:AddMiniMapEntity();
    inst.MiniMapEntity:SetIcon("bundle_large.tex");

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("bundle")
    inst.AnimState:SetBuild("bundle")
    inst.AnimState:PlayAnimation("idle_large")

    inst:AddTag("mie_bundle_state2");

    -- 不允许带下线、不允许打包
    if TUNING.MIE_TUNING.MOD_CONFIG_DATA.bundle_irreplaceable then
        inst:AddTag("irreplaceable")
    end
    inst:AddTag("nonpotatable")
    inst:AddTag("bundle")
    inst:AddTag("nobundling")

    MakeInventoryFloatable(inst, "med")

    -- 主客机交互
    inst._name = net_string(inst.GUID, "mie_bundle_state2._name")
    inst.displaynamefn = function(inst)
        if #inst._name:value() > 0 then
            return "被打包的 " .. inst._name:value();
        else
            return "未知打包物";
        end
    end

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem:ChangeImageName("bundle_large")

    inst:AddComponent("deployable")
    inst.components.deployable.ondeploy = ondeployfn;
    inst.components.deployable:SetDeploySpacing(DEPLOYSPACING.NONE)

    inst:AddComponent("mie_bundle")

    return inst
end

return Prefab("mie_bundle_state1", state1), Prefab("mie_bundle_state2", state2),
MakePlacer("mie_bundle_state2_placer", "bundle", "bundle", "idle_large");