---
--- @author zsh in 2023/2/9 9:53
---

local assets = {
    Asset("ANIM", "anim/wilsonstatue.zip"),
}

local fns = {};

local function canBackWound(afflicter)
    if afflicter:HasTag("player") then
        return false;
    end
    return true;
end

-- TODO: 计时器得到攻击速度、显示当前伤害、显示秒伤（秒伤的计算似乎需要10秒这样的一个时间限度）
-- 攻速：每秒普攻的次数

local TIMER = 10; -- 10秒后才稳定

local total_damage = 0;
local attack_number = 0;

local function showPlayerProperty(dummytarget, data, player)
    total_damage = total_damage + data.amount;
    attack_number = attack_number + 1;

    local msg = {};

    local timer = false;
    local dph = -data.amount;
    local dps = total_damage / TIMER;
    local speed = attack_number / TIMER;

    table.insert(msg, "伤害: " .. string.format("%.2f", dph));
    table.insert(msg, "秒伤: " .. string.format("%.2f", dps));
    table.insert(msg, "攻速: " .. string.format("%.2f", speed));

    dummytarget:DoTaskInTime(TIMER, function(inst)
        total_damage = 0;
        attack_number = 0;
    end)

    dummytarget.components.talker:Say(table.concat(msg, "\n"));
end

-- 不行。。客机没有血量变化的
function fns.OnHealthDeltaClient(inst, data)
    -- 判这么多空是因为我懒得开洞穴测试了，这样哪怕功能为实现也不会报错。
    if data and data.oldpercent and data.newpercent and data.newpercent < data.oldpercent then
        local delta_percent = data.oldpercent - data.newpercent;
        local amount;
        if inst.replica and inst.replica.health and inst.replica.health.classified then
            local maxhealth = inst.replica.health.classified.maxhealth and inst.replica.health.classified.maxhealth:value();
            if maxhealth and type(delta_percent) == "number" and type(maxhealth) == "number" then
                amount = delta_percent * maxhealth;
            end
        end
        if amount then
            inst.Label:SetText(string.format("%.2f", -amount));
            inst.Label:SetUIOffset(math.random() * 20 - 10, math.random() * 20 - 10, 0);
            --inst.AnimState:PlayAnimation("hit")
            --inst.AnimState:PushAnimation("idle")
        end
    end
end

