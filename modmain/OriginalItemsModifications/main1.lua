---
--- @author zsh in 2023/4/24 14:42
---

local config_data = TUNING.MONE_TUNING.GET_MOD_CONFIG_DATA;

local DATA = config_data.original_items_modifications_data;

if not config_data.original_items_modifications --[[总开关]] then
    return ;
end

if IsModEnabled("2039181790") --[[永不妥协]] then
    --config_data.wateringcan = false;
    config_data.premiumwateringcan = false;
    --config_data.telebase = false;
end

if IsModEnabled("2886753796") --[[为爽而虐]] then
    --config_data.beef_bell = false;
end

if IsModEnabled("2788995386") --[[巨兽掉落加强]] then
    --config_data.hivehat = false;
    --config_data.eyemaskhat = false;
    --config_data.shieldofterror = false;
    return ;
end

if IsModEnabled("1909182187") --[[能力勋章]] then

end

--[[
    备忘一下：
    -- 1. 注意和其他同样修改了原版物品的模组的兼容性。
    -- 2. 注意函数命名 prefabname_onpreload、prefabname_onload
    -- 3. 给物品加容器的时候记得 params 表中的项和预制物匹配起来。因为客户端是不会执行 OnLoad 函数的。
    -- 4. config_data.XXX 的命名请和 prefabname 保持一致。

    代码相关说明：
    -- 0. 这些说明可能是因为最初我的代码逻辑就有问题...
    -- 1. onpreload 函数中添加组件！ onload 函数中不要添加组件！
    ---- 游戏内给物品添加组件的话，就得这样，因为 onpreload(...) -> 添加各种保存的组件、执行各种组件的 OnLoad 函数 -> onload(...)
    -- 2. onload 函数里面不要做任何类似护甲：condition 和 maxcondition，condition 不能修改...
    ---- 因为 onload 函数是在 保存的组件以及组件的 OnLoad 函数执行之后再执行的。我修改了就是破坏了内容...
    -- 3. 组件的 OnLoad 函数先于实体的 OnLoad 函数执行......
]]

-- 不需要了！
config_data.eyemaskhat = false;
config_data.shieldofterror = false;
config_data.whip = false;

DATA.items_fns = {
    batbat = { CanMake = config_data.batbat; },
    nightstick = { CanMake = config_data.nightstick; },
    whip = { CanMake = config_data.whip; },
    wateringcan = { CanMake = config_data.wateringcan; },
    premiumwateringcan = { CanMake = config_data.premiumwateringcan; },
    hivehat = { CanMake = config_data.hivehat; },
    eyemaskhat = { CanMake = config_data.eyemaskhat; },
    shieldofterror = { CanMake = config_data.shieldofterror; },
}

local SWITCH;
for name, v in pairs(DATA.items_fns) do
    if v.CanMake then
        if not SWITCH then
            SWITCH = true;
        end
        print("original item: `" .. name .. "` takes effect!");
    end
end

if not SWITCH then
    return ;
end

env.modimport("modmain/OriginalItemsModifications/dependencies/containers.lua");
env.modimport("modmain/OriginalItemsModifications/dependencies/recipes.lua");

env.modimport("modmain/OriginalItemsModifications/dependencies/modifications.lua");