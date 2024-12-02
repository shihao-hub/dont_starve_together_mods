---
--- Created by zsh
--- DateTime: 2023/12/10 14:59
---

---
--- Created by zsh
--- DateTime: 2023/12/10 12:36
---

local config_data = TUNING.MONE_TUNING.GET_MOD_CONFIG_DATA

local function more_items_instruction_book()
    ------------------------------------------------------------------- BEG
    local _G = GLOBAL
    local PlayerHud = _G.require("screens/playerhud")
    local InstructionPopupScreen = require "screens/more_instruction_popup_screen"

    env.AddPopup("MORE_ITEMS_INSTRUCTION_BOOK")

    -- 主要就是这个函数
    POPUPS.MORE_ITEMS_INSTRUCTION_BOOK.fn = function(inst, show, target)
        if inst.HUD then
            if not show then
                inst.HUD:CloseMoreItemsInstructionPopupScreen()
            elseif not inst.HUD:OpenMoreItemsInstructionPopupScreen(target) then
                POPUPS.MORE_ITEMS_INSTRUCTION_BOOK:Close(inst)
            end
        end
    end

    function PlayerHud:OpenMoreItemsInstructionPopupScreen()
        self:CloseMoreItemsInstructionPopupScreen()
        self.morel_instruction_popup_screen = InstructionPopupScreen(self.owner)
        self:OpenScreenUnderPause(self.morel_instruction_popup_screen)
        return true
    end

    function PlayerHud:CloseMoreItemsInstructionPopupScreen()
        if self.morel_instruction_popup_screen ~= nil then
            if self.morel_instruction_popup_screen.inst:IsValid() then
                TheFrontEnd:PopScreen(self.morel_instruction_popup_screen)
            end
            self.morel_instruction_popup_screen = nil
        end
    end
    ------------------------------------------------------------------- END

    -- 添加配方
    local filter_name = "MONE_MORE_ITEMS1"
    local recipe_name = "more_items_instruction_book"
    local recipe = {
        CanMake = true,
        name = recipe_name,
        ingredients = AllRecipes["cookbook"].ingredients,
        tech = TECH.NONE,
        config = {
            placer = nil,
            min_spacing = nil,
            nounlock = nil,
            numtogive = nil,
            builder_tag = nil,
            atlas = "images/DLC/inventoryimages1.xml",
            image = "cookbook.tex"
        },
        filters = {
            filter_name
        }
    }
    if recipe.CanMake then
        local v = recipe
        env.AddRecipe2(v.name, v.ingredients, v.tech, v.config, v.filters);
        env.RemoveRecipeFromFilter(v.name, "MODS");
    end

    -- 添加修饰
    local name_upper = string.upper("more_items_instruction_book")
    local prefab_info = {
        names = "更多物品说明书",
        describe = "更多物品说明书",
        recipe_desc = "鼠标放到右侧的气球图案上可以看到详细内容"
    }
    STRINGS.NAMES[name_upper] = prefab_info.names
    STRINGS.CHARACTERS.GENERIC.DESCRIBE[name_upper] = prefab_info.describe
    STRINGS.RECIPE_DESC[name_upper] = prefab_info.recipe_desc

    -- 添加描述
    STRINGS.MONE_STRINGS[name_upper] = [[
    - 右键阅读可以简单查看物品介绍和更新日志等
    ]]

    -- 排个序，把这个说明书提到最前面
    local filter = CRAFTING_FILTERS[filter_name]
    local index = 0
    for i, v in ipairs(filter.recipes) do
        if v == recipe_name then
            index = i
            break
        end
    end
    if index ~= 0 then
        for i = index, 2, -1 do
            local tmp = filter.recipes[i]
            filter.recipes[i] = filter.recipes[i - 1]
            filter.recipes[i - 1] = tmp
        end
        filter.default_sort_values = table.invert(filter.recipes)
    end

    -- 送书
    local function give_player_starting_items(inst, items, starting_item_skins, give_item_fn)
        if items ~= nil and #items > 0 and inst.components.inventory ~= nil then
            inst.components.inventory.ignoresound = true
            if inst.components.inventory:GetNumSlots() > 0 then
                for i, v in ipairs(items) do
                    local skin_name = starting_item_skins and starting_item_skins[v];
                    local item = SpawnPrefab(v, skin_name, nil, inst.userid);
                    if item then
                        if give_item_fn then
                            give_item_fn(inst, items, starting_item_skins, skin_name, item);
                        end
                        inst.components.inventory:GiveItem(item);
                    end
                end
            else
                local spawned_items = {}
                for i, v in ipairs(items) do
                    local item = SpawnPrefab(v)
                    if item then
                        if item.components.equippable ~= nil then
                            inst.components.inventory:Equip(item)
                            table.insert(spawned_items, item)
                        else
                            item:Remove()
                        end
                    end
                end
                for i, v in ipairs(spawned_items) do
                    if v.components.inventoryitem == nil or not v.components.inventoryitem:IsHeld() then
                        v:Remove()
                    end
                end
            end
            inst.components.inventory.ignoresound = false
        end
    end
    env.AddPrefabPostInit("world", function(inst)
        if not TheWorld.ismastersim then
            return inst;
        end
        inst:ListenForEvent("ms_playerspawn", function(inst1, player)
            player.OnNewSpawn = morel_hook_fn(function()
                local old = player.OnNewSpawn
                return function(inst2, starting_item_skins)
                    give_player_starting_items(inst2, { "more_items_instruction_book" })
                    if old then return old(inst2, starting_item_skins) end
                end
            end)
        end)
    end)
end

more_items_instruction_book()
