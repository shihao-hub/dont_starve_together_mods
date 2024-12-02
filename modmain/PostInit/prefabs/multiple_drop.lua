---
--- Created by zsh
--- DateTime: 2023/9/11 16:17
---

local config_data = TUNING.MONE_TUNING.GET_MOD_CONFIG_DATA
local mdp = config_data.multiple_drop_probability
if mdp == 0 then
    return
end

local isValid = isValid;
local TUNING = TUNING;

local TEST = true;



local old_xpcall = xpcall;
local function xpcall(f, msgh, arg1, ...)
    if TEST then
        return old_xpcall(f, msgh, arg1, ...);
    else
        f();
        return true;
    end
end
local function msgh(msg)
    print(msg);
    if TheWorld and TheNet then TheNet:Announce("error(more items): " .. msg); end
end


--[[local function isEffectiveTarget(lootdropper)
    local self = lootdropper;
    local inst = self.inst;

    if isValid(inst) then
        if inst.prefab == "dragonfly" then
            xpcall(function()
                -- Test
                for i = 1, 10 do
                    local info = debug.getinfo(i + 4, "Sl");
                    if info == nil then break ; end
                    if info then
                        --local shortSrc = info.short_src;
                        --print("shortSrc:", shortSrc);
                        local source = info.source;
                        print("source:", source);
                    end
                end
            end, msgh)
        end
    end

    return false;
end

HookComponent("lootdropper", function(self)
    local oldGenerateLoot = self.GenerateLoot;
    function self:GenerateLoot(...)
        local loots = oldGenerateLoot(self, ...);

        if isEffectiveTarget(self) then
            local newLoots = deepcopy(loots);
            for _, v in ipairs(loots) do table.insert(newLoots, v); end
            loots = newLoots;
        end

        return loots;
    end
end)]]

local function tabContainNull(t, ...)
    assert(type(t) == "table");
    local args = { ... };
    local n = select("#", ...);
    for i = 1, n do
        if args[i] ~= nil and t[args[i]] == nil then
            return true;
        end
    end
    return false;
end

local function isExpectantTarget(inst)
    return not tabContainNull(inst.components, "health", "combat", "lootdropper")
            and not inst:HasTag("player")
            and inst:HasTag("epic");
end

local function inBuff(inst, data)
    local afflicter = data and data.afflicter;
    return afflicter and afflicter:HasTag("player") and afflicter:HasTag("mone_honey_ham_stick_buffer");
end

local function onDeath(inst, data)
    if isValid(inst) and inBuff(inst, data) then
        if math.random() < mdp then
            local afflicter = data.afflicter;
            if afflicter then afflicter.components.talker:Say("触发双倍掉落效果！"); end
            inst.components.lootdropper:DropLoot(inst:GetPosition());
        end
    end
end

-- This Is Meaningless! Please Don't Do Such As
local function UVSafe01(inst)
    if not TheWorld.ismastersim then return inst; end
    if isExpectantTarget(inst) then
        -- PAY ATTENTION
        inst:ListenForEvent("death", onDeath);
    end
end
env.AddPrefabPostInitAny(function(inst)
    xpcall(function()
        UVSafe01(inst);
    end, msgh)
end)
