---
--- @author zsh in 2023/1/10 20:01
---

local API = require("chang_mone.dsts.API");

-- 普通箱子、龙鳞宝箱、冰箱、盐盒关闭后自动整理
for _, p in ipairs({
    "treasurechest", "dragonflychest", "icebox", "saltbox",

    "mone_treasurechest", "mone_dragonflychest", "mone_icebox", "mone_saltbox",

    "mone_wardrobe", "mone_arborist", "mone_skull_chest",

    --"mone_piggyback",

    "mie_bear_skin_cabinet",
    "mie_fish_box",
    "mie_wooden_drawer",
    "mie_watersource",

    "mie_new_granary",

    "fish_box",

    "hiddenmoonlight",
}) do
    env.AddPrefabPostInit(p, function(inst)
        if not TheWorld.ismastersim then
            return inst;
        end

        if inst.components.container then
            local old_onclosefn = inst.components.container.onclosefn;
            inst.components.container.onclosefn = function(inst, ...)
                if old_onclosefn then
                    old_onclosefn(inst, ...);
                end

                API.arrangeContainer(inst);
            end
        end
    end)
end