---
--- @author zsh in 2023/3/29 10:05
---

local function SetNewName(inst)
    local name = inst.name or STRINGS.NAMES[string.upper(inst.prefab)] or "MISSING NAME";
    if inst.components.named == nil then
        inst:AddComponent("named");
    end
    if not string.find(name, "^逆转·") then
        inst.components.named:SetName("逆转·" .. name);
    end
end

local function onhas_eternity_task(self, new, old)
    if new then
        self.inst:RemoveTag("mone_pheromonestone_eternity");
        SetNewName(self.inst);
        -- 1/16 = 0.0625
        local MULTIPLE = 3;
        local RATE = 0.0625 / MULTIPLE;
        self.inst:DoPeriodicTask(30 / MULTIPLE, function(inst)
            local container = inst.components.container;
            if container then
                local items = container:GetAllItems();
                for _, v in ipairs(items) do
                    if v.components.perishable then
                        local percent = v.components.perishable:GetPercent() + RATE;
                        v.components.perishable:SetPercent(percent);
                    end
                end
            end
        end)
    end
end

local Eternity = Class(function(self, inst)
    self.inst = inst;

    self.inst:AddTag("mone_pheromonestone_eternity");

    self.has_eternity_task = nil;
end, nil, {
    has_eternity_task = onhas_eternity_task;
});

local function ConsumeMaterial(inst)
    if inst.components.stackable then
        inst.components.stackable:Get():Remove()
    else
        inst:Remove()
    end
end

local function GenericFX(inst)
    local scale = 0.5;
    local fx = SpawnPrefab("collapse_big");
    local x, y, z = inst.Transform:GetWorldPosition();
    fx.Transform:SetNoFaced();
    fx.Transform:SetPosition(x, y, z);
    fx.Transform:SetScale(scale, scale, scale);
end

function Eternity:Main(invobject)
    self.has_eternity_task = true;

    -- 为什么在此处执行不行？奇了怪了？离谱啊。
    --self.inst:RemoveTag("mone_pheromonestone_eternity");
    --SetNewName(self.inst);

    GenericFX(self.inst);
    ConsumeMaterial(invobject);
end

function Eternity:OnSave()
    return {
        has_eternity_task = self.has_eternity_task;
    }
end

function Eternity:OnLoad(data)
    if data then
        if data.has_eternity_task then
            self.has_eternity_task = data.has_eternity_task;
        end
    end
end

return Eternity;