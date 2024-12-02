---
--- @author zsh in 2023/5/2 1:20
---

local assets = {
    Asset("ANIM", "anim/staffs.zip"),
    Asset("ANIM", "anim/swap_staffs.zip"),
}

---------ORANGE STAFF-----------

local function onblink(staff, pos, caster)
    if staff.components.rechargeable then
        staff.components.rechargeable:StartRecharging();
    end

    -- DoNothing
    --if caster then
    --    if caster.components.staffsanity then
    --        caster.components.staffsanity:DoCastingDelta(-TUNING.SANITY_MED)
    --    elseif caster.components.sanity ~= nil then
    --        caster.components.sanity:DoDelta(-TUNING.SANITY_MED)
    --    end
    --end

    --staff.components.finiteuses:Use(1)
end

local function NoHoles(pt)
    return not TheWorld.Map:IsGroundTargetBlocked(pt)
end

local BLINKFOCUS_MUST_TAGS = { "blinkfocus" }

local function blinkstaff_reticuletargetfn()
    local player = ThePlayer
    local rotation = player.Transform:GetRotation()
    local pos = player:GetPosition()
    local ents = TheSim:FindEntities(pos.x, pos.y, pos.z, TUNING.CONTROLLER_BLINKFOCUS_DISTANCE, BLINKFOCUS_MUST_TAGS)
    for _, v in ipairs(ents) do
        local epos = v:GetPosition()
        if distsq(pos, epos) > TUNING.CONTROLLER_BLINKFOCUS_DISTANCESQ_MIN then
            local angletoepos = player:GetAngleToPoint(epos)
            local angleto = math.abs(anglediff(rotation, angletoepos))
            if angleto < TUNING.CONTROLLER_BLINKFOCUS_ANGLE then
                return epos
            end
        end
    end
    rotation = rotation * DEGREES
    for r = 13, 1, -1 do
        local numtries = 2 * PI * r
        local offset = FindWalkableOffset(pos, rotation, r, numtries, false, true, NoHoles)
        if offset ~= nil then
            pos.x = pos.x + offset.x
            pos.y = 0
            pos.z = pos.z + offset.z
            return pos
        end
    end
end

local ORANGEHAUNT_MUST_TAGS = { "locomotor" }
local ORANGEHAUNT_CANT_TAGS = { "playerghost", "INLIMBO" }

local function onhauntorange(inst)
    if math.random() <= TUNING.HAUNT_CHANCE_OCCASIONAL then
        local target = FindEntity(inst, 20, nil, ORANGEHAUNT_MUST_TAGS, ORANGEHAUNT_CANT_TAGS)
        if target ~= nil then
            local pos = target:GetPosition()
            local start_angle = math.random() * 2 * PI
            local offset = FindWalkableOffset(pos, start_angle, math.random(8, 12), 16, false, true, NoHoles)
            if offset ~= nil then
                pos.x = pos.x + offset.x
                pos.y = 0
                pos.z = pos.z + offset.z
                inst.components.blinkstaff:Blink(pos, target)
                inst.components.hauntable.hauntvalue = TUNING.HAUNT_LARGE
                return true
            end
        end
    end
    return false
end

---------COMMON FUNCTIONS---------

local function onfinished(inst)
    inst.SoundEmitter:PlaySound("dontstarve/common/gem_shatter")
    inst:Remove()
end

local function onunequip(inst, owner)
    owner.AnimState:Hide("ARM_carry")
    owner.AnimState:Show("ARM_normal")

    -- 快速采集
    owner:RemoveTag("mone_orangestaff_fast_picker");
end

local function onunequip_skinned(inst, owner)
    if inst:GetSkinBuild() ~= nil then
        owner:PushEvent("unequipskinneditem", inst:GetSkinName())
    end

    onunequip(inst, owner)
end

