---
--- @author zsh in 2023/4/30 14:23
---

local function getLuckComponent(inst)
    return inst and inst.components and inst.components.mone_luck;
end

local function getLuckWaterBuffComponent(inst)
    return inst and inst.components and inst.components.mone_luckwater_buff;
end

local function getPlayerLuck()

end