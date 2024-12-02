---
--- @author zsh in 2023/4/22 12:12
---

local API = require("chang_mone.dsts.API");
local Debug = API.Debug;

------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------
-- 其他物品可以堆叠：记得不能有生物！
local MUST_SINGLE_ITEMS = {
    ["lavae_egg"] = {};
    ["tallbirdegg"] = {};
}

local ETC_ITEMS = {
    "lavae_egg", -- 岩浆虫卵
    "tallbirdegg", -- 高脚鸟蛋
    "eyeturret_item", -- 眼球塔
    "minotaurhorn", -- 远古守护者角
    "deerclops_eyeball", -- 独眼巨鹿眼球
    "shadowheart", -- 暗影心房
}

for _, name in ipairs(ETC_ITEMS) do
    env.AddPrefabPostInit(name, function(inst)
        if not TheWorld.ismastersim then
            return inst;
        end
        if inst.components.inventoryitem == nil
                or inst.components.stackable
                or inst.components.perishable
                or inst.components.health then
            return inst;
        end

        inst:AddComponent("stackable");
        inst.components.stackable.maxsize = TUNING.STACK_SIZE_LARGEITEM;

        do
            return inst;
        end

        -- 2023-04-22-20:00：按道理来说，我应该修改的是孵化方面的内容，而不是丢地上变成一个一个的。
        MUST_SINGLE_ITEMS = {}; -- 2023-04-22-20:30：不需要此处了，因为已经在其他地方精确地修改了相关内容了。
        if table.containskey(MUST_SINGLE_ITEMS, inst.prefab) then
            if MUST_SINGLE_ITEMS[inst.prefab] == nil then
                MUST_SINGLE_ITEMS[inst.prefab] = {};
            end
            if MUST_SINGLE_ITEMS[inst.prefab].ondropfn == nil then
                MUST_SINGLE_ITEMS[inst.prefab].ondropfn = inst.components.inventoryitem.ondropfn;
            end
            inst.components.inventoryitem:SetOnDroppedFn(function(inst)
                local old_ondropfn;
                if MUST_SINGLE_ITEMS[inst.prefab] and MUST_SINGLE_ITEMS[inst.prefab].ondropfn then
                    old_ondropfn = MUST_SINGLE_ITEMS[inst.prefab].ondropfn;
                end

                if inst.components.stackable:StackSize() > 10 then
                    if old_ondropfn then
                        old_ondropfn(inst);
                    end
                    return ;
                end

                if inst.components.stackable == nil then
                    if old_ondropfn then
                        old_ondropfn(inst);
                    end
                    return ;
                end
                if inst.components.stackable:StackSize() == 1 then
                    if old_ondropfn then
                        old_ondropfn(inst);
                    end
                    return ;
                end
                local x, y, z = inst.Transform:GetWorldPosition();
                while inst.components.stackable:StackSize() > 1 do
                    local single = inst.components.stackable:Get();
                    single.Transform:SetPosition(x, y, z);
                    single.components.inventoryitem:OnDropped();
                end
                if inst.components.stackable:StackSize() == 1 then
                    if old_ondropfn then
                        old_ondropfn(inst);
                    end
                end
            end);
        end

    end)
end

for _, name in ipairs({ "lavae_egg", "tallbirdegg" }) do
    if table.contains(ETC_ITEMS, name) then
        env.AddPrefabPostInit(name, function(inst)
            if not TheWorld.ismastersim then
                return inst;
            end
            if inst.components.hatchable == nil then
                return inst;
            end

            local old_onstatefn = inst.components.hatchable.onstatefn;
            inst.components.hatchable.onstatefn = function(inst, state)
                local inst_stacksize = inst.components.stackable and inst.components.stackable:StackSize();
                local inst_pt = inst:GetPosition();

                if old_onstatefn then
                    old_onstatefn(inst, state);
                end

                if state == "crack" then
                    if inst_stacksize and inst_stacksize > 1 and inst_pt then
                        local new_inst = SpawnPrefab(inst.prefab);
                        new_inst.components.stackable:SetStackSize(inst_stacksize - 1);
                        new_inst.Transform:SetPosition(inst_pt:Get());
                    end
                end
            end
        end)
    end
