---
--- @author zsh in 2023/3/1 8:38
---

local function MakeGranary(name, data)
    local fns = {};

    -- 厉害
    local shows = { "corn", "garlic", "pepper", }
    local function showornot(inst)
        for _, v in ipairs(shows) do
            if inst.components.container:Has(v, 1) then
                inst.AnimState:ShowSymbol(v)
            else
                inst.AnimState:HideSymbol(v)
            end
        end
    end

    function fns.onopenfn(inst, data)
        inst.SoundEmitter:PlaySound("dontstarve/wilson/chest_open");
    end
    function fns.onclosefn(inst, data)
        inst.SoundEmitter:PlaySound("dontstarve/wilson/chest_close");

        showornot(inst)
    end
    function fns.onhammered(inst, worker)
        if inst.components.lootdropper then
            inst.components.lootdropper:DropLoot();
        end
        if inst.components.container then
            inst.components.container:DropEverything();
        end
        local fx = SpawnPrefab("collapse_small");
        fx.Transform:SetPosition(inst.Transform:GetWorldPosition());
        fx:SetMaterial("wood");
        inst:Remove();
    end
    function fns.onhit(inst, worker)
        if inst.components.container ~= nil then
            inst.components.container:DropEverything();
            inst.components.container:Close();
        end
    end
    function fns.onbuilt(inst)
        inst:Hide()
        inst:DoTaskInTime(0, function(inst)
            local x, y, z = inst.Transform:GetWorldPosition()
            x, y, z = TheWorld.Map:GetTileCenterPoint(x, 0, z)
            inst.Transform:SetPosition(x, 0, z)
            inst:Show()
        end)
    end

    local function fn()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddSoundEmitter()
        inst.entity:AddNetwork()

        inst.entity:AddMiniMapEntity()
        inst.MiniMapEntity:SetIcon(data.minimap);

        MakeObstaclePhysics(inst, 1.5);

        inst.AnimState:SetBank(data.animstate[1])
        inst.AnimState:SetBuild(data.animstate[2])
        inst.AnimState:PlayAnimation(data.animstate[3])

        if data.tags then
            for _, v in ipairs(data.tags) do
                inst:AddTag(v);
            end
        end

        MakeSnowCoveredPristine(inst)

        if not TheWorld.ismastersim then
            local old_OnEntityReplicated = inst.OnEntityReplicated
            inst.OnEntityReplicated = function(inst)
                if old_OnEntityReplicated then
                    old_OnEntityReplicated(inst)
                end
                if inst and inst.replica and inst.replica.container then
                    inst.replica.container:WidgetSetup(data.widgetsetup);
                end
            end
            return inst;
        end

        inst:AddComponent("inspectable")

        inst:AddComponent("container")
        inst.components.container:WidgetSetup(data.widgetsetup)
        inst.components.container.skipclosesnd = true;
        inst.components.container.skipopensnd = true;
        inst.components.container.onopenfn = fns.onopenfn;
        inst.components.container.onclosefn = fns.onclosefn;

        inst:AddComponent("lootdropper")
        inst:AddComponent("workable")
        inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
        inst.components.workable:SetWorkLeft(6)
        inst.components.workable:SetOnFinishCallback(fns.onhammered)
        --inst.components.workable:SetOnWorkCallback(fns.onhit)

        inst:AddComponent("preserver")
        inst.components.preserver:SetPerishRateMultiplier(0.1);

        AddHauntableDropItemOrWork(inst);

        inst:ListenForEvent("onbuilt", fns.onbuilt);

        MakeSnowCovered(inst);

        inst:DoTaskInTime(0, showornot);

        return inst;
    end
    return Prefab(name, fn, data.assets);
end

-- 说明：不具通用性，只适用于谷仓
return MakeGranary("mie_new_granary", {
    assets = {
        Asset("ANIM", "anim/ui_zx_5x10.zip"),
        Asset("ATLAS", "images/inventoryimages/self_use/map_icons/myth_granary.xml"),
        Asset("IMAGE", "images/inventoryimages/self_use/map_icons/myth_granary.tex"),
    },
    tags = { "structure", "mie_new_granary" },
    minimap = "myth_granary.tex",
    animstate = { "myth_granary", "myth_granary", "idle" },
    widgetsetup = "mie_new_granary",
}), MakePlacer("mie_new_granary_placer", "myth_granary", "myth_granary", "idle");