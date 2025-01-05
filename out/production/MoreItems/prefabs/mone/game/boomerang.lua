---
--- @author zsh in 2023/5/18 17:30
---

local assets = {
    Asset("ANIM", "anim/boomerang.zip"),
    Asset("ANIM", "anim/swap_boomerang.zip"),
}

local function OnFinished(inst)
    inst.AnimState:PlayAnimation("used")
    inst:ListenForEvent("animover", inst.Remove)
end

local function OnEquip(inst, owner)
    local skin_build = inst:GetSkinBuild()
    if skin_build ~= nil then
        owner:PushEvent("equipskinneditem", inst:GetSkinName())
        owner.AnimState:OverrideItemSkinSymbol("swap_object", skin_build, "swap_boomerang", inst.GUID, "swap_boomerang")
    else
        owner.AnimState:OverrideSymbol("swap_object", "swap_boomerang", "swap_boomerang")
    end
    owner.AnimState:Show("ARM_carry")
    owner.AnimState:Hide("ARM_normal")
end

local function OnDropped(inst)
    inst.AnimState:PlayAnimation("idle")
    inst.components.inventoryitem.pushlandedevents = true
    inst:PushEvent("on_landed")
end

local function OnUnequip(inst, owner)
    owner.AnimState:Hide("ARM_carry")
    owner.AnimState:Show("ARM_normal")
    local skin_build = inst:GetSkinBuild()
    if skin_build ~= nil then
        owner:PushEvent("unequipskinneditem", inst:GetSkinName())
    end
end

local function OnThrown(inst, owner, target)
    if target ~= owner then
        owner.SoundEmitter:PlaySound("dontstarve/wilson/boomerang_throw")
    end
    inst.AnimState:PlayAnimation("spin_loop", true)
    inst.components.inventoryitem.pushlandedevents = false
end

local function OnCaught(inst, catcher)
    if catcher ~= nil and catcher.components.inventory ~= nil and catcher.components.inventory.isopen then
        if inst.components.equippable ~= nil and not catcher.components.inventory:GetEquippedItem(inst.components.equippable.equipslot) then
            catcher.components.inventory:Equip(inst)
        else
            catcher.components.inventory:GiveItem(inst)
        end
        catcher:PushEvent("catch")
    end
end

local function ReturnToOwner(inst, owner)
    if owner ~= nil and not (inst.components.finiteuses ~= nil and inst.components.finiteuses:GetUses() < 1) then
        owner.SoundEmitter:PlaySound("dontstarve/wilson/boomerang_return")
        inst.components.projectile:Throw(owner, owner)
    end
end

local MAX_TARGETS_NUMBER = 19;

local function binding(guy)
    if guy and guy:HasTag("beefalo") then
        local follower = guy and guy.replica and guy.replica.follower;
        local leader = follower and follower:GetLeader();
        return leader and leader.prefab == "beef_bell";
    end
end

local function findValidTarget(inst)
    if inst.hit_targets_number == nil or inst.hit_targets == nil then
        return ;
    end
    if inst.hit_targets_number > MAX_TARGETS_NUMBER then
        return ;
    end

    local x, y, z = inst:GetPosition():Get();
    local DIST = 8;
    local MUST_TAGS = { "_combat" };
    local CANT_TAGS = {
        "INLIMBO", "NOCLICK", "FX", "DECOR",
        "hiding",
        "player", "playerghost", "wall", "companion", "abigail", "shadowminion"
    };
    local ents = TheSim:FindEntities(x, y, z, DIST, MUST_TAGS, CANT_TAGS);
    for _, v in ipairs(ents) do
        if v and v:IsValid()
                and v.components.health and not v.components.health:IsDead()
                and not inst.hit_targets[v]
                and not binding(v) then
            return v;
        end
    end
end

local function bounce(inst, owner, target)
    inst.components.projectile:Throw(owner, target)
end

local function playerDeath(player)
    return player and player.deathcause;
end

