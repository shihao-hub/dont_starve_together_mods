---
--- @author zsh in 2023/1/10 17:52
---


local function commonfn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()
    inst.entity:AddSoundEmitter()

    MakeInventoryPhysics(inst)
    MakeInventoryFloatable(inst, "med", nil, 0.75)

    inst:AddTag("sharp")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst;
    end

    inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(25)

    inst:AddComponent("tradable")

    -------

    inst:AddComponent("finiteuses")
    inst.components.finiteuses:SetMaxUses(150)
    inst.components.finiteuses:SetUses(150)

    inst.components.finiteuses:SetOnFinished(function()
        inst:Remove();
    end)

    inst:AddComponent("inspectable")

    inst:AddComponent("equippable")
    inst.components.equippable:SetOnEquip(function(inst, owner)
        owner.AnimState:OverrideSymbol("swap_object", "swap_spear", "swap_spear")
        owner.AnimState:Show("ARM_carry")
        owner.AnimState:Hide("ARM_normal")
    end)
    inst.components.equippable:SetOnUnequip(function(inst, owner)
        owner.AnimState:Hide("ARM_carry")
        owner.AnimState:Show("ARM_normal")
    end)

    return inst
end

local function poisonattack(inst, attacker, target, projectile)
    local canAttack = function(v, attacker, target)
        -- attacker 是武器的拥有者，target 是攻击目标，v 是被范围攻击的目标。
        if v and attacker and attacker:IsValid() and target and target:IsValid() then
            --被检索者和目标是同类（不需要了，加 true 取消）
            if v.prefab and target.prefab and (v.prefab == target.prefab or true) then
                -- 被检索者不是攻击目标 不是武器的拥有者
                if v ~= target and v ~= attacker then
                    --被检索者是有效目标
                    if attacker.components.combat and attacker.components.combat:IsValidTarget(v) then
                        -- 被检索者不是你的追随者
                        if attacker.components.leader and not attacker.components.leader:IsFollower(v) then
                            return true
                        end
                    end
                end
            end
        end
        return false
    end

    do
        -- 生成特效
        local fx, scale = SpawnPrefab("mone_reskin_tool_brush_explode_fx"), 0.5;
        fx.Transform:SetScale(scale, scale, scale);
        fx.Transform:SetPosition(target.Transform:GetWorldPosition());
    end

    local x, y, z = target.Transform:GetWorldPosition();
    if x and y and z then
        local DIST = 4 -- * 1.5
        local MUST_TAGS = { "_combat" }
        local CANT_TAGS = { "INLIMBO", "companion", "wall", "abigail", "shadowminion" }
        local ents = TheSim:FindEntities(x, y, z, DIST, MUST_TAGS, CANT_TAGS);
        for _, v in ipairs(ents) do
            if canAttack(v, attacker, target) then
                attacker:PushEvent("onareaattackother", { target = v, weapon = inst, stimuli = nil })
                v.components.combat:GetAttacked(attacker, 25, inst, nil)
                -- 生成特效
                local fxs = {
                    electrichitsparks = "electrichitsparks"; -- 晨星
                    nightsword_sharp_fx = "nightsword_sharp_fx"; -- 暗夜剑的相关特效好像和皮肤绑定的？生成了但是不显示呀。
                }

                local fx, scale = SpawnPrefab("mone_reskin_tool_brush_explode_fx"), 0.5;
                fx.Transform:SetScale(scale, scale, scale);
                fx.Transform:SetPosition(v.Transform:GetWorldPosition());

                --fxs.electrichitsparks:AlignToTarget(target, attacker, true)
            end
        end
    end
end

local function onequippoison(inst, owner)
    owner.AnimState:OverrideSymbol("swap_object", "swap_spear_poison", "swap_spear")
    owner.AnimState:Show("ARM_carry")
    owner.AnimState:Hide("ARM_normal")
end

local poison_assets = {
    Asset("ANIM", "anim/spear_poison.zip"),
    Asset("ANIM", "anim/swap_spear_poison.zip"),
}

local function poisonfn()
    local inst = commonfn()

    inst.AnimState:SetBuild("spear_poison")
    inst.AnimState:SetBank("spear_poison")
    inst.AnimState:PlayAnimation("idle")

    if not TheWorld.ismastersim then
        return inst;
    end

    inst:AddComponent("inventoryitem")

    inst.components.inventoryitem.imagename = "spear_poison"
    inst.components.inventoryitem.atlasname = "images/DLC0002/inventoryimages.xml"

    inst.components.weapon:SetOnAttack(poisonattack)
    inst.components.equippable:SetOnEquip(onequippoison)
    inst:AddTag("spear")

    inst.speartype = "poison"

    MakeHauntableLaunch(inst)

    return inst
end

return Prefab("mone_spear_poison", poisonfn, poison_assets);