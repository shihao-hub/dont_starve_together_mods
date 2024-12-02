---
--- @author zsh in 2023/4/27 3:12
---

--\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
do
    return ; --\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
end
--\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

local fx_data = require "fx";
table.insert(fx_data, {
    name = "mone_dragonfurnace_smoke_fx",
    bank = "lavaarena_creature_teleport_smoke_fx",
    build = "lavaarena_creature_teleport_smoke_fx",
    anim = function()
        return "smoke_" .. math.random(2)
    end,
    sound = "dontstarve_DLC001/creatures/dragonfly/land",
    fn = function(inst)
        local scale = inst.AnimState:IsCurrentAnimation("smoke_1") and 0.75 or 0.65
        inst.AnimState:SetScale(scale, scale)
        inst.SoundEmitter:OverrideVolumeMultiplier(0.5)
    end,
})

local function AddContainer(name, data)
    local containers = require("containers");
    local params = containers.params;

    local function validfn(inst)
        local canburn;
        if inst.replica.container ~= nil then
            for slot, item in pairs(inst.replica.container:GetItems()) do
                canburn = canburn or not (item:HasTag("cookable") or item:HasTag("heatrock"));
            end

            if ThePlayer ~= nil then
                local widget = Browse(ThePlayer, "HUD", "controls", "containers", inst);
                if widget ~= nil then
                    widget.bganim:SetScale(1, 0.94)
                    widget.bganim:SetPosition(0, -17)
                    if canburn then
                        widget.button.image:SetTint(1, 0.5, 0.5, 1)
                    else
                        widget.button.image:SetTint(1, 1, 1, 1)
                    end
                elseif not TheWorld.ismastersim or inst.replica.container:IsOpenedBy(ThePlayer) then
                    print("validfn: widget == nil!");
                    StartThread(validfn, inst.GUID, inst)
                end
            end
        end
        return canburn ~= nil;
    end

    params[name] = {
        widget = {
            pos = Vector3(200, 0),
            slotpos = { Vector3(0, 72), Vector3(0, 0), Vector3(0, -72) },
            side_align_tip = 100,
            animbank = "ui_lamp_1x4",
            animbuild = "ui_lamp_1x4",
            buttoninfo = {
                text = STRINGS.ACTIONS.LIGHT,
                position = Vector3(0, -129),
                fn = function(inst, doer)
                    if inst.components.container ~= nil then
                        inst.components.container:Close(doer)
                        inst.components.container:Close()
                    elseif inst.replica.container ~= nil and not inst.replica.container:IsBusy() then
                        SendRPCToServer(RPC.DoWidgetButtonAction, nil, inst)
                    end
                end,
                validfn = validfn;
            }
        },
        itemtestfn = function(container, item, slot)
            return not (item:HasTag("irreplaceable") or item:HasTag("ashes"))
        end,
        type = "cooker",
    }
end

local function dragonflyfurnace()
    for _, name in ipairs({ "log", "livinglog", "driftwood_log" }) do
        env.AddPrefabPostInit(name, function(inst)
            inst:AddTag("charcoalsource");
        end)
    end
    AddContainer();
end

--\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
local VOMIT_DELAY = 10 * FRAMES;

local function DropLoot(inst, loot, target)
    local hasloot, hasproduct, pt

    for item, fn in pairs(loot) do
        if type(fn) == "function" and item:IsValid() then
            pcall(fn)
        end
    end

    for item in pairs(loot) do
        if item:IsValid() then
            hasloot = true
            if not item:HasTag("ashes") then
                hasproduct = true
                break
            end
        end
    end

    if hasloot then
        if hasproduct and inst ~= target and target:IsValid() then
            pt = target:GetPosition()
        else
            local theta = GetRandomMinMax(0, 2 * math.pi)
            local dist = GetRandomMinMax(2, 3)
            pt = inst:GetPosition() + Point(math.cos(theta) * dist, 0, math.sin(theta) * dist)
        end
        SpawnPrefab("dragonflyfurnace_projectile"):LaunchProjectile(loot, pt, inst, target)
    end
end

local function AddHiddenChild(inst, child, target)
    if target ~= nil then
        child.Network:SetClassifiedTarget(target)
    end
    if inst ~= child.parent then
        inst:AddChild(child)
    end
    if not child:IsInLimbo() then
        child:ForceOutOfLimbo()
        child:RemoveFromScene()
    end
end
--\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

