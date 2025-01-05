---
--- @author zsh in 2023/3/19 23:08
---


local Mods = Class(function(self, inst)
    self.inst = inst;
    self.ms_playerspawn = {};
end);

function Mods:SetData(inst)
    if inst and inst.userid then
        self.ms_playerspawn[inst.userid] = true;
    end
end

function Mods:GetData()
    return self.ms_playerspawn;
end

function Mods:OnSave()
    return {
        ms_playerspawn = self.ms_playerspawn;
    }
end

function Mods:OnLoad(data)
    if data then
        if data.ms_playerspawn then
            self.ms_playerspawn = data.ms_playerspawn;
        end
    end
end

return Mods;

