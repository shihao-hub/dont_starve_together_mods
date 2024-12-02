---
--- Created by zsh
--- DateTime: 2023/12/10 12:36
---

local config_data = TUNING.MONE_TUNING.GET_MOD_CONFIG_DATA

local function more_grass_umbrella()
    -- 添加配方
    local recipe = {
        CanMake = true,
        name = "more_grass_umbrella",
        ingredients = morel_union_array(AllRecipes["grass_umbrella"].ingredients, {
            Ingredient("butter", 1)
        }),
        tech = TECH.NONE,
        config = {
            placer = nil,
            min_spacing = nil,
            nounlock = nil,
            numtogive = nil,
            builder_tag = nil,
            atlas = "images/DLC0000/inventoryimages.xml",
            image = "grass_umbrella.tex"
        },
        filters = {
            "MONE_MORE_ITEMS_MODIFY"
        }
    }
    if recipe.CanMake then
        local v = recipe
        --local all_items_one_recipetab = config_data.all_items_one_recipetab
        --if all_items_one_recipetab then
        --    if not table.contains(v.filters, "CHARACTER")
        --            and not table.contains(v.filters, "CRAFTING_STATION")
        --    then
        --        v.filters = { "MONE_MORE_ITEMS1" };
        --    end
        --end
        env.AddRecipe2(v.name, v.ingredients, v.tech, v.config, v.filters);
        env.RemoveRecipeFromFilter(v.name, "MODS");
    end

    -- 添加修饰
    local name_upper = string.upper("more_grass_umbrella")
    local prefab_info = {
        names = "神奇的花伞",
        describe = "神奇的花伞",
        recipe_desc = "鼠标放到右侧的气球图案上可以看到详细内容"
    }
    STRINGS.NAMES[name_upper] = prefab_info.names
    STRINGS.CHARACTERS.GENERIC.DESCRIBE[name_upper] = prefab_info.describe
    STRINGS.RECIPE_DESC[name_upper] = prefab_info.recipe_desc

    -- 添加描述
    STRINGS.MONE_STRINGS[name_upper] = [[
    - 装备时，击杀蝴蝶有更大概率掉落黄油
    - 这个概率是和当前时间密切相关的，自己体会哈
    - 你的随从击杀的目标也将视为被你本人击杀
    ]]

    env.AddPrefabPostInit("more_grass_umbrella", function(inst)
        if not TheWorld.ismastersim then
            return inst
        end
        inst.components.inventoryitem.imagename = "grass_umbrella"
        inst.components.inventoryitem.atlasname = "images/DLC0000/inventoryimages.xml"

        inst.components.equippable.onequipfn = morel_hook_fn(function()
            local old = inst.components.equippable.onequipfn
            return function(ins, owner, ...)
                if owner and owner:HasTag("player") then
                    owner:AddTag("more_grass_umbrella_tag")
                end
                return old(ins, owner, ...)
            end
        end)

        inst.components.equippable.onunequipfn = morel_hook_fn(function()
            local old = inst.components.equippable.onunequipfn
            return function(ins, owner, ...)
                if owner and owner:HasTag("player") then
                    owner:RemoveTag("more_grass_umbrella_tag")
                end
                return old(ins, owner, ...)
            end
        end)
    end)

    local function butterfly_ondeath(inst, data)
        local afflicter = data and data.afflicter
        if afflicter and afflicter.components.follower then
            afflicter = afflicter.components.follower.leader or afflicter
        end
        local probability = (os.time() % 100 + 1) / 100 / 3
        if afflicter and afflicter:HasTag("more_grass_umbrella_tag")
                and morel_is_valid(inst) then
            if math.random() < probability then
                afflicter.components.talker:Say(string.format("触发花伞的额外掉落黄油效果！此时的触发概率为 %.2f %%", probability * 100))

                ------------------------------------------------------- BEG LootDropper:DropLoot(pt)
                local self = inst.components.lootdropper
                local pt = inst:GetPosition()
                local prefabs = { "butter" }
                if self.inst:HasTag("burnt")
                        or (self.inst.components.burnable ~= nil and
                        self.inst.components.burnable:IsBurning() and
                        (self.inst.components.fueled == nil or self.inst.components.burnable.ignorefuel)) then

                    local isstructure = self.inst:HasTag("structure")
                    for k, v in pairs(prefabs) do
                        if TUNING.BURNED_LOOT_OVERRIDES[v] ~= nil then
                            prefabs[k] = TUNING.BURNED_LOOT_OVERRIDES[v]
                        elseif PrefabExists(v .. "_cooked") then
                            prefabs[k] = v .. "_cooked"
                        elseif PrefabExists("cooked" .. v) then
                            prefabs[k] = "cooked" .. v
                            --V2C: This used to make hammering WHILE burning give ash only
                            --     while hammering AFTER burnt give back good ingredients.
                            --     It *should* ALWAYS return ash based on certain types of
                            --     ingredients (wood), but we'll let them have this one :O
                        elseif (not isstructure and not self.inst:HasTag("tree")) or self.inst:HasTag("hive") then
                            -- because trees have specific burnt loot and "hive"s are structures...
                            prefabs[k] = "ash"
                        end
                    end
                end
                for k, v in pairs(prefabs) do
                    self:SpawnLootPrefab(v, pt)
                end

                if IsSpecialEventActive(SPECIAL_EVENTS.WINTERS_FEAST) then
                    local prefabname = string.upper(self.inst.prefab)
                    local num_decor_loot = self.GetWintersFeastOrnaments ~= nil and self.GetWintersFeastOrnaments(self.inst) or TUNING.WINTERS_FEAST_TREE_DECOR_LOOT[prefabname] or nil
                    if num_decor_loot ~= nil then
                        for i = 1, num_decor_loot.basic do
                            self:SpawnLootPrefab(GetRandomBasicWinterOrnament(), pt)
                        end
                        if num_decor_loot.special ~= nil then
                            self:SpawnLootPrefab(num_decor_loot.special, pt)
                        end
                    elseif not TUNING.WINTERS_FEAST_LOOT_EXCLUSION[prefabname] and (self.inst:HasTag("monster") or self.inst:HasTag("animal")) then
                        local loot = math.random()
                        if loot < 0.005 then
                            self:SpawnLootPrefab(GetRandomBasicWinterOrnament(), pt)
                        elseif loot < 0.20 then
                            self:SpawnLootPrefab("winter_food" .. math.random(NUM_WINTERFOOD), pt)
                        end
                    end
                end

                TheWorld:PushEvent("entity_droploot", { inst = self.inst })
                ------------------------------------------------------- END LootDropper:DropLoot(pt)
            else
                afflicter.components.talker:Say(string.format("未能触发花伞的额外掉落黄油效果！此时的触发概率为 %.2f %%", probability * 100))
            end
        end
    end
    env.AddPrefabPostInit("butterfly", function(inst)
        if not TheWorld.ismastersim then
            return inst
        end
        inst:ListenForEvent("death", butterfly_ondeath);
    end)
