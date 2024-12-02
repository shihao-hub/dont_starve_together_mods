---
--- @author zsh in 2023/8/2 1:48
---

local assets = {
    Asset("ANIM", "anim/warg_actions.zip"),
    Asset("ANIM", "anim/warg_build.zip"),
}

local function onextinguish(inst)
    local warg = SpawnPrefab("warg");
    if warg then
        local x, y, z = inst.Transform:GetWorldPosition();

        local fx = SpawnPrefab("collapse_small")
        fx.Transform:SetPosition(x, y, z);

        warg.Transform:SetPosition(x, y, z);

        local players = TheSim:FindEntities(x, y, z, 8, { "player" }, { "playerghost" });
        if #players > 0 then
            warg.components.combat:SetTarget(players[math.random(#players)]);
        end
    end
end
local function ReplaceOnExtinguish(old_fn)
    return function(inst)
        if old_fn then
            old_fn(inst);
        end
        onextinguish(inst);
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddSoundEmitter()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("warg")
    inst.AnimState:SetBuild("warg_build")
    inst.AnimState:PlayAnimation("idle_loop")

    inst.AnimState:SetScale(0, 5, 0.5, 0.5);

    MakeInventoryFloatable(inst, "med", 0.05, 0.68)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inventoryitem")
    --inst.components.inventoryitem.imagename = "";
    --inst.components.inventoryitem.atlasname = "";

    inst:AddComponent("inspectable")

    inst:AddComponent("fuel")
    inst.components.fuel.fuelvalue = TUNING.SMALL_FUEL

    MakeSmallBurnable(inst, TUNING.SMALL_BURNTIME)
    MakeSmallPropagator(inst)

    inst.components.burnable:SetOnExtinguishFn(ReplaceOnExtinguish(inst.components.burnable.onextinguish));

    MakeHauntableLaunchAndIgnite(inst)

    return inst
end

return Prefab("mone_warg_summons", fn, assets)


