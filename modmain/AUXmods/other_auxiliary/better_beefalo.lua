---
--- @author zsh in 2023/4/14 10:45
---

local API = require("chang_mone.dsts.API");
local Debug = API.Debug;

local function binding(guy)
    if guy and guy:HasTag("beefalo") then
        local follower = guy and guy.replica and guy.replica.follower;
        local leader = follower and follower:GetLeader();
        return leader and leader.prefab == "beef_bell";
    end
end

--[[
    部分计划：
    1. 被绑定的牛是盟友
    2. 被绑定的牛不会生成便便
    3. 被绑定的牛不会和其他皮弗娄牛共享仇恨
    4. 被绑定的牛不会被伯尼嘲讽
    5. 被绑定的牛训诫值/驯化度大于X%的时候不会发情和繁殖
]]

--[[ 被绑定的牛是盟友 ]]
local combat_replica = require "components/combat_replica";
local old_IsAlly = combat_replica.IsAlly;
function combat_replica:IsAlly(guy, ...)
    if guy and guy:HasTag("beefalo") then
        return binding(guy);
    end
    return old_IsAlly(self, guy, ...);
end

--[[ 被绑定的牛不会生成便便 ]]
env.AddPrefabPostInit("beefalo", function(inst)
    if not TheWorld.ismastersim then
        return inst;
    end
    if inst.components.periodicspawner then
        local old_spawntest = inst.components.periodicspawner.spawntest;
        if old_spawntest then
            inst.components.periodicspawner:SetSpawnTestFn(function(inst)
                if binding(inst) then
                    return false;
                end
                return old_spawntest and old_spawntest(inst);
            end);
        end
    end
end)

-- 以下部分为拓展功能，正常情况以上部分已经够了，而且并没有修改太多东西。
if not isDebug()--[[230622]]then
    return;
end

--[[ 被绑定的牛不会和其他皮弗娄牛共享仇恨 ?++小皮弗娄牛 ]]
env.AddSimPostInit(function()
    local Prefabs = GLOBAL.Prefabs;
    if null(Prefabs) then
        return ;
    end
    local beefalo_fn = Prefabs["beefalo"] and Prefabs["beefalo"].fn;
    if beefalo_fn then
        -- 不会和其他皮弗娄牛共享仇恨
        local OnAttacked = Debug.GetUpvalueFn(beefalo_fn, "OnAttacked");
        if OnAttacked then
            local CanShareTarget = Debug.GetUpvalueFn(OnAttacked, "CanShareTarget");
            if CanShareTarget then
                Debug.SetUpvalueFn(OnAttacked, "CanShareTarget", function(dude, ...)
                    return CanShareTarget(dude, ...) and not binding(dude);
                end)
            end
        end
    end

    -- 不会和其他皮弗娄牛共享仇恨：还需要处理小牛，似乎只能用覆盖法，但是似乎并未生效，为什么呢，再说吧。
    if isDebugSimple() --[[230622:TEST]]then
        local babybeefalo_fn = Prefabs["babybeefalo"] and Prefabs["babybeefalo"].fn;
        if babybeefalo_fn then
            local OnAttacked = Debug.GetUpvalueFn(babybeefalo_fn, "OnAttacked");
            --print("babybeefalo OnAttacked: "..tostring(OnAttacked));
            if OnAttacked then
                Debug.SetUpvalueFn(babybeefalo_fn, "OnAttacked", function(inst, data, ...)
                    inst.components.combat:SetTarget(data.attacker);
                    inst.components.combat:ShareTarget(data.attacker, 30, function(dude)
                        if binding(dude) then
                            print("dude binding: "..tostring(dude));
                        end
                        return dude:HasTag("beefalo")
                                and not dude:HasTag("player")
                                and not dude.components.health:IsDead()
                                and not binding(dude);
                    end, 5)
                end)
            end
        end
    end

end)

--[[ 被绑定的牛不会被伯尼嘲讽 ?++不会仇恨友军 ]]
env.AddPrefabPostInit("beefalo", function(inst)
    if not TheWorld.ismastersim then
        return inst;
    end
    if null(inst.components.combat) then
        return inst;
    end
    HookComponentSimulated("combat", inst, function(self, inst)
        local old_SetTarget = self.SetTarget;
        function self:SetTarget(target, ...)
            if isValid(target) and target.prefab == "bernie_big" then
                return ;
            end
            if old_SetTarget then
                return old_SetTarget(self, target, ...);
            end
        end
    end);
end)

do
    return; -- 2023-06-18：以下部分不执行，因为不完整，还是会繁殖的...
end

--[[ 被绑定的牛训诫值/驯化度大于X%的时候不会发情和繁殖 ]]
local DOMESTICATION_UPPER_LIMIT = 0.02;
-- 不会发情
env.AddSimPostInit(function()
    local Prefabs = GLOBAL.Prefabs;
    if null(Prefabs) then
        return ;
    end
    local beefalo_fn = Prefabs["beefalo"] and Prefabs["beefalo"].fn;
    if beefalo_fn then
        local fns = Debug.GetUpvalueTab(beefalo_fn, "fns");
        if isTab(fns) then
            local GetIsInMood = fns.GetIsInMood;
            if GetIsInMood then
                fns.GetIsInMood = function(inst, ...)
                    --print("fns.GetIsInMood:");
                    --print("GetIsInMood(inst, ...): " .. tostring(GetIsInMood(inst, ...)));
                    --print("binding: " .. tostring(binding(inst)));
                    if inst.components.domesticatable then
                        local domestication = inst.components.domesticatable.domestication;
                        if domestication then
                            if binding(inst) and domestication >= DOMESTICATION_UPPER_LIMIT then
                                --print("训诫值大于等于" .. (DOMESTICATION_UPPER_LIMIT * 100) .. "%");
                                --print();
                                return false;
                            end
                        end
                    end
                    --print();
                    return GetIsInMood(inst, ...);
                end
            end
        end
    end
end)
-- 不会繁殖
env.AddPrefabPostInit("beefalo", function(inst)
    if not TheWorld.ismastersim then
        return inst;
    end
    if null(inst.components.herdmember) or null(inst.components.domesticatable) then
        return inst;
    end
    HookComponentSimulated("domesticatable", inst, function(self, inst)
        local old_DeltaDomestication = self.DeltaDomestication;
        function self:DeltaDomestication(delta, ...)
            if binding(self.inst) then
                if self.inst.components.domesticatable and self.inst.components.herdmember then
                    local domestication = isNum(self.inst.components.domesticatable.domestication);
                    if domestication then
                        if domestication < DOMESTICATION_UPPER_LIMIT then
                            self.inst.components.herdmember:Enable(true);
                        else
                            self.inst.components.herdmember:Enable(false);
                        end
                    end
                end
            end
            if old_DeltaDomestication then
                return old_DeltaDomestication(self, delta, ...);
            end
        end
    end)
end)