end

local function more_winterometer()
    -- 添加配方
    local recipe = {
        CanMake = true,
        name = "more_winterometer",
        ingredients = morel_union_array(AllRecipes["winterometer"].ingredients, {
            --Ingredient("bluegem", 1)
        }),
        tech = TECH.NONE,
        config = {
            placer = "more_winterometer_placer",
            min_spacing = nil,
            nounlock = nil,
            numtogive = nil,
            builder_tag = nil,
            atlas = "images/DLC/inventoryimages3.xml",
            image = "winterometer.tex"
        },
        filters = {
            "MONE_MORE_ITEMS_MODIFY"
        }
    }
    if recipe.CanMake then
        local v = recipe
        env.AddRecipe2(v.name, v.ingredients, v.tech, v.config, v.filters);
        env.RemoveRecipeFromFilter(v.name, "MODS");
    end

    -- 添加修饰
    local name_upper = string.upper("more_winterometer")
    local prefab_info = {
        names = "神奇的温度计",
        describe = "神奇的温度计",
        recipe_desc = "鼠标放到右侧的气球图案上可以看到详细内容"
    }
    STRINGS.NAMES[name_upper] = prefab_info.names
    STRINGS.CHARACTERS.GENERIC.DESCRIBE[name_upper] = prefab_info.describe
    STRINGS.RECIPE_DESC[name_upper] = prefab_info.recipe_desc

    -- 添加描述
    STRINGS.MONE_STRINGS[name_upper] = [[
    - 高温或低温时候晚上会发光
    ]]

    local function DoCheckTemp(inst)
        if not inst:HasTag("burnt") then
            inst.AnimState:SetPercent("meter", 1 - math.clamp(TheWorld.state.temperature, 0, TUNING.OVERHEAT_TEMP) / TUNING.OVERHEAT_TEMP)
            -- ADD NEW
            if TheWorld.state.isday then
                inst.Light:Enable(false)
            else
                inst.Light:Enable(true)
                local temperature = TheWorld.state.temperature
                if temperature > 40 then
                    inst.Light:SetRadius(2.0)
                    inst.Light:SetFalloff(.9)
                    inst.Light:SetIntensity(0.5)
                    inst.Light:SetColour(235 / 255, 121 / 255, 12 / 255)
                elseif temperature < 20 then
                    inst.Light:SetRadius(2.0)
                    inst.Light:SetFalloff(.7)
                    inst.Light:SetIntensity(0.6)
                    inst.Light:SetColour(15 / 255, 160 / 255, 180 / 255)
                else
                    inst.Light:SetRadius(2.0)
                    inst.Light:SetFalloff(.9)
                    inst.Light:SetIntensity(0.6)
                    inst.Light:SetColour(180 / 255, 195 / 255, 150 / 255)
                end
            end
        end
    end

    local function StartCheckTemp(inst)
        if inst.light_task == nil and not inst:HasTag("burnt") then
            inst.light_task = inst:DoPeriodicTask(1, DoCheckTemp, 0)
        end
    end
    env.AddPrefabPostInit("more_winterometer", function(inst)
        inst.entity:AddLight()
        inst.Light:Enable(false)
        if not TheWorld.ismastersim then
            return inst
        end
        StartCheckTemp(inst)
    end)
end

if config_data.grass_umbrella then
    more_grass_umbrella()
end

if config_data.winterometer then
    more_winterometer()
end
