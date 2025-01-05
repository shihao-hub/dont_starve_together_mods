---
--- @author zsh in 2023/1/13 22:48
---

local assets = {
    Asset("ANIM", "anim/chiminea.zip")
};

local function onhit(inst, worker)
    inst.AnimState:PlayAnimation("hit")
    inst.AnimState:PushAnimation("idle")
end

local function onhammered(inst, worker)
    if inst.components.lootdropper then
        inst.components.lootdropper:DropLoot()
    end

    if inst.components.container then
        inst.components.container:DropEverything()
    end

    local x, y, z = inst.Transform:GetWorldPosition()
    if x and y and z then
        local fx = SpawnPrefab("collapse_small")
        if fx then
            fx.Transform:SetPosition(x, y, z)
            fx:SetMaterial("wood")
        end
        inst:Remove()
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.entity:AddMiniMapEntity()
    inst.MiniMapEntity:SetIcon("chiminea.tex")

    inst.AnimState:SetBank("chiminea")
    inst.AnimState:SetBuild("chiminea")
    inst.AnimState:PlayAnimation("idle")

    inst:AddTag("structure")
    inst:AddTag("mone_chiminea")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        local old_OnEntityReplicated = inst.OnEntityReplicated

        inst.OnEntityReplicated = function(inst)

            if old_OnEntityReplicated then
                old_OnEntityReplicated(inst)
            end
            if inst and inst.replica and inst.replica.container then
                inst.replica.container:WidgetSetup("mone_chiminea");
            end
        end
        return inst;
    end

    inst:AddComponent("inspectable")

    inst:AddComponent("container")
    inst.components.container:WidgetSetup("mone_chiminea");
    inst.components.container.onopenfn = function(inst)
        inst.SoundEmitter:PlaySound("dontstarve/wilson/chest_open")
    end
    inst.components.container.onclosefn = function(inst)
        inst.SoundEmitter:PlaySound("dontstarve/wilson/chest_close")
    end

    inst:AddComponent("lootdropper")
    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(3)
    inst.components.workable:SetOnFinishCallback(onhammered)
    inst.components.workable:SetOnWorkCallback(onhit)

    inst:ListenForEvent( "onbuilt", function(inst)
        inst.AnimState:PlayAnimation("place")
        inst.AnimState:PushAnimation("idle",false)
        --inst.SoundEmitter:PlaySound("dontstarve/common/fireAddFuel")
    end)


    return inst;
end

return Prefab("mone_chiminea",fn,assets),MakePlacer("mone_chiminea_placer","chiminea","chiminea","idle");