local fns;
fns = {
    onopenfn = function(inst)
        --inst.SoundEmitter:PlaySound("dontstarve/wilson/chest_open");
        inst:RemoveComponent("cooker") -- TEMP!!!

        inst._lightrad = inst.Light:GetRadius()
        inst.Light:SetRadius(0.85)
        inst.AnimState:PlayAnimation("idle", true)
        inst.SoundEmitter:KillSound("loop")
        inst.SoundEmitter:PlaySound("dontstarve/common/fireOut")
        inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/dragonfly/vomitrumble", "rumble", 0.75)
    end,
    onclosefn = function(inst, doer)
        --inst.SoundEmitter:PlaySound("dontstarve/wilson/chest_close");
        doer = doer or inst

        local loot = {}

        for slot, item in pairs(inst.components.container.slots) do
            inst.components.container:RemoveItemBySlot(slot)

            local product, vomitfn
            local pcallqueue = {}

            if item.components.cookable ~= nil then
                product = FunctionOrValue(item.components.cookable.product, item, inst, doer)
                if item.components.cookable.oncooked ~= nil then
                    table.insert(pcallqueue, function()
                        item.components.cookable.oncooked(item, inst, doer)
                    end)
                end
            elseif item.components.temperature == nil then
                if item.components.explosive == nil then
                    product = item:HasTag("charcoalsource") and "charcoal" or "ash"
                end
                if item.components.burnable ~= nil then
                    item.components.burnable.burning = true
                    table.insert(pcallqueue, function()
                        item:PushEvent("onignite", { doer = doer })
                    end)
                    if item.components.burnable.onignite ~= nil then
                        table.insert(pcallqueue, function()
                            item.components.burnable.onignite(item, inst, doer)
                        end)
                    end
                    if item.components.burnable.onburnt ~= DefaultBurntFn then
                        vomitfn = function()
                            item.components.burnable:LongUpdate(0)
                        end
                    end
                end
            end

            if product ~= nil then
                product = SpawnPrefab(product)
                if product ~= nil then
                    if product.components.perishable ~= nil and item.components.perishable ~= nil and not item:HasTag("smallcreature") then
                        product.components.perishable:SetPercent(1 - (1 - item.components.perishable:GetPercent()) * 0.5)
                    end
                    if product.components.stackable ~= nil and item.components.stackable ~= nil then
                        local stacksize = item.components.stackable:StackSize() * product.components.stackable:StackSize()
                        product.components.stackable:SetStackSize(math.min(product.components.stackable.maxsize, stacksize))
                    end
                end
            end

            if next(pcallqueue) ~= nil then
                item:DoTaskInTime(0, function()
                    for i, fn in ipairs(pcallqueue) do
                        if not pcall(fn) or not item:IsValid() then
                            break
                        end
                    end
                end)
                if vomitfn == nil and product ~= nil then
                    item:DoTaskInTime(VOMIT_DELAY, item.Remove)
                end
                AddHiddenChild(inst, item, doer)
            elseif vomitfn ~= nil then
                AddHiddenChild(inst, item, doer)
            elseif product ~= nil then
                item:Remove()
            end

            local item = product or item
            if item.components.inventoryitem ~= nil then
                item.components.inventoryitem:InheritMoisture(0, false)
            end
            if item.components.temperature ~= nil then
                item.components.temperature:SetTemperature(item.components.temperature:GetMax())
            end
            AddHiddenChild(inst, item)

            loot[item] = vomitfn or false
        end

        if inst.components.cooker == nil then
            inst:AddComponent("cooker")
        end
        if inst._lightrad ~= nil then
            inst.Light:SetRadius(inst._lightrad)
        end
        inst.AnimState:PlayAnimation("hi_pre")
        inst.AnimState:PushAnimation("hi")
        inst.SoundEmitter:KillSound("rumble")
        inst.SoundEmitter:PlaySound("dontstarve/common/together/dragonfly_furnace/fire_LP", "loop")

        if next(loot) == nil then
            inst.SoundEmitter:PlaySound("dontstarve/common/together/dragonfly_furnace/light")
        else
            inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/dragonfly/vomit")

            local fx = inst:SpawnChild("firesplash_fx")
            fx.Transform:SetScale(0.5, 0.5, 0.5)
            fx.Transform:SetPosition(0, 0.1, 0)

            inst:DoTaskInTime(VOMIT_DELAY, DropLoot, loot, doer)
        end
    end,
    GetStatus = function(inst, observer)
        return not inst.components.container:IsOpen() and "HIGH" or nil
    end,
    GetHeat = function(inst, observer)
        local heat = inst.components.heater.heat
        if inst.components.container:IsOpen() then
            heat = heat / 2
        end
        if observer ~= nil and observer:HasTag("player") then
            heat = heat * Clamp(1 - TheWorld.state.temperature / TUNING.OVERHEAT_TEMP, 0.5, 1)
        end
        return heat
    end,
    OnHit = function(inst, data)
        if inst.components.container ~= nil then
            inst.components.container:DropEverything()
            inst.components.container:Close()
        end
    end,
    OnLoad = function(inst, data)
        if not inst.components.container:IsEmpty() then
            fns.onclosefn(inst)
        end
    end
};

dragonflyfurnace();

env.AddPrefabPostInit("mone_dragonflyfurnace", function(inst)
    if not TheWorld.ismastersim then
        local old_OnEntityReplicated = inst.OnEntityReplicated
        inst.OnEntityReplicated = function(inst)
            if old_OnEntityReplicated then
                old_OnEntityReplicated(inst)
            end
            if inst.replica.container then
                inst.replica.container:WidgetSetup("mone_dragonflyfurnace");
            end
        end
        return inst;
    end
    if inst.components.container then
        return inst;
    end

    inst:AddComponent("container");
    inst.components.container:WidgetSetup("mone_dragonflyfurnace");
    inst.components.container.onopenfn = fns.onopenfn;
    inst.components.container.onclosefn = fns.onclosefn;
    inst.components.container.skipclosesnd = true;
    inst.components.container.skipopensnd = true;

    inst.components.inspectable.getstatus = fns.GetStatus
    inst.components.heater.heatfn = fns.GetHeat

    inst:ListenForEvent("worked", fns.OnHit)

    Parallel(inst, "OnLoad", fns.OnLoad)
end)