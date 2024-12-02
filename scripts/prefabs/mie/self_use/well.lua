---
--- @author zsh in 2023/3/1 9:29
---

local function MakePrefab(name, data)
    local fns = {};

    local function OnCheck(inst)
        local x, y, z = inst.Transform:GetWorldPosition()
        local ents = TheSim:FindEntities(x, y, z, 16, nil, { "FX", "NOCLICK", "DECOR", "INLIMBO", "playerghost" }, { "smolder" })
        for i, v in pairs(ents) do
            if v.components.burnable ~= nil then
                if v.components.burnable:IsSmoldering() then
                    v.components.burnable:SmotherSmolder()
                end
            end
        end
    end

    local function setdried(inst)
        inst.dried = true
        if inst.check then
            inst.check:Cancel()
            inst.check = nil
        end
        inst.AnimState:PlayAnimation("idle_empty")
    end

    local function setwatersource(inst)
        inst.dried = false
        if not inst.check then
            inst.check = inst:DoPeriodicTask(1, OnCheck, 1)
        end
        inst.AnimState:PlayAnimation("fill")
        inst.AnimState:PushAnimation("idle_full")
    end

    local function OnIsRaining(inst, israining)
        if israining and inst.dried then
            inst:DoTaskInTime(5, setwatersource)
        end
    end

    function fns.onhammered(inst, worker)
        if inst.components.lootdropper then
            inst.components.lootdropper:DropLoot();
        end
        local fx = SpawnPrefab("collapse_small")
        fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
        fx:SetMaterial("metal")
        inst:Remove()
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
            inst.AnimState:PlayAnimation("fill")
            inst.AnimState:PushAnimation("idle_full")
        end)
    end

    function fns.onload(inst, data)
        if data ~= nil and data.dried then
            setdried(inst)
        end
    end

    function fns.onsave(inst, data)
        data.dried = inst.dried
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
        inst.AnimState:PlayAnimation(data.animstate[3], data.animstate[4])

        if data.tags then
            for _, v in ipairs(data.tags) do
                inst:AddTag(v);
            end
        end

        MakeSnowCoveredPristine(inst)

        if not TheWorld.ismastersim then
            return inst;
        end

        inst:AddComponent("inspectable")

        inst:AddComponent("watersource")

        inst:AddComponent("lootdropper")
        inst:AddComponent("workable")
        inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
        inst.components.workable:SetWorkLeft(3)
        inst.components.workable:SetOnFinishCallback(fns.onhammered)

        inst.OnSave = fns.onsave
        inst.OnLoad = fns.onload

        -- 这个是神话书说的大树需要用到的函数
        inst.SetDried = setdried;
        -- 遏制焖烧
        inst.check = inst:DoPeriodicTask(1, OnCheck, 1);

        inst:WatchWorldState("israining", OnIsRaining);
        inst:ListenForEvent("onbuilt", fns.onbuilt);

        return inst;
    end
    return Prefab(name, fn, data.assets);
end

-- 说明：不具通用性，只适用于水井
return MakePrefab("mie_well", {
    assets = {
        Asset("ATLAS", "images/inventoryimages/self_use/map_icons/myth_well.xml"),
        Asset("IMAGE", "images/inventoryimages/self_use/map_icons/myth_well.tex"),
    },
    tags = { "structure", "mie_well", "watersource", "antlion_sinkhole_blocker", "birdblocker", "shelter" },
    minimap = "myth_well.tex",
    animstate = { "myth_well", "myth_well", "idle_full", true },
}), MakePlacer("mie_well_placer", "myth_well", "myth_well", "idle_full");