function fns.OnHealthDeltaServer(inst, data)
    if data.amount and data.amount < 0 then
        inst.Label:SetText(string.format("%.2f", data.amount));
        inst.Label:SetUIOffset(math.random() * 20 - 10, math.random() * 20 - 10, 0)
        inst.AnimState:PlayAnimation("hit")
        inst.AnimState:PushAnimation("idle")

        if inst.components.talker then
            inst.components.talker:Say(string.format("%.2f", data.amount));
        end

        local afflicter = data and data.afflicter;
        if afflicter == nil then
            return ;
        end

        -- 显示玩家的属性 -- TODO: 未实现
        --if afflicter:HasTag("player") then
        --    showPlayerProperty(inst, data, afflicter);
        --end

        -- 血量减少的时候反伤，并推送引发仇恨的事件。
        if canBackWound(afflicter) then
            if afflicter.components.health then
                local DAMAGE = 34; -- 牛的默认伤害为34点

                -- 概率造成 100 点的伤害
                if math.random() < 0.1 then
                    DAMAGE = 100;
                end
                -- 概率造成目标最大生命值的伤害
                if math.random() < 0.01 then
                    DAMAGE = afflicter.components.health.maxhealth;
                end

                if afflicter.prefab == "frog" then
                    DAMAGE = afflicter.components.health.maxhealth;
                end

                afflicter.components.health:DoDelta(-DAMAGE);

                -- 仇恨
                afflicter:PushEvent("attacked", {
                    attacker = inst,
                    damage = DAMAGE,
                    damageresolved = DAMAGE,
                    weapon = nil,
                    noimpactsound = afflicter.components.combat.noimpactsound
                })

                if afflicter.components.combat.onhitfn then
                    afflicter.components.combat.onhitfn(afflicter, inst, DAMAGE);
                end

                -- 生成特效
                local fx = SpawnPrefab("mie_wanda_attack_pocketwatch_old_fx")
                if fx then
                    local x, y, z = afflicter.Transform:GetWorldPosition()
                    if x and y and z then
                        local radius = afflicter:GetPhysicsRadius(.5)
                        local angle = (inst.Transform:GetRotation() - 90) * DEGREES
                        fx.Transform:SetPosition(x + math.sin(angle) * radius, 0, z + math.cos(angle) * radius)
                    end
                end
            end
        end
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()
    inst.entity:AddLabel()

    inst.entity:AddMiniMapEntity()
    inst.MiniMapEntity:SetIcon("resurrect.png")

    -- 客机不显示数字。。。。。。
    inst.Label:SetFontSize(40)
    inst.Label:SetFont(DEFAULTFONT)
    inst.Label:SetWorldOffset(0, 3, 0)
    inst.Label:SetUIOffset(0, 0, 0)
    inst.Label:SetColour(0.7, 0, 0) -- 红色 0.7, 0, 0
    inst.Label:Enable(true)

    MakeObstaclePhysics(inst, .3)

    inst.AnimState:SetBank("wilsonstatue")
    inst.AnimState:SetBuild("wilsonstatue")
    inst.AnimState:PlayAnimation("idle")


    --inst:AddTag("monster")
    inst:AddTag("mone_dummytarget")

    MakeSnowCoveredPristine(inst)

    -- !!!
    inst:AddComponent("talker")
    inst.components.talker.fontsize = 40;
    inst.components.talker.font = DEFAULTFONT;
    inst.components.talker.colour = Vector3(0.7, 0, 0); -- 0.7, 0, 0  1 不行。。太艳了
    inst.components.talker.offset = Vector3(-50, -630, 0);
    inst.components.talker.symbol = "fossil_chest";

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        -- 额，客机没有血量变化的，不然简易血条就可以是客户端模组了。。。
        --inst:ListenForEvent("healthdelta", fns.OnHealthDeltaClient);
        return inst;
    end

    inst:AddComponent("bloomer")
    inst:AddComponent("colouradder")

    inst:AddComponent("inspectable")

    inst:AddComponent("combat")
    --[[    if not TUNING.MIE_TUNING.MOD_CONFIG_DATA.kill_dummytarget then
            -- 如果攻击者是玩家的话，锁血
            local old_GetAttacked = inst.components.combat.GetAttacked;
            function inst.components.combat:GetAttacked(attacker, damage, weapon, stimuli)
                if attacker and attacker:HasTag("player") then
                    local currenthealth = self.inst.components.health.currenthealth;
                    if damage > currenthealth then
                        damage = 0;
                    end
                end

                if old_GetAttacked then
                    old_GetAttacked(self, attacker, damage, weapon, stimuli);
                end
            end
        end]]
    -- 如果攻击者是玩家的话，锁血
    local old_GetAttacked = inst.components.combat.GetAttacked;
    function inst.components.combat:GetAttacked(attacker, damage, weapon, stimuli, ...)
        if attacker and attacker:HasTag("player") then
            local currenthealth = self.inst.components.health.currenthealth;
            local ishammer = weapon and weapon.prefab and weapon.prefab == "hammer";
            ishammer = weapon and weapon.HasTag and weapon:HasTag("hammer");
            if damage > currenthealth then
                if not ishammer then
                    damage = 0;
                end
            end
        end

        if old_GetAttacked then
            old_GetAttacked(self, attacker, damage, weapon, stimuli, ...);
        end
    end

    inst:AddComponent("debuffable")
    inst.components.debuffable:SetFollowSymbol("ww_head", 0, -250, 0)

    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(2000);
    inst.components.health:StartRegen(TUNING.BEEFALO_HEALTH_REGEN * 2, TUNING.BEEFALO_HEALTH_REGEN_PERIOD / 4); -- 牛10秒回一次
    inst:ListenForEvent("healthdelta", fns.OnHealthDeltaServer);

    inst.taunt_task = inst:DoPeriodicTask(2, function(inst)
        local x, y, z = inst.Transform:GetWorldPosition();
        if not (x and y and z) then
            return ;
        end
        local DIST = 16;
        local MUST_TAGS = { "_combat", "_health" };
        local CANT_TAGS = {
            "player", -- 玩家是可以用来测试伤害的
            "INLIMBO", "structure", "butterfly", "wall", "balloon", "groundspike", "smashable", "companion", "abigail", "shadowminion",
            "mone_dummytarget", "bird"
        };
        local function binding(guy)
            if guy and guy:HasTag("beefalo") then
                local follower = guy and guy.replica and guy.replica.follower;
                local leader = follower and follower:GetLeader();
                return leader and leader.prefab == "beef_bell";
            end
        end
        local ents = TheSim:FindEntities(x, y, z, DIST, MUST_TAGS, CANT_TAGS);
        for _, v in ipairs(ents) do
            if ShiHao.isValid(v) and binding(v) then
                break ;
            end
            if ShiHao.isValid(v) and v.components.combat then
                if v.components.combat.target then
                    -- 加个限定，不然生物会摇头！
                    if v.components.combat.target.prefab ~= inst.prefab then
                        v.components.combat:SetTarget(inst);
                        v:DoTaskInTime(math.random() * 0.25, function(inst)
                            SpawnPrefab("battlesong_instant_taunt_fx").Transform:SetPosition(inst.Transform:GetWorldPosition());
                        end)
                    end
                elseif v.components.combat.target == nil then
                    v.components.combat:SetTarget(inst);
                    v:DoTaskInTime(math.random() * 0.25, function(inst)
                        SpawnPrefab("battlesong_instant_taunt_fx").Transform:SetPosition(inst.Transform:GetWorldPosition());
                    end)
                end

                --[[                --print("","",tostring(v));
                                --print("",tostring(v.components.combat.target));
                                v.components.combat:SetTarget(inst);
                                -- 没声音有点难受！但 20% 都太吵了。
                                -- 2023-02-27-14:41：太吵啦，关掉！
                                --if math.random() < .1 then
                                --    inst.SoundEmitter:PlaySound("dontstarve_DLC001/characters/wathgrithr/quote/taunt");
                                --end
                                -- 生成特效
                                v:DoTaskInTime(math.random() * 0.25, function(inst)
                                    SpawnPrefab("battlesong_instant_taunt_fx").Transform:SetPosition(inst.Transform:GetWorldPosition());
                                end)]]
            end
        end
    end)

    inst:ListenForEvent("death", function(inst, data)
        -- 给予最后一击的生物真实伤害（无视护甲）：10%血量，由于已经死亡，故不必推送仇恨事件了。
        local cause = data and data.cause;
        local afflicter = data and data.afflicter;
        if afflicter and canBackWound(afflicter) then
            if afflicter.components.health then
                local maxhealth = afflicter.components.health.maxhealth;
                afflicter.components.health:DoDelta(-maxhealth * 0.1, nil, nil, nil, nil, true); -- 由于已经死亡故不必传递afflicter参数
            end
        end

        -- 生成特效，避免直接 Remove 的突兀感
        local fx = SpawnPrefab("collapse_big");
        local scale = 0.5; -- 0.25 太小
        fx.Transform:SetNoFaced()
        fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
        fx.Transform:SetScale(scale, scale, scale)
        inst:Remove();
    end);

    return inst
end

return Prefab("mone_dummytarget", fn, assets),
MakePlacer("mone_dummytarget_placer", "wilsonstatue", "wilsonstatue", "idle");
