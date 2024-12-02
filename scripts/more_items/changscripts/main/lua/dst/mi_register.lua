---
--- @author zsh in 2023/3/4 11:59
---

-- 所有库存预制物的图片数据
local Data = {

    ["mone_walking_stick"] = { imagename = "", atlasname = "" },
    ["mone_spear_poison"] = { imagename = "spear_poison", atlasname = "images/DLC0002/inventoryimages.xml" },
    ["mone_harvester_staff"] = { imagename = "machete", atlasname = "images/DLC0002/inventoryimages.xml" },
    ["mone_harvester_staff_gold"] = { imagename = "goldenmachete", atlasname = "images/DLC0002/inventoryimages.xml" },
    ["mone_halberd"] = { imagename = "halberd", atlasname = "images/DLC0003/inventoryimages.xml" },

    ["mone_pith"] = { imagename = "pithhat", atlasname = "images/DLC0003/inventoryimages.xml" },
    ["mone_gashat"] = { imagename = "gashat", atlasname = "images/DLC0003/inventoryimages.xml" },
    ["mone_double_umbrella"] = { imagename = "", atlasname = "" },
    ["mone_brainjelly"] = { imagename = "", atlasname = "" },
    ["mone_bathat"] = { imagename = "", atlasname = "" },

    ["mone_wathgrithr_box"] = { imagename = "", atlasname = "" },
    ["mone_wanda_box"] = { imagename = "", atlasname = "" },
    ["mone_candybag"] = { imagename = "", atlasname = "" },
    ["mone_backpack"] = { imagename = "backpack", atlasname = "images/inventoryimages1.xml" },
    ["mone_piggyback"] = { imagename = "piggyback", atlasname = "" },
    ["mone_storage_bag"] = { imagename = "", atlasname = "" },
    ["mone_piggybag"] = { imagename = "", atlasname = "" },
    ["mone_waterchest_inv"] = { imagename = "", atlasname = "" },

    ["mone_poisonblam"] = { imagename = "", atlasname = "" },
    ["mone_waterballoon"] = { imagename = "", atlasname = "" },
    ["mone_pheromonestone"] = { imagename = "", atlasname = "" },

    ["mone_beef_wellington"] = { imagename = "", atlasname = "" },
    ["mone_chicken_soup"] = { imagename = "", atlasname = "" },
    ["mone_lifeinjector_vb"] = { imagename = "", atlasname = "" },
    ["mone_stomach_warming_hamburger"] = { imagename = "", atlasname = "" },
    ["mone_honey_ham_stick"] = { imagename = "", atlasname = "" },
    ["mone_guacamole"] = { imagename = "", atlasname = "" },

    fns = {

    }
};

-- 提供个给 modmain.lua 的接口，用于批量修改预制物
function Data.fns.InventoryItemImageAtlas(env)
    for k, v in pairs(Data) do
        if k ~= "fns" then
            local TheWorld = env.GLOBAL.TheWorld;
            env.AddPrefabPostInit(k, function(inst)
                if not TheWorld.ismastersim then
                    return inst;
                end
                if inst.component.inventoryitem then
                    inst.components.inventoryitem.imagename = v.imagename;
                    inst.components.inventoryitem.atlasname = v.atlasname;
                end
            end)
        end
    end
end

-- 提供个给配方栏的接口，修改 config.image 和 config.atlas
function Data.fns.RecipeImagesAtlas(recipes)
    for k, image_atlas in pairs(Data) do
        if k ~= "fns" then
            for _, v in ipairs(recipes) do
                if v.name and v.name == k and v.config --[[and v.isklei == nil]] then
                    v.config.atlas = image_atlas.atlasname;
                    v.config.image = image_atlas.imagename;
                end
            end
        end
    end
end

return Data;