end

-- 尝试换一种方式实现该功能：关于岩浆虫卵和高脚鸟蛋的孵化问题
---- 注意此处函数的执行似乎非常靠前，因为此处崩溃我的本地模组会被全部禁用。
------ 找到原因了：Prefabs.lavae_egg、Prefabs.tallbirdegg 为空是因为需要调用 GLOBAL 里面的 Prefabs ...
if false  then
    env.AddSimPostInit(function(wilson)
        -- wilson 这个参数好像一直都是 nil。试了一次，打印出来确实是 nil
        ---- 2023-04-22：第一次用 AddSimPostInit 函数第一次进游戏卡住了，不知道什么情况。后续都正常了。
        print("SimPostInit:wilson:" .. tostring(wilson));

        -- 以下部分的 OnHatchState 函数内容已经过时
        if table.contains(ETC_ITEMS, "lavae_egg") and Prefabs and Prefabs["lavae_egg"] then
            local lavae_egg = Prefabs["lavae_egg"].fn;
            local old_OnHatchState = Debug.GetUpvalueFn(lavae_egg, "OnHatchState");
            Debug.SetUpvalueFn(lavae_egg, "OnHatchState", function(inst, state)
                if state == "crack" then
                    local function PlaySound(inst, sound)
                        inst.SoundEmitter:PlaySound(sound)
                    end

                    local cracked = SpawnPrefab("lavae_egg_cracked")
                    cracked.Transform:SetPosition(inst.Transform:GetWorldPosition())
                    cracked.AnimState:PlayAnimation("crack")
                    inst:DoTaskInTime(14 * FRAMES, PlaySound, "dontstarve/creatures/together/lavae/egg_crack")
                    inst:DoTaskInTime(22 * FRAMES, PlaySound, "dontstarve/creatures/together/lavae/egg_bounce")
                    cracked.AnimState:PushAnimation("happy", true)

                    if inst.components.stackable then
                        inst.components.stackable:Get():Remove();
                    else
                        inst:Remove();
                    end
                else
                    if old_OnHatchState then
                        old_OnHatchState(inst, state);
                    end
                end
            end)
        end

        if table.contains(ETC_ITEMS, "tallbirdegg") and Prefabs and Prefabs["tallbirdegg"] then
            local tallbirdegg = Prefabs["tallbirdegg"].fn;
            local old_OnHatchState = Debug.GetUpvalueFn(tallbirdegg, "OnHatchState");
            Debug.SetUpvalueFn(tallbirdegg, "OnHatchState", function(inst, state)
                inst.SoundEmitter:KillSound("uncomfy")

                if state == "crack" then
                    local cracked = SpawnPrefab("tallbirdegg_cracked")
                    cracked.Transform:SetPosition(inst.Transform:GetWorldPosition())
                    cracked.AnimState:PlayAnimation("crack")
                    cracked.AnimState:PushAnimation("idle_happy", true)
                    cracked.SoundEmitter:PlaySound("dontstarve/creatures/egg/egg_hatch_crack")

                    if inst.components.stackable then
                        inst.components.stackable:Get():Remove();
                    else
                        inst:Remove();
                    end
                else
                    if old_OnHatchState then
                        old_OnHatchState(inst, state);
                    end
                end
            end)
        end
    end)
end



------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------
-- 生物可以堆叠
local CREATURES_DATA = {};

local function isCreature(inst)
    return inst.components.inventoryitem
            and inst.components.perishable
            and (inst.components.health
            or (inst:HasTag("pondfish") or inst:HasTag("smallcreature")));
end