local function commonfn(colour, tags, hasskin, hasshadowlevel)
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("staffs")
    inst.AnimState:SetBuild("staffs")
    inst.AnimState:PlayAnimation(colour .. "staff")

    if tags ~= nil then
        for i, v in ipairs(tags) do
            inst:AddTag(v)
        end
    end

    if hasshadowlevel then
        --shadowlevel (from shadowlevel component) added to pristine state for optimization
        inst:AddTag("shadowlevel")
    end

    local floater_swap_data = {
        sym_build = "swap_staffs",
        sym_name = "swap_" .. colour .. "staff",
        bank = "staffs",
        anim = colour .. "staff"
    }
    MakeInventoryFloatable(inst, "med", 0.1, { 0.9, 0.4, 0.9 }, true, -13, floater_swap_data)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    -------
    inst:AddComponent("finiteuses")
    inst.components.finiteuses:SetOnFinished(onfinished)

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")

    inst:AddComponent("tradable")

    inst:AddComponent("equippable")

    if hasskin then
        inst.components.equippable:SetOnEquip(function(inst, owner)
            local skin_build = inst:GetSkinBuild()
            if skin_build ~= nil then
                owner:PushEvent("equipskinneditem", inst:GetSkinName())
                owner.AnimState:OverrideItemSkinSymbol("swap_object", skin_build, "swap_" .. colour .. "staff", inst.GUID, "swap_staffs")
            else
                owner.AnimState:OverrideSymbol("swap_object", "swap_staffs", "swap_" .. colour .. "staff")
            end
            owner.AnimState:Show("ARM_carry")
            owner.AnimState:Hide("ARM_normal")

            -- 快速采集
            owner:AddTag("mone_orangestaff_fast_picker");
        end)
        inst.components.equippable:SetOnUnequip(onunequip_skinned)
    else
        inst.components.equippable:SetOnEquip(function(inst, owner)
            owner.AnimState:OverrideSymbol("swap_object", "swap_staffs", "swap_" .. colour .. "staff")
            owner.AnimState:Show("ARM_carry")
            owner.AnimState:Hide("ARM_normal")

            -- 快速采集
            owner:AddTag("mone_orangestaff_fast_picker");
        end)
        inst.components.equippable:SetOnUnequip(onunequip)
    end

    if hasshadowlevel then
        inst:AddComponent("shadowlevel")
        inst.components.shadowlevel:SetDefaultLevel(TUNING.STAFF_SHADOW_LEVEL)
    end

    return inst
end

---------COLOUR SPECIFIC CONSTRUCTIONS---------

local function orange()
    --weapon (from weapon component) added to pristine state for optimization
    local inst = commonfn("orange", { "weapon" }, true, true)

    inst:AddTag("hide_percentage");

    inst:AddComponent("reticule")
    inst.components.reticule.targetfn = blinkstaff_reticuletargetfn
    inst.components.reticule.ease = true

    if not TheWorld.ismastersim then
        return inst
    end

    inst.components.inventoryitem:ChangeImageName("orangestaff");

    inst.fxcolour = { 1, 145 / 255, 0 }
    inst.castsound = "dontstarve/common/staffteleport"

    inst:AddComponent("blinkstaff")
    inst.components.blinkstaff:SetFX("sand_puff_large_front", "sand_puff_large_back")
    inst.components.blinkstaff.onblinkfn = onblink

    -- 修改相关函数
    local old_Blink = inst.components.blinkstaff.Blink;
    function inst.components.blinkstaff:Blink(pt, caster, ...)
        local rechargeable = self.inst.components.rechargeable;
        if rechargeable and rechargeable.recharging then
            return false;
        end
        if old_Blink then
            return old_Blink(self, pt, caster, ...);
        end
    end

    inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(TUNING.CANE_DAMAGE) -- NOTES(JBK): This item is created from a cane it should do cane damage.

    inst.components.equippable.walkspeedmult = 1.25 -- TUNING.CANE_SPEED_MULT

    inst.components.finiteuses:SetMaxUses(TUNING.ORANGESTAFF_USES)
    inst.components.finiteuses:SetUses(TUNING.ORANGESTAFF_USES)
    inst.components.finiteuses:SetIgnoreCombatDurabilityLoss(true)

    -- 不消耗耐久度
    local old_Use = inst.components.finiteuses.Use
    function inst.components.finiteuses:Use(num, ...)
        num = 0;
        if old_Use then
            return old_Use(self, num, ...);
        end
    end

    -- 添加冷却组件：这组件是我自己的，多少需要注意一下。假如有人修改全体有 rechargeable 组件的咋办？
    inst:AddTag("rechargeable");
    inst:AddComponent("mone_rechargeable");
    inst.components.rechargeable = inst.components.mone_rechargeable;
    inst.components.rechargeable:SetRechargeTime(5);
    inst:RegisterComponentActions("rechargeable");

    MakeHauntableLaunch(inst)
    AddHauntableCustomReaction(inst, onhauntorange, true, false, true)

    return inst
end

return Prefab("mone_orangestaff", orange, assets);
