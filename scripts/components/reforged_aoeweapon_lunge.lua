---
--- @author zsh in 2023/5/23 3:21
---

-- 呃，这里应该需要继承一下基类 AOEWeapon_Base，不然少东西
local AOEWeapon_Lunge = Class(function(self, inst)
    self.inst = inst
    self.width = 3
    self.damage = nil
    self.stimuli = nil
    self.onlunge = nil
end)

function AOEWeapon_Lunge:SetWidth(width)
    self.width = width
end

function AOEWeapon_Lunge:SetStimuli(stimuli)
    self.stimuli = stimuli
end

function AOEWeapon_Lunge:SetOnLungeFn(fn)
    self.onlunge = fn
end

function AOEWeapon_Lunge:DoLunge(lunger, starting_pos, target_pos)
    local mob_index = {}
    local targets = {}
    local total_steps = 10
    local scale = lunger and lunger.components.scaler and lunger.components.scaler.scale or 1
    local dist_per_step = 0.6 * scale
    local total_distance = math.sqrt(distsq(starting_pos, target_pos))--10-- * scale
    local offset_vector = (target_pos - starting_pos):GetNormalized()
    local count = 1

    --TEST
    local test_multi = 2;


    -- old_value
    test_multi = 1;

    while (count * dist_per_step <= total_distance * test_multi) do
        local offset = offset_vector * count * dist_per_step
        local current_pos = starting_pos + offset
        local lunge_fx = ShiHao.ReForged.COMMON_FNS.CreateFX("spear_gungnir_lungefx", nil, lunger)
        lunge_fx.Transform:SetPosition(current_pos:Get())
        local radius = self.width / 2 * scale;
        radius = 4; -- 5，一次打出了 8、9 次伤害...呃。这个搜索目标的函数需要重写一下，不太理想...
        ShiHao.ReForged.COMMON_FNS.EQUIPMENT.GetAOETargets(lunger, current_pos, radius, nil, {
            "INLIMBO", "NOCLICK", "FX", "DECOR",
            "hiding",
            "player", "playerghost", "wall", "companion", "abigail", "shadowminion",
            "notarget","noattack","flight","invisible",
            "glommer",
        } or ShiHao.ReForged.COMMON_FNS.GetPlayerExcludeTags(lunger), targets);
        --ShiHao.ReForged.COMMON_FNS.EQUIPMENT.GetAOETargets(lunger, current_pos, radius, nil, ShiHao.ReForged.COMMON_FNS.GetPlayerExcludeTags(lunger), targets, mob_index, true)
        count = count + 1
    end

    --if self.inst.components.weapon and self.inst.components.weapon:HasAltAttack() then
    --    self.inst.components.weapon:DoAltAttack(lunger, targets, nil, self.stimuli)
    --end
    self.inst.components.weapon:ReForgedDoAttack(lunger, targets, nil, self.stimuli)

    if self.onlunge ~= nil then
        self.onlunge(self.inst, lunger, starting_pos, target_pos)
    end
    return true
end

return AOEWeapon_Lunge
