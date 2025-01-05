---
--- @author zsh in 2023/1/9 1:45
---


-- 有待优化

do
    return nil;
end

local assets = {}

local function fn1()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)
    MakeInventoryFloatable(inst, "med")

    inst.AnimState:SetBank("bundle")
    inst.AnimState:SetBuild("bundle")
    inst.AnimState:PlayAnimation("idle")

    inst:AddTag("acb_pack_everything")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")

    --补充，让库存栏得以显示
    inst.components.inventoryitem.imagename = "bundlewrap"
    inst.components.inventoryitem.atlasname = "images/inventoryimages.xml"

    inst:AddComponent("acb_pack_for_action")

    return inst
end

local function fn2()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)
    MakeInventoryFloatable(inst, "med")

    inst.AnimState:SetBank("bundle")
    inst.AnimState:SetBuild("bundle")
    inst.AnimState:PlayAnimation("idle_large")

    inst:AddTag("acb_pack_everything_full")

    --天体宝珠的两个标签
    -- inst:AddTag("irreplaceable")
    -- inst:AddTag("nonpotatable")

    --补充判断标签
    inst:AddTag("bundle")
    inst:AddTag("nobundling")

    --个人判断标签
    inst:AddTag("nonpackable")

    --主客机交互
    inst._name = net_string(inst.GUID, "acb_pack_everything_full._name")
    inst.displaynamefn = function(inst)
        if #inst._name:value() > 0 then
            return "被打包的 " .. inst._name:value()
        else
            return "未知打包物"
        end
    end

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")

    --打包带 inst.UpdateInventoryImage = UpdateInventoryImage 涉及
    inst.components.inventoryitem:ChangeImageName("bundle_large")

    inst:AddComponent("deployable")
    inst.components.deployable.ondeploy = function(inst, pt, deployer)
        if inst.components.acb_pack_everything then
            inst.components.acb_pack_everything:Release(pt) --释放

            inst:Remove()

            if deployer and deployer.components.inventory then
                --释放后，将打包带还回来
                local acb_pack_everything = SpawnPrefab("acb_pack_everything")
                if acb_pack_everything then
                    deployer.components.inventory:GiveItem(acb_pack_everything)
                end
            end
        end
    end
    inst.components.deployable:SetDeploySpacing(DEPLOYSPACING.NONE)

    inst:AddComponent("acb_pack_everything")

    return inst
end

return Prefab("acb_pack_everything", fn1, assets), Prefab("acb_pack_everything_full", fn2, assets), MakePlacer(
        "acb_pack_everything_full_placer",
        "bundle",
        "bundle",
        "idle_large"
)
