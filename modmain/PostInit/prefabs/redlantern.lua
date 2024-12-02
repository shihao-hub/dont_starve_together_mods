---
--- @author zsh in 2023/5/5 16:45
---

local UpvalueUtil = require("chang_mone.dsts.UpvalueUtil");

-- 坎普斯不会偷
local krampusbrain = require("brains/krampusbrain");
if krampusbrain then
    local OnStart = krampusbrain.OnStart;
    local STEAL_CANT_TAGS = UpvalueUtil.GetUpvalue(OnStart, "StealAction.STEAL_CANT_TAGS");
    if isTab(STEAL_CANT_TAGS) then
        table.insert(STEAL_CANT_TAGS, "mone_nosteal");
    end
end

-- 地洞猴子不会偷
local monkeybrain = require("brains/monkeybrain");
if monkeybrain then
    local OnStart = monkeybrain.OnStart;
    local NO_PICKUP_TAGS = UpvalueUtil.GetUpvalue(OnStart, "AnnoyLeader.NO_PICKUP_TAGS");
    if isTab(NO_PICKUP_TAGS) then
        table.insert(NO_PICKUP_TAGS, "mone_nosteal");
    end
end

