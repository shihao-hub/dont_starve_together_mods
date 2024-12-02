---
--- @author zsh in 2023/1/9 17:05
---

local API = require("chang_mone.dsts.API");

local config_data = TUNING.MONE_TUNING.GET_MOD_CONFIG_DATA;

-- 2023-05-20：有机会自己实现一个快捷装备栏
--[[ 兼容自用的本地 mod，添加 mone_portable_container 标签]]
do
    for _, p in ipairs({
        "mone_storage_bag", "mone_piggybag", "mone_tool_bag",
        "mone_backpack", "mone_candybag", "mone_icepack",
        -- 这两个大容器排除掉吧！这个快捷装备栏模组性能不行，会卡顿！！！
        -- 花了一个下午找到原因了。。。。。。
        --"mone_piggyback", "mone_waterchest_inv",
        "mone_wathgrithr_box", "mone_wanda_box"
    }) do
        env.AddPrefabPostInit(p, function(inst)
            inst:AddTag("mone_portable_container");
        end)
    end
end

-- 注意这两个常数非常重要
TUNING.MONE_TUNING.IGICF_FLAG_NAME = "mone_priority_container_flag";
TUNING.MONE_TUNING.IGICF_TAG = "mone_item_go_into_container_first_tag";


-- 2023-02-16-14:42：这部分内容，我觉得我是有必要重写一下的......
-- 2023-05-20：呃，我还是没有重写。
-- 2023-05-29：呃，物品优先进容器和自动分拣机都要重写，我目前还没有重写...我好难受。
--[[ 物品优先进容器 ]]
do
    if TUNING.MONE_TUNING.GET_MOD_CONFIG_DATA.IGICF then
        env.AddPrefabPostInitAny(function(inst)
            if not TheWorld.ismastersim then
                return inst;
            end
            if inst.components.container == nil then
                return inst;
            end

            -- 记得给指定的那个预制物添加这个标签
            if inst:HasTag(TUNING.MONE_TUNING.IGICF_TAG) then
                local old_onopenfn = inst.components.container.onopenfn;
                inst.components.container.onopenfn = function(inst, data)
                    if old_onopenfn then
                        old_onopenfn(inst, data);
                    end

                    if inst.more_items_task then
                        inst.more_items_task:Cancel();
                        inst.more_items_task = nil;
                    end

                    inst.more_items_task = inst:DoPeriodicTask(API.ItemsGICF.redirectItemFlagAndGetTime(inst), function()
                        API.ItemsGICF.redirectItemFlagAndGetTime(inst);
                    end)
                end

                local old_onclosefn = inst.components.container.onclosefn;
                inst.components.container.onclosefn = function(inst, data)
                    if old_onclosefn then
                        old_onclosefn(inst, data);
                    end

                    if inst.more_items_task then
                        inst.more_items_task:Cancel();
                        inst.more_items_task = nil;
                    end

                    API.ItemsGICF.redirectItemFlagAndGetTime(inst);
                end

                API.ItemsGICF.setListenForEvent(inst);
            end
        end)

        ---之前就有个小问题，我用 “只为解决这个问题的方法暂时解决了”，有待优化
        env.AddComponentPostInit("inventory", function(self)
            local priority = {
                ["mone_candybag"] = -99999,
                ["mone_storage_bag"] = 0, -- 保鲜袋要不算了？
                ["mone_icepack"] = 1,
                ["mone_wanda_box"] = 1.5,
                ["mone_backpack"] = 2,
                ["mone_tool_bag"] = 2.5,
                ["mone_piggybag"] = 3,
                ["mone_seedpouch"] = 4,
                ["mone_wathgrithr_box"] = 99999,
            };

            -- 猪猪袋优先级高于装备袋
            priority["mone_piggybag"] = priority["mone_backpack"] + 0.0001;

            if TUNING.MONE_TUNING.GET_MOD_CONFIG_DATA.IGICF_mone_piggyback then
                priority["mone_piggyback"] = -1;
            end

            if TUNING.MONE_TUNING.GET_MOD_CONFIG_DATA.IGICF_waterchest_inv then
                priority["mone_waterchest_inv"] = -2;
            end

            --[[ 兼容能力勋章 ]]
            if TUNING.FUNCTIONAL_MEDAL_IS_OPEN then
                priority["medal_box"] = 99999;
                priority["medal_ammo_box"] = 99999;
            end

            API.ItemsGICF.itemsGoIntoContainersFirst(self, priority);
        end)

    end

    -- 2023-02-16-09:01：我应该直接用 for 循环生成的！
    local need_tag_prefabs = {
        --"mone_waterchest_inv", -- 这两个大容量的不能这样！
        --"mone_piggyback",
        "mone_wathgrithr_box",
        "mone_backpack",
        "mone_storage_bag",
        "mone_piggybag",
        "mone_seedpouch",
        "mone_wanda_box",
        "mone_candybag",
        "mone_icepack",
        "mone_tool_bag"
        --"mie_book_silviculture" -- 懒人书
    };

    -- 2023-03-10-13:15：大容量的不能这样。
    -- 除非的加个判断 tag，如果是通过我的整理函数整理的，就不会监听！
    -- 确实可以如此！
    -- ? 不对啊，为什么没有生效。。。
    -- 为什么收纳袋一键整理就卡顿，海上箱子却很流畅？
    if TUNING.MONE_TUNING.GET_MOD_CONFIG_DATA.IGICF_mone_piggyback then
        table.insert(need_tag_prefabs, "mone_piggyback");
    end

    if TUNING.MONE_TUNING.GET_MOD_CONFIG_DATA.IGICF_waterchest_inv then
        table.insert(need_tag_prefabs, "mone_waterchest_inv");
    end

    --[[ 兼容能力勋章 ]]
    if TUNING.FUNCTIONAL_MEDAL_IS_OPEN then
        table.insert(need_tag_prefabs, "medal_box");
        table.insert(need_tag_prefabs, "medal_ammo_box");
    end

    for _, p in ipairs(need_tag_prefabs) do
        env.AddPrefabPostInit(p, function(inst)
            inst:AddTag(TUNING.MONE_TUNING.IGICF_TAG);
        end)
    end
