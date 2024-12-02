---
--- @author zsh in 2023/2/5 20:15
---

local API = require("chang_mone.dsts.API");
local config_data = TUNING.MIE_TUNING.MOD_CONFIG_DATA;

STRINGS.CHARACTERS.GENERIC.ACTIONFAIL.MIE_BUNDLE_ACTION = {
    NOPT = "释放坐标点非法，无法释放！",
    CANNOT = "警告：非法目标，不允许打包！",
    BUSY = "目标很忙，请稍后再试！",
    SUCCESS = "打包成功！请注意保护好它，避免物品损失！"
}

local inf_meat_food_on = config_data.mie_bonestew or config_data.mie_perogies;
inf_meat_food_on = false; -- 不添加动作了。很麻烦的，因为直接增加三维的话，wanda也会增加。。。

local custom_actions = {
    ["MIE_BEEF_BELL_ACTION"] = {
        execute = false, -- FALSE!!!
        id = "MIE_BEEF_BELL_ACTION",
        str = "召唤/收回",
        fn = function(act)

        end,
        actiondata = {
            strfn = function(act)
                return act.target:HasTag("beef_bell_isCD_NO") and "CALL" or ""
            end
        },
        state = "dolongaction"
    },
    -- 任何一个 _inventoryitem 的预制物都可以对着这个书使用，使其内部物品全部掉落。
    ["MIE_BOOK_SILVICULTURE_ACTION"] = {
        execute = config_data.mie_book_silviculture,
        id = "MIE_BOOK_SILVICULTURE_ACTION",
        str = "打开/关闭", -- "全部掉落",
        fn = function(act)
            local target = act and act.target;
            --if target and target.components.container then
            --    target.components.container:DropEverything();
            --end
            local doer = act and act.doer;
            if target and doer and target.components.container then
                if not target.components.container:IsOpen() then
                    target.components.container:Open(doer);
                else
                    target.components.container:Close();
                end
            end
            return true;
        end,
        actiondata = {
            strfn = function(act)
                local target = act and act.target;
                return target:HasTag("mie_simplebooks_open") and "CLOSE" or "OPEN";
            end
        },
        state = "doshortaction" --"dolongaction"
    },
    ["MIE_BOOK_HORTICULTURE_ACTION"] = {
        execute = config_data.mie_book_horticulture,
        id = "MIE_BOOK_HORTICULTURE_ACTION",
        str = "打开/关闭", --"全部掉落",
        fn = function(act)
            local target = act and act.target;
            --if target and target.components.container then
            --    target.components.container:DropEverything();
            --end
            local doer = act and act.doer;
            if target and doer and target.components.container then
                if not target.components.container:IsOpen() then
                    target.components.container:Open(doer);
                else
                    target.components.container:Close();
                end
            end
            return true;
        end,
        actiondata = {
            strfn = function(act)
                local target = act and act.target;
                return target and target:HasTag("mie_simplebooks_open") and "CLOSE" or "OPEN";
            end
        },
        state = "doshortaction" --"dolongaction"
    },
    ["MIE_BUNDLE_ACTION"] = {
        execute = config_data.bundle,
        id = "MIE_BUNDLE_ACTION",
        str = "打包",
        fn = function(act)
            local target = act.target
            local invobject = act.invobject
            local doer = act.doer
            if target and invobject and doer then
                local targetpos = target:GetPosition();
                if not (targetpos.x and targetpos.y and targetpos.z) then
                    return false, "NOPT";
                end

                local mie_bundle_state2 = SpawnPrefab("mie_bundle_state2", invobject.linked_skinname, invobject.skin_id);

                if not mie_bundle_state2.components.mie_bundle:IsLegitimateTarget(target) then
                    mie_bundle_state2:Remove();
                    return false, "CANNOT";
                end

                if target.components.teleporter and target.components.teleporter:IsBusy() then
                    mie_bundle_state2:Remove()
                    return false, "BUSY";
                end

                -- 开始执行
                mie_bundle_state2.components.mie_bundle:Main(target, invobject, doer);
                mie_bundle_state2.Transform:SetPosition(targetpos:Get());

                return true, "SUCCESS"; --成功并不会说话
            end

        end,
        actiondata = {},
        state = "dolongaction"
    },
    ["MIE_INF_MEAT_FOODS_ACTION"] = {
        execute = inf_meat_food_on,
        id = "MIE_INF_MEAT_FOODS_ACTION",
        str = "吃",
        fn = function(act)
            local doer = act and act.doer;
            if doer then

            end
        end,
        actiondata = {},
        state = "eat" -- 呀，这个 eat or quickeat 就能限制了啊！！！
    }
}

