---
--- @author zsh in 2023/1/8 14:13
---

setfenv(1, _G)
local API = {};

-- 23/10/29 神话书说的更新似乎导致不能这样了
--package.loaded["chang_mone.dsts.API"] = API; -- 避免循环加载，而且 require 的形式也必须是 .

local function contains_key(t, e)
    for k, _ in pairs(t) do
        if k == e then
            return true;
        end
    end
    return false;
end

local function contains_value(t, e)
    for _, v in pairs(t) do
        if v == e then
            return true;
        end
    end
    return false;
end


-----------------------------------------------------------------------------
-- PUBLIC FUNCTIONS IMPLEMENTATIONS
-----------------------------------------------------------------------------

local ac_fns = {
    printStrSeq = function(list)
        local msg = {};
        for _, v in ipairs(list) do
            table.insert(msg, tostring(v.prefab));
        end
        print("{ " .. table.concat(msg, ",") .. " }");
    end,
    cmp = function(p1, p2)
        if not (p1 and p2) then
            --print("", "??? cmp-p1: " .. tostring(p1));print("", "??? cmp-p2: " .. tostring(p2));
            return ;
        end
        return tostring(p1.prefab) < tostring(p2.prefab) and true or false;
    end,
    isEquippable = function(inst)
        return inst.components.equippable;
    end,
    isStackable = function(inst)
        return inst.components.stackable;
    end,
    isPerishable = function(inst)
        return inst.components.perishable;
    end,
    isEdible = function(inst)
        return inst.components.edible;
    end,
    hasPercent = function(inst)
        if inst.components.fueled
                or inst.components.finiteuses
                or inst.components.armor
        then
            return true;
        end
        return false;
    end,
    isCHARACTER = function(inst)
        local recipes = CRAFTING_FILTERS.CHARACTER.recipes;
        if recipes and type(recipes) == "table" then
            for _, v in ipairs(recipes) do
                if inst.prefab == v then
                    return true;
                end
            end
        end
        return false;
    end,
    isREFINE = function(inst)
        if inst.prefab == "bearger_fur" then
            return false;
        end
        local recipes = CRAFTING_FILTERS.REFINE.recipes;
        if recipes and type(recipes) == "table" then
            for _, v in ipairs(recipes) do
                if inst.prefab == v then
                    return true;
                end
            end
        end
        return false;
    end,
    isRESTORATION = function(inst)
        -- 遍历治疗制作栏
        local recipes = CRAFTING_FILTERS.RESTORATION.recipes;
        if recipes and type(recipes) == "table" then
            for _, v in ipairs(recipes) do
                if inst.prefab == v then
                    return true;
                end
            end
        end
        if inst.prefab == "jellybean" then
            return true;
        end
        return false;
    end,
    isSilkFabric = function(inst)
        if inst:HasTag("cattoy")
                or inst.prefab == "silk"
                or inst.prefab == "bearger_fur"
                or inst.prefab == "furtuft"
                or inst.prefab == "shroom_skin"
                or inst.prefab == "dragon_scales"
        then
            --print("isSilkFabric: "..tostring(inst.prefab));
            return true;
        end
        return false;
    end,
    isRocks = function(inst)
        if inst:HasTag("molebait")
                or inst.prefab == "townportaltalisman"
                or inst.prefab == "moonrocknugget"
        then
            return true;
        end
        return false;
    end,
    genericResult = function(...)
        local args = { ... };
        local result = {};
        if #args > 0 then
            for _, tab in ipairs(args) do
                for _, v in ipairs(tab) do
                    table.insert(result, v);
                end
            end
        end
        return result;
    end
}

-- 注意每个ifelse的判定块都必须有一张表存在，不然会丢东西。
-- 2023-06-22：后续优化方向：改为基数排序(不对，感觉目前的思路可能最优了？emm，再想想...)实现该排序算法！
-- 辅助空间 O(n) 时间复杂度也还好，就遍历一次
---@param slots table[] Prefab
local function preciseClassification(slots)
    local equippable = { perishable = {}, non_percentage = {}, hands = {}, head = {}, body = {}, rest = {} }
    local non_stackable = { perishable = {}, rest = {}, }
    local stackable = { perishable = {}, rest = { } } -- 由于扩充表的存在，perishable 算是 rest。
    -- 扩充表内容。注意此处请提前初始化完毕，不然会弄混！
    local stackable_perishable = {
        deployedfarmplant = {},
        preparedfood = {
            edible_veggie = {},
            edible_meat = {},
            rest = {}
        },
        edible_veggie = {},
        edible_meat = {}
    }

    -- 初始化表。注意新加表的时候必须在此处初始化！
    equippable.perishable = equippable.perishable or {};
    equippable.non_percentage = equippable.non_percentage or {};
    equippable.hands = equippable.hands or {};
    equippable.head = equippable.head or {};
    equippable.body = equippable.body or {};
    equippable.rest = equippable.rest or {};

    non_stackable.perishable = non_stackable.perishable or {};
    non_stackable.rest[1] = non_stackable.rest[1] or {};
    non_stackable.rest[2] = non_stackable.rest[2] or {};

    stackable.perishable = stackable.perishable or {};
    stackable.rest[1] = stackable.rest[1] or {};
    stackable.rest[2] = stackable.rest[2] or {};
    stackable.rest[3] = stackable.rest[3] or {};
    stackable.rest[4] = stackable.rest[4] or {};
    stackable.rest[5] = stackable.rest[5] or {};
    stackable.rest[6] = stackable.rest[6] or {};
    stackable.rest[7] = stackable.rest[7] or {};
    stackable.rest[8] = stackable.rest[8] or {};
    stackable.rest[9] = stackable.rest[9] or {};

    slots = slots or {};

    if #slots > 0 then
        for _, v in ipairs(slots) do
            if ac_fns.isEquippable(v) then
                local equipslot = v.components.equippable.equipslot;
                if ac_fns.isPerishable(v) then
                    table.insert(equippable.perishable, v);
                elseif not ac_fns.hasPercent(v) or (ac_fns.hasPercent(v) and v:HasTag("hide_percentage")) then
                    table.insert(equippable.non_percentage, v);
                elseif equipslot == EQUIPSLOTS.HANDS then
                    table.insert(equippable.hands, v);
                elseif equipslot == EQUIPSLOTS.HEAD then
                    table.insert(equippable.head, v);
                elseif equipslot == EQUIPSLOTS.BODY then
                    table.insert(equippable.body, v);
                else
                    table.insert(equippable.rest, v); -- 剩余
                end
            elseif not ac_fns.isStackable(v) then
                if ac_fns.isPerishable(v) then
                    table.insert(non_stackable.perishable, v);
                elseif ac_fns.hasPercent(v) then
                    table.insert(non_stackable.rest[1], v);
                else
                    table.insert(non_stackable.rest[2], v); -- 剩余
                end
            else
                if ac_fns.isPerishable(v) then
                    if v:HasTag("deployedfarmplant") then
                        table.insert(stackable_perishable.deployedfarmplant, v);
                    elseif v:HasTag("preparedfood") then
                        if ac_fns.isEdible(v) then
                            if v.components.edible.foodtype == FOODTYPE.VEGGIE then
                                table.insert(stackable_perishable.preparedfood.edible_veggie, v);
                            elseif v.components.edible.foodtype == FOODTYPE.MEAT then
                                table.insert(stackable_perishable.preparedfood.edible_meat, v);
                            else
                                table.insert(stackable_perishable.preparedfood.rest, v); -- 剩余
                            end
                        else
                            table.insert(stackable_perishable.preparedfood.rest, v); -- 剩余
                        end
                    else
                        if ac_fns.isEdible(v) then
                            if v.components.edible.foodtype == FOODTYPE.VEGGIE then
                                table.insert(stackable_perishable.edible_veggie, v);
                            elseif v.components.edible.foodtype == FOODTYPE.MEAT then
                                table.insert(stackable_perishable.edible_meat, v);
                            else
                                table.insert(stackable.perishable, v); -- 剩余
                            end
                        else
                            table.insert(stackable.perishable, v); -- 剩余
                        end
                    end
                elseif v:HasTag("fertilizerresearchable") then
                    table.insert(stackable.rest[4], v);
                elseif ac_fns.isCHARACTER(v) then
                    table.insert(stackable.rest[7], v);
                elseif ac_fns.isRESTORATION(v) then
                    table.insert(stackable.rest[6], v);
                elseif v:HasTag("gem") then
                    table.insert(stackable.rest[1], v);
                elseif ac_fns.isRocks(v) then
                    table.insert(stackable.rest[2], v);
                elseif ac_fns.isREFINE(v) then
                    table.insert(stackable.rest[8], v);
                elseif ac_fns.isSilkFabric(v) then
                    table.insert(stackable.rest[5], v);
                elseif ac_fns.isEdible(v) then
                    table.insert(stackable.rest[9], v);
                else
                    table.insert(stackable.rest[3], v); -- 剩余
                end
            end
        end
    end

    local cmp = ac_fns.cmp;


    -- 首先把列表里面的项全按字典序排列一遍
    table.sort(equippable.perishable, cmp); -- perishable
    table.sort(equippable.non_percentage, cmp); -- non_percentage
    table.sort(equippable.hands, cmp); -- hands
    table.sort(equippable.head, cmp); -- head
    table.sort(equippable.body, cmp); -- body
    table.sort(equippable.rest, cmp); -- rest

    table.sort(non_stackable.perishable, cmp); -- perishable
    table.sort(non_stackable.rest[1], cmp); -- hasPercent
    table.sort(non_stackable.rest[2], cmp); -- rest

    table.sort(stackable.perishable, cmp); -- perishable
    table.sort(stackable.rest[1], cmp); -- tag:gem
    table.sort(stackable.rest[2], cmp); -- tag:molebait
    table.sort(stackable.rest[3], cmp); -- rest
    table.sort(stackable.rest[4], cmp); -- tag:fertilizerresearchable
    table.sort(stackable.rest[5], cmp); -- custom: 丝织类
    table.sort(stackable.rest[6], cmp); -- custom: 治疗
    table.sort(stackable.rest[7], cmp); -- custom: 人物
    table.sort(stackable.rest[8], cmp); -- custom: 精炼
    table.sort(stackable.rest[9], cmp); -- custom: 食用

    table.sort(stackable_perishable.deployedfarmplant, cmp);
    table.sort(stackable_perishable.edible_veggie, cmp);
    table.sort(stackable_perishable.edible_meat, cmp);
    table.sort(stackable_perishable.preparedfood.edible_veggie, cmp);
    table.sort(stackable_perishable.preparedfood.edible_meat, cmp);
    table.sort(stackable_perishable.preparedfood.rest, cmp);

    -- 请保证健壮性。如果漏东西，那么问题是会非常严重的。

    -- 2023-03-13-20:08：搞复杂了，没必要。之后简化一下！！！而且其实没这么细！有些交集太多了。但是到底应该怎么设计呢？
    return ac_fns.genericResult(
    -- 装备：头部、身体、手部、剩余、无百分比
            equippable.head, equippable.body, equippable.hands, equippable.rest, equippable.non_percentage,
    -- 不可堆叠：有百分比、剩余
            non_stackable.rest[1], non_stackable.rest[2],
    -- 可堆叠：人物、治疗、可食用、宝石、鼹鼠爱吃的、丝织类、精炼、剩余、粪肥
            stackable.rest[7], stackable.rest[6], stackable.rest[9], stackable.rest[1], stackable.rest[2],
            stackable.rest[5], stackable.rest[8], stackable.rest[3], stackable.rest[4],
    -- 装备：有新鲜度；
    -- 不可堆叠：有新鲜度；
    -- 可堆叠有新鲜度：种子、可食用素、可食用荤、剩余；
    -- 可堆叠有新鲜度的料理：可食用素、可食用荤、剩余；
            equippable.perishable,
            non_stackable.perishable,
            stackable_perishable.deployedfarmplant, stackable_perishable.edible_veggie, stackable_perishable.edible_meat,
            stackable.perishable, -- rest
            stackable_perishable.preparedfood.edible_veggie, stackable_perishable.preparedfood.edible_meat, stackable_perishable.preparedfood.rest
    );