end


--[[ 被冰冻后容器会被关闭，设置一下重新打开 ]]
do
    local function isMyContainers(inst)
        local cons = {
            "mone_candybag", -- 材料袋
            "mone_backpack", -- 装备袋
            "mone_piggyback", -- 收纳袋
            "mone_storage_bag", -- 保鲜袋
            "mone_icepack", -- 食物袋
            "mone_tool_bag", -- 材料袋
            "mone_piggybag", -- 猪猪袋
            "mone_wathgrithr_box", -- 女武神歌谣盒
            "mone_wanda_box", -- 旺达钟表盒
            "mie_book_silviculture", -- 懒人书
            "mie_book_horticulture", -- 懒人书+
        };
        for _, v in ipairs(cons) do
            if inst.prefab == v then
                return true;
            end
        end
        return false;
    end
    local function hideHook(self)
        local old_Hide = self.Hide
        function self:Hide()
            --先将不受特殊效果而关闭的容器存起来
            local cons = {}
            for k, _ in pairs(self.opencontainers) do
                if isMyContainers(k) then
                    if k.components.container.openlist then
                        for opener, _ in pairs(k.components.container.openlist) do
                            if k.components.inventoryitem and k.components.inventoryitem:IsHeldBy(opener) then
                                table.insert(cons, { container = k, doer = opener })
                            end
                        end
                    end
                end
            end
            if old_Hide then
                old_Hide(self);
            end
            for _, v in ipairs(cons) do
                if v.container and v.doer then
                    if not v.container.components.container:IsOpen() then
                        v.container.components.container:Open(v.doer)
                    end
                end
            end
        end
    end
    env.AddComponentPostInit("inventory", hideHook);
end

--[[ 防止我的容器在黑暗中自动关闭 ]]
do
    env.AddComponentPostInit("inventoryitem", function(self)
        local old_IsHeldBy = self.IsHeldBy
        self.IsHeldBy = function(self, guy)
            if self.owner and self.owner.components.container then
                if self.owner.components.inventoryitem and self.owner.components.inventoryitem.owner == guy then
                    return true
                end
            end
            return old_IsHeldBy(self, guy)
        end
    end)
end

--[[ 猴子不会偷：这个好像是海上猴子不会偷而已... ]]
do
    for _, p in ipairs({
        "mone_candybag", -- 材料袋
        "mone_backpack", -- 装备袋
        "mone_icepack", -- 食物袋
        "mone_piggyback", -- 收纳袋
        "mone_nightspace_cape", -- 暗影斗篷
        "mone_seasack", -- 种子袋
        "mone_storage_bag", -- 保鲜袋
        "mone_brainjelly", -- 智慧帽
        "mone_bathat", -- 蝙蝠帽
        "mone_piggybag", -- 猪猪袋
        "mone_waterchest_inv", -- 海上箱子
        "mone_redlantern" -- 灯笼
    }) do
        env.AddPrefabPostInit(p, function(inst)
            inst:AddTag("nosteal");
        end)
    end
end

--[[ 处理一下老麦使用暗影秘典的问题 ]]
do
    -- 2023-05-02：先算了！
    --local playerhud = require("screens/playerhud");
    --if playerhud then
    --    local old_CloseContainer = playerhud.CloseContainer;
    --    if old_CloseContainer then
    --        function playerhud:CloseContainer(container, side, ...)
    --            print("self.inst: " .. tostring(self.inst));
    --            if self.inst and self.inst.HasTag
    --                    and self.inst:HasTag("player") and self.inst:HasTag("shadowmagic") then
    --                print("self.inst: " .. tostring(self.inst));
    --                if container and container.inst then
    --                    print("container.inst: " .. tostring(container.inst));
    --                    if table.contains({
    --                        "mone_storage_bag", "mone_piggybag", "mone_tool_bag",
    --                        "mone_backpack", "mone_candybag", "mone_icepack", "mone_piggyback",
    --                        "mone_waterchest_inv",
    --                        "mone_wathgrithr_box", "mone_wanda_box",
    --
    --                        "mie_book_silviculture", "mie_book_horticulture",
    --                    }, container.inst.prefab) then
    --                        side = true;
    --                    end
    --                end
    --            end
    --            if old_CloseContainer then
    --                return old_CloseContainer(self, container, side, ...);
    --            end
    --        end
    --    end
    --end
end

