local locale = LOC.GetLocaleCode();
local L = (locale == "zh" or locale == "zht" or locale == "zhr") and true or false;

local modname = KnownModIndex:GetModActualName(L and "更多物品" or "More Items") or "";
local fow_setting = GetModConfigData("Draw over FoW", modname);

fow_setting = "enabled";

local IMAGES_COLOUR = {
    [1] = { r = 24, g = 24, b = 224, a = 1 },
    [2] = { r = 239, g = 0, b = 0, a = 1 },
    [3] = { r = 232, g = 7, b = 232, a = 1 },
    [4] = { r = 82, g = 255, b = 255, a = 1 },
    [5] = { r = 3, g = 232, b = 3, a = 1 },
    [6] = { r = 243, g = 243, b = 46, a = 1 },
    [7] = { r = 172, g = 38, b = 38, a = 1 },
    [8] = { r = 245, g = 164, b = 80, a = 1 },
    [9] = { r = 160, g = 160, b = 160, a = 1 },
    [10] = { r = 162, g = 125, b = 200, a = 1 },
    [11] = { r = 90, g = 114, b = 163, a = 1 },
    [12] = { r = 43, g = 106, b = 101, a = 1 },
    [13] = { r = 0, g = 0, b = 0, a = 1 },
    [14] = { r = 0, g = 0, b = 0, a = 1 },
    [15] = { r = 0, g = 0, b = 0, a = 1 },
    [16] = { r = 0, g = 0, b = 0, a = 1 },
    [17] = { r = 0, g = 0, b = 0, a = 1 },
    [18] = { r = 0, g = 0, b = 0, a = 1 },
    [19] = { r = 0, g = 0, b = 0, a = 1 },
    [20] = { r = 0, g = 0, b = 0, a = 1 },
    [21] = { r = 0, g = 0, b = 0, a = 1 },
    [22] = { r = 0, g = 0, b = 0, a = 1 },
}

local function colour(self, rgba, typ)
    local tab = IMAGES_COLOUR[self.wormhole_number];
    local res = typ == "r" and tab.r or typ == "g" and tab.g or typ == "b" and tab.b or typ == "a" and tab.a * 255; -- and>or
    return (res or 255) / 255 * (rgba or 1);
end

local Wormhole_Marks = Class(function(self, inst)
    self.inst = inst
    self.marked = false
    self.wormhole_number = nil
end)

function Wormhole_Marks:MarkEntrance()
    self:GetNumber()
    if self.wormhole_number <= 22 then
        self.marked = true
        if fow_setting == "enabled" then
            self.inst.MiniMapEntity:SetDrawOverFogOfWar(true)
        end
        self.inst.MiniMapEntity:SetIcon("mark_" .. self.wormhole_number .. ".tex")
        -- 本体变色...没啥用啊。
        --if self.wormhole_number <= 12 then
        --    local r, g, b, a = self.inst.AnimState:GetMultColour();
        --    self.inst.AnimState:SetMultColour(colour(self, r, "r"), colour(self, g, "g"), colour(self, b, "b"), colour(self, a, "a"));
        --end
    end
end

function Wormhole_Marks:MarkExit()
    self:GetNumber()
    if self.wormhole_number <= 22 then
        self.marked = true
        if fow_setting == "enabled" then
            self.inst.MiniMapEntity:SetDrawOverFogOfWar(true)
        end
        self.inst.MiniMapEntity:SetIcon("mark_" .. self.wormhole_number .. ".tex")
        TheWorld.components.wormhole_counter:Set()
        -- 本体变色...没啥用啊。
        --if self.wormhole_number <= 12 then
        --    local r, g, b, a = self.inst.AnimState:GetMultColour();
        --    self.inst.AnimState:SetMultColour(colour(self, r, "r"), colour(self, g, "g"), colour(self, b, "b"), colour(self, a, "a"));
        --end
    end
end

function Wormhole_Marks:GetNumber()
    self.wormhole_number = TheWorld.components.wormhole_counter:Get()
end

function Wormhole_Marks:CheckMark()
    return self.marked
end

function Wormhole_Marks:OnSave()
    local data = {}
    data.marked = self.marked
    data.wormhole_number = self.wormhole_number
    return data
end

function Wormhole_Marks:OnLoad(data)
    if data then
        self.marked = data.marked
        self.wormhole_number = data.wormhole_number
        if self.marked and self.wormhole_number then
            self.inst.entity:AddMiniMapEntity()
            self.inst.MiniMapEntity:SetIcon("mark_" .. self.wormhole_number .. ".tex")
            if fow_setting == "enabled" then
                self.inst.MiniMapEntity:SetDrawOverFogOfWar(true)
            end
        end
    else
        self.marked = false
        self.wormhole_number = 0
    end
end

return Wormhole_Marks