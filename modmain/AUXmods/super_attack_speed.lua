---
--- @author zsh in 2023/3/27 8:59
---

-- 单纯的超级攻速，直接修改的全体人物，并未实现类似 buff 的效果。
---- 2023-04-16：新备注，只修改 inst.components.combat:SetAttackPeriod 的值好像也可以，这样似乎就能实现 buff 效果了！
local SAVED_FNS = {};

local MIN_ATTACK_PERIOD = 0.2;

local PLAYER_NAME = "willow"; -- 以薇洛为例

env.AddPrefabPostInit(PLAYER_NAME, function(inst)
    if not TheWorld.ismastersim then
        return inst;
    end
    if inst.components.combat then
        local old_min_attack_period = TUNING.WILSON_ATTACK_PERIOD;
        inst.components.combat:SetAttackPeriod(MIN_ATTACK_PERIOD);
    end
end)

-- ThePlayer.components.combat:SetAttackPeriod(0.2)

env.AddStategraphPostInit("wilson", function(sg)
    -- 修改 attack 攻速
    local old_attack_onenter = sg.states.attack.onenter;
    if old_attack_onenter then
        sg.states.attack.onenter = function(inst)
            if old_attack_onenter then
                old_attack_onenter(inst);
            end
            if inst.prefab == PLAYER_NAME then
                inst.sg:SetTimeout(MIN_ATTACK_PERIOD + 0.5 * FRAMES);
            else
                -- DoNothing?
            end
        end

        table.insert(sg.states.attack.timeline, 1, TimeEvent(4 * FRAMES, function(inst)
            if inst.prefab == PLAYER_NAME then
                if not (inst.sg.statemem.isbeaver or
                        inst.sg.statemem.ismoose or
                        -- inst.sg.statemem.iswhip or
                        -- inst.sg.statemem.ispocketwatch or
                        inst.sg.statemem.isbook) and
                        inst.sg.statemem.projectiledelay == nil then
                    inst:PerformBufferedAction()
                    inst.sg:RemoveStateTag("abouttoattack")
                end
            elseif not inst.sg:HasStateTag("abouttoattack") then
                --inst.sg:AddStateTag("abouttoattack") -- ???
            else
                -- DoNothing
            end
        end))
    end

    -- 修改 slingshot_shoot 的攻速，这应该是弹弓
    local old_slingshot_shoot_onenter = sg.states.slingshot_shoot.onenter;
    if old_slingshot_shoot_onenter then
        sg.states.slingshot_shoot.onenter=function(inst)
            if old_slingshot_shoot_onenter then
                old_slingshot_shoot_onenter(inst);
            end
            if inst.prefab == PLAYER_NAME then
                inst.sg:SetTimeout(MIN_ATTACK_PERIOD + 0.5 * FRAMES);
            else
                -- DoNothing?
            end
        end

        table.insert(sg.states.slingshot_shoot.timeline, 1, TimeEvent(2 * FRAMES, function(inst)
            if inst.prefab == PLAYER_NAME then
                if inst.sg.statemem.chained then
                    local buffaction = inst:GetBufferedAction()
                    local target = buffaction ~= nil and buffaction.target or nil
                    if not (target ~= nil and target:IsValid() and inst.components.combat:CanTarget(target)) then
                        inst:ClearBufferedAction()
                        inst.sg:GoToState("idle")
                    end
                end
            else
                -- DoNothing
            end
        end))
        table.insert(sg.states.slingshot_shoot.timeline, 2, TimeEvent(3 * FRAMES, function(inst)
            if inst.prefab == PLAYER_NAME then
                if inst.sg.statemem.chained then
                    inst.SoundEmitter:PlaySound("dontstarve/characters/walter/slingshot/stretch")
                end
            else
                -- DoNothing
            end
        end))
        table.insert(sg.states.slingshot_shoot.timeline, 3, TimeEvent(4 * FRAMES, function(inst)
            if inst.prefab == PLAYER_NAME then
                if inst.sg.statemem.chained then
                    local buffaction = inst:GetBufferedAction()
                    local equip = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
                    if equip ~= nil and equip.components.weapon ~= nil and equip.components.weapon.projectile ~= nil then
                        local target = buffaction ~= nil and buffaction.target or nil
                        if target ~= nil and target:IsValid() and inst.components.combat:CanTarget(target) then
                            inst.sg.statemem.abouttoattack = false
                            inst:PerformBufferedAction()
                            inst.SoundEmitter:PlaySound("dontstarve/characters/walter/slingshot/shoot")
                        else
                            inst:ClearBufferedAction()
                            inst.sg:GoToState("idle")
                        end
                    else
                        -- out of ammo
                        inst:ClearBufferedAction()
                        inst.components.talker:Say(GetString(inst, "ANNOUNCE_SLINGHSOT_OUT_OF_AMMO"))
                        inst.SoundEmitter:PlaySound("dontstarve/characters/walter/slingshot/no_ammo")
                    end
                end
            else
                -- DoNothing
            end
        end))
    end
end)