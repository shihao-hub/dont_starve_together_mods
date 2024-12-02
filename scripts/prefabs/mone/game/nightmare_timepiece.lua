---
--- @author zsh in 2023/7/6 9:56
---

local assets = {
    Asset("ANIM", "anim/nightmare_timepiece.zip"),
}

local DEFAULT_STATE = {
    anim = "idle_1",
    inventory = "nightmare_timepiece",
}

local STATES = {
    calm = DEFAULT_STATE,
    warn = {
        anim = "idle_2",
        inventory = "nightmare_timepiece_warn",
    },
    wild = {
        anim = "idle_3",
        inventory = "nightmare_timepiece_nightmare",
    },
    dawn = DEFAULT_STATE,
}

for k, v in pairs(STATES) do
    if v.inventory ~= "nightmare_timepiece" then
        table.insert(assets, Asset("INV_IMAGE", v.inventory))
    end
end

local function GetStatus(inst)
    return (TheWorld.state.isnightmarewarn and "WARN")
            or (TheWorld.state.isnightmarecalm and "CALM")
            or (TheWorld.state.isnightmaredawn and "DAWN")
            or (not TheWorld.state.isnightmarewild and "NOMAGIC")
            or (TheWorld.state.nightmaretimeinphase < .33 and "WAXING")
            or (TheWorld.state.nightmaretimeinphase < .66 and "STEADY")
            or "WANING"
end

local function OnNightmarePhaseChanged(inst, phase)
    local state = STATES[phase] or DEFAULT_STATE
    inst.AnimState:PlayAnimation(state.anim)
    inst.components.inventoryitem:ChangeImageName(state.inventory)
end

local function toground(inst)
    if inst._owner ~= nil then
        inst._owner:RemoveTag("nightmaretracker")
        inst._owner:RemoveEventCallback("onremove", toground, inst)
        inst._owner = nil
    end

    -- NEW!
    -- TODO:模仿这里设置监听！而且这里非常妙！
end

local function SetNewName(inst)
    local named = inst.components.named;
    local old_name = named.name;
    if inst.more_items_binder_name and old_name then
        named:SetName(inst.more_items_binder_name .. "的" .. old_name);
    end
end

local function topocket(inst, owner)
    owner = owner.components.inventoryitem ~= nil and owner.components.inventoryitem:GetGrandOwner() or owner
    if owner ~= inst._owner then
        toground(inst)
        owner:AddTag("nightmaretracker")
        owner:ListenForEvent("onremove", toground, inst)
        inst._owner = owner
    end

    -- NEW!
    local player = inst:GetPlayerOwner();
    if player then
        if inst.more_items_binder_userid == nil then
            inst.more_items_binder_userid = player.userid;
            inst.more_items_binder_name = player.name;
            SetNewName(inst);
        elseif inst.more_items_binder_userid ~= player.userid then
            local say = "这不是你的东西！";
            if inst.more_items_binder_name then
                say = say .. "这是" .. inst.more_items_binder_name .. "的东西！";
            end
            player.components.talker:Say(say);
            player.components.inventory:DropItem(inst);
            -- TODO：播放灼烧音效
        end
    end
end

-- NEW!
local function ReplaceOnSave(old_fn)
    return function(inst, data)
        if old_fn then
            old_fn(inst, data);
        end
        data.more_items_binder_userid = inst.more_items_binder_userid;
        data.more_items_binder_name = inst.more_items_binder_name;
    end
end

local function ReplaceOnLoad(old_fn)
    return function(inst, data)
        if old_fn then
            old_fn(inst, data);
        end
        if data then
            inst.more_items_binder_userid = data.more_items_binder_userid;
            inst.more_items_binder_name = data.more_items_binder_name;
            if inst.more_items_binder_userid then
                SetNewName(inst);
            end
        end
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()
    inst.entity:AddMiniMapEntity()

    inst.MiniMapEntity:SetIcon("nightmare_timepiece.tex")

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("nightmare_watch")
    inst.AnimState:SetBuild("nightmare_timepiece")
    inst.AnimState:PlayAnimation("idle_1")
    inst.scrapbook_anim = "idle_1"

    MakeInventoryFloatable(inst, "med", nil, 0.62)

    inst:AddTag("mone_nightmare_timepiece")
    --Sneak these into pristine state for optimization
    inst:AddTag("_named")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")
    inst.components.inspectable.getstatus = GetStatus

    inst:AddComponent("named")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "nightmare_timepiece";
    inst.components.inventoryitem.atlasname = "images/DLC/inventoryimages.xml";

    -- NEW!
    inst.components.inventoryitem.canonlygoinpocket = true; -- 啊，就这样吧，限定一下！不然不好写...
    inst.GetPlayerOwner = function(inst)
        local owner = inst.components.inventoryitem.owner;
        return owner and owner:HasTag("player");
    end

    MakeHauntableLaunch(inst)

    inst:WatchWorldState("nightmarephase", OnNightmarePhaseChanged)
    OnNightmarePhaseChanged(inst, TheWorld.state.nightmarephase)

    inst._owner = nil
    inst:ListenForEvent("onputininventory", topocket)
    inst:ListenForEvent("ondropped", toground)

    -- NEW!
    inst.OnSave = ReplaceOnSave(inst.OnSave);
    inst.OnLoad = ReplaceOnLoad(inst.OnLoad);

    return inst
end

return Prefab("mone_nightmare_timepiece", fn, assets)
