---
--- @author zsh in 2023/1/12 1:05
---

local API = require("chang_mone.dsts.API");

local function MakeHat(prefabname, assets, animstate, overridesymbol)
    local swap_data = { bank = animstate[1], anim = animstate[3] }

    local function _onequip(inst, owner)
        -- 此函数内有和皮肤有关的东西，不知道在干嘛，先删除。

        owner.AnimState:OverrideSymbol("swap_hat", overridesymbol[1], overridesymbol[2])

        owner.AnimState:ClearOverrideSymbol("headbase_hat") --clear out previous overrides

        owner.AnimState:Show("HAT")
        owner.AnimState:Show("HAIR_HAT")
        owner.AnimState:Hide("HAIR_NOHAT")
        owner.AnimState:Hide("HAIR")

        if owner:HasTag("player") then
            owner.AnimState:Hide("HEAD")
            owner.AnimState:Show("HEAD_HAT")
        end

        if inst.components.fueled ~= nil then
            inst.components.fueled:StartConsuming()
        end
    end

    local function _onunequip(inst, owner)

        owner.AnimState:ClearOverrideSymbol("headbase_hat") --it might have been overriden by _onequip

        owner.AnimState:ClearOverrideSymbol("swap_hat")
        owner.AnimState:Hide("HAT")
        owner.AnimState:Hide("HAIR_HAT")
        owner.AnimState:Show("HAIR_NOHAT")
        owner.AnimState:Show("HAIR")

        if owner:HasTag("player") then
            owner.AnimState:Show("HEAD")
            owner.AnimState:Hide("HEAD_HAT")
        end

        if inst.components.fueled ~= nil then
            inst.components.fueled:StopConsuming()
        end
    end

    local function simple_onequip(inst, owner)
        _onequip(inst, owner);
    end

    local function simple_onunequip(inst, owner)
        _onunequip(inst, owner);
    end

    local function simple_onequiptomodel(inst, owner)
        if inst.components.fueled ~= nil then
            inst.components.fueled:StopConsuming()
        end
    end

    local function simple()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddNetwork()

        MakeInventoryPhysics(inst)

        inst.AnimState:SetBank(animstate[1])
        inst.AnimState:SetBuild(animstate[2])
        inst.AnimState:PlayAnimation(animstate[3])

        inst:AddTag("hat")

        MakeInventoryFloatable(inst)
        inst.components.floater:SetBankSwapOnFloat(false, nil, swap_data)
        --Hats default animation is not "idle", so even though we don't swap banks, we need to specify the swap_data for re-skinning to reset properly when floating

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end

        inst:AddComponent("inventoryitem")

        inst:AddComponent("inspectable")

        inst:AddComponent("tradable")

        inst:AddComponent("equippable")
        inst.components.equippable.equipslot = EQUIPSLOTS.HEAD
        inst.components.equippable:SetOnEquip(simple_onequip)
        inst.components.equippable:SetOnUnequip(simple_onunequip)
        inst.components.equippable:SetOnEquipToModel(simple_onequiptomodel)

        MakeHauntableLaunch(inst)

        return inst
    end

    local function captain_onequip(inst, owner)
        simple_onequip(inst, owner);

    end

    local function captain_onunequip(inst, owner)
        simple_onunequip(inst, owner);
    end

    local function captain()
        local inst = simple();

        if not TheWorld.ismastersim then
            return inst
        end

        inst.components.equippable:SetOnEquip(captain_onequip);
        inst.components.equippable:SetOnUnequip(captain_onunequip);

        inst.components.inventoryitem.imagename = "captain"
        inst.components.inventoryitem.atlasname = "images/DLC0002/inventoryimages.xml"

        inst:AddComponent("armor")
        inst.components.armor:InitCondition(TUNING.ARMORGRASS, TUNING.ARMORGRASS_ABSORPTION)

        return inst
    end

    local function pithhat()
        local inst = simple();

        if not TheWorld.ismastersim then
            return inst
        end

        inst.components.inventoryitem.imagename = "pithhat"
        inst.components.inventoryitem.atlasname = "images/DLC0003/inventoryimages.xml"

        inst:AddComponent("armor")
        inst.components.armor:InitCondition(TUNING.ARMORGRASS, 0.7)

        return inst
    end

    local function brainjelly()
        local inst = simple();

        if not TheWorld.ismastersim then
            return inst
        end

        inst.components.inventoryitem.imagename = "brainjellyhat"
        inst.components.inventoryitem.atlasname = "images/DLC0002/inventoryimages.xml"

        local old_onequipfn = inst.components.equippable.onequipfn;
        inst.components.equippable.onequipfn = function(inst, owner)
            if old_onequipfn then
                old_onequipfn(inst, owner);
            end

            inst.mone_owner = owner;
            if inst.components.fueled then
                if inst.components.fueled:GetPercent() <= 0 then
                    inst.components.equippable.dapperness = 0;
                    inst.mone_owner:RemoveTag("mone_brainjelly_const_temperature");
                else
                    inst.components.equippable.dapperness = TUNING.DAPPERNESS_LARGE + TUNING.DAPPERNESS_MED_LARGE;
                    inst.mone_owner:AddTag("mone_brainjelly_const_temperature");
                end
            end

        end
        local old_onunequipfn = inst.components.equippable.onunequipfn;
        inst.components.equippable.onunequipfn = function(inst, owner)
            if old_onunequipfn then
                old_onunequipfn(inst, owner);
            end
            inst.mone_owner = owner;
            inst.mone_owner:RemoveTag("mone_brainjelly_const_temperature");
        end

        -- 回理智
        inst.components.equippable.dapperness = TUNING.DAPPERNESS_LARGE + TUNING.DAPPERNESS_MED_LARGE

        inst:AddComponent("fueled")
        inst.components.fueled.fueltype = FUELTYPE.USAGE
        inst.components.fueled:InitializeFuelLevel(TUNING.WALRUSHAT_PERISHTIME)
        inst.components.fueled:SetDepletedFn(function()
            -- DoNothing
        end);

        --inst:AddComponent("armor")
        --inst.components.armor:InitCondition(TUNING.ARMORGRASS, TUNING.ARMORGRASS_ABSORPTION/2)

        inst:ListenForEvent("percentusedchange", function(inst, data)
            --print(inst.mone_owner and "inst.mone_owner ~= nil" or "inst.mone_owner == nil");
            if data and inst.mone_owner then
                if data.percent <= 0 then
                    --print("percentusedchange:data.percent <= 0");
                    inst.components.equippable.dapperness = 0;
                    inst.mone_owner:RemoveTag("mone_brainjelly_const_temperature");
                else
                    --print("percentusedchange:data.percent > 0");
                    inst.components.equippable.dapperness = TUNING.DAPPERNESS_LARGE + TUNING.DAPPERNESS_MED_LARGE;
                    inst.mone_owner:AddTag("mone_brainjelly_const_temperature");
                end
            end
        end)

        return inst
    end

    local function double_umbrella()
        local inst = simple();

        inst:AddTag("open_top_hat")
        inst:AddTag("umbrella")

        --waterproofer (from waterproofer component) added to pristine state for optimization
        inst:AddTag("waterproofer")

        if not TheWorld.ismastersim then
            return inst
        end

        inst.components.inventoryitem.imagename = "double_umbrellahat"
        inst.components.inventoryitem.atlasname = "images/DLC0002/inventoryimages.xml"

        local old_onequipfn = inst.components.equippable.onequipfn;
        inst.components.equippable.onequipfn = function(inst, owner)
            if old_onequipfn then
                old_onequipfn(inst, owner);
            end
            owner.DynamicShadow:SetSize(2.2, 1.4)
        end
        local old_onunequipfn = inst.components.equippable.onunequipfn;
        inst.components.equippable.onunequipfn = function(inst, owner)
            if old_onunequipfn then
                old_onunequipfn(inst, owner);
            end
            owner.DynamicShadow:SetSize(1.3, 0.6)
        end

        inst:AddComponent("fueled")
        inst.components.fueled.fueltype = FUELTYPE.USAGE
        inst.components.fueled:InitializeFuelLevel(TUNING.EYEBRELLA_PERISHTIME)
        inst.components.fueled:SetDepletedFn(function(inst)
            --local equippable = inst.components.equippable
            --if equippable ~= nil and equippable:IsEquipped() then
            --    local owner = inst.components.inventoryitem ~= nil and inst.components.inventoryitem.owner or nil
            --    if owner ~= nil then
            --        owner.DynamicShadow:SetSize(1.3, 0.6)
            --        local data = {
            --            prefab = inst.prefab,
            --            equipslot = equippable.equipslot,
            --        }
            --        inst:Remove()--generic_perish(inst)
            --        owner:PushEvent("umbrellaranout", data)
            --        return
            --    end
            --end
            inst:Remove()--generic_perish(inst)
        end)

        inst:AddComponent("waterproofer")
        inst.components.waterproofer:SetEffectiveness(0.7)

        inst:AddComponent("insulator")
        inst.components.insulator:SetInsulation(TUNING.INSULATION_LARGE * 2)
        inst.components.insulator:SetSummer()

        inst.components.equippable.insulated = true

        return inst
    end

    local function desert()
        local inst = simple();

        --waterproofer (from waterproofer component) added to pristine state for optimization
        inst:AddTag("waterproofer")

        inst:AddTag("goggles")

        inst.components.floater:SetSize("med")
        inst.components.floater:SetScale(0.72)

        if not TheWorld.ismastersim then
            return inst
        end

        inst.components.inventoryitem.imagename = "double_umbrellahat"
        inst.components.inventoryitem.atlasname = "images/DLC0002/inventoryimages.xml"

        inst.components.equippable.dapperness = TUNING.DAPPERNESS_MED

        inst:AddComponent("fueled")
        inst.components.fueled.fueltype = FUELTYPE.USAGE
        inst.components.fueled:InitializeFuelLevel(TUNING.GOGGLES_PERISHTIME)
        inst.components.fueled:SetDepletedFn(--[[generic_perish]]inst.Remove)

        inst:AddComponent("waterproofer")
        inst.components.waterproofer:SetEffectiveness(TUNING.WATERPROOFNESS_SMALL)

        inst:AddComponent("insulator")
        inst.components.insulator:SetSummer()
        inst.components.insulator:SetInsulation(TUNING.INSULATION_MED)

        --inst:AddComponent("armor")
        --inst.components.armor:InitCondition(TUNING.ARMORGRASS, TUNING.ARMORGRASS_ABSORPTION/2)

        return inst
    end

    local function bathat()
        local inst = simple();

        if not TheWorld.ismastersim then
            return inst
        end

        inst.components.inventoryitem.imagename = "bathat"
        inst.components.inventoryitem.atlasname = "images/DLC0003/inventoryimages.xml"

        local old_onequipfn = inst.components.equippable.onequipfn;
        inst.components.equippable.onequipfn = function(inst, owner)
            if old_onequipfn then
                old_onequipfn(inst, owner);
            end
            if not owner:HasTag("player") then
                return ; -- 排除假人
            end
            owner:AddTag("mone_bathat_fly_isEquiped");
        end
        local old_onunequipfn = inst.components.equippable.onunequipfn;
        inst.components.equippable.onunequipfn = function(inst, owner)
            if old_onunequipfn then
                old_onunequipfn(inst, owner);
            end
            if not owner:HasTag("player") then
                return ; -- 排除假人
            end
            owner:RemoveTag("mone_bathat_fly_isEquiped");
            if owner.components.mone_bathat_fly then
                owner.components.mone_bathat_fly:Land(owner);
            end
        end

        return inst
    end
    local function gashat()
        local inst = simple();

        if not TheWorld.ismastersim then
            return inst
        end

        inst.components.inventoryitem.imagename = "gashat"
        inst.components.inventoryitem.atlasname = "images/DLC0003/inventoryimages.xml"

        local function LowSanityHighArmor(inst)
            local owner = inst.components.inventoryitem.owner;
            inst.mone_gashat_owner = owner;
            if owner and owner.components.sanity and owner.components.combat then
                local percent = owner.components.sanity:GetPercent();
                if percent >= 0.8 then
                    inst.components.armor.absorb_percent = 0.8
                    owner.components.combat.externaldamagemultipliers:SetModifier(inst.prefab, 1)
                elseif percent >= 0.55 then
                    inst.components.armor.absorb_percent = 0.85
                    owner.components.combat.externaldamagemultipliers:SetModifier(inst.prefab, 1.15)
                elseif percent >= 0.3 then
                    inst.components.armor.absorb_percent = 0.85
                    owner.components.combat.externaldamagemultipliers:SetModifier(inst.prefab, 1.3)
                elseif percent >= 0.15 then
                    inst.components.armor.absorb_percent = 0.9
                    owner.components.combat.externaldamagemultipliers:SetModifier(inst.prefab, 1.5)
                else
                    inst.components.armor.absorb_percent = 0.95
                    owner.components.combat.externaldamagemultipliers:SetModifier(inst.prefab, 2)
                end
            end
        end

        local old_onequipfn = inst.components.equippable.onequipfn;
        inst.components.equippable.onequipfn = function(inst, owner)
            if old_onequipfn then
                old_onequipfn(inst, owner);
            end
            if inst.mone_sanity_task then
                inst.mone_sanity_task:Cancel()
                inst.mone_sanity_task = nil
            end

            -- TEMP FRAMES--一帧
            inst.mone_sanity_task = inst:DoPeriodicTask(FRAMES, LowSanityHighArmor);
            --inst.mone_sanity_task = inst:DoPeriodicTask(0.33, LowSanityHighArmor, 0.33);
        end
        local old_onunequipfn = inst.components.equippable.onunequipfn;
        inst.components.equippable.onunequipfn = function(inst, owner)
            if old_onunequipfn then
                old_onunequipfn(inst, owner);
            end
            if inst.mone_gashat_owner and inst.mone_gashat_owner.components.combat then
                inst.mone_gashat_owner.components.combat.externaldamagemultipliers:RemoveModifier(inst.prefab);
                inst.components.armor.absorb_percent = 0.8
                inst.mone_gashat_owner = nil
            end

            if inst.mone_sanity_task then
                inst.mone_sanity_task:Cancel()
                inst.mone_sanity_task = nil
            end
        end

        inst:AddComponent("armor")
        --inst.components.armor:InitCondition(TUNING.ARMOR_WATHGRITHRHAT, TUNING.ARMOR_WATHGRITHRHAT_ABSORPTION);
        --inst.components.armor:InitCondition(TUNING.ARMORMARBLE, TUNING.ARMOR_WATHGRITHRHAT_ABSORPTION);
        inst.components.armor:InitCondition(TUNING.ARMORRUINS, TUNING.ARMOR_WATHGRITHRHAT_ABSORPTION);

        inst:AddComponent("waterproofer")
        inst.components.waterproofer:SetEffectiveness(TUNING.WATERPROOFNESS_SMALL)

        return inst
    end
    local function bandit()
        local inst = simple();

        if not TheWorld.ismastersim then
            return inst
        end

        inst.components.inventoryitem.imagename = "bandithat"
        inst.components.inventoryitem.atlasname = "images/DLC0003/inventoryimages.xml"

        inst:AddComponent("mone_bandithat")

        --inst:AddComponent("fueled")
        --inst.components.fueled:InitializeFuelLevel(TUNING.YELLOWAMULET_FUEL)
        --inst.components.fueled:SetDepletedFn(inst.Remove)
        --inst.components.fueled:SetFirstPeriod(TUNING.TURNON_FUELED_CONSUMPTION, TUNING.TURNON_FULL_FUELED_CONSUMPTION)

        local old_onequipfn = inst.components.equippable.onequipfn;
        inst.components.equippable.onequipfn = function(inst, owner)
            if old_onequipfn then
                old_onequipfn(inst, owner);
            end
            owner:AddTag("equip_mone_bandit");
            inst.components.mone_bandithat:SetEquipStatus(true); -- 其实设置一个标签就行了，不需要这个
            inst.mone_bandit_owner = owner;
        end
        local old_onunequipfn = inst.components.equippable.onunequipfn;
        inst.components.equippable.onunequipfn = function(inst, owner)
            if old_onunequipfn then
                old_onunequipfn(inst, owner);
            end
            owner:RemoveTag("equip_mone_bandit");
            inst.components.mone_bandithat:SetEquipStatus(false);
            inst.mone_bandit_owner = nil;
        end

        return inst
    end

    local function bushhat_stopusingbush(inst, data)
        -- 这个 inst 为 owner ！！！！！！
        local hat = inst.components.inventory ~= nil and inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HEAD) or nil

        if hat ~= nil and data.statename ~= "hide" then
            hat.components.useableitem:StopUsingItem()
            API.RemoveTag(inst, "mone_notarget");
            return ;
        end

        if hat ~= nil and data.statename == "hide" then
            API.AddTag(inst, "mone_notarget");

            local bushhat = inst.mone_bushhat_prefab;
            if bushhat and bushhat.components.finiteuses then
                if bushhat.components.finiteuses:GetPercent() <= 0 then
                    API.RemoveTag(inst, "mone_notarget");
                end
            end

            return ;
        end
    end

    local function bushhat()
        local inst = simple();

        inst.entity:AddMiniMapEntity()
        inst.MiniMapEntity:SetIcon("bushhat.tex")

        -- 因此时能发出微光

        inst:AddTag("hide")

        inst.foleysound = "dontstarve/movement/foley/bushhat"

        inst.components.floater:SetSize("med")
        inst.components.floater:SetScale(0.65)

        inst.mone_repair_materials = { redgem = 1 };
        inst:AddTag("mone_can_be_repaired");

        if not TheWorld.ismastersim then
            return inst
        end

        inst.components.inventoryitem:ChangeImageName("bushhat");

        inst:AddComponent("useableitem")
        inst.components.useableitem:SetOnUseFn(function(inst)
            local owner = inst.components.inventoryitem.owner;
            if owner then
                owner.sg:GoToState("hide");
            end
        end)

        --inst:AddComponent("fueled");
        --inst.components.fueled:InitializeFuelLevel(TUNING.TORCH_FUEL * 2)
        --inst.components.fueled:SetDepletedFn(function(inst)
        --
        --end)
        ---- 这个函数到底啥意思？
        --inst.components.fueled:SetFirstPeriod(TUNING.TURNON_FUELED_CONSUMPTION, TUNING.TURNON_FULL_FUELED_CONSUMPTION)

        inst:AddComponent("finiteuses");
        inst.components.finiteuses:SetMaxUses(100);
        inst.components.finiteuses:SetUses(100);

        -- TEMPLATE!!!
        local old_onequipfn = inst.components.equippable.onequipfn;
        inst.components.equippable.onequipfn = function(inst, owner, from_ground)
            if old_onequipfn then
                old_onequipfn(inst, owner, from_ground);
            end

            --API.AddTag(owner,"notarget");

            owner.mone_bushhat_prefab = inst;

            inst:ListenForEvent("newstate", bushhat_stopusingbush, owner);
        end

        local old_onunequipfn = inst.components.equippable.onunequipfn;
        inst.components.equippable.onunequipfn = function(inst, owner)
            if old_onunequipfn then
                old_onunequipfn(inst, owner);
            end

            --API.RemoveTag(owner,"notarget");

            owner.mone_bushhat_prefab = nil;

            -- !!!移除监听器
            inst:RemoveEventCallback("newstate", bushhat_stopusingbush, owner);
        end

        inst:DoTaskInTime(0, function(inst)
            if inst.components.finiteuses:GetPercent() <= 0 then
                API.RemoveTag(inst, "mone_notarget");
            end
        end);

        inst:ListenForEvent("percentusedchange", function(inst, data)
            if data and data.percent <= 0 then
                API.RemoveTag(inst, "mone_notarget");
            end
        end)

        return inst;
    end

    local fn = nil
    if string.find(prefabname, "_captain") then
        fn = captain;
    elseif string.find(prefabname, "_pith") then
        fn = pithhat;
    elseif string.find(prefabname, "_brainjelly") then
        fn = brainjelly;
    elseif string.find(prefabname, "_double_umbrella") then
        fn = double_umbrella;
    elseif string.find(prefabname, "_desert") then
        fn = desert;
    elseif string.find(prefabname, "_bathat") then
        fn = bathat;
    elseif string.find(prefabname, "_shark_teeth") then
        fn = simple; -- shark_teeth;
    elseif string.find(prefabname, "_gashat") then
        fn = gashat;
    elseif string.find(prefabname, "_bandit") then
        fn = bandit;
    elseif string.find(prefabname, "_bushhat") then
        fn = bushhat;
    else
        fn = simple;
    end

    return Prefab(prefabname, fn, assets);
