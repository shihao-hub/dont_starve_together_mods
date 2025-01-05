---
--- @author zsh in 2023/4/30 13:54
---

local LuckWaterBuff = {
    duration = 0;
    lucktime = 480;
    doomtime = 0;
    currenteffect = 0;
}

function Remap(i, a, b, x, y)
    return (((i - a) / (b - a)) * (y - x)) + x
end

local function OnTick(inst, self)
    self.duration = self.duration + 1;
    if self.duration < self.lucktime then
        self.currenteffect = 100;
    elseif self.duration < self.lucktime + self.doomtime then
        self.currenteffect = Remap(self.duration - self.lucktime, 0, self.doomtime, -100, 0);
    else
        self:StopTick();
    end
end

print(Remap(480 - 240, 0, 480, -100, 0));

local name = "1进阶·"
print(string.find(name,"^进阶·"))