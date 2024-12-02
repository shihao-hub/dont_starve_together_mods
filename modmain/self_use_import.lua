---
--- @author zsh in 2023/3/1 12:56
---

local data = {};

local dyn_assets = {};

data["new_granary"] = {
    CanMake = env.GetModConfigData("new_granary"),
    fn = function()
        table.insert(env.PrefabFiles, "mie/self_use/new_granary"); -- 谷仓
        table.insert(dyn_assets, "myth_granary");
    end
}

data["mie_well"] = {
    CanMake = env.GetModConfigData("mie_well"),
    fn = function()
        table.insert(env.PrefabFiles, "mie/self_use/well"); -- 水井
        table.insert(dyn_assets, "myth_well");
    end
}

data["mie_cash_tree_ground"] = {
    CanMake = env.GetModConfigData("mie_cash_tree_ground"),
    fn = function()
        table.insert(env.PrefabFiles, "mie/self_use/cash_tree"); -- 摇钱树
    end
}

data["mie_yjp"] = {
    CanMake = env.GetModConfigData("mie_yjp"),
    fn = function()
        table.insert(env.PrefabFiles, "mie/self_use/yjp"); -- 羊脂玉净瓶

        -- 添加新动作
        local MIE_YJP_GIVE = Action({ mount_valid = true, priority = 2 })
        MIE_YJP_GIVE.id = "MIE_YJP_GIVE"
        MIE_YJP_GIVE.str = STRINGS.ACTIONS.USEITEM
        MIE_YJP_GIVE.fn = function(act)
            if act.invobject and act.target and act.invobject.components.finiteuses and act.invobject.components.finiteuses.current >= 20 then
                if act.target:HasTag("farm_plant_killjoy") and act.target._base_name ~= nil then
                    act.invobject.components.finiteuses:Use(20)
                    local x, y, z = act.target.Transform:GetWorldPosition()
                    local flower = SpawnPrefab(act.target._base_name .. "_oversized")
                    if flower then
                        act.target:Remove()
                        flower.Transform:SetPosition(x, y, z)
                    end
                    return true
                elseif act.target.components.growable ~= nil then
                    local stage = act.target.components.growable.stage
                    if act.target.components.growable.stages and act.target.components.growable.stages[stage] ~= nil and
                            act.target.components.growable.stages[stage].name == "rotten" and stage > 1 then
                        act.target.components.growable.stage = stage - 1
                        act.target.components.growable:StopGrowing()
                        local pd = act.target:GetPersistData()
                        local new = SpawnPrefab(act.target.prefab) -- 崩了别怪我
                        if new then
                            new:SetPersistData(pd, {})
                            new.Transform:SetPosition(act.target.Transform:GetWorldPosition())
                            act.target:Remove()
                            act.invobject.components.finiteuses:Use(5) -- old_value: 20
                            return true
                        end
                    end
                end
            end
        end
        env.AddAction(MIE_YJP_GIVE)

        env.AddComponentAction("USEITEM", "mie_yjp", function(inst, doer, target, actions)
            if target:HasTag("pickable_harvest_str") then
                table.insert(actions, ACTIONS.MIE_YJP_GIVE)
            end
        end)

        env.AddStategraphActionHandler("wilson", ActionHandler(MIE_YJP_GIVE, "dolongaction"))
        env.AddStategraphActionHandler("wilson_client", ActionHandler(MIE_YJP_GIVE, "dolongaction"))

        -- !!! 添加新状态节点！
        env.AddStategraphState("wilson", State {
            name = "mie_useyjp",
            tags = { "busy", 'doing', 'nodangle', 'pausepredict' },

            onenter = function(inst)
                inst.components.locomotor:Stop()
                inst.AnimState:PlayAnimation("wendy_channel_pst")
                if inst.bufferedaction ~= nil then
                    inst.sg.statemem.action = inst.bufferedaction
                end
            end,

            timeline = {
                TimeEvent(.2, function(inst)
                    inst:PerformBufferedAction()
                end),
            },
            events = {
                EventHandler("animover", function(inst)
                    if inst.AnimState:AnimDone() then
                        inst.sg:GoToState("idle")
                    end
                end),
            },

            onexit = function(inst)
                if inst.bufferedaction == inst.sg.statemem.action then
                    inst:ClearBufferedAction()
                end
            end,
        })

        env.AddStategraphState("wilson_client", State {
            name = "mie_useyjp",
            tags = { "busy", 'doing' },

            onenter = function(inst)
                inst.components.locomotor:Stop()
                inst.AnimState:PlayAnimation("wendy_channel_pst")

                local buffaction = inst:GetBufferedAction()
                if buffaction ~= nil then
                    inst:PerformPreviewBufferedAction()
                end
                inst.sg:SetTimeout(2)
            end,

            onupdate = function(inst)
                if inst:HasTag("doing") then
                    if inst.entity:FlattenMovementPrediction() then
                        inst.sg:GoToState("idle", "noanim")
                    end
                elseif inst.bufferedaction == nil then
                    inst.sg:GoToState("idle")
                end
            end,

            ontimeout = function(inst)
                inst:ClearBufferedAction()
                inst.sg:GoToState("idle")
            end,
        })
    end
}

