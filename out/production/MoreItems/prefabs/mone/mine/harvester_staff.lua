---
--- @author zsh in 2023/1/8 22:43
---


local TEXT = require("languages.mone.loc");

local names = {
    harvester = "mone_harvester_staff",
    harvester_gold = "mone_harvester_staff_gold",
}

local assets = {
    Asset("ANIM", "anim/machete.zip"),
    Asset("ANIM", "anim/machete_obsidian.zip"),

    Asset("ANIM", "anim/swap_machete.zip"),
    Asset("ANIM", "anim/swap_machete_obsidian.zip"),

    Asset("ANIM", "anim/goldenmachete.zip"),
    Asset("ANIM", "anim/swap_goldenmachete.zip"),
}

---播放音效和移除预制物
local function onfinished(inst)
    inst.SoundEmitter:PlaySound("dontstarve/common/gem_shatter")
    inst:Remove()
end

---隐藏和显示动画
--local function onunequip(inst, owner)
--    owner.AnimState:Hide("ARM_carry")
--    owner.AnimState:Show("ARM_normal")
--end

--local function onunequip_skinned(inst, owner)
--    if inst:GetSkinBuild() ~= nil then
--        owner:PushEvent("unequipskinneditem", inst:GetSkinName())
--    end
--
--    onunequip(inst, owner)
--end

local function commonfn(tags, anims)
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    --inst.AnimState:SetBank("mandrake_staff");
    --inst.AnimState:SetBuild("mandrake_staff");
    --inst.AnimState:PlayAnimation("idle", false);
    inst.AnimState:SetBank(anims[1]);
    inst.AnimState:SetBuild(anims[2]);
    inst.AnimState:PlayAnimation(anims[3]);

    if tags then
        for i, v in ipairs(tags) do
            inst:AddTag(v)
        end
    end

    inst:AddTag("tool");


    -- TEMP
    MakeInventoryFloatable(inst, "med", 0.1, { 0.9, 0.4, 0.9 });

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    -------
    inst:AddComponent("finiteuses")
    inst.components.finiteuses:SetOnFinished(onfinished)

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")

    inst:AddComponent("equippable")

    return inst
end

local function debuff(inst, owner)
    local amount_san, amount_hun;
    if inst.prefab == "mone_harvester_staff" then
        --amount_san = -2;
        amount_hun = -2;
    else
        --amount_san = -1;
        amount_hun = -1;
    end

    --if math.random() < 0.4 then
    --    owner.components.sanity:DoDelta(amount_san);
    --else
    --    owner.components.hunger:DoDelta(amount_hun);
    --end
    owner.components.hunger:DoDelta(amount_hun)
end

local function onequipCommonly(inst, owner, use)
    owner.AnimState:Show("ARM_carry")
    owner.AnimState:Hide("ARM_normal")

    owner:AddTag("mone_fast_picker");

    -- 闭包到底对性能的影响大不大呢？我不该考虑这个东西！
    local function isExcludedPrefabs(data)
        if data and data.object then
            --print(tostring(data.object.prefab));
            for _, v in ipairs({ "carrot_planted", "succulent_plant", "cave_fern", "flower",
                                 "" }) do
                -- 恶魔花?
                if data.object.prefab == v then
                    return true;
                end
            end
        end
        return false;
    end

    inst.pick = function(self, data)
        if not isExcludedPrefabs(data) then
            if inst.components.finiteuses then
                inst.components.finiteuses:Use(use);
            end
            debuff(inst, owner);
        end
    end

    owner:ListenForEvent("picksomething", inst.pick);
    owner:ListenForEvent("harvestsomething", inst.pick);
    owner:ListenForEvent("takesomething", inst.pick);
end

local function onequip(inst, owner)
    --owner.AnimState:OverrideSymbol("swap_object", "swap_mandrake_staff", "swap_mandrake_staff")
    owner.AnimState:OverrideSymbol("swap_object", "swap_machete", "swap_machete")

    onequipCommonly(inst, owner, 3);
