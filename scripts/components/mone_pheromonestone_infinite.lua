---
--- @author zsh in 2023/1/12 18:48
---

local function exception(self)
    -- 直接重写旺达警告表的 onattack 函数（2023-01-18-10:15）
    local inst = self.inst;
    --if inst and inst.prefab == "pocketwatch_weapon" and inst.components.weapon then
    --    inst.components.weapon:SetOnAttack(function(inst, attacker, target)
    --        if not inst.components.fueled:IsEmpty() then
    --            --inst.components.fueled:DoDelta(-TUNING.TINY_FUEL) -- 不减少
    --
    --            if attacker == nil or attacker.age_state == nil or attacker.age_state == "young" then
    --                inst.SoundEmitter:PlaySound("wanda2/characters/wanda/watch/weapon/shadow_attack")
    --            else
    --                -- fx will handle sounds
    --            end
    --        else
    --            inst.SoundEmitter:PlaySound("wanda2/characters/wanda/watch/weapon/attack")
    --        end
    --    end);
    --end
end

local function setNewName(self)
    local name = self.inst.name or STRINGS.NAMES[string.upper(self.inst.prefab)] or "MISSING NAME";
    if self.inst.components.named == nil then
        self.inst:AddComponent("named")
    end
    if not string.find(name,"^进阶·") then
        self.inst.components.named:SetName("进阶·" .. name);
    end
end

--local CommonFunction = {};
--
--function CommonFunction.fueledDoDelta()
--
--end

local function onmakeinfinite(self, makeinfinite)
    if makeinfinite then
        --print("111");
        self.inst:RemoveTag("mone_pheromonestone_infinite");
        self.inst:AddTag("hide_percentage")

        if self.inst.components.fueled then
            self.inst.components.fueled.StartConsuming = function(self,...)
                self:StopConsuming();
            end
            self.inst.components.fueled:StopConsuming();
            self.inst.components.fueled.rate = 0;
            self.inst.components.fueled:SetPercent(1);
            -- 处理一下调用 DoDelta 函数的装备
            local old_DoDelta = self.inst.components.fueled.DoDelta;
            function self.inst.components.fueled:DoDelta(amount, doer,...)
                amount = 0;
                if old_DoDelta then
                    return old_DoDelta(self, amount, doer,...);
                end
            end
        end
        if self.inst.components.finiteuses then
            self.inst.components.finiteuses:SetPercent(1)
            local old_Use = self.inst.components.finiteuses.Use
            self.inst.components.finiteuses.Use = function(self, num,...)
                num = 0;
                if old_Use then
                    return old_Use(self, num,...);
                end
            end
        end
        if self.inst.components.armor then
            self.inst.components.armor:SetPercent(1);
            self.inst.components.armor.indestructible = true;
        end
        if self.inst.components.perishable then
            self.inst.components.perishable.StartPerishing = function(self,...)
                self:StopPerishing();
            end
            self.inst.components.perishable:StopPerishing();
            self.inst.components.perishable:SetPercent(1);
        end

        setNewName(self);

        -- 诸如：旺达的警告表燃料不是 StartConsuming/StopConsuming 而是直接 DoDelta
        --exception(self);
    end
end

local Infinite = Class(function(self, inst)
    self.inst = inst;
    self.inst:AddTag("mone_pheromonestone_infinite");
    self.makeinfinite = nil;
end, nil, {
    makeinfinite = onmakeinfinite; -- 只要 self.makeinfinite 被更新一次，这个函数就会被调用，传入的参数有 self、键值
});

local function consumeMaterial(inst)
    if inst.components.stackable then
        inst.components.stackable:Get():Remove()
    else
        inst:Remove()
    end
end

function Infinite:MakeInfinite(invo)
    self.makeinfinite = true;
    TheFocalPoint.SoundEmitter:PlaySound("dontstarve/HUD/collect_resource");
    consumeMaterial(invo)
end

function Infinite:OnSave()
    --print("Infinite:OnSave():"..tostring(self.makeinfinite));
    return {
        makeinfinite = self.makeinfinite;
    }
end

function Infinite:OnLoad(data)
    --print("---Infinite:OnLoad(data)");
    if data and data.makeinfinite then
        --print("Infinite:OnLoad(data)---");
        self.makeinfinite = data.makeinfinite;
    end
end


return Infinite;