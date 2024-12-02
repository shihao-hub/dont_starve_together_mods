---
--- @author zsh in 2023/5/20 19:43
---

local name = "crowndamager"; -- 这里的名字是官方原版贴图的文件名的部分内容
local bank = name .. "hat";
local build = "hat_" .. name;

local prefab_name = "me_resplendentnoxhelm"; -- 这里的名字是我的物品名

local assets = { Asset("ANIM", "anim/" .. build .. ".zip") };

local onequipfn = ENV.HEAD.onequipfn({
    build = build;
    hidesymbols = true;
}, function(inst, owner)
    owner:AddTag("me_resplendentnoxhelm_owner");

    inst:ListenForEvent("blocked", inst._onblocked, owner);
    inst:ListenForEvent("attacked", inst._onblocked, owner);
end);

local onunequipfn = ENV.HEAD.onunequipfn({
    hidesymbols = true;
}, function(inst, owner)
    owner:RemoveTag("me_resplendentnoxhelm_owner");

    inst:RemoveEventCallback("blocked", inst._onblocked, owner);
    inst:RemoveEventCallback("attacked", inst._onblocked, owner);
end);

local function OnCooldown(inst)
    inst._cdtask = nil
end

local function OnBlocked(owner, data, inst)
    if inst._cdtask == nil and data ~= nil and not data.redirected then
        --V2C: tiny CD to limit chain reactions
        inst._cdtask = inst:DoTaskInTime(.3, OnCooldown)

        SpawnPrefab("me_bramblefx_armor"):SetFXOwner(owner);

        if owner.SoundEmitter ~= nil then
            owner.SoundEmitter:PlaySound("dontstarve/common/together/armor/cactus")
        end
    end
end

local function fn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank(bank)
    inst.AnimState:SetBuild(build)
    inst.AnimState:PlayAnimation("anim")

    inst:AddTag("hat")

    inst:AddTag("waterproofer")

    inst:AddTag("bramble_resistant")

    MakeInventoryFloatable(inst)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst;
    end

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "lavaarena_" .. name .. "hat";
    inst.components.inventoryitem.atalsname = "images/inventoryimages.xml";

    inst:AddComponent("equippable")
    inst.components.equippable.equipslot = EQUIPSLOTS.HEAD;
    inst.components.equippable:SetOnEquip(onequipfn)
    inst.components.equippable:SetOnUnequip(onunequipfn)

    inst:AddComponent("armor")
    inst.components.armor:InitCondition(TUNING.ARMOR_WATHGRITHRHAT, TUNING.ARMOR_WATHGRITHRHAT_ABSORPTION)

    inst:AddComponent("waterproofer")
    inst.components.waterproofer:SetEffectiveness(TUNING.WATERPROOFNESS_SMALL)

    inst._onblocked = function(owner, data)
        OnBlocked(owner, data, inst);
    end

    return inst;
end

local function MakeBrambleFxArmor(name, anim, damage)
    local assets = {
        Asset("ANIM", "anim/bramblefx.zip"),
    }

    --DSV uses 4 but ignores physics radius
    local MAXRANGE = 3
    local _NO_TAGS_NO_PLAYERS = { "bramble_resistant", "INLIMBO", "notarget", "noattack", "flight", "invisible", "player" }
    local _NO_TAGS = { "bramble_resistant", "INLIMBO", "notarget", "noattack", "flight", "invisible", "playerghost" }
    local COMBAT_TARGET_TAGS = { "_combat" }

    local CANT_TAGS = {
        "INLIMBO", "NOCLICK", "FX", "DECOR",
        "hiding",
        "player", "playerghost", "wall", "companion", "abigail", "shadowminion",
        "notarget","noattack","flight","invisible",
        "glommer",
    };

    local NO_TAGS_NO_PLAYERS = UnionSeq(deepcopy(CANT_TAGS), _NO_TAGS_NO_PLAYERS);
    local NO_TAGS = UnionSeq(deepcopy(CANT_TAGS), _NO_TAGS);

    local function OnUpdateThorns(inst)
        inst.range = inst.range + .75

        local x, y, z = inst.Transform:GetWorldPosition()
        for i, v in ipairs(TheSim:FindEntities(x, y, z, inst.range + 3, COMBAT_TARGET_TAGS, inst.canhitplayers and NO_TAGS or NO_TAGS_NO_PLAYERS)) do
            if not inst.ignore[v] and
                    v:IsValid() and
                    v.entity:IsVisible() and
                    v.components.combat ~= nil and
                    not (v.components.inventory ~= nil and
                            v.components.inventory:EquipHasTag("bramble_resistant")) then
                local range = inst.range + v:GetPhysicsRadius(0)
                if v:GetDistanceSqToPoint(x, y, z) < range * range then
                    if inst.owner ~= nil and not inst.owner:IsValid() then
                        inst.owner = nil
                    end
                    if inst.owner ~= nil then
                        if inst.owner.components.combat ~= nil and inst.owner.components.combat:CanTarget(v) then
                            inst.ignore[v] = true
                            v.components.combat:GetAttacked(v.components.follower ~= nil and v.components.follower:GetLeader() == inst.owner and inst or inst.owner, inst.damage)
                            --V2C: wisecracks make more sense for being pricked by picking
                            --v:PushEvent("thorns")
                        end
                    elseif v.components.combat:CanBeAttacked() then
                        inst.ignore[v] = true
                        v.components.combat:GetAttacked(inst, inst.damage)
                        --v:PushEvent("thorns")
                    end
                end
            end
        end

        if inst.range >= MAXRANGE then
            inst.components.updatelooper:RemoveOnUpdateFn(OnUpdateThorns)
        end
    end

    local function SetFXOwner(inst, owner)
        inst.Transform:SetPosition(owner.Transform:GetWorldPosition())
        inst.owner = owner
        inst.canhitplayers = not owner:HasTag("player") or TheNet:GetPVPEnabled()
        inst.ignore[owner] = true
    end

    local function fn()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddNetwork()

        inst:AddTag("FX")
        inst:AddTag("thorny")

        if name == "me_bramblefx_trap" then
            inst:AddTag("trapdamage")
        end

        inst.Transform:SetFourFaced()

        inst.AnimState:SetBank("bramblefx")
        inst.AnimState:SetBuild("bramblefx")
        inst.AnimState:PlayAnimation(anim)

        --inst:SetPrefabNameOverride("bramblefx") -- 这个到底有啥用？

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end

        inst:AddComponent("updatelooper")
        inst.components.updatelooper:AddOnUpdateFn(OnUpdateThorns)

        inst:ListenForEvent("animover", inst.Remove)
        inst.persists = false
        inst.damage = 34; -- TUNING[damage]
        inst.range = .75
        inst.ignore = {}
        inst.canhitplayers = true
        --inst.owner = nil

        inst.SetFXOwner = SetFXOwner

        return inst
    end
    return Prefab(name, fn, assets);
end

return Prefab(prefab_name, fn, assets), MakeBrambleFxArmor("me_bramblefx_armor", "idle", "ARMORBRAMBLE_DMG");