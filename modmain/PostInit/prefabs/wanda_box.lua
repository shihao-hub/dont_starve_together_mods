---
--- @author zsh in 2023/1/23 4:36
---


local prefabs = {
    "pocketwatch_revive", -- 第二次机会表
    "pocketwatch_heal", --不老表
    "pocketwatch_weapon", --警告表 武器
    --"pocketwatch_warp", --倒走表（这确实不应该允许放）
    "pocketwatch_dismantler", --钟表匠工具
    "pocketwatch_revive", --第二次机会表

    -- 我觉得不应该可以放材料，就应该纯粹一点！
    "nightmarefuel", -- 噩梦燃料
    "pocketwatch_parts", --时间碎片

    --"livinglog", -- 活木
    "marble", -- 大理石
    --"rope", -- 草绳
}
if TUNING.MONE_TUNING.GET_MOD_CONFIG_DATA.mone_wanda_box_itemtestfn_extra1 then
    table.insert(prefabs, "pocketwatch_warp"); -- 倒走表
end
if TUNING.MONE_TUNING.GET_MOD_CONFIG_DATA.mone_wanda_box_itemtestfn_extra2 then
    table.insert(prefabs, "pocketwatch_portal"); -- 裂缝表
    table.insert(prefabs, "pocketwatch_recall"); -- 溯源表
end
for _, p in ipairs(prefabs) do
    env.AddPrefabPostInit(p, function(inst)
        inst:AddTag("mone_wanda_box_itemtestfn");
        if p == "pocketwatch_revive" then
            inst:AddTag("mone_wanda_box_pocketwatch_revive");
        end
    end)
end

env.AddPrefabPostInit("wanda", function(inst)
    if not TheWorld.ismastersim then
        return inst;
    end
    inst:ListenForEvent("death", function(inst)
        -- 此处先执行还是掉落所有物品先执行？
        -- 监听设置在inventory组件的构造函数中。所以此处为后发？错！此处确实执行了的。。。不确定。。。
        local inventory = inst.components.inventory;
        if inventory then
            local boxs = inventory:FindItems(function(item)
                return item and item.prefab == "mone_wanda_box";
            end) or {};
            local pocketwatch_revive;
            for _, con in ipairs(boxs) do
                local container = con.components.container;
                if container then
                    pocketwatch_revive = container:FindItem(function(item)
                        return item and item.prefab == "pocketwatch_revive";
                    end);
                    if pocketwatch_revive then
                        container:DropEverythingWithTag("mone_wanda_box_pocketwatch_revive");
                        break ; -- 只找到第一个就跳出循环
                    end
                end
            end
        end

        -- 查找周围目标
        --local x, y, z = inst.Transform:GetWorldPosition();
        --local boxs = TheSim:FindEntities(x, y, z, 8, { "mone_wanda_box" }, nil) or {};
        --local pocketwatch_revive;
        --for _, con in ipairs(boxs) do
        --    local container = con.components.container;
        --    if container then
        --        pocketwatch_revive = container:FindItem(function(item)
        --            return item and item.prefab == "pocketwatch_revive";
        --        end);
        --        if pocketwatch_revive then
        --            container:DropEverythingWithTag("mone_wanda_box_pocketwatch_revive");
        --            break ;
        --        end
        --    end
        --end
    end);
end)

env.AddPlayerPostInit(function(inst)
    if not TheWorld.ismastersim then
        return inst;
    end
    -- 查找装备袋里有没有重生护符？算了，太麻烦。
    --inst:ListenForEvent("death", function(inst)
    --    -- 此处先执行还是掉落所有物品先执行？
    --    -- 监听设置在inventory组件的构造函数中。所以此处为后发？错！此处确实执行了的。。。不确定。。。
    --    local inventory = inst.components.inventory;
    --    if inventory then
    --        local boxs = inventory:FindItems(function(item)
    --            return item and item.prefab == "mone_wanda_box";
    --        end) or {};
    --        local pocketwatch_revive;
    --        for _, con in ipairs(boxs) do
    --            local container = con.components.container;
    --            if container then
    --                pocketwatch_revive = container:FindItem(function(item)
    --                    return item and item.prefab == "pocketwatch_revive";
    --                end);
    --                if pocketwatch_revive then
    --                    container:DropEverythingWithTag("mone_wanda_box_pocketwatch_revive");
    --                    break ; -- 只找到第一个就跳出循环
    --                end
    --            end
    --        end
    --    end
    --end);
end)