local component_actions = {
    {
        actiontype = "INVENTORY",
        component = "mie_beef_bell_action", -- 似乎同样的一个组件绑定多个动作的话，被覆盖？还是优先级低于的话不显示？
        tests = {
            {
                execute = custom_actions["MIE_BEEF_BELL_ACTION"].execute,
                id = "MIE_BEEF_BELL_ACTION",
                testfn = function(inst, doer, actions, right)
                    return inst and inst:HasTag("mie_beef_bell") and right;
                end
            }
        }
    },
    {
        actiontype = "USEITEM",
        component = "mie_bundle_action",
        tests = {
            {
                execute = custom_actions["MIE_BUNDLE_ACTION"].execute,
                id = "MIE_BUNDLE_ACTION",
                testfn = function(inst, doer, target, actions, right)
                    return inst and inst:HasTag("mie_bundle_state1") and target and not target:HasTag("INLIMBO") and right;
                end
            }
        }
    },
    {
        actiontype = "USEITEM",
        component = "mie_book_silviculture_action", -- 拥有这个组件的物品，对着目标。。。
        tests = {
            {
                execute = custom_actions["MIE_BOOK_SILVICULTURE_ACTION"].execute,
                id = "MIE_BOOK_SILVICULTURE_ACTION",
                testfn = function(inst, doer, target, actions, right)
                    return inst and target and target:HasTag("mie_book_silviculture") and right;
                end
            }
        }
    },
    {
        actiontype = "USEITEM",
        component = "mie_book_horticulture_action", -- 拥有这个组件的物品，对着目标。。。
        tests = {
            {
                execute = custom_actions["MIE_BOOK_HORTICULTURE_ACTION"].execute,
                id = "MIE_BOOK_HORTICULTURE_ACTION",
                testfn = function(inst, doer, target, actions, right)
                    return inst and target and target:HasTag("mie_book_horticulture") and right;
                end
            }
        }
    },
    -- 废弃
    {
        actiontype = "INVENTORY",
        component = "mie_inf_meat_foods_action",
        tests = {
            {
                execute = custom_actions["MIE_INF_MEAT_FOODS_ACTION"].execute,
                id = "MIE_INF_MEAT_FOODS_ACTION",
                testfn = function(inst, doer, actions, right)
                    print("--1: " .. tostring(doer:HasTag("MEAT_eater")))
                    return inst and inst:HasTag("mie_inf_food_meat") and doer and doer:HasTag("player") and doer:HasTag("MEAT_eater") and right;
                end
            }
        }
    }
}

API.addCustomActions(env, custom_actions, component_actions);

-- 修改优先级
if ACTIONS.MIE_BUNDLE_ACTION and ACTIONS.STORE then
    ACTIONS.MIE_BUNDLE_ACTION.priority = ACTIONS.STORE.priority + 1;
end
if ACTIONS.MIE_BOOK_SILVICULTURE_ACTION and ACTIONS.STORE then
    ACTIONS.MIE_BOOK_SILVICULTURE_ACTION.priority = ACTIONS.STORE.priority + 1;
end
if ACTIONS.MIE_BOOK_HORTICULTURE_ACTION and ACTIONS.STORE then
    ACTIONS.MIE_BOOK_HORTICULTURE_ACTION.priority = ACTIONS.STORE.priority + 1;
end

-- 其他
--if ACTIONS.MIE_BOOK_HORTICULTURE_ACTION then
--    ACTIONS.MIE_BOOK_HORTICULTURE_ACTION.strfn = function(act)
--        local target = act and act.target;
--        print("TEST-1");
--        return target and target:HasTag("mie_simplebooks_open") and "CLOSE" or "OPEN";
--    end
--end

-- stings动作的定义要在动作加载之后
STRINGS.ACTIONS.MIE_BOOK_SILVICULTURE_ACTION = {
    EXCEPTION = "EXCEPTION",
    OPEN = "打开容器",
    CLOSE = "关闭容器"
}

STRINGS.ACTIONS.MIE_BOOK_HORTICULTURE_ACTION = {
    EXCEPTION = "EXCEPTION",
    OPEN = "打开容器",
    CLOSE = "关闭容器"
}
