---
--- @author zsh in 2023/2/8 16:49
---

local config_data = TUNING.MIE_TUNING.MOD_CONFIG_DATA;

local data = {};

data["池塘1"] = {
    CanMake = config_data.ponds,
    fn = function()
        return "pond_placer", "marsh_tile", "marsh_tile", "idle", true;
    end
}

data["池塘2"] = {
    CanMake = config_data.ponds,
    fn = function()
        return "pond_cave_placer", "marsh_tile", "marsh_tile", "idle_cave", true; -- 第五个变量设置旋转方向
    end
}

data["池塘3"] = {
    CanMake = config_data.ponds,
    fn = function()
        return "pond_mos_placer", "marsh_tile", "marsh_tile", "idle_mos", true;
    end
}

data["池塘4"] = {
    CanMake = config_data.ponds,
    fn = function()
        return "lava_pond_placer", "lava_tile", "lava_tile", "bubble_lava", true;
    end
}

data["月台"] = {
    CanMake = config_data.moonbase,
    fn = function()
        return "moonbase_placer", "moonbase", "moonbase", "med";
    end
}

data["老奶奶的晾肉架"] = {
    CanMake = config_data.meatrack_hermit,
    fn = function()
        return "meatrack_hermit_placer", "meatrack_hermit", "meatrack_hermit", "idle_empty";
    end
}

data["老奶奶的蜂箱"] = {
    CanMake = config_data.beebox_hermit,
    fn = function()
        return "beebox_hermit_placer", "bee_box_hermitcrab", "bee_box_hermitcrab", "idle";
    end
}

---@deprecated 且待完成
data["香蕉树"] = {
    CanMake = config_data.cave_banana_tree,
    fn = function()
        return "cave_banana_tree_placer", "cave_banana_tree", "cave_banana_tree", "idle_loop";
    end
}

data["中空树桩"] = {
    CanMake = config_data.catcoonden,
    fn = function()
        return "catcoonden_placer", "catcoon_den", "catcoon_den", "idle";
    end
}

data["猪人火炬"] = {
    CanMake = config_data.pigtorch,
    fn = function()
        return "pigtorch_placer", "pigtorch", "pig_torch", "idle";
    end
}

data["高脚鸟巢穴"] = {
    CanMake = config_data.tallbirdnest,
    fn = function()
        return "tallbirdnest_placer", "egg", "tallbird_egg", "eggnest";
    end
}

data["蛞蝓鬼巢穴"] = {
    CanMake = config_data.slurtlehole,
    fn = function()
        return "slurtlehole_placer", "slurtle_mound", "slurtle_mound", "idle";
    end
}


local placers = {};

for k, v in pairs(data) do
    if v.CanMake then
        table.insert(placers, MakePlacer(v.fn()));
    end
end

return unpack(placers);