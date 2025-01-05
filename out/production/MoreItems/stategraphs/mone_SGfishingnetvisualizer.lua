---
--- @author zsh in 2023/6/2 12:11
---

require("stategraphs/commonstates")

local events = {

}

local states = {
    State {
        name = "casting",
        onenter = function(inst)
            inst.AnimState:PlayAnimation("throw_pre", false)
            inst.AnimState:PushAnimation("throw_loop", true)

            -- uc:new
            inst.SoundEmitter:PlaySound("wolfgang1/dumbbell/throw_twirl", "spin_loop")
        end,

        events = {
            EventHandler("play_throw_pst", function(inst)
                inst.AnimState:PlayAnimation("throw_pst", false)
            end),
            EventHandler("begin_opening", function(inst)
                inst.sg:GoToState("opening")
            end),
        },

        onupdate = function(inst, dt)
            inst.components.fishingnetvisualizer:UpdateWhenMovingToTarget(dt)
        end,

    },

    State {
        name = "opening",

        onenter = function(inst)
            inst.components.fishingnetvisualizer:BeginOpening()

            -- uc:new
            inst.SoundEmitter:KillSound("spin_loop")
            inst.SoundEmitter:PlaySound("dontstarve/wilson/backpack_close")

            local my_x, my_y, my_z = inst.Transform:GetWorldPosition()
            local splash_fx = SpawnPrefab("fishingnetvisualizerfx")
            splash_fx.Transform:SetPosition(my_x, 0, my_z)
        end,

        --[[
        timeline =
        {
            TimeEvent(0 * FRAMES, function(inst)
                local splash_fx = SpawnPrefab("fishingnetvisualizerfx")
                splash_fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
            end),
        },
        ]]--

        events = {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("retrieving")
            end),
        },

        onupdate = function(inst, dt)
            inst.components.fishingnetvisualizer:UpdateWhenOpening(dt)
        end,
    },

    State {
        name = "retrieving",
        onenter = function(inst)
            if inst.components.fishingnetvisualizer and inst.components.fishingnetvisualizer.thrower then
                inst.components.fishingnetvisualizer:BeginRetrieving()
                inst:FacePoint(inst.components.fishingnetvisualizer.thrower.Transform:GetWorldPosition())
                inst.AnimState:PlayAnimation("pull_loop", true)
            end
        end,

        onupdate = function(inst, dt)
            inst.components.fishingnetvisualizer:UpdateWhenRetrieving(dt)
        end,

        events = {
            EventHandler("begin_final_pickup", function(inst)
                inst.sg:GoToState("final_pickup")
            end),
        },
    },

    State {
        name = "final_pickup",
        onenter = function(inst)
            inst.components.fishingnetvisualizer:BeginFinalPickup()

            --local NAME = string.upper(tostring(inst.item.prefab));
            --local displayname = STRINGS.NAMES[NAME] or "";

            -- uc:new
            if inst.item ~= nil and inst.item.components.finiteuses then
                local uses = inst.item.netweight ~= nil and inst.item.netweight or 1

                -- TEMP
                --print("fishingnet: "..tostring(uses))

                inst.item.components.finiteuses:Use(uses)
            end
        end,
    },
}

return StateGraph("mone_fishingnetvisualizer", states, events, "casting")
