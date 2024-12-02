---
--- @author zsh in 2023/3/26 14:26
---

-- 更容易召唤伯尼-半成品-说明
-- 理智低于80就能召唤伯尼，还可以召唤多只伯尼。
-- 注意事项：假如你开的模组太多，此处功能有可能失效。
-- 额，疯狂状态只能召唤一只，不知道为什么。。

-- bug 有点多，主要会召唤多只伯尼的问题。。。
---- 2023-03-27：有点儿无语，bernie_inactive\bernie_active\berniebrain\berniebigbrain
------ 我想要解决这个问题可能需要看懂 brain 以及执行过程。。再说吧。

local config_data = TUNING.MONE_TUNING.GET_MOD_CONFIG_DATA;

local API = require("chang_mone.dsts.API");
local Debug = API.Debug;

env.AddPrefabPostInit("willow", function(inst)
    if not TheWorld.ismastersim then
        return inst;
    end
    if inst.components.sanity then
        local MAX_LEVEL = 2; -- 最多允许被几个模组 hook。但是如果我的模组最后加载，那就不用担心了。
        local old_IsCrazy = inst.components.sanity.IsCrazy;
        function inst.components.sanity:IsCrazy(...)
            -- 只判断薇洛的理智，其他玩家的不管
            if self.inst.prefab == "willow" then
                for i = 0, MAX_LEVEL do
                    local debugInfo = debug.getinfo(i + 2, "Sl");
                    if debugInfo then
                        local short_src = debugInfo.short_src;
                        --print("what: " .. tostring(debugInfo.what));
                        --local currentline = debugInfo.currentline;
                        --if short_src:find("scripts/brains/berniebigbrain.lua") then
                        --    -- DoNothing
                        --else
                        --    print("short_src: " .. tostring(short_src));
                        --    if short_src:find("scripts/brains/berniebrain.lua")
                        --        or short_src:find("scripts/behaviourtree.lua")
                        --    then
                        --        print("currentline: "..tostring(currentline));
                        --    end
                        --end
                        if short_src and (short_src:find("scripts/prefabs/bernie_inactive.lua")
                                or short_src:find("scripts/brains/berniebrain.lua")
                                or short_src:find("scripts/brains/berniebigbrain.lua"))
                        then
                            if not self:IsInsane() and self.inst.components.sanity.current < 100 then
                                return true;
                            elseif self:IsInsane() then
                                --print("Crazy State，此处不生效！");
                                return old_IsCrazy(self, ...);
                            end
                        end
                    end
                end
            end
            return old_IsCrazy(self, ...);
        end

        --local old_IsCrazy_Test = inst.components.sanity.IsCrazy;
        --function inst.components.sanity:IsCrazy(...)
        --    return old_IsCrazy_Test(self, ...);
        --end
        --
        --local old_IsCrazy_Test = inst.components.sanity.IsCrazy;
        --function inst.components.sanity:IsCrazy(...)
        --    return old_IsCrazy_Test(self, ...);
        --end
    end
end)

do
    -- 暂时不需要，因为没效果。到时候解决 Crazy 状态只能召唤一只伯尼的情况的时候可能需要此处。
    -- 2023-03-27：感觉应该是处理掉非 Crazy 状态能召唤多只大伯尼的问题。。。
    return ;
end
-- 修改小伯尼的脑子
local BernieBrain = require "brains/berniebrain";
local BIG_LEADER_DIST_SQ = 8 * 8;
local old_OnStart = BernieBrain and BernieBrain.OnStart;
if old_OnStart then
    local old_ShouldGoBig = Debug.GetUpvalueFn(old_OnStart, "ShouldGoBig");
    Debug.SetUpvalueFn(old_OnStart, "ShouldGoBig", function(self)
        local x, y, z = self.inst.Transform:GetWorldPosition()
        for i, v in ipairs(AllPlayers) do
            if v:HasTag("bernieowner") and
                    v.bigbernies == nil and -- 可以召唤多只伯尼！但是会变大变小。。为啥。
                    v.blockbigbernies == nil and
                    v.components.sanity:IsCrazy() and
                    v.entity:IsVisible() and
                    v:GetDistanceSqToPoint(x, y, z) < BIG_LEADER_DIST_SQ then
                self._leader = v
                return true
            end
        end
        return old_ShouldGoBig(self);
    end);
end


