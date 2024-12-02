---
--- @author zsh in 2023/2/8 9:47
---



local function MakeGranary(name, data)
    local fns = {};
    function fns.onopenfn(inst, data)
        --inst.SoundEmitter:PlaySound("saltydog/common/saltbox/open");
        inst.SoundEmitter:PlaySound("dontstarve/wilson/chest_open");
    end
    function fns.onclosefn(inst, data)
        --inst.SoundEmitter:PlaySound("saltydog/common/saltbox/close");
        inst.SoundEmitter:PlaySound("dontstarve/wilson/chest_close");
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

        MakeSnowCovered(inst);

        return inst;
    end
    return Prefab(name, fn, data.assets);
end

return MakeGranary("mie_granary_meats", {
    assets = {
        Asset("ANIM", "anim/ui_zx_5x10.zip"),
        Asset("ANIM", "anim/zx_granary_meat.zip"),
        Asset("ATLAS", "images/inventoryimages/zx_granary_meat.xml"),
        Asset("IMAGE", "images/inventoryimages/zx_granary_meat.tex"),
        --Asset("MINIMAP_IMAGE", "zx_granary_meat")
    },
    tags = { "structure" },
    minimap = "zx_granary_meat.tex",
    animstate = { "zx_granary_meat", "zx_granary_meat", "idle" },
    widgetsetup = "mie_granary_meats",
}), MakeGranary("mie_granary_greens", {
    assets = {
        Asset("ANIM", "anim/ui_zx_5x10.zip"),
        Asset("ANIM", "anim/zx_granary_veggie.zip"),
        Asset("ATLAS", "images/inventoryimages/zx_granary_veggie.xml"),
        Asset("IMAGE", "images/inventoryimages/zx_granary_veggie.tex"),
        --Asset("MINIMAP_IMAGE", "zx_granary_veggie")
    },
    tags = { "structure" },
    minimap = "zx_granary_veggie.tex",
    animstate = { "zx_granary_veggie", "zx_granary_veggie", "idle" },
    widgetsetup = "mie_granary_greens",
}), MakePlacer("mie_granary_meats_placer", "zx_granary_meat", "zx_granary_meat", "idle"),
MakePlacer("mie_granary_greens_placer", "zx_granary_veggie", "zx_granary_veggie", "idle");