---
--- @author zsh in 2023/5/18 18:38
---

local config_data = TUNING.MONE_TUNING.GET_MOD_CONFIG_DATA;
if config_data.mone_boomerang_damage_multiple ~= false then
    local damage_multiple = config_data.mone_boomerang_damage_multiple;
    env.AddPrefabPostInit("mone_boomerang", function(inst)
        if not TheWorld.ismastersim then
            return inst;
        end
        if inst.components.weapon then
            inst.components.weapon:SetDamage(inst.components.weapon.damage * damage_multiple);
        end
    end)
end


-- 升级版·回旋镖拥有真实伤害、秒杀致命亮茄
HookComponent("combat", function(self)
    local old_GetAttacked = self.GetAttacked;
    function self:GetAttacked(attacker, damage, weapon, ...)
        if weapon and weapon.prefab == "mone_boomerang" then
            local res = {};
            local health = self.inst.components.health;
            local old_DoDelta;
            local flag;

            if health and health.DoDelta then
                flag = true;
                old_DoDelta = health.DoDelta;
                health.DoDelta = function(self, amount, overtime, cause, ignore_invincible, afflicter, ignore_absorb, ...)
                    ignore_absorb = true;
                    return old_DoDelta(self, amount, overtime, cause, ignore_invincible, afflicter, ignore_absorb, ...);
                end
            end

            local old_damage = damage;
            if self.inst.prefab == "lunarthrall_plant" then
                damage = 999999999;
            end

            res = { old_GetAttacked(self, attacker, damage, weapon, ...) };

            damage = old_damage;

            if flag then
                health.DoDelta = old_DoDelta;
            end

            return unpack(res, 1, table.maxn(res));
        else
            return old_GetAttacked(self, attacker, damage, weapon, ...);
        end
    end
end)