local function ondropfn(inst)
    local old_ondropfn;
    if CREATURES_DATA[inst.prefab] and CREATURES_DATA[inst.prefab].ondropfn then
        --print("get " .. inst.prefab .. "'s `ondropfn` function");
        old_ondropfn = CREATURES_DATA[inst.prefab].ondropfn;
    end
    if inst.components.stackable == nil then
        if old_ondropfn then
            old_ondropfn(inst);
        end
        return ;
    end
    if inst.components.stackable:StackSize() == 1 then
        if old_ondropfn then
            old_ondropfn(inst);
        end
        return ;
    end

    -- 开启个线程避免卡顿。用 TheWorld 而不是 inst 是担心要是 inst 在线程没执行完之前就被移除了咋办？
    --TheWorld:StartThread(function()
    --    local x, y, z = inst.Transform:GetWorldPosition();
    --    while inst.components.stackable:StackSize() > 1 do
    --        Sleep((0.1) * 0.001);
    --        local single = inst.components.stackable:Get();
    --        single.Transform:SetPosition(x, y, z);
    --        single.components.inventoryitem:OnDropped();
    --    end
    --    if inst.components.stackable:StackSize() == 1 then
    --        if old_ondropfn then
    --            old_ondropfn(inst);
    --        end
    --    end
    --end)

    local x, y, z = inst.Transform:GetWorldPosition();
    while inst.components.stackable:StackSize() > 1 do
        local single = inst.components.stackable:Get();
        single.Transform:SetPosition(x, y, z);
        single.components.inventoryitem:OnDropped();
    end
    if inst.components.stackable:StackSize() == 1 then
        if old_ondropfn then
            old_ondropfn(inst);
        end
    end
end

env.AddPrefabPostInitAny(function(inst)
    if not TheWorld.ismastersim then
        return inst;
    end
    if inst.components.inventoryitem == nil or inst.components.stackable then
        return inst;
    end
    if not isCreature(inst) then
        return inst;
    end

    inst:AddComponent("stackable");
    inst.components.stackable.maxsize = TUNING.STACK_SIZE_LARGEITEM;

    local old_ondropfn = inst.components.inventoryitem.ondropfn;
    if CREATURES_DATA[inst.prefab] == nil then
        CREATURES_DATA[inst.prefab] = {};
    end
    if CREATURES_DATA[inst.prefab].ondropfn == nil then
        CREATURES_DATA[inst.prefab].ondropfn = old_ondropfn;
    end
    inst.components.inventoryitem:SetOnDroppedFn(ondropfn);

end)

-- 生物可以堆叠：处理一下有雇佣时间的某些生物
-- 功能：被雇佣的生物仍保留雇佣状态
---- 2023-04-22-15:58：功能较为复杂，尚未完成。不仅未完成，连如何完美地实现都没有想好呢！
local HANDLE_FOLLOWER_OPTION = false;

if HANDLE_FOLLOWER_OPTION then
    local function isFollower(inst)
        return inst.components.follower;
    end

    env.AddComponentPostInit("stackable", function(self)

        if isFollower(self.inst) then
            self.inst.creatures_stackable_data = {};
        end
        local old_Get = self.Get;
        function self:Get(num, ...)
            local item = old_Get and old_Get(self, num, ...);

            local inst = self.inst;
            if item and item:IsValid()
                    and inst and inst:IsValid()
                    and item.creatures_stackable_data and inst.creatures_stackable_data then

            end

            return item;
        end

        local old_Put = self.Put;
        function self:Put(item, source_pos, ...)
            local inst = self.inst;

            if item.components.stackable:StackSize() == 1 then
                if item.creatures_stackable_data == nil then
                    item.creatures_stackable_data = {};
                    table.insert(item.creatures_stackable_data, item:GetSaveRecord());
                end
            end

            if item and item:IsValid()
                    and inst and inst:IsValid()
                    and item.creatures_stackable_data and inst.creatures_stackable_data then
                for _, v in ipairs(item.creatures_stackable_data) do
                    table.insert(inst.creatures_stackable_data, v);
                end
            end

            return old_Put and old_Put(self, item, source_pos, ...);
        end
    end)
end

