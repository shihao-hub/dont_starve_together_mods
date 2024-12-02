---
--- @author zsh in 2023/3/19 13:00
---

local API = require("chang_mone.dsts.API");
local Debug = API.Debug;

env.AddPrefabPostInitAny(function(inst)
    if not TheWorld.ismastersim then
        return inst;
    end
    if inst.components.perishable then
        inst:AddTag("_perishable_mone");
    end
end)

-- 以下的两个功能其实算是覆写法，但是我精确限制了只有在贮藏室中才会执行我的相关修改逻辑

-- 能够制冷！
env.AddComponentPostInit("temperature", function(self)
    local old_OnUpdate = self.OnUpdate;
    function self:OnUpdate(dt, applyhealthdelta, ...)
        local owner = self.inst.components.inventoryitem ~= nil and self.inst.components.inventoryitem.owner or nil
        if owner and owner:HasTag("more_items_fridge") and not owner:HasTag("more_items_nocool") then
            self.externalheaterpower = 0
            self.delta = 0
            self.rate = 0

            if self.settemp ~= nil or
                    self.inst.is_teleporting or
                    (self.inst.components.health ~= nil and self.inst.components.health:IsInvincible()) then
                return
            end

            -- Can override range, e.g. in special containers
            local mintemp = self.mintemp
            local maxtemp = self.maxtemp
            local ambient_temperature = TheWorld.state.temperature
            ------------

            mintemp = math.max(mintemp, math.min(0, ambient_temperature))
            self.rate = owner:HasTag("more_items_lowcool") and -.5 * TUNING.WARM_DEGREES_PER_SEC or -TUNING.WARM_DEGREES_PER_SEC

            self:SetTemperature(math.clamp(self.current + self.rate * dt, mintemp, maxtemp))

            if applyhealthdelta ~= false and self.inst.components.health ~= nil then
                if self.current < 0 then
                    self.inst.components.health:DoDelta(-self.hurtrate * dt, true, "cold")
                elseif self.current > self.overheattemp then
                    self.inst.components.health:DoDelta(-(self.overheathurtrate or self.hurtrate) * dt, true, "hot")
                end
            end
            return ; -- 直接 return，不需要也不应该执行原函数。算是重写了。
        end

        return old_OnUpdate(self, dt, applyhealthdelta, ...);
    end
end)

-- 冰块不会腐烂！
local perishable = require("components/perishable");
if perishable then
    local function new_Update(inst, dt, ...)
        -- 提示：此处有 frozen 标签的预制物才会进入该逻辑
        --- 当然，有可能我只限制冰块才能进入，避免和其他模组的兼容性问题...

        local self = inst.components.perishable
        if self ~= nil then
            dt = self.start_dt or dt
            self.start_dt = nil

            local modifier = 1
            local owner = inst.components.inventoryitem and inst.components.inventoryitem.owner or nil
            if not owner and inst.components.occupier then
                owner = inst.components.occupier:GetOwner()
            end
            ------------

            -- 此处修改了内容，其余部分为官方原版代码，没办法，只能覆盖了(2023-06-15)
            if owner then
                modifier = TUNING.PERISH_COLD_FROZEN_MULT

                if owner:HasTag("spoiler") then
                    modifier = modifier * TUNING.PERISH_GROUND_MULT
                end
            else
                modifier = TUNING.PERISH_GROUND_MULT
            end
            ------------

            if inst:GetIsWet() and not self.ignorewentness then
                modifier = modifier * TUNING.PERISH_WET_MULT
            end

            if TheWorld.state.temperature < 0 then
                if inst:HasTag("frozen") and not self.frozenfiremult then
                    modifier = TUNING.PERISH_COLD_FROZEN_MULT
                else
                    modifier = modifier * TUNING.PERISH_WINTER_MULT
                end
            end

            if self.frozenfiremult then
                modifier = modifier * TUNING.PERISH_FROZEN_FIRE_MULT
            end

            if TheWorld.state.temperature > TUNING.OVERHEAT_TEMP then
                modifier = modifier * TUNING.PERISH_SUMMER_MULT
            end

            modifier = modifier * self.localPerishMultiplyer

            modifier = modifier * TUNING.PERISH_GLOBAL_MULT

            local old_val = self.perishremainingtime
            local delta = dt or (10 + math.random() * FRAMES * 8)
            if self.perishremainingtime then
                self.perishremainingtime = math.min(self.perishtime, self.perishremainingtime - delta * modifier)
                if math.floor(old_val * 100) ~= math.floor(self.perishremainingtime * 100) then
                    inst:PushEvent("perishchange", { percent = self:GetPercent() })
                end
            end

            --Cool off hot foods over time (faster if in a fridge)
            --Skip and retain heat in containers with "nocool" tag
            if inst.components.edible ~= nil and inst.components.edible.temperaturedelta ~= nil and inst.components.edible.temperaturedelta > 0 and not (owner ~= nil and owner:HasTag("nocool")) then
                if owner ~= nil and owner:HasTag("more_items_fridge") then
                    inst.components.edible:AddChill(1)
                elseif TheWorld.state.temperature < TUNING.OVERHEAT_TEMP - 5 then
                    inst.components.edible:AddChill(.25)
                end
            end

            --trigger the next callback
            if self.perishremainingtime and self.perishremainingtime <= 0 then
                self:Perish()
            end
        end
    end
    ------------

    local self = perishable;

    local old_StartPerishing = self.StartPerishing;
    if old_StartPerishing then
        local old_Update = Debug.GetUpvalueFn(old_StartPerishing, "Update");
        if old_Update then
            Debug.SetUpvalueFn(old_StartPerishing, "Update", function(inst, dt, ...)
                local owner = inst.components.inventoryitem and inst.components.inventoryitem.owner or nil;
                if owner and owner:HasTag("more_items_fridge") then
                    if inst:HasTag("frozen") and not owner:HasTag("more_items_nocool") and not owner:HasTag("more_items_lowcool") then
                        if inst.prefab == "ice" then
                            return new_Update(inst, dt, ...);
                        end
                    end
                end
                return old_Update(inst, dt, ...);
            end)
        end
    end
end
