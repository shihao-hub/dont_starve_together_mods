---
--- @author zsh in 2023/1/20 23:19
---


-- 随便改了改，保证一直处在满月的动画效果 (202301202325)

require("stategraphs/commonstates")

local actionhandlers = {
}

local events = {
    EventHandler("worked", function(inst)
        inst.sg:GoToState("hit")
    end),
    EventHandler("onbuilt", function(inst)
        inst.sg:GoToState("placed")
    end),
}

local function CalcPhaseAnimName(anim)
    --return anim.."_"..TheWorld.state.moonphase
    return anim .. "_" .. "full" -- chang
end

local function CalcTransitionAnimName()
    --if TheWorld.state.moonphase == "full" then
    --    return "wax_to_full"
    --elseif TheWorld.state.moonphase == "new" then
    --    return "wane_to_new"
    --end
    --
    --return (TheWorld.state.iswaxingmoon and "wax" or "wane").."_to_"..TheWorld.state.moonphase
    return "wax_to_full" -- chang
end

local states = {
    State {
        name = "idle",

        onenter = function(inst)
            inst.AnimState:PlayAnimation(CalcPhaseAnimName("idle"), true)

            --if TheWorld.state.moonphase == "full" then
            --    inst.SoundEmitter:PlaySound("dontstarve/common/together/moondial/full_LP", "loop")
            --else
            --    inst.SoundEmitter:KillSound("loop")
            --end
            -- 不应注释，但我觉得太吵了
            --inst.SoundEmitter:PlaySound("dontstarve/common/together/moondial/full_LP", "loop") -- chang
        end,

        onexit = function(inst)
            inst.SoundEmitter:KillSound("loop")
        end,
    },

    State {
        name = "next",

        onenter = function(inst)
            inst.AnimState:PlayAnimation(CalcTransitionAnimName())
        end,

        timeline = {
            TimeEvent(4 * FRAMES, function(inst)
                -- 不应注释，但我觉得太吵了
                --inst.SoundEmitter:PlaySound("dontstarve/common/together/moondial/fill")
            end),
        },

        events = {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },
    },

    State {
        name = "hit",

        onenter = function(inst)
            inst.AnimState:PlayAnimation(inst.is_glassed and "hit_glassed" or CalcPhaseAnimName("hit"))
        end,

        timeline = {
            TimeEvent(9 * FRAMES, function(inst)
                -- 不应注释，但我觉得太吵了
                --inst.SoundEmitter:PlaySound("dontstarve/common/together/moondial/water_movement")
            end),
        },

        events = {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState(inst.is_glassed and "glassed_idle" or "idle")
                end
            end),
        },
    },

    State {
        name = "placed",

        onenter = function(inst)
            inst.AnimState:PlayAnimation(CalcPhaseAnimName("place"))
        end,

        timeline = {
            TimeEvent(5 * FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve/common/together/moondial/craft")
            end),
            TimeEvent(7 * FRAMES, function(inst)
                --if TheWorld.state.moonphase ~= "new" then
                --    inst.SoundEmitter:PlaySound("dontstarve/common/together/moondial/water_movement")
                --end
                -- 不应注释，但我觉得太吵了
                --inst.SoundEmitter:PlaySound("dontstarve/common/together/moondial/water_movement") -- chang
            end),
        },

        events = {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState(inst.is_glassed and "glassed_pre" or "idle")
                end
            end),
        },
    },

    State {
        name = "glassed_pre",

        onenter = function(inst)
            if not TheWorld.state.isalterawake then
                --inst.sg.statemem.from_fullmoon = TheWorld.state.moonphase == "full"
                inst.sg.statemem.from_fullmoon = true -- chang
                inst.GoToState("glassed_pst")
            else
                inst.AnimState:PlayAnimation(CalcPhaseAnimName("glassed_from"))
            end
        end,

        timeline = {
            TimeEvent(5 * FRAMES, function(inst)
                if not inst.sg.statemem.from_fullmoon then
                    inst.SoundEmitter:PlaySound("dontstarve/common/together/moondial/fill")
                end
            end),
            TimeEvent(20 * FRAMES, function(inst)
                if not inst.sg.statemem.from_fullmoon then
                    -- 不应注释，但我觉得太吵了
                    --inst.SoundEmitter:PlaySound("dontstarve/common/together/moondial/water_movement")
                end
            end),

            TimeEvent(8 * FRAMES, function(inst)
                if inst.sg.statemem.from_fullmoon then
                    -- 不应注释，但我觉得太吵了
                    --inst.SoundEmitter:PlaySound("dontstarve/common/together/moondial/water_movement")
                end
            end),
        },

        events = {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("glassed_idle")
                end
            end),
        },
    },

    State {
        name = "glassed_idle",

        onenter = function(inst)
            if not TheWorld.state.isalterawake then
                inst.GoToState("glassed_pst")
            else
                inst.AnimState:PlayAnimation("glassed", true)
                -- 不应注释，但我觉得太吵了
                --inst.SoundEmitter:PlaySound("dontstarve/common/together/moondial/full_LP", "loop")
            end
        end,

        onexit = function(inst)
            inst.SoundEmitter:KillSound("loop")
        end,
    },

    State {
        name = "glassed_pst",

        onenter = function(inst)
            inst.AnimState:PlayAnimation("glassed_pst")
        end,

        timeline = {
            --TimeEvent(5*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve/common/together/moondial/craft") end),
            TimeEvent(10 * FRAMES, function(inst)
                inst.components.lootdropper:FlingItem(SpawnPrefab("moonglass"))
                inst.is_glassed = false
            end),
        },

        events = {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },
    }
}

return StateGraph("moondial", states, events, "idle", actionhandlers)

