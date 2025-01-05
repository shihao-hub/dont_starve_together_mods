---
--- @author zsh in 2023/6/29 17:32
---

require "prefabutil"

local assets = {
    Asset("ANIM", "anim/bookstation.zip"),
    Asset("ANIM", "anim/ui_bookstation_4x5.zip")
}

local prefabs = {
    "collapse_small",
}

local function onhammered(inst, worker)
    if inst.components.burnable ~= nil and inst.components.burnable:IsBurning() then
        inst.components.burnable:Extinguish()
    end

    if inst.components.container ~= nil then
        inst.components.container:DropEverything()
    end

    inst.components.lootdropper:DropLoot()
    local fx = SpawnPrefab("collapse_small")
    fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
    fx:SetMaterial("wood")
    inst:Remove()
end

local function onhit(inst)
    if not inst:HasTag("burnt") then
        inst.AnimState:PlayAnimation("hit")
        inst.AnimState:PushAnimation("idle", true)
    end
end

local function doonact(inst)
    --, soundprefix)
    if inst._activecount > 1 then
        inst._activecount = inst._activecount - 1
    else
        inst._activecount = 0
        inst.SoundEmitter:KillSound("sound")
    end
    --inst.SoundEmitter:PlaySound("dontstarve/common/researchmachine_"..soundprefix.."_ding")
end

local function onsave(inst, data)
    if inst:HasTag("burnt") or (inst.components.burnable ~= nil and inst.components.burnable:IsBurning()) then
        data.burnt = true
    end
end

local function onload(inst, data)
    if data ~= nil and data.burnt then
        inst.components.burnable.onburnt(inst)
    end
end

local function onturnon(inst)
    if inst._activetask == nil and not inst:HasTag("burnt") then
        if inst.AnimState:IsCurrentAnimation("place") then
            inst.AnimState:PushAnimation("proximity_loop", true)
        else
            inst.AnimState:PlayAnimation("proximity_loop", true)
        end
        inst.SoundEmitter:KillSound("idlesound")
    end
end

local function onturnoff(inst)
    if inst._activetask == nil and not inst:HasTag("burnt") then
        inst.AnimState:PlayAnimation("idle", true)
        inst.SoundEmitter:KillSound("proximity_loop")
    end
end

local function doneact(inst)
    inst._activetask = nil
    if not inst:HasTag("burnt") then
        if inst.components.prototyper.on then
            onturnon(inst)
        else
            onturnoff(inst)
        end
    end
end

local function onopen(inst)
    if not inst:HasTag("burnt") then
        inst.AnimState:PlayAnimation("hit")
        inst.AnimState:PushAnimation("idle", true)
        inst.SoundEmitter:PlaySound("dontstarve/wilson/chest_open")
    end
end

local function onclose(inst)
    if not inst:HasTag("burnt") then
        inst.AnimState:PlayAnimation("hit")
        inst.AnimState:PushAnimation("idle", true)
        inst.SoundEmitter:PlaySound("dontstarve/wilson/chest_close")
    end
end

local function RestoreBooks(inst)

    local wicker_bonus = 1
    local x, y, z = inst.Transform:GetWorldPosition()
    local players = FindPlayersInRange(x, y, z, TUNING.BOOKSTATION_BONUS_RANGE, true)

    for _, player in ipairs(players) do
        if player:HasTag("bookbuilder") then
            wicker_bonus = TUNING.BOOKSTATION_WICKER_BONUS
            break
        end
    end

    -- 薇克巴顿靠近回复速度并不会加倍
    wicker_bonus = 1;

    for k, v in pairs(inst.components.container.slots) do
        if v:HasTag("book") and v.components.finiteuses then
            local percent = v.components.finiteuses:GetPercent()
            if percent < 1 then
                v.components.finiteuses:SetPercent(math.min(1, percent + (TUNING.BOOKSTATION_RESTORE_AMOUNT * wicker_bonus)))
            end
        end
    end
end

local function CountBooks(inst)
    local cmp = inst.components.container
    return cmp and (cmp:NumItems() / cmp:GetNumSlots()) or 0
end

local BOOKS_SOME = "empty"
local BOOKS_MORE = "mid"
local BOOKS_FULL = "full"

local function UpdateBookAesthetics(inst, countoverride)
    local count = countoverride or CountBooks(inst)
    if count == 0 then
        inst.AnimState:Hide(BOOKS_SOME)
        inst.AnimState:Hide(BOOKS_MORE)
        inst.AnimState:Hide(BOOKS_FULL)
    elseif count < 0.5 then
        inst.AnimState:Show(BOOKS_SOME)
        inst.AnimState:Hide(BOOKS_MORE)
        inst.AnimState:Hide(BOOKS_FULL)
    elseif count < 1 then
        inst.AnimState:Show(BOOKS_SOME)
        inst.AnimState:Show(BOOKS_MORE)
        inst.AnimState:Hide(BOOKS_FULL)
    else
        inst.AnimState:Show(BOOKS_SOME)
        inst.AnimState:Show(BOOKS_MORE)
        inst.AnimState:Show(BOOKS_FULL)
    end
end

local function ItemGet(inst)
    if inst.RestoreTask == nil then
        if inst.components.container:HasItemWithTag("book", 1) then
            inst.RestoreTask = inst:DoPeriodicTask(TUNING.BOOKSTATION_RESTORE_TIME, RestoreBooks)
        end
    end
    UpdateBookAesthetics(inst)
end

local function ItemLose(inst)
    if not inst.components.container:HasItemWithTag("book", 1) then
        if inst.RestoreTask ~= nil then
            inst.RestoreTask:Cancel()
            inst.RestoreTask = nil
        end
    end
    UpdateBookAesthetics(inst)
end

local function ondropped(inst)
    if inst.components.container then
        inst.components.container:Close()
    end
end

local SCALE = 0.6;

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.MiniMapEntity:SetPriority(5)
    inst.MiniMapEntity:SetIcon("bookstation.png")

    inst.Transform:SetScale(SCALE, SCALE, SCALE)

    MakeInventoryFloatable(inst, "med")

    inst.AnimState:SetBank("bookstation")
    inst.AnimState:SetBuild("bookstation")
    inst.AnimState:PlayAnimation("idle")
    UpdateBookAesthetics(inst, 0)

    inst:AddTag("mone_bookstation")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        local old_OnEntityReplicated = inst.OnEntityReplicated
        inst.OnEntityReplicated = function(inst)
            if old_OnEntityReplicated then
                old_OnEntityReplicated(inst)
            end
            if inst and inst.replica and inst.replica.container then
                inst.replica.container:WidgetSetup("mone_bookstation");
            end
        end
        return inst
    end

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "bookstation";
    inst.components.inventoryitem.atlasname = "images/DLC/inventoryimages1.xml";
    inst.components.inventoryitem:SetOnDroppedFn(ondropped);

    inst:AddComponent("container")
    inst.components.container:WidgetSetup("mone_bookstation")
    inst.components.container.onopenfn = onopen
    inst.components.container.onclosefn = onclose
    inst.components.container.skipclosesnd = true
    inst.components.container.skipopensnd = true

    inst:ListenForEvent("itemget", ItemGet)
    inst:ListenForEvent("itemlose", ItemLose)

    return inst
end

--------------------------------------------------------------------------

return Prefab("mone_bookstation", fn, assets, prefabs),
MakePlacer("mone_bookstation_placer", "bookstation", "bookstation", "idle", nil, nil, nil, SCALE)