end

local function onequip_gold(inst, owner)
    --owner.AnimState:OverrideSymbol("swap_object", "swap_mandrake_staff", "swap_mandrake_staff")
    owner.AnimState:OverrideSymbol("swap_object", "swap_goldenmachete", "swap_goldenmachete")

    onequipCommonly(inst, owner, 1);
end

local function onunequip(inst, owner)
    owner.AnimState:Hide("ARM_carry")
    owner.AnimState:Show("ARM_normal")

    owner:RemoveTag("mone_fast_picker");

    owner:RemoveEventCallback("picksomething", inst.pick);
    owner:RemoveEventCallback("harvestsomething", inst.pick);
    owner:RemoveEventCallback("takesomething", inst.pick);
end

local function harvester()
    local tags = {
        --"nopunch"
        "mone_harvester_staff"
    };
    local inst = commonfn(tags, {
        "machete", "machete", "idle"
    });

    if not TheWorld.ismastersim then
        return inst
    end

    inst.fxcolour = { 104 / 255, 40 / 255, 121 / 255 }

    inst.components.inventoryitem.imagename = "machete";
    inst.components.inventoryitem.atlasname = "images/DLC0002/inventoryimages.xml"

    inst.components.equippable:SetOnEquip(onequip)
    inst.components.equippable:SetOnUnequip(onunequip)
    inst.components.equippable.walkspeedmult = 1.05;

    inst.components.finiteuses:SetMaxUses(TEXT.HARVESTER_STAFF_USES * 2)
    inst.components.finiteuses:SetUses(TEXT.HARVESTER_STAFF_USES * 2)

    inst:AddComponent("weapon");
    inst.components.weapon:SetDamage(17);
    inst.components.weapon:SetOnAttack(function(inst, attacker, target)

    end);
    --inst.components.weapon.attackwear = 0;

    -- TEMP
    --inst.components.floater:SetScale({ 0.9, 0.4, 0.9 })

    -- Question
    --inst:AddComponent("shadowlevel")
    --inst.components.shadowlevel:SetDefaultLevel(TEXT.HARVESTER_SHADOW_LEVEL)

    MakeHauntableLaunch(inst)
    --AddHauntableCustomReaction(inst, onhauntpurple, true, false, true)

    return inst
end

local function harvester_gold()
    local tags = {
        --"nopunch"
        "mone_harvester_staff"
    };
    local inst = commonfn(tags, {
        "machete", "goldenmachete", "idle"
    });

    if not TheWorld.ismastersim then
        return inst
    end

    inst.fxcolour = { 104 / 255, 40 / 255, 121 / 255 }

    inst.components.inventoryitem.imagename = "goldenmachete";
    inst.components.inventoryitem.atlasname = "images/DLC0002/inventoryimages.xml"

    inst.components.equippable:SetOnEquip(onequip_gold)
    inst.components.equippable:SetOnUnequip(onunequip);
    inst.components.equippable.walkspeedmult = 1.1;

    inst.components.finiteuses:SetMaxUses(TEXT.HARVESTER_STAFF_GOLD_USES * 2)
    inst.components.finiteuses:SetUses(TEXT.HARVESTER_STAFF_GOLD_USES * 2)

    inst:AddComponent("weapon");
    inst.components.weapon:SetDamage(17);
    inst.components.weapon:SetOnAttack(function(inst, attacker, target)

    end);
    --inst.components.weapon.attackwear = 0;

    -- TEMP
    --inst.components.floater:SetScale({ 0.9, 0.4, 0.9 })

    -- Question
    --inst:AddComponent("shadowlevel")
    --inst.components.shadowlevel:SetDefaultLevel(TEXT.HARVESTER_SHADOW_LEVEL)

    MakeHauntableLaunch(inst)
    --AddHauntableCustomReaction(inst, onhauntpurple, true, false, true)

    return inst
end

return Prefab(names.harvester, harvester, assets), Prefab(names.harvester_gold, harvester_gold, assets);