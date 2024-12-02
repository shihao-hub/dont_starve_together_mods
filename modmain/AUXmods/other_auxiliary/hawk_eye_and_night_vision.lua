---
--- @author zsh in 2023/6/22 12:49
---

--[[
    既是服务端又是客户端进程：不开洞穴的房主饥荒进程
    单纯的服务端进程：开洞的房主服务端进程、专服进程
    单纯的客户端进程：开洞的房主的饥荒进程、所有加入房间或专服玩家的饥荒进程

    TheNet:GetIsServer() -- 不开洞的房主饥荒进程，开洞的房主服务端进程，专服进程 返回 true
    TheNet:IsDedicated() -- 开洞的房主服务端进程，专服进程 返回 true
    TheNet:GetIsClient()  -- 开洞的房主的饥荒进程，所有加入房间或专服玩家的饥荒进程 返回 true
    TheNet:GetServerIsClientHosted() -- 若游戏不是专用服务器，那么任何端都会返回 true

    not TheNet:IsDedicated()：不开洞的房主饥荒进程、开洞的房主的饥荒进程、所有加入房间或专服玩家的饥荒进程
]]

local function OnlyServer()
    return TheNet:IsDedicated();
end

local function OnlyClient()
    return TheNet:GetIsClient();
end

local function BothServerClient()
    return TheNet:GetIsServer() and not TheNet:IsDedicated();
end

local function AllServer()
    return OnlyServer() or BothServerClient();
end

local function AllClient()
    return OnlyClient() or BothServerClient();
end
-------------------------------------------------------------


--[[ 禁用鹰眼 ?是否禁用大视野呢？ ]]
local followcamera = require("cameras/followcamera");
if followcamera then
    local old_Apply = followcamera.Apply;
    if old_Apply then
        local function SetCamera(camera, zoomstep, mindist, maxdist, mindistpitch, maxdistpitch, distance, distancetarget)
            camera.zoomstep = zoomstep or camera.zoomstep
            camera.mindist = mindist or camera.mindist
            camera.maxdist = maxdist or camera.maxdist
            camera.mindistpitch = mindistpitch or camera.mindistpitch
            camera.maxdistpitch = maxdistpitch or camera.maxdistpitch
            camera.distance = distance or camera.distance
            camera.distancetarget = distancetarget or camera.distancetarget
        end

        local function StandardView(camera)
            if TheWorld ~= nil then
                if TheWorld:HasTag("cave") then
                    SetCamera(camera, 4, 15, 35, 25, 40, 25, 25)
                else
                    SetCamera(camera, 4, 15, 50, 30, 60, 30, 30)
                end
            end

            camera.fov = 35;
        end

        function followcamera:Apply(...)
            if self.fov > 35 then
                if ThePlayer then
                    ThePlayer.components.talker:Say("抱歉，本服务器不允许使用鹰眼！");
                end
                StandardView(self);
            end

            return old_Apply(self, ...);
        end
    end
end





--[[ 禁用客户端夜视 ]]
env.AddComponentPostInit("playervision", function(self)
    self.inst.henv_nightvision = net_bool(self.inst.GUID, "henv_nightvision", "henv_ForceNightVision");

    -- 默认值是 false
    --print("self.inst.henv_nightvision: " .. tostring(self.inst.henv_nightvision:value()));

    local old_ForceNightVision = self.ForceNightVision;
    if old_ForceNightVision then
        function self:ForceNightVision(force, ...)
            -- 排除部分人物模组，可能会导致视野仍是黑的？因为该模组实现的时候是直接修改客户端滤镜的？
            if not self.inst or table.contains({ "wathom", "wayne" }, self.inst.prefab) then
                return old_ForceNightVision(self, force, ...);
            end

            -- 实现思路：服务器修改了才行，如果只动客户端，则无效。
            if OnlyServer() then
                force = force == nil and false or force;
                self.inst.henv_nightvision:set(force);
            else
                force = self.inst.henv_nightvision:value();
            end

            return old_ForceNightVision(self, force, ...);
        end
    end
end)