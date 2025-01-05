---
--- @author zsh in 2023/3/24 13:08
---

--\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
-- 备注一下 --\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
--\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
--[[
    2023-03-25-20:00：
    配合 游戏内主菜单 模组使用非常不方便，因为会直接读取 modworldgenmain.lua 文件，
    然后进入游戏就报奇怪的错误。HasTag(TUNING.MONE_TUNING.XXX)报错，不知道为什么。

    等繁花更新之后再启用！
    到时候 modtuning.lua 接在在 modworldgenmain.lua 里导入，modmain.lua 里面的删除就行了。

    PS: 还有个奇怪的问题。
    此处和原模组同时开启的时候，砖石路铲除之后没有掉落物。其他地皮有，但是掉落我自己的。mone_前缀那个。
    还好是我自己使用的。主要和 terraformer 组件有关，还有就是地皮编号相互覆盖了。
    之后试试单开我自己的会不会出问题。
]]
--config_data.hamlet_ground = false; -- 算了，问题太多了！还有底层错误。。。不想解决了。
-- 哈姆雷特地皮
--if config_data.hamlet_ground then
--    env.modimport("scripts/mi_modules/hamlet_ground/modmain.lua");
--end



-- 环境设置
local ENV = TUNING.MONE_TUNING.MI_MODULES.HAMLET_GROUND.ENV;
setfenv(1, ENV);

-- 变量局部化，从需要检索全局表变成闭包一个指针
local _G = GLOBAL
local GROUND = _G.GROUND
local require = _G.require
local TECH = _G.TECH
local RECIPETABS = _G.RECIPETABS
local Ingredient = _G.Ingredient

-- 预制物文件和资源导入
table.insert(env.PrefabFiles, "mi_modules/hamlet_ground");
table.insert(env.Assets, Asset("IMAGE", "scripts/mi_modules/hamlet_ground/images/inventoryimages/hamletturfs.tex"));
table.insert(env.Assets, Asset("ATLAS", "scripts/mi_modules/hamlet_ground/images/inventoryimages/hamletturfs.xml"));

-- 内容汉化
modimport("scripts/mi_modules/hamlet_ground/scripts/strings_chs.lua")

-- 添加小地图图标
AddMinimap();
--------------------------------------------------------------------------------------------------------------
--[[ 添加配方 ]]
--------------------------------------------------------------------------------------------------------------
local function DoAddRecipe0(prefab, ig, num, tech)
    num = 4 -- num or 1
    tech = tech or TECH.SCIENCE_TWO
    AddRecipe("mone_" .. prefab, ig, RECIPETABS.TOWN, tech, nil, nil, nil, num, nil, MORE_ITEMS_MODULES_HAMLET_GROUND_ROOT .. "images/inventoryimages/hamletturfs.xml", prefab .. ".tex")
end

-- NEW!
local function DoAddRecipe(prefab, ig, num, tech)
    num = 4; -- num or 1
    tech = TECH.SCIENCE_TWO; -- tech or TECH.SCIENCE_TWO
    env.AddRecipe2("mone_" .. prefab, ig, tech, {
        placer = nil,
        min_spacing = nil,
        nounlock = nil,
        numtogive = 4,
        builder_tag = nil,
        atlas = "scripts/mi_modules/hamlet_ground/images/inventoryimages/hamletturfs.xml",
        image = prefab .. ".tex"
    }, {
        "MONE_MORE_ITEMS_DECOR"
    })
end

local recipes = {
    turf_pigruins = { ig = { Ingredient("rocks", 2), --[[Ingredient("nitre", 1)]] } },
    turf_rainforest = { ig = { Ingredient("turf_forest", 1), Ingredient("pinecone", 1) }, tech = TECH.SCIENCE_ONE },
    turf_deeprainforest = { ig = { Ingredient("turf_forest", 1), Ingredient("acorn", 1) }, tech = TECH.SCIENCE_ONE },
    turf_lawn = { ig = { Ingredient("cutgrass", 1), --[[Ingredient("nitre", 1),]] Ingredient("petals", 1) } },
    turf_gasjungle = { ig = { Ingredient("turf_forest", 1), Ingredient("poop", 1) }, tech = TECH.SCIENCE_ONE },
    turf_moss = { ig = { Ingredient("turf_grass", 1), Ingredient("seeds", 1) } },
    turf_fields = {
        ig = { Ingredient("turf_rainforest", 1, "scripts/mi_modules/hamlet_ground/images/inventoryimages/hamletturfs.xml"), Ingredient("ash", 1) }
    },
    turf_foundation = { ig = { Ingredient("cutstone", 1) } },
    turf_cobbleroad = { ig = { Ingredient("cutstone", 1), Ingredient("boards", 1) }, num = 2 }
}

for prefab, data in pairs(recipes) do
    DoAddRecipe(prefab, data.ig, data.num, data.tech)
end
--------------------------------------------------------------------------------------------------------------
--[[ locomotor 组件修改 ]]
--------------------------------------------------------------------------------------------------------------
env.AddComponentPostInit("locomotor", function(inst)
    local old = inst.UpdateGroundSpeedMultiplier
    inst.UpdateGroundSpeedMultiplier = function(self)
        old(self)
        if self.wasoncreep == false and self:FasterOnRoad()
                and _G.TheWorld.Map:GetTileAtPoint(self.inst.Transform:GetWorldPosition()) == GROUND.COBBLEROAD
        then
            self.groundspeedmultiplier = self.fastmultiplier
        end
    end
end)

