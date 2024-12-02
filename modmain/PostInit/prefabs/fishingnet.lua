---
--- @author zsh in 2023/6/2 12:02
---

-- 打个补丁，骑牛的时候不能有这个动作...
if EntityScript then
    local CollectActions = EntityScript.CollectActions;
    if CollectActions then
        local UpvalueUtil = require("chang_mone.dsts.UpvalueUtil");
        local COMPONENT_ACTIONS = UpvalueUtil.GetUpvalue(CollectActions, "COMPONENT_ACTIONS");
        if COMPONENT_ACTIONS and type(COMPONENT_ACTIONS) == "table" then
            local old_fishingnet = COMPONENT_ACTIONS.POINT and COMPONENT_ACTIONS.POINT.fishingnet;
            if old_fishingnet and type(old_fishingnet) == "function" then
                COMPONENT_ACTIONS.POINT.fishingnet = function(inst, doer, target, actions, right, ...)
                    if right then
                        local inventory = doer.replica.inventory
                        local handitem = inventory and inventory:GetEquippedItem(EQUIPSLOTS.HANDS);
                        local rider = doer.replica.rider;
                        if handitem and handitem:HasTag("mone_fishingnet") and rider and rider:IsRiding() then
                            return false;
                        else
                            return old_fishingnet(inst, doer, target, actions, right, ...);
                        end
                    else
                        return old_fishingnet(inst, doer, target, actions, right, ...);
                    end
                end
            end
        end
    end
end

HookComponent("fishingnet", function(self)
    local old_CastNet = self.CastNet;
    if old_CastNet then
        function self:CastNet(pos_x, pos_z, doer, ...)
            if self.inst:HasTag("mone_fishingnetvisualizer") then
                local visualizer = SpawnPrefab("mone_fishingnetvisualizer")
                visualizer.components.fishingnetvisualizer:BeginCast(doer, pos_x, pos_z)
                visualizer.item = self.inst
                self.visualizer = visualizer
                return true
            else
                return old_CastNet(self, pos_x, pos_z, doer, ...)
            end
        end
    end
end)

HookComponent("fishingnetvisualizer", function(self)
    local old_BeginOpening = self.BeginOpening;
    local old_DropItem = self.DropItem;

    if oneOfNull(2, old_BeginOpening, old_DropItem) then
        return ;
    end

    local SHOAL_MUST_TAGS = { "oceanshoalspawner" };

    function self:BeginOpening(...)
        old_BeginOpening(self, ...);

        if self.inst:HasTag("mone_fishingnetvisualizer") then
            if self.inst.item ~= nil then
                self.inst.item.netweight = 1;
            end

            local my_x, my_y, my_z = self.inst.Transform:GetWorldPosition()
            local fishies = TheSim:FindEntities(my_x, my_y, my_z, self.collect_radius, { "oceanfishable" })
            for k, v in pairs(fishies) do
                local fishdef = v.fish_def ~= nil and v.fish_def.prefab ~= nil and v.fish_def.prefab or nil
                local fish = fishdef ~= nil and SpawnPrefab(fishdef .. "_inv") or nil

                if fish == nil then
                    fish = fishdef ~= nil and SpawnPrefab(fishdef .. "_land") or nil
                end

                if fish == nil then
                    return ;
                elseif fish ~= nil and k < 3 then
                    if self.inst.item ~= nil and v.components.weighable ~= nil then
                        local minweight = v.components.weighable.min_weight

                        if minweight < 100 then
                            self.inst.item.netweight = self.inst.item.netweight + 2
                        elseif minweight >= 100 and minweight < 200 then
                            self.inst.item.netweight = self.inst.item.netweight + 3
                        elseif minweight >= 200 then
                            self.inst.item.netweight = self.inst.item.netweight + 4
                        end
                    end

                    v:Remove()
                    fish.Transform:SetPosition(my_x, my_y, my_z)
                    fish.components.weighable:SetWeight(fish.components.weighable.min_weight)

                    if fish:IsValid() then
                        fish:RemoveFromScene()
                    end

                    table.insert(self.captured_entities, fish)
                    self.captured_entities_collect_distance[fish] = 0

                    -- An ocean shoal nearby? Send an event to notify listners
                    local shoals = TheSim:FindEntities(my_x, my_y, my_z, 16, SHOAL_MUST_TAGS)
                    if shoals ~= nil then
                        local shoal = shoals[1]
                        TheWorld:PushEvent("ms_shoalfishhooked", shoal)
                    end
                end
            end
        end
    end

    function self:DropItem(item, last_dir_x, last_dir_z, idx, ...)
        if self.inst:HasTag("mone_fishingnetvisualizer") then
            local thrower_x, thrower_y, thrower_z = self.thrower.Transform:GetWorldPosition()

            local time_between_drops = 0.25
            local initial_delay = 0.15
            item:DoTaskInTime(idx * time_between_drops + initial_delay, function(item)
                item:ReturnToScene()
                item:PushEvent("on_release_from_net")

                local drop_vec_x = TheCamera:GetRightVec().x
                local drop_vec_z = TheCamera:GetRightVec().z

                local camera_up_vec_x, camera_up_vec_z = -TheCamera:GetDownVec().x, -TheCamera:GetDownVec().z

                if VecUtil_Dot(last_dir_x, last_dir_z, drop_vec_x, drop_vec_z) < 0 then
                    drop_vec_x = -drop_vec_x
                    drop_vec_z = -drop_vec_z
                end

                local up_offset_dist = 0.1

                local drop_offset = GetRandomWithVariance(1, 0.2)
                local pt_x = drop_vec_x * drop_offset + thrower_x + camera_up_vec_x * up_offset_dist
                local pt_z = drop_vec_z * drop_offset + thrower_z + camera_up_vec_z * up_offset_dist

                local physics = item.Physics

                if not TheWorld.Map:IsOceanAtPoint(pt_x, 0, pt_z) then
                    if physics ~= nil then
                        local drop_height = GetRandomWithVariance(0.65, 0.2)
                        local pt_y = drop_height + thrower_y
                        item.Transform:SetPosition(pt_x, pt_y, pt_z)
                        physics:SetVel(0, -0.25, 0)
                    else
                        item.Transform:SetPosition(pt_x, 0, pt_z)
                    end
                else
                    if physics ~= nil then
                        local drop_height = GetRandomWithVariance(0.65, 0.2)
                        local pt_y = drop_height + thrower_y
                        item.Transform:SetPosition(thrower_x, pt_y, thrower_z)
                        physics:SetVel(0, -0.25, 0)
                    else
                        item.Transform:SetPosition(thrower_x, 0, thrower_z)
                    end
                end

                if item:HasTag("stunnedbybomb") then
                    item.sg:GoToState("stunned", false)
                end
            end)
        else
            return old_DropItem(self, item, last_dir_x, last_dir_z, idx, ...)
        end
    end
end)