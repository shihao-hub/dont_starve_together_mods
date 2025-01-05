---
--- Created by zsh
--- DateTime: 2023/10/31 2:32
---

setfenv(1, _G)

--[[
    灵感：某玩家 23/10/30
    指南针：有个小格子，给予对应物品，地图上可探测到对应怪物或物品（如给骨片可找到无眼鹿，老鼠尾巴显示老鼠洞）
    南瓜灯:现在具有微弱恢复精神功能，可用盐修复
    强化版启迪之冠，给启迪之冠加上铥矿头效果，以及防风暴，防水
    花伞：增加蝴蝶出现概率，与黄油出现概率
    毛皮铺盖：可修复
    帐篷卷：次数减半，恢复加倍(加个小格子可以放入提灯或萤火虫瓶子）
    烹饪指南：携带在身上可加速烹饪，烤东西（这玩意解锁完就没人碰过吧）
    便便桶：可添加肥料修复耐久
    雨量计：下雨天塞进去青蛙腿可概率召唤青蛙雨，盐块会概率停雨（科学赌狗）
    温度计：高温或低温时候晚上会发光
    饥饿腰带：可暂停大力士肌肉值掉落，穿戴去健身时候效果加倍
    天文护目镜：可显示科学家位置
]]
local prefab_names = {
    "compass", -- 指南针
    --"pumpkin_lantern", -- 南瓜灯 TEMP ABANDON
    "alterguardianhat", -- 启迪之冠
    "grass_umbrella", -- 花伞
    --"bedroll_furry", -- 毛皮铺盖 TEMP ABANDON
    --"portabletent_item", -- 帐篷卷 TEMP ABANDON
    "cookbook", -- 烹饪指南
    --"fertilizer", -- 便便桶

    "rainometer", -- 雨量计
    "rainometer_placer",

    "winterometer", -- 温度计
    "winterometer_placer",

    "armorslurper", -- 饥饿腰带
    "moonstorm_goggleshat", -- 天文护目镜
}

local prefabs = {}

for i, name in ipairs(prefab_names) do
    local p = Prefabs[name]
    if p then
        table.insert(prefabs, Prefab("more_" .. name, p.fn, p.assets, p.deps, p.force_path_search))
    end
end

return unpack(prefabs)