data["mie_bananafan_big"] = {
    CanMake = env.GetModConfigData("mie_bananafan_big"),
    fn = function()
        table.insert(env.PrefabFiles, "mie/self_use/bananafan_big"); -- 芭蕉宝扇

        -- 修改旧的状态节点
        env.AddStategraphPostInit("wilson", function(sg)
            local use_fan = sg.states["use_fan"]
            if use_fan then
                local oldonenter = use_fan.onenter
                use_fan.onenter = function(inst, fan)
                    if fan and fan.prefab == "mie_bananafan_big" then
                        inst.components.locomotor:Stop()
                        --inst.sg.statemem.item = invobject -- chang: ??????，为什么 invobject，这是 nil 啊
                        inst.sg.statemem.item = fan
                        inst.sg:AddStateTag("busy")
                        inst.AnimState:PlayAnimation("action_uniqueitem_pre")
                        inst.AnimState:PushAnimation("fan", false)
                        -- 话说这里的动画，怎么找到
                        inst.AnimState:OverrideSymbol("fan01", "bananafan_big", "fan01")
                        inst.AnimState:Show("ARM_normal")
                        inst.components.inventory:ReturnActiveActionItem(fan)
                    else
                        oldonenter(inst);
                    end
                end
            end
        end)
    end
}

data["mie_myth_fuchen"] = {
    CanMake = env.GetModConfigData("mie_myth_fuchen"),
    fn = function()
        do
            return; -- 先弃用
        end

        table.insert(env.PrefabFiles, "mie/self_use/myth_fuchen"); -- 拂尘

        -- 添加新动作
        local MIE_MYTH_FUCHEN = Action({ mount_valid = true, distance = 12 })
        MIE_MYTH_FUCHEN.id = "MIE_MYTH_FUCHEN"
        MIE_MYTH_FUCHEN.strfn = function(act)
            return act.target ~= nil
                    and act.target:HasTag("_inventoryitem")
                    and "QUWU"
                    or "MOREN"
        end

        MIE_MYTH_FUCHEN.fn = function(act)
            if act.invobject and act.invobject.components.mie_fuchen_spell and act.target then
                act.invobject.components.mie_fuchen_spell:CastSpell(act.doer, act.target)
                return true
            end
        end
        AddAction(MIE_MYTH_FUCHEN)

        AddComponentAction("EQUIPPED", "mie_fuchen_spell", function(inst, doer, target, actions, right)
            if right and inst:HasTag("mie_can_spell_fuchen") and target and target ~= doer
                    and (target:HasTag("_combat") or target:HasTag("_jianzhufanzhuan") or target:HasTag("_inventoryitem")) then
                table.insert(actions, ACTIONS.MIE_MYTH_FUCHEN)
            end
        end)

        AddStategraphActionHandler("wilson", ActionHandler(MIE_MYTH_FUCHEN, function(inst)
            return "dojostleaction"
        end))
        AddStategraphActionHandler("wilson_client", ActionHandler(MIE_MYTH_FUCHEN, function(inst)
            return "dojostleaction"
        end))

        STRINGS.ACTIONS.MIE_MYTH_FUCHEN = {
            QUWU = "隔空取物",
            MOREN = "施法",
        }
    end
}

for k, v in pairs(data) do
    if v.CanMake ~= false then
        v.fn();
    end
end

-- 为什么要转dyn呢？ 因为官方的也是dyn 看着好玩 = 。=
for _, v in ipairs(dyn_assets) do
    table.insert(env.Assets, Asset("DYNAMIC_ANIM", "anim/dynamic/" .. v .. ".zip"))
    table.insert(env.Assets, Asset("PKGREF", "anim/dynamic/" .. v .. ".dyn"))
end
