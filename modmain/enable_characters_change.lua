---
--- Created by zsh.
--- DateTime: 2023/9/4 14:27
---

local config_data = TUNING.MONE_TUNING.GET_MOD_CONFIG_DATA;

-- 女武神
if config_data.wathgrithr_change_master_switch then
    -- 可吃素：2023-06-22：想删掉...
    if config_data.wathgrithr_vegetarian ~= 0 then
        env.modimport("modmain/Characters/wathgrithr/vegetarian.lua");
    end
end

-- 大力士
if config_data.wolfgang_change_master_switch then
    -- 不掉力量值 + 吃东西增加力量值
    if config_data.wolfgang_mightiness or config_data.wolfgang_mightiness_oneat then
        env.modimport("modmain/Characters/wolfgang/mightiness.lua");
    end
end

--[[
    -- 灵感参考
    * Willow 现在可以以她的理智为代价来熄灭燃烧的物体（可配置；默认：是）
    * Willow 现在不会从她杀死的敌人那里烧掉她的战利品（可配置；默认：是）。
    * 当 Willow 达到可能的最高温度（从 90 到 100 不等）时，她会在火焰中爆炸（可配置；默认值：是）。
    * Willow 消耗的耐久度是 Fire Staff 的一半，造成 25 点火焰伤害并在使用时获得理智（可配置；默认：是）。
    * Willow 现在在较高温度下会过热（可配置；默认值：80）。
    * 现在下雨时 Willow 会更快变湿（可配置；默认值：50%）。
    Willow 的打火机改动：
        * Willow 在使用打火机时不会消耗它的耐久度（可配置；默认：是）。
        * 如果使用 Willow 的打火机，它的发光半径现在会加倍（可配置；默认值：否）。
    伯尼的变化：
        * 伯尼！现在造成区域伤害，而不是每次攻击攻击一个敌人（可配置；默认：是）。
        * Bernie 现在可以减少 X% 的暗影生物伤害（可配置；默认值：70%）。
        * Bernie 被抱住时不再失去耐久度，现在可以被 Willow 拥抱以降低附近暗影生物的注意力并恢复 Willow 的理智（可配置；默认值：是）。
]]
-- 薇洛
if config_data.willow_change_master_switch then

    env.modimport("modmain/Characters/willow/items_modification.lua");
    env.modimport("modmain/Characters/willow/willow.lua");

    -- 伯尼改动
    if config_data.willow_bernie then
        env.modimport("modmain/Characters/willow/bernie.lua");
    end
    -- 修改攻击倍数
    if config_data.willow_externaldamagemultiplier then
        env.modimport("modmain/Characters/willow/externaldamagemultiplier.lua");
    end
    -- 不会烧掉战利品
    if config_data.willow_not_burning_loots then
        env.modimport("modmain/Characters/willow/not_burning_loots.lua");
    end
end