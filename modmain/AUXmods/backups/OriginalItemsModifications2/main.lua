---
--- @author zsh in 2023/4/24 14:42
---

local config_data = TUNING.MONE_TUNING.GET_MOD_CONFIG_DATA;

local DATA = config_data.original_items_modifications_data;

if not config_data.original_items_modifications --[[总开关]] then
    return ;
end

if IsModEnabled("2039181790") --[[永不妥协]]then
    config_data.wateringcan = false;
    config_data.premiumwateringcan = false;
    --config_data.telebase = false;
end

if IsModEnabled("2886753796") --[[为爽而虐]]then
    --config_data.beef_bell = false;
end

if IsModEnabled("2788995386") --[[巨兽掉落加强]]then

end

if IsModEnabled("1909182187") --[[能力勋章]]then

end

DATA.original_items = {
    batbat = config_data.batbat;
    nightstick = config_data.nightstick;
    whip = config_data.whip;
    wateringcan = config_data.wateringcan;
    premiumwateringcan = config_data.premiumwateringcan;
    hivehat = config_data.hivehat;
    eyemaskhat = config_data.eyemaskhat;
    shieldofterror = config_data.shieldofterror;
}

local SWITCH;
for _, switch in pairs(DATA.original_items) do
    if switch then
        SWITCH = true;
        break ;
    end
end
if SWITCH ~= true then
    return ;
end

env.modimport("modmain/OriginalItemsModifications2/dependencies/containers.lua");
env.modimport("modmain/OriginalItemsModifications2/dependencies/recipes.lua");

env.modimport("modmain/OriginalItemsModifications2/dependencies/modifications.lua");