local function OnHit(inst, owner, target)
    inst.hit_targets[target or 1] = true;
    inst.hit_targets_number = inst.hit_targets_number + 1;

    -- 如果直接发送死亡事件(T键)，似乎会崩溃，原版的回旋镖也崩溃了...因为科雷有判定，进入死亡 state 之后不能离开
    ---- 单纯用标签判断不够及时...需要用其他方法，因为 animover 之后，才会推送生成灵魂的事件。
    if playerDeath(owner) then
        OnDropped(inst);
    elseif owner == target then
        OnCaught(inst, owner);
    else
        local targ = findValidTarget(inst);
        if targ then
            bounce(inst, owner, targ);
        else
            ReturnToOwner(inst, owner);
        end
    end

    if target ~= nil and target:IsValid() and target.components.combat and not target:HasTag("player") then
        local impactfx = SpawnPrefab("impact")
        if impactfx ~= nil then
            local follower = impactfx.entity:AddFollower()
            follower:FollowSymbol(target.GUID, target.components.combat.hiteffectsymbol, 0, 0, 0)
            impactfx:FacePoint(inst.Transform:GetWorldPosition())
        end
    end
end

-- 这个是什么情况下调用的呢？距离太远了？
local function OnMiss(inst, owner, target)
    ReturnToOwner(inst, owner)
end

local function OnPutInInventory(inst)
    inst.hit_targets_number = 0;
    inst.hit_targets = {};
end

local function getdamagefn(inst)
    inst.hit_targets_number = inst.hit_targets_number or 0;
    if inst.hit_targets_number > 5 then
        return 25
    else
        return math.max(Remap(inst.hit_targets_number, 0, 5, 50, 25))
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)
    RemovePhysicsColliders(inst)

    inst.AnimState:SetBank("boomerang")
    inst.AnimState:SetBuild("boomerang")
    inst.AnimState:PlayAnimation("idle")
    inst.AnimState:SetRayTestOnBB(true)

    inst:AddTag("thrown")

    --weapon (from weapon component) added to pristine state for optimization
    inst:AddTag("weapon")

    --projectile (from projectile component) added to pristine state for optimization
    inst:AddTag("projectile")

    local swap_data = { sym_build = "swap_boomerang" }
    MakeInventoryFloatable(inst, "small", 0.18, { 0.8, 0.9, 0.8 }, true, -6, swap_data)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(34)
    inst.components.weapon:SetRange(16, 18)
    inst.components.weapon.getdamagefn = getdamagefn

    inst:AddComponent("finiteuses")
    inst.components.finiteuses:SetMaxUses(TUNING.BOOMERANG_USES)
    inst.components.finiteuses:SetUses(TUNING.BOOMERANG_USES)
    inst.components.finiteuses:SetOnFinished(OnFinished)

    -- 不消耗耐久度
    inst:AddTag("hide_percentage");
    local old_Use = inst.components.finiteuses.Use
    function inst.components.finiteuses:Use(num, ...)
        num = 0;
        if old_Use then
            return old_Use(self, num, ...);
        end
    end

    inst:AddComponent("inspectable")

    inst:AddComponent("projectile")
    inst.components.projectile:SetSpeed(14)
    inst.components.projectile:SetCanCatch(true)
    inst.components.projectile:SetHitDist(1.5)
    inst.components.projectile:SetOnThrownFn(OnThrown)
    inst.components.projectile:SetOnHitFn(OnHit)
    inst.components.projectile:SetOnMissFn(OnMiss)
    inst.components.projectile:SetOnCaughtFn(OnCaught)
    inst.components.projectile:SetLaunchOffset(Vector3(0, 0.2, 0));

    -- 目标是玩家的话不会造成伤害，注意，此处我应该写在 postinit 里面吧
    local old_Hit = inst.components.projectile.Hit;
    if old_Hit then
        function inst.components.projectile:Hit(target, ...)
            if old_Hit == nil then
                return ;
            end
            local res = {};

            local attacker = self.owner;

            if target and target:IsValid() and target:HasTag("player") and attacker and attacker.components.combat.DoAttack then
                local old_DoAttack = attacker.components.combat.DoAttack;

                attacker.components.combat.DoAttack = function()
                    -- DoNothing
                end

                res = { old_Hit(self, target, ...) };

                attacker.components.combat.DoAttack = old_DoAttack;
            else
                res = { old_Hit(self, target, ...) };
            end

            return unpack(res, 1, table.maxn(res));
        end
    end

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem:SetOnDroppedFn(OnDropped)
    inst.components.inventoryitem:ChangeImageName("boomerang");

    inst:ListenForEvent("onputininventory", OnPutInInventory);

    inst:AddComponent("equippable")
    inst.components.equippable:SetOnEquip(OnEquip)
    inst.components.equippable:SetOnUnequip(OnUnequip)

    MakeHauntableLaunch(inst)

    return inst
end

return Prefab("mone_boomerang", fn, assets)