end

local config_data = TUNING.MONE_TUNING.GET_MOD_CONFIG_DATA;

local hats = {};

if config_data.pith then
    table.insert(hats, MakeHat("mone_pith", {
        Asset("ANIM", "anim/hat_pith.zip"),
    }, { "pithhat", "hat_pith", "anim" }, { "hat_pith", "swap_hat" }));
end

if config_data.gashat then
    table.insert(hats, MakeHat("mone_gashat", {
        Asset("ANIM", "anim/hat_gas.zip"),
    }, { "gashat", "hat_gas", "anim" }, { "hat_gas", "swap_hat" }));
end

if config_data.double_umbrella then
    table.insert(hats, MakeHat("mone_double_umbrella", {
        Asset("ANIM", "anim/hat_double_umbrella.zip"),
    }, { "hat_double_umbrella", "hat_double_umbrella", "anim" }, { "hat_double_umbrella", "swap_hat" }));
end

if config_data.brainjelly then
    table.insert(hats, MakeHat("mone_brainjelly", {
        Asset("ANIM", "anim/hat_brainjelly.zip"),
    }, { "brainjellyhat", "hat_brainjelly", "anim" }, { "hat_brainjelly", "swap_hat" }));
end

if config_data.bathat then
    table.insert(hats, MakeHat("mone_bathat", {
        Asset("ANIM", "anim/hat_bat.zip"),
    }, { "bathat", "hat_bat", "anim" }, { "hat_bat", "swap_hat" }));
end

--if config_data.bushhat then
--    table.insert(hats, MakeHat("mone_bushhat", {
--        Asset("ANIM", "anim/hat_bush.zip"),
--    }, { "bushhat", "hat_bush", "anim" }, { "hat_bush", "swap_hat" }));
--end

--table.insert(hats, MakeHat("mone_shark_teeth", {
--    Asset("ANIM", "anim/hat_shark_teeth.zip"),
--}, { "hat_shark_teeth", "hat_shark_teeth", "anim" }, { "hat_shark_teeth", "swap_hat" }));

-- 功能未生效，以后再说吧。主要贴图也不舒服。
--table.insert(hats, MakeHat("mone_bandit", {
--    Asset("ANIM", "anim/hat_bandit.zip"),
--}, { "bandithat", "hat_bandit", "anim" }, { "hat_bandit", "swap_hat" }));

return unpack(hats);