end
-- 优化一下整理算法。不只是按字母首字母排序。
---- 我不知道如何评价我的这个写法。但是毕竟功能实现了。。。能跑就行！
function API.arrangeContainer2(inst)
    if not (inst and inst.components and inst.components.container) then
        return ;
    end
    -- 首先先把里面的空洞给处理掉
    local container = inst.components.container;
    local slots = container.slots;

    local keys = {};
    for k, _ in pairs(slots) do
        keys[#keys + 1] = k;
    end
    table.sort(keys);

    -- 这里很强！
    for k, v in ipairs(keys) do
        if k ~= v then
            local item = container:RemoveItemBySlot(v);
            container:GiveItem(item, k); -- Q: 如果超过堆叠上限会发生什么？ A: 会掉落
        end
    end

    -- 新的 slots
    slots = container.slots;

    -- 空洞已经处理完毕，开始排序了
    container.slots = preciseClassification(slots);

    -- 更 新的 slots
    slots = container.slots;

    -- 此时，已经完全排序好了，开始整理
    for i, _ in ipairs(slots) do
        local item = container:RemoveItemBySlot(i);
        container:GiveItem(item); -- slot == nil，会遍历每一个格子把 item 塞进去，item == nil，返回 true
    end
end

-- 最原始的排序算法，字典序排序
function API.arrangeContainer0(inst)
    if not (inst and inst.components.container) then
        return ;
    end

    local container = inst.components.container;
    local slots = container.slots;
    local keys = {};

    -- pairs 是随机的
    for k, _ in pairs(slots) do
        keys[#keys + 1] = k;
    end
    table.sort(keys);

    -- ipairs 是顺序的
    for k, v in ipairs(keys) do
        if (k ~= v) then
            -- 存在空洞
            local item = container:RemoveItemBySlot(v);
            container:GiveItem(item, k); -- TODO:如果超过堆叠上限会发生什么？ Answer: 会掉落
        end
    end
    -- 此时，slot 不存在空洞
    slots = container.slots;

    -- 空洞处理完毕，根据预制物的名字进行字典序
    table.sort(slots, function(entity1, entity2)
        if not (entity1 and entity2) then
            return ;
        end
        -- 2023-03-10-17:24：没有判断 entity1, entity2 是否为空，为什么未报错？
        local a, b = tostring(entity1.prefab), tostring(entity2.prefab);

        --[[        -- 如果预制物名字末尾存在数字，且除末尾数字外，相等，按序号大小排列
                -- NOTE: 没必要，因为字符串可以判断大小
                local prefix_name1,num1 = string.match(a, '(.-)(%d+)$');
                local prefix_name2,num2 = string.match(b, '(.-)(%d+)$');
                if (prefix_name1 == prefix_name2 and num1 and num2) then
                    return tonumber(num1) < tonumber(num2);
                end]]

        return a < b and true or false; -- 便于自己理解
    end)

    -- 此时，slots 已经排序好了，开始整理
    for i, v in ipairs(slots) do
        local item = container:RemoveItemBySlot(i);
        container:GiveItem(item); -- slot == nil，会遍历每一个格子把 item 塞进去，item == nil，返回 true
    end
end

---整理容器
---@type fun(inst:table):void
---@param inst table
function API.arrangeContainer(inst)
    local arrange_container = TUNING and TUNING.MONE_TUNING and TUNING.MONE_TUNING.GET_MOD_CONFIG_DATA and TUNING.MONE_TUNING.GET_MOD_CONFIG_DATA.arrange_container;
    if arrange_container ~= false then
        API.arrangeContainer2(inst);
    else
        API.arrangeContainer0(inst);
    end
end

---转移容器内的预制物
---@param src table
---@param dest table
function API.transferContainerAllItems(src, dest)
    local src_container = src and src.components.container;

    local dest_container = dest and dest.components.container;

    if src_container and dest_container then
        for i = 1, src_container.numslots do
            local item = src_container:RemoveItemBySlot(i);
            dest_container:GiveItem(item);
        end
    end

end

-- TODO: 非固定伤害的 AOE
function API.onattackAOE()

end

-- TODO: 无视护甲的伤害
function API.onattackTrueDamage()

end

---传入的 inst，owner 代表这是在 OnEquip 函数中调用的
function API.runningOnWater(inst, owner)
    if inst.running_on_water_task then
        inst.running_on_water_task:Cancel()
        inst.running_on_water_task = nil
    end
    inst.delay_count = 0;

    inst.running_on_water_task = inst:DoPeriodicTask(0.1, function(inst, owner)
        if owner.sg == nil then
            return ; -- 修复假人bug
        end
        local is_moving = owner.sg:HasStateTag("moving") --玩家正在移动
        local is_running = owner.sg:HasStateTag("running") --玩家正在奔跑
        local x, y, z = owner.Transform:GetWorldPosition()

        -- 如果不是在换人物
        if x and y and z then
            -- 有时候 owner.Physics:ClearCollisionMask() 又被加回去了好像，比如跳虫洞
            -- 这个问题要不要解决呢？

            if owner.components.drownable and owner.components.drownable:IsOverWater() then
                -- 增加潮湿度
                inst.components.equippable.equippedmoisture = 0.5
                inst.components.equippable.maxequippedmoisture = 80

                if is_running or is_moving then
                    inst.delay_count = inst.delay_count + 1
                    if inst.delay_count >= 5 then
                        SpawnPrefab("weregoose_splash_less" .. tostring(math.random(2))).entity:SetParent(owner.entity)
                        inst.delay_count = 0
                    end
                end
                -- 下地瞬间居然没有 drownable 组件
            elseif owner.components.drownable and not owner.components.drownable:IsOverWater() then
                -- 取消增加潮湿度
                inst.components.equippable.equippedmoisture = 0
                inst.components.equippable.maxequippedmoisture = 0
            end
        end
    end, nil, owner)

    -- !!!
    if owner.components.drownable then
        if owner.components.drownable.enabled ~= false then
            owner.components.drownable.enabled = false
            owner.Physics:ClearCollisionMask()
            owner.Physics:CollidesWith(COLLISION.GROUND)
            owner.Physics:CollidesWith(COLLISION.OBSTACLES)
            owner.Physics:CollidesWith(COLLISION.SMALLOBSTACLES)
            owner.Physics:CollidesWith(COLLISION.CHARACTERS)
            owner.Physics:CollidesWith(COLLISION.GIANTS)
            -- TODO: 移除水陆冲突面？LAND_OCEAN_LIMITS

            local x, y, z = owner.Transform:GetWorldPosition()
            if x and y and z then
                --换人物时，x,y,z为nil，所以需要判断一下。
                owner.Physics:Teleport(owner.Transform:GetWorldPosition())
            end
        end
    end
end

-- 这是在 onunequipfn 函数中调用的
function API.runningOnWaterCancel(inst, owner)
    -- 取消增加潮湿度
    inst.components.equippable.equippedmoisture = 0
    inst.components.equippable.maxequippedmoisture = 0

    if inst.running_on_water_task then
        inst.running_on_water_task:Cancel()
        inst.running_on_water_task = nil
    end
    if owner.components.drownable then
        if owner.components.drownable.enabled == false then
            owner.components.drownable.enabled = true
            if not owner:HasTag("playerghost") then
                --非死亡状态
                owner.Physics:ClearCollisionMask()
                owner.Physics:CollidesWith(COLLISION.WORLD)
                owner.Physics:CollidesWith(COLLISION.OBSTACLES)
                owner.Physics:CollidesWith(COLLISION.SMALLOBSTACLES)
                owner.Physics:CollidesWith(COLLISION.CHARACTERS)
                owner.Physics:CollidesWith(COLLISION.GIANTS)
                local x, y, z = owner.Transform:GetWorldPosition()
                if x and y and z then
                    owner.Physics:Teleport(owner.Transform:GetWorldPosition())
                end
            end
        end
    end
end

-- 虽然还是有可能出现如下情况：
-- A模组添加a标签，然后执行我的添加标签部分代码，我能够识别出来此标签是否是我添加的。删除的时候也能判断出来。
-- 但是加入我添加标签后，A模组也添加了标签。然后我移除标签的时候等于把A模组的相关功能也移除了。那肯定就出问题了。
-- 反正怎么说呢，这个方法有用但不完全有用。。。但是没有可不行！

local tags = {};

function API.AddTag(inst, tag)
    if not inst:HasTag(tag) then
        inst:AddTag(tag);
        if tags[inst] == nil then
            tags[inst] = {};
        end
        tags[inst][tag] = true;
    end
end

function API.RemoveTag(inst, tag)
    if inst:HasTag(tag) then
        if tags[inst] and tags[inst][tag] then
            inst:RemoveTag(tag);
            tags[inst][tag] = nil;
        end
    end
end

---???待定
local state_tags = {};

function API.AddStateTag(inst, tag)
    if not inst:HasTag(tag) then
        inst:AddTag(tag);
        if state_tags[inst] == nil then
            state_tags[inst] = {};
        end
        state_tags[inst][tag] = true;
    end
end

function API.RemoveStateTag(inst, tag)
    if inst:HasTag(tag) then
        if state_tags[inst] and state_tags[inst][tag] then
            inst:RemoveTag(tag);
            state_tags[inst][tag] = nil;
        end
    end
end

-- 这是清洁扫把的那个函数罢了，必须保证 build、bank 一致
-- 未来 TODO： 同类型物品都可以换皮肤，比如灯类，皮肤互换。背包类，皮肤互换。
-- NOTE: 感觉换皮肤的函数，有些不能这样统一换。因为函数各异！！！！！！有空重写一下！
---@param name string 游戏内对应的那个预制物的代码名
---@param build string 那个对应的预制物的 build
---@param prefabs table[] 有哪些预制物要被修改呢？
function API.reskin(prefabname, build, prefabs)
    local name = prefabname;
    local fn_name = name .. '_clear_fn';
    local fn = rawget(_G, fn_name);
    if not fn then
        print('`' .. fn_name .. '` global function does not exist!');
        return ;
    else
        rawset(_G, fn_name, function(inst, def_build)
            if not contains_value(prefabs, inst.prefab) then
                return fn(inst, def_build);
            else
                inst.AnimState:SetBuild(build);
            end
        end);

        if ((rawget(_G, 'PREFAB_SKINS') or {})[name] and (rawget(_G, 'PREFAB_SKINS_IDS') or {})[name]) then
            for _, reskin_prefab in ipairs(prefabs) do
                PREFAB_SKINS[reskin_prefab] = PREFAB_SKINS[name];
                PREFAB_SKINS_IDS[reskin_prefab] = PREFAB_SKINS_IDS[name];
            end
        end
    end
end

---- TEST: 2023-02-08-15:57
--API.reskin2 = nil;

-- 关于饥荒的服务端和客户端
--[[
    -- 服务端：
        -- 不开洞穴的房主饥荒进程
        -- 开了洞穴的房主服务端进程(地面的服务端进程、洞穴的服务端进程)
        -- 专用服务器的进程(地上地下?，而且地上地下可能不是在同一个服务器上运行)
    -- 客户端：
        -- 房主的饥荒进程(开洞和不开洞都是)，也就是说：房主的饥荒进程可能出现即使客户端又是服务端的情况。
        -- 加入房间或专服的玩家饥荒进程
    -- ps: 专服好像没有房主，所以玩家都是客户端？

    --相关函数结果
        -- TheNet:GetIsServer() -- 不开洞的房主饥荒进程，开洞的房主服务端进程，专服进程 返回 true
        -- TheNet:IsDedicated() -- 开洞的房主服务端进程，专服进程 返回 true
        -- TheNet:GetIsClient()  -- 开洞的房主的饥荒进程，所有加入房间或专服玩家的饥荒进程 返回 true
        -- TheNet:GetServerIsClientHosted() -- 若游戏不是专用服务器，那么任何端都会返回 true
    -- 不开洞的房主饥荒进程、开洞的房主服务端进程、专服进程、开洞的房主的饥荒进程、所有加入房间或专服玩家的饥荒进程

    --??? 这描述好难受啊。命名分不清啥区别。。

    -- Q：话说 不开洞的房主饥荒进程 是不是代表只有这一个进程？即使服务端又是客户端？
    -- A：YES

    -- server: 不开洞穴的房主饥荒进程、开洞的房主服务端进程、专服进程
    -- client: 不开洞的房主饥荒进程、开洞的房主的饥荒进程、所有加入房间或专服玩家的饥荒进程

    -- not TheNet:GetIsServer()：开洞的房主的饥荒进程、所有加入房间或专服玩家的饥荒进程
    -- 所以 not TheNet:GetIsServer() 不足以判断是客户端！

    -- not TheNet:IsDedicated()：不开洞的房主饥荒进程、开洞的房主的饥荒进程、所有加入房间或专服玩家的饥荒进程
    -- 故判断客户端：not TheNet:IsDedicated()
]]

-- 关于主世界和从世界
--[[
    -- TheWorld.ismastershard == TheWorld.ismastersim and not TheShard:IsSecondary()

    --部分函数结果
        -- TheShard:IsSecondary() -- 从世界返回true
        -- TheShard:IsMaster()  -- 主世界返回true
        -- TheShard:GetShardId()  -- 拿到对应世界的ID
        -- 注意以上判定在客户端使用不能拿到正确的结果
]]

-- TheWorld.ismastersim 和 TheNet:GetIsServer() 这两个判定没有出现过分歧
-- 但是在世界实体没有生成的时候，TheWorld 自然是不能用的。推荐关于 世界生成后进行的修改 都用 TheWorld.ismastersim
-- 如果是 modworldgenmain.lua 里关于地图方面的修改万万不能用 TheWorld
-- 关系等价，ismastersim 相关的定义：TheWorld.ismastersim == TheNet:GetIsMasterSimulation()
function API.isServer()
    return TheWorld and TheWorld.ismastersim or TheNet:GetIsServer();
end

function API.isClient()
    return TheWorld and not TheWorld.ismastersim or not TheNet:IsDedicated();
end

-- 该注释部分是错误的，只是笔记。
--[[---不开洞的房主饥荒进程
function API.isHouseOwnerProcessNoCave()
    return TheNet:GetIsServer();
end

---开洞的房主服务端进程、专服进程(啥是专服进程?)
function API.isHouseOwnerProcessWithMasterCaveAndDedicatedProcess()
    return TheNet:GetIsServer();
end

---开洞的房主服务端进程、专服进程(啥是专服进程?)
function API.isHouseOwnerProcessWithCaveAndDedicatedProcess()
    return TheNet:IsDedicated();
end

-- TheNet:GetServerIsClientHosted(): 若游戏不是专用服务器，那么任何端都会返回true
---专服进程
function API.isDedicatedServer()
    return not TheNet:GetServerIsClientHosted();
end]]


-- RPC
--[[
    -- RPC: 远程过程调用(Remote Procedure Call)
        -- 主要功能用于客户端向服务器发送指令，通知服务端在客户端发生的操作
        -- 部分使用居多
    -- 事实上，RPC 不仅限于客户端通知服务端，也可用于服务端通知客户端，世界之间通知
        -- 你可以在networkclientrpc.lua内找到官方的所有RPC和相关函数
    --

]]

---只是笔记，请忽略

--function API.RPCNote(env)
--    do
--        return ;
--    end
--
--    setfenv(1, env);
--
--    -- 客户端RPC
--    -- 这是使用最多的，客户端向服务端发送 RPC，一般模组也只会在 UI 里使用到客户端 RPC
--
--    --[[
--        -- 第一个是名称空间，使用一个专属于你的字符串，防止不同模组之间RPC名称冲突
--        -- 第二个是 RPC 名称，随便取
--        -- 第三个是预设回调函数
--            -- 当服务端接收到了客户端的 RPC 通知，就会调用这个预设函数，
--            -- 并将对应客户端玩家的实体作为第一个实参传入，其它的实参按客户端通知顺序传入
--    ]]
--    -- RPC 的核心在于一个回调函数，当服务端接收到了客户端相关通知，就会调用相对应的预设函数
--    -- 声明定义一个客户端 RPC，这个声明主客机部分代码都要有
--    AddModRPCHandler("more_items", "rpc_name_test", function(player, ...)
--
--    end)
--
--    --[[
--        -- 第一个参数说明发送的 RPC 名称，其它参数为传给预设函数的形参
--            -- 注意：参数不可以是一个表，实体表除外，你可以传入实体，底层做了处理，在服务端的函数会正确对应实体
--    ]]
--    -- 客户端代码部分发送 RPC 到服务端
--    SendModRPCToServer(MOD_RPC["more_items"]["rpc_name_test"], ...)
--
--    -- 其他：!!!
--    --[[
--        -- RPC的定义是可以主客机分离的
--            -- 如果你打算开服，玩家下载的客户端模组内部可以放一个空定义，服务器内的模组放真正的定义
--        if TheNet:GetIsServer() then
--            AddModRPCHandler("namespace","rpc_name",function(player,...)
--                -- DoSomething
--            end)
--        else
--            AddModRPCHandler("namespace","rpc_name", function(player,...)
--                -- DoNothing
--            end)
--        end
--    ]]
--
--    -- 服务端 RPC
--    -- 由服务端发送至客户端，支持单播，广播，组播
--
--    AddClientModRPCHandler("namespace", "rpc_name", function(...)
--
--    end)
--
--    --[[
--        -- 第一个参数确定 RPC 名称，注意是 CLIENT_MOD_RPC
--        -- 第二个参数表明发送对象(服务端发生给客户端的某个玩家?)
--            -- nil 传入 nil 表明发送 RPC 到所有连接到该世界的客户端
--            -- player.userid 传入一个玩家的 userid 表明只发送到该玩家客户端
--            -- { a.userid, b.userid } 传入一个元素为玩家 userid 表明发送到对应的多个玩家
--        -- Q：什么是 userid？ A：以 KU_ 开头的那串玩家识别码
--        -- Q：如何获得 userid？ A：玩家对象表里的 userid 键值
--    ]]
--    SendModRPCToClient(CLIENT_MOD_RPC["namespace"]["rpc_name"], users, ...)
--
--
--    -- 世界RPC !!!!!!
--    AddShardModRPCHandler("namespace", "rpc_name", function(...)
--
--    end)
--
--    --[[
--        -- 第一个参数确定 RPC 名称，注意是 SHARD_MOD_RPC
--        -- 第二个参数表明发送对象
--            -- nil 传入 nil 发送 RPC 到所有连接的世界
--            -- shardid 传入一个世界的 id 只发送到该世界
--            -- { id1, id2 } 传入一个元素为 shardid 的表 发送到对应的多个世界
--        -- shardid 必须服务端获取。
--            -- TheShard:IsSecondary() -- 从世界返回true
--            -- TheShard:IsMaster()  -- 主世界返回true
--            -- TheShard:GetShardId()  -- 拿到对应世界的ID
--            -- 注意以上判定在客户端使用不能拿到正确的结果
--    ]]
--    SendModRPCToShard(SHARD_MOD_RPC["namespace"]["rpc_name"], users, ...)
--
--
--    -- NetVar
--    -- 网络变量，简称 net。网络变量会在服务端和客户端之间自动同步。
--    -- 你可以在 netvar.lua 里找到所有类型的 netvar 说明
--
--    -- 以int类型的网络变量举例
--    --[[
--        -- 网络变量的声明必须要在主客机代码部分都要存在
--            -- 第一个参数传入一个实体的 GUID，表明网络变量的归属
--            -- 第二个参数为网络变量的名称，随便取，不冲突即可
--            -- 第三个参数为网络变量被`改变后`在归属实体上触发的事件
--    ]]
--    local nic = net_int(inst.GUID, "name", "eventname")
--    nic:set(num) -- 设置网络变量的值，同步并触发事件，仅服务端代码部分调用有效
--    nic:set_local(num) -- 设置网络变量的值但不同步，服务端和客户端均可以调用
--    nic:value() -- 获取网络变量值，服务端和客户端均可调用
--
--    -- set_local
--    --[[
--        -- 只会影响调用的一端，并不会进行同步，即便是服务端调用，客户端也不会同步修改，一般情况下用不到。
--        -- 调用 set_local 会保证下一次 set 必定触发同步。(?话说有啥用???emm,再说吧！)
--    ]]
--
--    -- 同步
--    --[[
--        -- 当网络变量的值真正被 set 做出了修改，才会触发事件。也就是如果在 set 后网络变量的值没有变，那么不触发事件。
--        -- 如果一定要触发，可以先用 set_local 设置，再使用 set 设置，原因如上。
--    ]]
--
--end


function API.SetGetEventCallbacks(event, source, source_file)
    function EntityScript:____GetEventCallbacks(event, source, source_file)
        source = source or self;

        assert(self.event_listening[event] and self.event_listening[event][source]);

        for _, fn in ipairs(self.event_listening[event][source]) do
            if source_file then
                local info = debug.getinfo(fn, "S");
                if info and info.source == source_file then
                    return fn;
                end
            else
                return fn;
            end
        end

    end
end


function API.isDebug(env)
    return env.GetModConfigData("debug") == true and env.modname == morel_DEBUG_DIR_NAME
end

---@param env env
---@return boolean
function API.hasBeenReleased(env)
    if string.find(env.modname, "workshop") then
        return true;
    end
    return false;
end

-- 注意饥荒好像是左手系，三维
-- 二维屏幕的话，应该就是正常的 第一象限 的坐标轴。
function API.SetPosAccordingToScreenResolution(x, y, z, env)
    local width, height = TheSim:GetScreenSize(); -- 1280, 720; -- 获得当前的屏幕分辨率？怎么获得？
    -- 算了，暂时不知道怎么实现实时变化，我debug的时候再执行吧！
    if env and not API.isDebug(env) then
        width, height = 1980, 1080;
    end

    local RESOLUTION_X, RESOLUTION_Y = 1980, 1080; -- 我的屏幕分辨率
    local ratio_x, ratio_y = width / RESOLUTION_X, height / RESOLUTION_Y;
    return Vector3(ratio_x * x, ratio_y * y, z);
end

---新版本，目前的内容是：如果始终保持静态的话，那应该是可以换皮的！
function API.reskin2(env, prefabname, bank, build, prefabs)
    local name = prefabname;

    -- 补丁
    if prefabname == "cane" and #prefabs > 1 then
        return ;
    end

    local init_fn_name = name .. '_init_fn';
    local init_fn = rawget(_G, init_fn_name);
    if not init_fn then
        print('`' .. init_fn_name .. '` global function does not exist!');
        return ;
    end

    rawset(_G, init_fn_name, function(inst, build_name, def_build)
        if not contains_value(prefabs, inst.prefab) then
            return init_fn(inst, build_name, def_build);
        else
            if bank then
                inst.AnimState:SetBank(bank);
            end
            basic_init_fn(inst, build_name, build);

            -- 补丁
            if prefabname == "cane" then
                if inst.components.inventoryitem then
                    inst.components.inventoryitem:ChangeImageName("walkingstick");
                end
            end
        end
    end);

    local clear_fn_name = name .. '_clear_fn';
    local clear_fn = rawget(_G, clear_fn_name);
    if not clear_fn then
        print('`' .. clear_fn_name .. '` global function does not exist!');
        return ;
    end

    rawset(_G, clear_fn_name, function(inst, def_build)
        if not contains_value(prefabs, inst.prefab) then
            return clear_fn(inst, def_build);
        else
            if bank then
                inst.AnimState:SetBank(bank);
            end
            basic_clear_fn(inst, build);

            -- 补丁
            if prefabname == "cane" then
                if inst.components.inventoryitem then
                    inst.components.inventoryitem:ChangeImageName("walkingstick");
                end
            end
        end
    end);

    -- 补丁
    if prefabname == "cane" then
        for _, v in ipairs(prefabs) do
            env.AddPrefabPostInit(v, function(inst)
                if not TheWorld.ismastersim then
                    return inst;
                end
                if inst.components.equippable then
                    local old_onequipfn = inst.components.equippable.onequipfn;
                    inst.components.equippable.onequipfn = function(inst, owner, ...)
                        if old_onequipfn then
                            old_onequipfn(inst, owner, ...);
                        end

                        -- 这样是换不了的！至于原因？未知。2023-02-08-16:00
                        -- 如果我用的官方的 inventoryitem.image 和 atlas，换皮的时候是完全正常的。
                        -- 可以去看看 event:imagechange，以及 itemtile 小部件
                        --local skin_name = inst:GetSkinName();
                        --if skin_name then
                        --    if inst.components.inventoryitem then
                        --        inst.components.inventoryitem:ChangeImageName(skin_name);
                        --    end
                        --end

                        -- 我的物品没自己的皮肤，所以 skin_build 不需要模式匹配
                        local skin_build = inst:GetSkinBuild();
                        if skin_build then
                            owner:PushEvent("equipskinneditem", skin_build);
                            owner.AnimState:OverrideItemSkinSymbol("swap_object", skin_build, "swap_cane", inst.GUID, "swap_cane");
                        end
                    end

                    local old_onunequipfn = inst.components.equippable.onunequipfn;
                    inst.components.equippable.onunequipfn = function(inst, owner, ...)
                        if old_onunequipfn then
                            old_onunequipfn(inst, owner, ...);
                        end

                        local skin_build = inst:GetSkinBuild()
                        if skin_build then
                            owner:PushEvent("unequipskinneditem", inst:GetSkinName());
                        end
                    end
                end
            end)
        end
    end

    -- 修改全局表，应该可以让制作物品页面可以选皮肤
    if ((rawget(_G, 'PREFAB_SKINS') or {})[name] and (rawget(_G, 'PREFAB_SKINS_IDS') or {})[name]) then
        for _, reskin_prefab in ipairs(prefabs) do
            PREFAB_SKINS[reskin_prefab] = PREFAB_SKINS[name];
            PREFAB_SKINS_IDS[reskin_prefab] = PREFAB_SKINS_IDS[name];
        end
    end

end

---添加自定义的动作
function API.addCustomActions(env, custom_actions, component_actions)
    --[[
    execute = nil|false|其他 true,,
    id = '', -- 动作 id，需要全大写字母
    str = '', -- 游戏内显示的动作名称

    ---动作触发时执行的函数，注意这是 server 端
    fn = function(act) ... return ture|false|nil; end, ---@param act BufferedAction,

    actiondata = {}, -- 需要添加的一些动作相关参数，比如：优先级、施放距离等
    state = '', -- 要绑定的 SG 的 state
]]
    custom_actions = custom_actions or {};

    --[[    actiontype = '', -- 场景，'SCENE'|'USEITEM'|'POINT'|'EQUIPPED'|'INVENTORY'|'ISVALID'
        component = '', -- 指的是 inst 的 component，不同场景下的 inst 指代的目标不同，注意一下
        tests = {
            -- 允许绑定多个动作，如果满足条件都会插入动作序列中，具体会执行哪一个动作则由动作优先级来判定。
            {
                execute = nil|false|其他 true,
                id = '', -- 动作 id，同上

                ---注意这是 client 端
                testfn = function() ... return ture|false|nil; end; -- 参数根据 actiontype 而不同！
            },
        }]]

    component_actions = component_actions or {};

    for _, data in pairs(custom_actions) do
        if (data.execute ~= false and data.id and data.str and data.fn and data.state) then
            data.id = string.upper(data.id);

            -- 添加自定义动作
            env.AddAction(data.id, data.str, data.fn);

            if (type(data.actiondata) == 'table') then
                for k, v in pairs(data.actiondata) do
                    ACTIONS[data.id][k] = v;
                end
            end

            -- 添加动作驱动行为图
            env.AddStategraphActionHandler("wilson", ActionHandler(ACTIONS[data.id], data.state));
            env.AddStategraphActionHandler("wilson_client", ActionHandler(ACTIONS[data.id], data.state));
        end
    end

    for _, data in pairs(component_actions) do
        if (data.actiontype and data.component and data.tests) then
            -- 添加动作触发器（动作和组件绑定）
            env.AddComponentAction(data.actiontype, data.component, function(...)
                data.tests = data.tests or {};
                for _, v in pairs(data.tests) do
                    if (v.execute ~= false and v.id and v.testfn and v.testfn(...)) then
                        table.insert((select(-2, ...)), ACTIONS[v.id]);
                    end
                end
            end)
        end
    end
end

function API.modifyOldActions(env, old_actions)
    old_actions = old_actions or {};

    for _, data in pairs(old_actions) do
        if (data.execute ~= false and data.id) then
            local action = ACTIONS[data.id];

            if (type(data.actiondata) == 'table') then
                for k, v in pairs(data.actiondata) do
                    action[k] = v;
                end
            end

            if (type(data.state) == 'table' and action) then
                local testfn = function(sg)
                    local old_handler = sg.actionhandlers[action].deststate;
                    sg.actionhandlers[action].deststate = function(doer, action)
                        if data.state.testfn and data.state.testfn(doer, action) and data.state.deststate then
                            return data.state.deststate(doer, action);
                        end
                        return old_handler(doer, action);
                    end
                end

                if data.state.client_testfn then
                    testfn = data.state.client_testfn;
                end

                env.AddStategraphPostInit("wilson", testfn);
                env.AddStategraphPostInit("wilson_client", testfn);
            end
        end
    end
end


-----------------------------------------------------------------------------
-- FunctionAPI
-----------------------------------------------------------------------------

-- 23/10/29 这里的代码是什么东西啊？我怎么写出这样的代码来的？
API.AutoSorter = {};

local function FunctionAPI_isSaltBox(con)
    return con:HasTag("structure") and con:HasTag("saltbox");
end

local function FunctionAPI_isIceboxOrSaltboxETC(con)
    -- 没有建筑标签的都不算
    if not con:HasTag("structure") then
        return false;
    end
    if con.prefab == "medal_livingroot_chest" then
        return false;
    end

    if con.components.preserver or con:HasTag("fridge") or con:HasTag("foodpreserver") then
        return true;
    end
    return false;
end

local FunctionAPI_as_fns = {
    ---暂时先留着吧
    entsNumberEstimate = function(ents)
        return true;
    end,
    ---@param con table 检索到的容器
    genericFX = function(self, con)
        local selfFX = SpawnPrefab("sand_puff_large_front");
        local conFX = SpawnPrefab("sand_puff");
        local scale = 1.5;
        conFX.Transform:SetScale(scale, scale, scale)
        selfFX.Transform:SetScale(scale, scale, scale)
        conFX.Transform:SetPosition(con.Transform:GetWorldPosition())
        selfFX.Transform:SetPosition(self.Transform:GetWorldPosition())
    end,
    ---@param self table 容器自身
    ---@param con table 检索到的容器
    ---@param slot number 要转移的物品所在的槽
    findSameObjectAndTransfer = function(self, con, slot)
        local item = self.components.container:GetItemInSlot(slot);
        local src_pos = self:GetPosition();
        src_pos = nil; -- 不需要的
        if item and item:IsValid() and con and con.components.container and con.components.container:Has(item.prefab, 1)
                and con.prefab ~= self.prefab and item.components.inventoryitem.cangoincontainer then
            item = self.components.container:RemoveItemBySlot(slot);
            item.prevslot = nil;
            item.prevcontainer = nil;
            if con.components.container:GiveItem(item, nil, src_pos) then
                return true;
            else
                self.components.container:GiveItem(item, slot);
                return false;
            end
        end
        return false;
    end,
    noFindObjectAndTransfer = function(self, con, slot)
        local item = self.components.container:GetItemInSlot(slot);
        local src_pos = self:GetPosition();
        src_pos = nil; -- 不需要的
        if item and item:IsValid() and con and con.components.container and con.prefab ~= self.prefab
                and item.components.inventoryitem.cangoincontainer then
            item = self.components.container:RemoveItemBySlot(slot);
            item.prevslot = nil;
            item.prevcontainer = nil;
            if item.components.perishable then
                -- 注意：如果物品有新鲜度，那么只会尝试找有保鲜组件的容器。找不到就 false！
                if FunctionAPI_isIceboxOrSaltboxETC(con) and con.components.container:GiveItem(item, nil) then
                    return true;
                else
                    self.components.container:GiveItem(item, slot);
                    return false;
                end
            else
                if not FunctionAPI_isIceboxOrSaltboxETC(con) and con.components.container:GiveItem(item, nil, src_pos) then
                    return true;
                else
                    self.components.container:GiveItem(item, slot);
                    return false;
                end
            end
        end
    end,
    ---需要优先转移的对象
    transferIntoSpecialCon = function(self, con, slot, patch)
        -- patch == true 的时候证明找到了 Special container
        if patch then
            return con and (con.prefab == "mone_wardrobe" or con.prefab == "mie_watersource");
        end

        local item = self.components.container:GetItemInSlot(slot);
        local src_pos = self:GetPosition();
        src_pos = nil; -- 不需要的
        if con.prefab == "mone_wardrobe" then
            if item and item:IsValid() and item:HasTag("_equippable") and con and con.components.container and con.prefab ~= self.prefab and item.components.inventoryitem.cangoincontainer then
                item = self.components.container:RemoveItemBySlot(slot);
                item.prevslot = nil;
                item.prevcontainer = nil;
                if con.components.container:GiveItem(item, nil, src_pos) then
                    return true;
                else
                    self.components.container:GiveItem(item, slot);
                    return false;
                end
            end
        end
        return false;
    end,
    ---在转移完同类物品后需要选择转移进去的容器
    transferIntoSomeCon = function(self, con, slot)
        local item = self.components.container:GetItemInSlot(slot);
        local src_pos = self:GetPosition();
        src_pos = nil; -- 不需要的
        if con.prefab == "mie_watersource" then
            if item and item:IsValid() and con and con.components.container and con.prefab ~= self.prefab and item.components.inventoryitem.cangoincontainer then
                item = self.components.container:RemoveItemBySlot(slot);
                item.prevslot = nil;
                item.prevcontainer = nil;
                if con.components.container:GiveItem(item, nil, src_pos) then
                    return true;
                else
                    self.components.container:GiveItem(item, slot);
                    return false;
                end
            end
        elseif con.prefab == "mie_new_granary" then
            if item and item:IsValid() and con and con.components.container and con.prefab ~= self.prefab and item.components.inventoryitem.cangoincontainer then
                item = self.components.container:RemoveItemBySlot(slot);
                item.prevslot = nil;
                item.prevcontainer = nil;
                if con.components.container:GiveItem(item, nil, src_pos) then
                    return true;
                else
                    self.components.container:GiveItem(item, slot);
                    return false;
                end
            end
        elseif con.prefab == "mone_skull_chest" then
            if item and item:IsValid() and con and con.components.container and con.prefab ~= self.prefab and item.components.inventoryitem.cangoincontainer then
                item = self.components.container:RemoveItemBySlot(slot);
                item.prevslot = nil;
                item.prevcontainer = nil;
                if con.components.container:GiveItem(item, nil, src_pos) then
                    return true;
                else
                    self.components.container:GiveItem(item, slot);
                    return false;
                end
            end
        elseif con:HasTag("saltbox") then
            -- 呃，会导致优先进盐盒，不进谷仓了...
            --if item and item:IsValid() and con and con.components.container and con.prefab ~= self.prefab and item.components.inventoryitem.cangoincontainer then
            --    item = self.components.container:RemoveItemBySlot(slot);
            --    item.prevslot = nil;
            --    item.prevcontainer = nil;
            --    if con.components.container:GiveItem(item, nil, src_pos) then
            --        return true;
            --    else
            --        self.components.container:GiveItem(item, slot);
            --        return false;
            --    end
            --end
        end
        return false;
    end
};

-- 先留着吧
API.AutoSorter.beginTransfer_HOT_UPDATE = false; -- false 代表主模组已经更新，依赖模组不必覆盖了
API.AutoSorter.beginTransfer_HOT_UPDATE2 = false;
API.AutoSorter.beginTransfer_upvalues = {
    entsNumberEstimate = FunctionAPI_as_fns.entsNumberEstimate,
    transferIntoSpecialCon = FunctionAPI_as_fns.transferIntoSpecialCon,
    transferIntoSomeCon = FunctionAPI_as_fns.transferIntoSomeCon,
    genericFX = FunctionAPI_as_fns.genericFX,
    findSameObjectAndTransfer = FunctionAPI_as_fns.findSameObjectAndTransfer,
    noFindObjectAndTransfer = FunctionAPI_as_fns.noFindObjectAndTransfer,
}

TUNING.__FIRE_DETECTOR_RANGE__ = 15;
-- 这性能绝对垃圾！
function API.AutoSorter.beginTransfer(inst)
    local x, y, z = inst.Transform:GetWorldPosition();
    local DIST = TUNING.__FIRE_DETECTOR_RANGE__; -- 转移的话，范围大一点点
    local MUST_TAGS = { "_container" };
    local CANT_TAGS = {
        "INLIMBO", "NOCLICK", "knockbackdelayinteraction", "catchable", "mineactive",
        "stewer", "tree", "bundle",
        "_inventoryitem", "_health",
        "mie_sand_pit", "mone_firesuppressor", "mone_chiminea", "pets_container_tag", "mie_wooden_drawer", "mie_relic_2",
        "more_items_auto_sorter_cant_tag"
    };
    if x and y and z then
        local ents = TheSim:FindEntities(x, y, z, DIST, MUST_TAGS, CANT_TAGS);

        -- 多遍历的一次
        local excludes = TheSim:FindEntities(x, y, z, DIST, { "mone_seedpouch" });
        for _, v in ipairs(excludes) do
            if v and v:IsValid() then
                table.insert(ents, 1, v);
            end
        end

        if FunctionAPI_as_fns.entsNumberEstimate(ents) then
            local _ents = {};
            for _, v in ipairs(ents) do
                if v and v:IsValid() and v.components.container then
                    table.insert(_ents, v);
                end
            end
            local slotsNum = inst.components.container:GetNumSlots();

            -- 第一次遍历：转移进衣柜(pitch:补充一下，把特殊容器都找出来，然后执行一次转移同类物品的操作！)
            local special_containers = {};
            local pitch = true; -- pitch == true 的时候只找指定容器，不执行转移操作
            slotsNum = inst.components.container:GetNumSlots();
            for i = 1, slotsNum do
                for _, v in ipairs(_ents) do
                    if v and v:IsValid() then
                        if FunctionAPI_as_fns.transferIntoSpecialCon(inst, v, i, pitch) then
                            if pitch then
                                table.insert(special_containers, v);
                            else
                                FunctionAPI_as_fns.genericFX(inst, v);
                                break ;
                            end
                        end
                    end
                end
                -- 将 special_containers 排序一下，水桶排在你的装备柜前面，但是这个 comp 咋用来着？
                ---- 算了先手动排序吧：测试发现此处代码会导致转移瞬间卡一下？这....??
                if #special_containers > 0 then
                    --local mie_watersources, mone_wardrobes, others = {}, {}, {};
                    --for _, v in ipairs(special_containers) do
                    --    if v.prefab == "mie_watersource" then
                    --        table.insert(mie_watersources, v);
                    --    elseif v.prefab == "mone_wardrobe" then
                    --        table.insert(mone_wardrobes, v);
                    --    else
                    --        table.insert(others, v);
                    --    end
                    --end
                    --special_containers = {};
                    --local function generic_result(...)
                    --    local args = { ... };
                    --    for index = 1, table.maxn(args) do
                    --        if isSeq(args[index]) then
                    --            for _, v in ipairs(args[index]) do
                    --                table.insert(special_containers, v);
                    --            end
                    --        end
                    --    end
                    --end
                    --generic_result(mie_watersources, mone_wardrobes, others);
                end
            end
            if pitch then
                -- 转移同类物品
                slotsNum = inst.components.container:GetNumSlots();
                for i = 1, slotsNum do
                    for _, v in ipairs(special_containers) do
                        if v and v:IsValid() then
                            if FunctionAPI_as_fns.findSameObjectAndTransfer(inst, v, i) then
                                FunctionAPI_as_fns.genericFX(inst, v);
                                break ;
                            end
                        end
                    end
                end
                -- 转移剩余物品
                slotsNum = inst.components.container:GetNumSlots();
                for i = 1, slotsNum do
                    for _, v in ipairs(special_containers) do
                        if v and v:IsValid() then
                            if FunctionAPI_as_fns.noFindObjectAndTransfer(inst, v, i) then
                                FunctionAPI_as_fns.genericFX(inst, v);
                                break ;
                            end
                        end
                    end
                end
            end
            -- 第二次遍历：转移同类物品
            slotsNum = inst.components.container:GetNumSlots();
            for i = 1, slotsNum do
                for _, v in ipairs(_ents) do
                    if v and v:IsValid() then
                        if FunctionAPI_as_fns.findSameObjectAndTransfer(inst, v, i) then
                            --print("findSameObjectAndTransfer---[" .. tostring(i) .. "]");
                            FunctionAPI_as_fns.genericFX(inst, v);
                            break ;
                        end
                    end
                end
            end
            -- 第三次遍历：转移进指定容器
            slotsNum = inst.components.container:GetNumSlots();
            for i = 1, slotsNum do
                for _, v in ipairs(_ents) do
                    if v and v:IsValid() then
                        if FunctionAPI_as_fns.transferIntoSomeCon(inst, v, i) then
                            FunctionAPI_as_fns.genericFX(inst, v);
                            break ;
                        end
                    end
                end
            end
            -- 第四次遍历：转移剩余物品(此次遍历我感觉需要做点事情了，优化一下！)
            slotsNum = inst.components.container:GetNumSlots();
            for i = 1, slotsNum do
                for _, v in ipairs(_ents) do
                    if v and v:IsValid() then
                        if FunctionAPI_as_fns.noFindObjectAndTransfer(inst, v, i) then
                            FunctionAPI_as_fns.genericFX(inst, v);
                            break ;
                        end
                    end
                end
            end
        end
    end
end

local function FunctionAPI_isExcludedSomething(inst)
    -- 把牛鞍收走了？所以崩溃吗？ A:罪魁祸首就是这个！具体怎么导致的再说。反正不能有这个。 A:排除标签即可。。。
    local prefabslist = {
        "terrarium", --盒中泰拉
        "glommerflower", --格罗姆花
        "chester_eyebone", --眼骨
        "hutch_fishbowl", --星空
        "beef_bell", --皮弗娄牛铃
        "heatrock", --暖石
        "moonrockseed", --天体宝珠
        "fruitflyfruit", --友好果蝇果
        "singingshell_octave3", --贝壳
        "singingshell_octave4",
        "singingshell_octave5",
        "powcake", --芝士蛋糕（后续应该添加和猪人陷阱相关的东西）
        "farm_plow_item", --耕地机（原版）
        "winter_food4", -- 永远的水果蛋糕
        "mie_bundle_state1",
        "mie_bundle_state2"
    };
    if table.contains(prefabslist, inst.prefab) then
        return true;
    end
    if inst:HasTag("trap") then
        return true;
    end
    --if string.find(inst.prefab,"wx78module_") then
    --    return true;
    --end
    if inst.components.burnable then
        if inst.components.burnable:IsBurning() or inst.components.burnable:IsSmoldering() then
            return true;
        end
    end
    return false;
end

function FunctionAPI_as_fns.pickObjectOnFloorCommonly(inst, MUST_TAGS, CANT_TAGS)
    local x, y, z = inst.Transform:GetWorldPosition();
    local src_pos = inst:GetPosition(); -- Question: 不自然！
    src_pos = nil;
    local DIST = TUNING.__FIRE_DETECTOR_RANGE__;
    --local MUST_TAGS = MUST_TAGS;
    --local CANT_TAGS = CANT_TAGS;
    if x and y and z then
        local ents = TheSim:FindEntities(x, y, z, DIST, MUST_TAGS, CANT_TAGS);
        for _, v in ipairs(ents) do
            if not FunctionAPI_isExcludedSomething(v) then
                if v and v:IsValid() and v.components.inventoryitem
                        and v.components.inventoryitem.canbepickedup
                        and v.components.inventoryitem.cangoincontainer
                        and not v.components.inventoryitem.canonlygoinpocket
                        and not v.components.inventoryitem:IsHeld()
                        and not v:HasTag("_container")
                then
                    if inst.components.container:GiveItem(v, nil, src_pos) then
                        local fx = SpawnPrefab("sand_puff");
                        local scale = 1.5;
                        fx.Transform:SetScale(scale, scale, scale);
                        fx.Transform:SetPosition(v.Transform:GetWorldPosition());
                    end
                end
            end
        end
    end
end

local FunctionAPI_PickObjectOnFloor_MUST_TAGS = { "_inventoryitem" };
local FunctionAPI_PickObjectOnFloor_CANT_TAGS = {
    "INLIMBO", "NOCLICK", "knockbackdelayinteraction", "catchable", "mineactive",
    "irreplaceable", "nonpotatable", "heatrock", "trap", "_health",
    "mone_auto_sorter_exclude_prefabs",
    "_equippable", "_container",
};
API.AutoSorter.PickObjectOnFloor_MUST_TAGS = FunctionAPI_PickObjectOnFloor_MUST_TAGS;
API.AutoSorter.PickObjectOnFloor_CANT_TAGS = FunctionAPI_PickObjectOnFloor_CANT_TAGS;

---正常捡的时候东西少一点
function API.AutoSorter.pickObjectOnFloor(inst)
    local MUST_TAGS = FunctionAPI_PickObjectOnFloor_MUST_TAGS;
    local CANT_TAGS = FunctionAPI_PickObjectOnFloor_CANT_TAGS;
    FunctionAPI_as_fns.pickObjectOnFloorCommonly(inst, MUST_TAGS, CANT_TAGS);
end

local FunctionAPI_PickObjectOnFloorOnClick_MUST_TAGS = { "_inventoryitem" };
local FunctionAPI_PickObjectOnFloorOnClick_CANT_TAGS = {
    "INLIMBO", "NOCLICK", "knockbackdelayinteraction", "catchable", "mineactive",
    "irreplaceable", "nonpotatable", "heatrock", "trap", "_health",
    "mone_auto_sorter_exclude_prefabs",
};

API.AutoSorter.PickObjectOnFloorOnClick_MUST_TAGS = FunctionAPI_PickObjectOnFloorOnClick_MUST_TAGS;
API.AutoSorter.PickObjectOnFloorOnClick_CANT_TAGS = FunctionAPI_PickObjectOnFloorOnClick_CANT_TAGS;

---点击的时候捡起的东西更多！
function API.AutoSorter.pickObjectOnFloorOnClick(inst)
    local MUST_TAGS = FunctionAPI_PickObjectOnFloorOnClick_MUST_TAGS;
    local CANT_TAGS = FunctionAPI_PickObjectOnFloorOnClick_CANT_TAGS;
    FunctionAPI_as_fns.pickObjectOnFloorCommonly(inst, MUST_TAGS, CANT_TAGS);
end


API.ItemsGICF = {};

local function FunctionAPI_old_itemsGoIntoContainersFirst(inventory, priority)
    local old_GiveItem = inventory.GiveItem;

    inventory.GiveItem = function(self, inst, slot, src_pos, ...)
        if inst == nil then
            print("Warning: Can't give item because `inst == nil`.")
            return ;
        end
        if inst and not inst:IsValid() then
            print("Warning: Can't give item because `inst:IsValid() == false`.")
            return ;
        end
        if inst and inst.components.inventoryitem == nil then
            print("Warning: Can't give item because `inst.components.inventoryitem == nil`.")
            return ;
        end

        -- klei's
        if inst.components.inventoryitem == nil or not inst:IsValid() then
            print("Warning: Can't give item because it's not an inventory item.")
            return ;
        end

        local eslot = self:IsItemEquipped(inst)

        if eslot then
            self:Unequip(eslot)
        end

        local new_item = inst ~= self.activeitem
        if new_item then
            for k, v in pairs(self.equipslots) do
                if v == inst then
                    new_item = false
                    break
                end
            end
        end

        if inst.components.inventoryitem.owner and inst.components.inventoryitem.owner ~= self.inst then
            inst.components.inventoryitem:RemoveFromOwner(true)
        end

        local objectDestroyed = inst.components.inventoryitem:OnPickup(self.inst, src_pos)
        if objectDestroyed then
            return
        end

        -- 这部分代码是官方优化过的代码，prevslot和prevcontainer!!!
        --[[        local can_use_suggested_slot = false

                if not slot and inst.prevslot and not inst.prevcontainer then
                    slot = inst.prevslot
                end

                if not slot and inst.prevslot and inst.prevcontainer then
                    if inst.prevcontainer.inst:IsValid() and inst.prevcontainer:IsOpenedBy(self.inst) then
                        local item = inst.prevcontainer:GetItemInSlot(inst.prevslot)
                        if item == nil then
                            if inst.prevcontainer:GiveItem(inst, inst.prevslot) then
                                return true
                            end
                        elseif item.prefab == inst.prefab and item.skinname == inst.skinname and
                                item.components.stackable ~= nil and
                                inst.prevcontainer:AcceptsStacks() and
                                inst.prevcontainer:CanTakeItemInSlot(inst, inst.prevslot) and
                                item.components.stackable:Put(inst) == nil then
                            return true
                        end
                    end
                    inst.prevcontainer = nil
                    inst.prevslot = nil
                    slot = nil
                end

                if slot then
                    local olditem = self:GetItemInSlot(slot)
                    can_use_suggested_slot = slot ~= nil
                            and slot <= self.maxslots
                            and (olditem == nil or (olditem and olditem.components.stackable and olditem.prefab == inst.prefab and olditem.skinname == inst.skinname))
                            and self:CanTakeItemInSlot(inst, slot)
                end]]

        if true then
            local can_use_suggested_slot = false

            -- 此处指的就是物品栏
            --if not slot and inst.prevslot and not inst.prevcontainer then
            --    slot = inst.prevslot
            --end

            local can_enter = true;
            -- 加速类的手持物品不需要记住之前的位置。意义不大。。
            --if inst.components.equippable
            --        and inst.components.equippable.equipslot and inst.components.equippable.equipslot == EQUIPSLOTS.HANDS
            --        and inst.components.equippable.walkspeedmult and inst.components.equippable.walkspeedmult > 1 then
            --    can_enter = false;
            --end

            --print(tostring(inst.prevslot));
            --print(tostring(inst.prevcontainer));
            --print(tostring(inst.prevcontainer and inst.prevcontainer.inst));
            if can_enter and not slot and inst.prevslot and inst.prevcontainer and inst.prevcontainer.inst
                    and (inst.prevcontainer.inst.prefab == "mone_tool_bag"
                    or inst.prevcontainer.inst.prefab == "mone_backpack"
                    or inst.prevcontainer.inst.prefab == "mone_piggybag") then
                if inst.prevcontainer.inst:IsValid() and inst.prevcontainer:IsOpenedBy(self.inst) then
                    local item = inst.prevcontainer:GetItemInSlot(inst.prevslot)
                    if item == nil then
                        if inst.prevcontainer:GiveItem(inst, inst.prevslot) then
                            return true
                        end
                    elseif item.prefab == inst.prefab and item.skinname == inst.skinname and
                            item.components.stackable ~= nil and
                            inst.prevcontainer:AcceptsStacks() and
                            inst.prevcontainer:CanTakeItemInSlot(inst, inst.prevslot) and
                            item.components.stackable:Put(inst) == nil then
                        return true
                    end
                end
                inst.prevcontainer = nil
                inst.prevslot = nil
                slot = nil
            end

            if slot then
                local olditem = self:GetItemInSlot(slot)
                can_use_suggested_slot = slot ~= nil
                        and slot <= self.maxslots
                        and (olditem == nil or (olditem and olditem.components.stackable and olditem.prefab == inst.prefab and olditem.skinname == inst.skinname))
                        and self:CanTakeItemInSlot(inst, slot)
            end
        end



        -- 如果是蜜蜂、月熠这类有生命值的、可堆叠的物品就用这种方法处理吧。反正处理了就行了，哈哈。
        if (inst.components.stackable and inst.components.health)
                or (inst.components.stackable and inst.components.workable)
        then
            return old_GiveItem(self, inst, slot, src_pos, ...);
        end

        -- 排除神话书说黑白无常的铃铛和招魂幡。emm，因为会崩溃。但是测试没发现。
        ---- 2023-04-18：补充，排除人参果，因为采摘直接进食物袋可能崩溃。为什么不清楚，排除了就完事了。
        ---- 2023-04-18：补充，能力勋章的孢子？啥玩意哦，为什么会崩溃哇。和 inventoryitem 的 OnRemoved, ClearOwner 有关。
        if table.contains({
            "hat_commissioner_white", "pennant_commissioner", "bell_commissioner", "hat_commissioner_black", "token_commissioner", "whip_commissioner",
            "myth_infant_fruit",
            "medal_spore_moon",
            "aria_fantasycore", "aria_magiccore"
        }, inst.prefab) then
            return old_GiveItem(self, inst, slot, src_pos, ...);
        end

        --[[ 只有此处这个 if 判断语句是我的内容，其余是官方代码 ]]
        if (not slot and not inst[TUNING.MONE_TUNING.IGICF_FLAG_NAME]) then
            local opencontainers = self.opencontainers;

            local vip_containers = {};
            local priority_containers = priority;

            for c, v in pairs(opencontainers) do
                if c and v then
                    if contains_key(priority_containers, c.prefab) then
                        vip_containers[#vip_containers + 1] = c;
                    end
                end
            end

            table.sort(vip_containers, function(entity1, entity2)
                local p1, p2;
                if entity1 and entity2 then
                    p1, p2 = priority_containers[entity1.prefab], priority_containers[entity2.prefab];
                end
                if p1 and p2 then
                    return p1 > p2;
                end
            end);

            for _, c in ipairs(vip_containers) do
                ---@type
                local container = c and c.components.container;
                if container and container:IsOpen() then

                    --print(tostring(container.inst.prefab),tostring(inst.prefab));
                    -- 补丁（没有continue只能用if else了）
                    if container.inst.prefab == "mone_storage_bag" and inst.prefab == "hambat" then
                        --print("", "DoNothing!");
                        -- DoNothing
                        -- 虽然会导致火腿棒不会自动进入保鲜袋了，但是我觉得这是可以舍弃的
                        -- 因为在装备袋里面切换手杖和火腿棒这个功能更值得。
                    else
                        if inst and inst:IsValid() and container:GiveItem(inst, nil, src_pos) then
                            -- tips: self.inst 是人物，PushEvent 可以发出声音
                            -- self.inst:PushEvent("gotnewitem", { item = inst, slot = slot })

                            -- 2023-02-16-22:44：客机没声音。。。无语。为什么？
                            if TheFocalPoint and TheFocalPoint.SoundEmitter then
                                TheFocalPoint.SoundEmitter:PlaySound("dontstarve/HUD/collect_resource");
                            end
                            -- 2023-03-29-23:20：让可以发出声音
                            --print("self.inst: "..tostring(self.inst));
                            --print("self.inst.userid: "..tostring(self.inst.userid));
                            if self.inst and self.inst:HasTag("player") and self.inst.userid then
                                SendModRPCToClient(CLIENT_MOD_RPC["more_items"]["container_client_play_sound"], self.inst.userid, container.inst);
                            end

                            -- 补丁（由于是猪猪袋，所以owner=="player"）
                            if container.inst.prefab == "mone_piggybag" then
                                local owner = container.inst.components.inventoryitem and container.inst.components.inventoryitem.owner;
                                if owner and owner:HasTag("player") then
                                    if inst.prefab == "mone_backpack"
                                            or inst.prefab == "mone_candybag"
                                            or inst.prefab == "mone_storage_bag" then
                                        if inst.components.container then
                                            inst.components.container:Open(owner);
                                        end
                                    end
                                end
                            end

                            return true;
                        end
                    end
                end
            end
        end

        return old_GiveItem(self, inst, slot, src_pos, ...);
    end
end

-- 2023-07-03：大致优化了一下
local function FunctionAPI_PutItemsInContainerFirst(inventory, priority)
    local function Warning(self, inst, slot, src_pos, ...)
        if inst == nil then
            print("Warning: Can't give item because `inst == nil`.")
            return true;
        end
        if inst and not inst:IsValid() then
            print("Warning: Can't give item because `inst:IsValid() == false`.")
            return true;
        end
        if inst and inst.components.inventoryitem == nil then
            print("Warning: Can't give item because `inst.components.inventoryitem == nil`.")
            return true;
        end

        -- klei's
        if inst.components.inventoryitem == nil or not inst:IsValid() then
            print("Warning: Can't give item because it's not an inventory item.")
            return ;
        end
    end

    local function HandleSpecificException(self, inst, slot, src_pos, ...)
        -- 蜜蜂、月熠这类有生命值的、可堆叠的物品就用这种方法处理吧。先这样处理吧！
        if (inst.components.stackable and inst.components.health)
                or (inst.components.stackable and inst.components.workable)
        then
            return true;
        end

        -- 排除一些物品，这些物品可能导致崩溃，原因未知：崩溃可能和 inventoryitem 的 OnRemoved, ClearOwner 有关
        -- 2023-07-17：
        -- 大概率和 owner 有关，永不妥协的荨麻孢子在保鲜袋里的时候
        -- inst.components.inventoryitem:GetGrandOwner() 获取不到值
        if table.contains({
            "hat_commissioner_white",
            "pennant_commissioner",
            "bell_commissioner",
            "hat_commissioner_black",
            "token_commissioner",
            "whip_commissioner",
            "myth_infant_fruit",
            "medal_spore_moon",
            "aria_fantasycore",
            "aria_magiccore",
            "um_smolder_spore",
        }, inst.prefab) then
            return true;
        end
    end

    -- 2023-07-10：主体复制自官方源码，然后修改的
    local function CanAcceptCount(self, item, maxcount)
        local stacksize = math.max(maxcount or 0, item.components.stackable ~= nil and item.components.stackable.stacksize or 1)
        if stacksize <= 0 then
            return 0
        end

        local acceptcount = 0

        --check for empty space in the container
        for k = 1, self.maxslots do
            local v = self.itemslots[k]
            -- 只检索非空物品栏，空的物品栏忽略
            if v ~= nil then
                if v.prefab == item.prefab and v.skinname == item.skinname and v.components.stackable ~= nil then
                    acceptcount = acceptcount + v.components.stackable:RoomLeft()
                    if acceptcount >= stacksize then
                        return stacksize
                    end
                end
            end
        end

        if not (item.components.inventoryitem ~= nil and item.components.inventoryitem.canonlygoinpocket) then
            --check for empty space in our backpack
            local overflow = self:GetOverflowContainer()
            if overflow ~= nil then
                for k = 1, overflow.numslots do
                    local v = overflow.slots[k]
                    -- 这里也同理，空的格子忽略
                    if v ~= nil then
                        if v.prefab == item.prefab and v.skinname == item.skinname and v.components.stackable ~= nil then
                            acceptcount = acceptcount + v.components.stackable:RoomLeft()
                            if acceptcount >= stacksize then
                                return stacksize
                            end
                        end
                    end
                end
            end
        end

        if item.components.stackable ~= nil then
            --check for equip stacks that aren't full
            for k, v in pairs(self.equipslots) do
                if v.prefab == item.prefab and v.skinname == item.skinname and v.components.equippable.equipstack and v.components.stackable ~= nil then
                    acceptcount = acceptcount + v.components.stackable:RoomLeft()
                    if acceptcount >= stacksize then
                        return stacksize
                    end
                end
            end
        end

        -- 如果已有的格子塞不下，返回 0
        return 0
    end

    local old_GiveItem = inventory.GiveItem;
    function inventory:GiveItem(inst, slot, src_pos, ...)
        if Warning(self, inst, slot, src_pos, ...) then
            return ;
        end

        local eslot = self:IsItemEquipped(inst)

        if eslot then
            self:Unequip(eslot)
        end

        local new_item = inst ~= self.activeitem
        if new_item then
            for k, v in pairs(self.equipslots) do
                if v == inst then
                    new_item = false
                    break
                end
            end
        end

        if inst.components.inventoryitem.owner and inst.components.inventoryitem.owner ~= self.inst then
            inst.components.inventoryitem:RemoveFromOwner(true)
        end

        local objectDestroyed = inst.components.inventoryitem:OnPickup(self.inst, src_pos)
        if objectDestroyed then
            return
        end
        ------------

        -- 官方代码修改：让物品记住之前的位置
        local can_use_suggested_slot = false

        -- 此处指的就是物品栏
        if not slot and inst.prevslot and not inst.prevcontainer then
            slot = inst.prevslot
        end

        -- 补充一个背包栏
        if not slot and inst.prevslot and inst.prevcontainer
                and inst.prevcontainer == self:GetOverflowContainer() then
            return old_GiveItem(self, inst, slot, src_pos, ...);
        end

        if not slot and inst.prevslot and inst.prevcontainer then
            local prevcontainerinst = inst.prevcontainer.inst;
            if prevcontainerinst and table.contains({ "mone_tool_bag", "mone_backpack", "mone_piggybag" }, prevcontainerinst.prefab) then
                if inst.prevcontainer.inst:IsValid() and inst.prevcontainer:IsOpenedBy(self.inst) then
                    local item = inst.prevcontainer:GetItemInSlot(inst.prevslot)
                    if item == nil then
                        if inst.prevcontainer:GiveItem(inst, inst.prevslot) then
                            return true
                        end
                    elseif item.prefab == inst.prefab and item.skinname == inst.skinname and
                            item.components.stackable ~= nil and
                            inst.prevcontainer:AcceptsStacks() and
                            inst.prevcontainer:CanTakeItemInSlot(inst, inst.prevslot) and
                            item.components.stackable:Put(inst) == nil then
                        return true
                    end
                end
                inst.prevcontainer = nil
                inst.prevslot = nil
                slot = nil
            end
        end
        ------------


        if HandleSpecificException(self, inst, slot, src_pos, ...) then
            return old_GiveItem(self, inst, slot, src_pos, ...);
        end
        ------------

        -- 身上能放下，就放身上吧
        if inst.components.stackable and CanAcceptCount(self, inst, 1) > 0 then
            return old_GiveItem(self, inst, slot, src_pos, ...);
        end
        ------------

        if not slot and not inst[TUNING.MONE_TUNING.IGICF_FLAG_NAME] then
            local opencontainers = self.opencontainers;

            local vip_containers = {};
            local priority_containers = priority;

            for c, v in pairs(opencontainers) do
                if c and v then
                    if contains_key(priority_containers, c.prefab) then
                        vip_containers[#vip_containers + 1] = c;
                    end
                end
            end

            table.sort(vip_containers, function(entity1, entity2)
                local p1, p2;
                if entity1 and entity2 then
                    p1, p2 = priority_containers[entity1.prefab], priority_containers[entity2.prefab];
                end
                if p1 and p2 then
                    return p1 > p2;
                end
            end);

            for _, c in ipairs(vip_containers) do
                local container = c and c.components.container;
                if container and container:IsOpen() then
                    if container.inst.prefab == "mone_storage_bag" and inst.prefab == "hambat" then
                        -- DoNothing
                    else
                        if inst and inst:IsValid()
                                and container:CanTakeItemInSlot(inst)
                                and container:GiveItem(inst, nil, src_pos) then


                            local overflow = self:GetOverflowContainer();
                            local container_owner = c.components.inventoryitem.owner;
                            if container_owner and container_owner ~= self.inst
                                    and (container.inst:HasTag("more_items_owner_is_piggybag")
                                    or overflow and container_owner == overflow.inst) then
                                if new_item and not self.ignoresound then
                                    ShiHao.NonGeneralFns.PlaySoundOnGotNewItem(self.inst, { item = inst, slot = slot });
                                    if self.inst and self.inst:HasTag("player") and self.inst.userid and CLIENT_MOD_RPC["more_items"] and CLIENT_MOD_RPC["more_items"]["container_client_play_sound"] then
                                        SendModRPCToClient(CLIENT_MOD_RPC["more_items"]["container_client_play_sound"], self.inst.userid, container.inst, inst.pickupsound);
                                    end
                                end
                            end


                            -- TEMP
                            local function Patch()
                                if container.inst.prefab == "mone_piggybag" then
                                    local owner = container.inst.components.inventoryitem and container.inst.components.inventoryitem.owner;
                                    if owner and owner:HasTag("player") then
                                        if inst.prefab == "mone_backpack"
                                                or inst.prefab == "mone_candybag"
                                                or inst.prefab == "mone_storage_bag" then
                                            if inst.components.container then
                                                inst.components.container:Open(owner);
                                            end
                                        end
                                    end
                                end
                            end
                            Patch();

                            return true;
                        end
                    end
                end
            end
        end

        return old_GiveItem(self, inst, slot, src_pos, ...);
    end
end


function API.ItemsGICF.itemsGoIntoContainersFirst(inventory, priority)
    FunctionAPI_PutItemsInContainerFirst(inventory, priority);
end

---全部设置一个标记，表明已经在容器中了。这样可以保证 shift+左键 能够从容器中出去。
function API.ItemsGICF.redirectItemFlagAndGetTime(inst)
    if not (inst and inst.components.container) then
        return 2 ^ 31 - 1;
    end

    local container = inst.components.container;

    for _, v in pairs(container.slots) do
        v[TUNING.MONE_TUNING.IGICF_FLAG_NAME] = true;
    end

    if (container.numslots < 47) then
        return 1;
    else
        return 2;
    end
end

function API.ItemsGICF.clearAllFlag(inst)
    local container = inst.components.container;
    if container then
        for _, v in pairs(container.slots) do
            v[TUNING.MONE_TUNING.IGICF_FLAG_NAME] = nil;
        end
    end
end

---函数调用位置：预制物文件末尾，设置这四个监听器
---作用：取消标记。标记的作用：有这个标记的预制物，将调用官方的原函数，而不是我重写的部分。
function API.ItemsGICF.setListenForEvent(inst)
    inst:ListenForEvent("dropitem", function(inst, data)
        if data and data.item then
            data.item[TUNING.MONE_TUNING.IGICF_FLAG_NAME] = nil;
        end
    end)
    inst:ListenForEvent("itemlose", function(inst, data)
        inst:DoTaskInTime(0, function(inst, data)
            if data and data.prev_item then
                data.prev_item[TUNING.MONE_TUNING.IGICF_FLAG_NAME] = nil;
            end
        end, data)
    end)
    inst:ListenForEvent("gotnewitem", function(inst, data)
        if data and data.item then
            data.item[TUNING.MONE_TUNING.IGICF_FLAG_NAME] = true;
        end
    end)
    inst:ListenForEvent("itemget", function(inst, data)
        if data and data.item then
            data.item[TUNING.MONE_TUNING.IGICF_FLAG_NAME] = true;
        end
    end)
end


-----------------------------------------------------------------------------
-- UpvalueAPI
-----------------------------------------------------------------------------
API.Debug = {};


local UpvalueAPI_MAX_LEVEL = 63; -- 按道理不需要设置 UpvalueAPI_MAX_LEVEL 的，直接遍历到为 nil 为止？

local UpvalueAPI_db_fns = {
    common_upvalue_fn = function(fn_reference, value_name, value_type)
        if fn_reference == nil then
            print("HaoWarning: " .. "[" .. tostring(fn_reference) .. "] is nil.");
            return ;
        end
        if type(fn_reference) ~= "function" then
            print("HaoWarning: " .. "[" .. tostring(fn_reference) .. "] is not a function type.");
            return ;
        end
        local level = 1;
        for i = 1, math.huge do
            local name, value = debug.getupvalue(fn_reference, level);
            if name and name == value_name then
                if value and type(value) == value_type then
                    return value, level;
                end
                break ;
            end
            level = level + 1;
            if level > UpvalueAPI_MAX_LEVEL then
                break ;
            end
        end
    end
};

function API.Debug.GetUpvalueFn(fn_reference, fn_name)
    return UpvalueAPI_db_fns.common_upvalue_fn(fn_reference, fn_name, "function");
end

-- FIXME: 这往往找两次，感觉不太好。。但是确实省事！
---如果没找到这个函数，是不会设置值的，所以内部不必判空！
function API.Debug.SetUpvalueFn(fn_reference, fn_name, value)
    local val, up = UpvalueAPI_db_fns.common_upvalue_fn(fn_reference, fn_name, "function");

    if val and up then
        debug.setupvalue(fn_reference, up, value);
    end
end

function API.Debug.GetUpvalueTab(fn_reference, tab_name)
    return UpvalueAPI_db_fns.common_upvalue_fn(fn_reference, tab_name, "table");
end

function API.Debug.SetUpvalueTab(fn_reference, tab_name, value)
    local val, up = UpvalueAPI_db_fns.common_upvalue_fn(fn_reference, tab_name, "table");
    if val and up then
        debug.setupvalue(fn_reference, up, value);
    end
end




-----------------------------------------------------------------------------
-- CODE GRAVE
-----------------------------------------------------------------------------
-- FIXME: __API.xpcall 有问题，好像是里面的 pack unpack 的问题，1,2,3,nil,4 这样的话，nil 后面都忽略了？
-- FIXME: 问题是只有第一个文件的物品导入成功了，后面的文件都注册失败。
-- 2023-02-13-08:54：刚刚看了一下代码，发现是自己写错了。。。现在应该是对的了，但是好像没必要了。
---@param files table[]
function API.loadPrefabs(files)
    local prefabsList = {};
    local file_cnt, prefab_cnt = 0, 0;
    for _, filepath in ipairs(files) do
        file_cnt = file_cnt + 1;
        if not string.find(filepath, ".lua$") then
            filepath = filepath .. ".lua";
        end
        local f, msg = loadfile(filepath); -- 加载文件，返回该文件代码构成的匿名函数
        if not f then
            print("ChangError: ", msg);
        else
            local res = { xpcall(f) };
            table.remove(res, 1);
            for _, prefab in pairs(res) do
                if type(prefab) == "table" and prefab.is_a and prefab:is_a(Prefab) then
                    table.insert(prefabsList, prefab);
                end
            end
        end
    end
    print(string.format("%s%s%s%s%s", "成功导入了：", file_cnt, " 个文件，共 ", prefab_cnt, " 个预制物。"));
    return prefabsList;
end

return API;