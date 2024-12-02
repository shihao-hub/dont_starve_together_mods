---
--- @author zsh in 2023/1/8 20:31
---

--[[SCENE = --args: inst, doer, actions, right					--场景		(inst:指针指向实体, doer:行为人实体, right:左键行为)
USEITEM = --args: inst, doer, target, actions, right		--使用项目	(inst:指针手持实体, target:指针指向实体)
POINT = --args: inst, doer, pos, actions, right				--地面		(inst:指针手持实体(种植型), pos:指针坐标)
EQUIPPED = --args: inst, doer, target, actions, right		--装备
INVENTORY = --args: inst, doer, actions, right				--库存		(inst:指针指向实体)
ISVALID = --args: inst, action, right						--是有效的
--]]
--[[
要搭建一条传输线路，我们需要一个组件以及相应的组件动作搜集器，以及一个动作，以及动作对于的sg里的动作处理器。
组件动作，在官方制作者那里是分好了类的，不过分类并不是唯一的，同一个组件动作，可能会同时有多个类的属性。比如说Book这个组件，就是读书。
你可以在物品栏里按右键读，也可以左键拿起书，然后对着人物点左键读。虽然是同一个动作，但执行的场景不一样，前者是Inventory，也就是你的物品栏，
后者是Scene，也就是屏幕。不同的场景下，传输给组件动作搜集器的数据是不一样的。也就是说，组件动作搜集器有5种。
官方默认分为5个类，SCENE，USEITEM，POINT，EQUIPPED，INVENTORY。这里翻译一下klei论坛上的教程里，对这5个类的介绍。原作者是rezecib。
----------------
SCENE           --args: inst, doer, actions, right                                  --直接点击某个具有某个组件的物品
使用变量inst(拥有这个组件的东西），doer（做这个动作的玩家）,actions（你添加的动作会被添加到哪张动作表中去，这个参数一般会在函数参数表的尾端。
译者注：如果有right的话，在right前面)，right（是否是一个右键点击动作)。
--SCENE 动作是通过点击一个在物品栏或者世界上物品来完成的。
拥有这个组件动作的这个东西，让自己能够被点击从而执行动作，这一点与USEITEM和EQUIPPED相反，它们是让你能够点击在你的鼠标所指向的物品，
或者物品栏的物品来执行动作。一个例子是收集作物这个动作。
译者注：这里补充几句。edible这个组件，是物品可食用的组件。这个组件没有SCENE 这个组件动作搜集器，
只有USEITEM 和 INVENTORY。所以，你不能把食物放在地上，然后右键点击吃掉它（除了woodie的海狸形态，那个比较特殊，这里略过不谈）。
要吃掉食物，你只能左键拿起食物，然后对着人点击鼠标，或者把食物放到物品栏里，右键点击。
【【【【【【SCENE则就是，你能直接点击它然后完成对应动作。】】】】】】
-----------------
USEITEM         --args: inst, doer, target, actions, right                          --拿着具有某个组件的物品对着另一个物品
使用变量 inst,doer,target(被点击的东西），actions和right。USEITEM 动作是这样的，
你拿起这个物品（译者注：拥有这个组件动作的物品），
去对着世界上的某些其它的物品，就可以激活该动作，按下去就会执行这个动作，典型的例子就是拿起燃料往火坑里添火。
-----------------
POINT           --args: inst, doer, pos, actions, right                             --对着地面，或者物体
使用变量inst,doer,pos（被点击的位置)，actions和right。POINT动作可以被很多东西激活（装备一个手持物品（其它部位不行），或者将一个物品拿起来（附在鼠标上）），
【【【【但这是唯一一种对着地面而不是一个具体的物体作为变量的动作。】】】】
典型的例子有deployable组件--种植东西以及放置陷阱。另一个例子则是橙宝石法杖（闪现）。
-----------------
EQUIPPED        --args: inst, doer, target, actions, right                          --让某个特殊的物品装备时，具有对应的动作
使用变量inst,doer,target,actions,right。
【【【EQUIPPED动作是在你让某个特别的物品被装备时激活。】】】
例子：装备火把可以激活点火动作，装备铥矿斧可以砍树，装备武器可以攻击。
-----------------
INVENTORY       --args: inst, doer, actions, right                                  --点击物品栏执行的
使用变量inst,doer,actions,right。INVENTORY动作可以通过右键点击物品栏执行。例子有吃东西，装备物品，治疗等等。
--------------------
在联机版中，是通过一个名为componentactions.lua的文件来储存所有的动作搜集器，并通过AddComponentAction这个函数来添加新的动作搜集器。
]]
--[[
-----actions-----自定义动作
{
	id,--动作ID
	str,--动作显示名字
	fn,--动作执行函数
	actiondata,--其他动作数据，诸如strfn、mindistance等，可参考actions.lua
	state,--关联SGstate,可以是字符串或者函数
	canqueuer,--兼容排队论 allclick为默认，rightclick为右键动作
}
-----component_actions-----动作和组件绑定
{
	type,--动作类型
		*SCENE--点击物品栏物品或世界上的物品时执行,比如采集
		*USEITEM--拿起某物品放到另一个物品上点击后执行，比如添加燃料
		*POINT--装备某手持武器或鼠标拎起某一物品时对地面执行，比如植物人种田
		*EQUIPPED--装备某物品时激活，比如装备火把点火
		*INVENTORY--物品栏右键执行，比如吃东西

        *SCENE      testfn = function(inst,doer,actions,right)
		*USEITEM    testfn = function(inst, doer, target, actions, right)
		*POINT
		*EQUIPPED   testfn = function(inst, doer, target, actions, right)
		*INVENTORY  testfn = function(inst,doer,actions,right)
	component,--绑定的组件
	tests,--尝试显示动作，可写多个绑定在同一个组件上的动作及尝试函数
}
-----old_actions-----修改老动作
{
	switch,--开关，用于确定是否需要修改
	id,--动作ID
	actiondata,--需要修改的动作数据，诸如strfn、fn等，可不写
	state,--关联SGstate,可以是字符串或者函数
}
--]]

local API = require("chang_mone.dsts.API");
local locale = LOC.GetLocaleCode();
local L = (locale == "zh" or locale == "zht" or locale == "zhr") and true or false;
local old_actions_fn = require("definitions.mone.old_actions_fn");

local function consumMaterials(invobject)
    if invobject then
        if invobject.components.stackable then
            invobject.components.stackable:Get():Remove()
        else
            invobject:Remove() --显然此处是主机代码
        end
        --TheFocalPoint.SoundEmitter:PlaySound("dontstarve/common/nightmareAddFuel")
        TheFocalPoint.SoundEmitter:PlaySound("dontstarve/HUD/collect_resource")
    end
end

local function containValue(tab, value)
    if tab and type(tab) == "table" then
        for k, _ in pairs(tab) do
            if k == value then
                return true;
            end
        end
    end
end

local custom_actions = {
    ["MONE_REPAIR_OBJECT"] = {
        execute = true,
        id = "MONE_REPAIR_OBJECT",
        str = "修复",
        fn = function(act)
            if act.target and act.target.mone_repair_materials and act.invobject and act.doer
                    and act.target:HasTag("mone_can_be_repaired") then
                local amount;
                for pf, num in pairs(act.target.mone_repair_materials) do
                    if pf == act.invobject.prefab then
                        amount = num;
                        break ;
                    end
                end
                --print(tostring(amount));
                if not (amount == nil) then
                    local function repair(target, amount, invobject, doer)
                        if target.components.fueled then
                            local percent = target.components.fueled:GetPercent() + amount
                            local max_precent = percent <= 1 and percent or 1
                            target.components.fueled:SetPercent(max_precent)
                        elseif target.components.finiteuses then
                            local percent = target.components.finiteuses:GetPercent() + amount
                            local max_precent = percent <= 1 and percent or 1
                            target.components.finiteuses:SetPercent(max_precent)
                        elseif target.components.armor then
                            --armor组件中SetCondition()最大值就是最大值
                            local percent = target.components.armor:GetPercent() + amount
                            local max_precent = percent <= 1 and percent or 1
                            target.components.armor:SetPercent(max_precent)
                        elseif target.components.perishable then
                            --需要吗？
                            local percent = target.components.perishable:GetPercent() + amount
                            local max_precent = percent <= 1 and percent or 1
                            target.components.perishable:SetPercent(max_precent)
                        else
                            return ;
                        end
                        consumMaterials(invobject);
                    end
                    if act.target.components.fueled then
                        repair(act.target, amount, act.invobject, act.doer)
                    elseif act.target.components.finiteuses then
                        repair(act.target, amount, act.invobject, act.doer)
                    elseif act.target.components.armor then
                        repair(act.target, amount, act.invobject, act.doer)
                    elseif act.target.components.perishable then
                        repair(act.target, amount, act.invobject, act.doer)
                    end
                end
                return true;
            end
        end,
        state = "dolongaction"
    },
    ["MONE_PHEROMONESTONE_INFINITE"] = {
        execute = true,
        id = "MONE_PHEROMONESTONE_INFINITE",
        str = "进阶",
        fn = function(act)
            local function exclude(target)
                local items = {};
                if not TUNING.MONE_TUNING.GET_MOD_CONFIG_DATA.greenamulet_pheromonestone then
                    table.insert(items, "greenamulet");
                end
                --table.insert(items, "mie_bushhat"); -- 排除升级版·灌木丛帽
                for _, v in ipairs(items) do
                    if target and target.prefab == v then
                        return true;
                    end
                end
            end

            if act.doer and act.invobject and act.target then
                if act.target:HasTag("mone_pheromonestone_infinite") then
                    -- 开启 Insight 之后，现在可以使用素石了。因为修复了。
                    --if not TUNING.MONE_TUNING.GET_MOD_CONFIG_DATA.insight_and_pheromonestone_permit then
                    --    if rawget(env.GLOBAL, "Insight") then
                    --        if act.doer.components.talker then
                    --            act.doer.components.talker:Say("由于您开启了Insight模组，为了避免游戏崩溃，素石它失效了。")
                    --        end
                    --        return true; -- 不要 return false; return; 不然人物会说我做不到...
                    --    end
                    --end
                    if exclude(act.target) then
                        if act.doer.components.talker then
                            act.doer.components.talker:Say("不合理目标，无法使用！")
                        end
                        return true;
                    end
                    -- 正常执行
                    act.target.components.mone_pheromonestone_infinite:MakeInfinite(act.invobject);
                    return true;
                end
            end
            --return true; -- 只有 return ture 人物才不会说我做不到！
        end,
        state = "dolongaction"
    },
    ["MONE_PHEROMONESTONE_ETERNITY"] = {
        execute = true,
        id = "MONE_PHEROMONESTONE_ETERNITY",
        str = "逆转",
        fn = function(act)
            if act.doer and act.invobject and act.target then
                if act.target:HasTag("mone_pheromonestone_eternity") then
                    act.target.components.mone_pheromonestone_eternity:Main(act.invobject);
                    return true;
                end
            end
        end,
        state = "dolongaction"
    },
    ["MONE_BATHAT"] = {
        execute = true,
        id = "MONE_BATHAT",
        str = "起飞",
        fn = function(act)
            --主客机通用代码
            local function isFlying(player)
                return player and player:HasTag("mone_bathat_fly");
            end

            if act.doer and act.target and act.target:HasTag("player") and act.target.components.mone_bathat_fly then
                if isFlying(act.doer) then
                    act.doer.components.mone_bathat_fly:Land(act.doer)
                elseif not isFlying(act.doer) then
                    act.doer.components.mone_bathat_fly:Fly(act.doer)

                    -- debuff
                    if act.doer.components.sanity then
                        act.doer.components.sanity:DoDelta(-act.doer.components.sanity.current / 3);
                    end
                end
                return true
            end
            return false
        end,
        state = "doshortaction"
    },
    ["MONE_WATERCHEST_HAMMER"] = {
        execute = true,
        id = "MONE_WATERCHEST_HAMMER",
        str = "徒手拆卸",
        fn = function(act)
            local target, doer = act.target, act.doer;
            if target and doer and target.onhammered then
                target.onhammered(target, doer);
                return true;
            end
        end,
        state = "domediumaction"
    },
    ["MONE_POISONBLAM_ROTTEN"] = {
        execute = true,
        id = "MONE_POISONBLAM_ROTTEN",
        str = "腐朽",
        fn = function(act)
            if act.target and act.target.components.perishable then
                local cper = act.target.components.perishable:GetPercent();
                act.target.components.perishable:ReducePercent(cper);
                -- 消耗
                if act.invobject then
                    if act.invobject.components.stackable then
                        act.invobject.components.stackable:Get():Remove();
                    else
                        act.invobject:Remove();
                    end
                    --TheFocalPoint.SoundEmitter:PlaySound("dontstarve/HUD/collect_resource")
                end
                return true;
            end
        end,
        state = "dolongaction"
    },
    ["MONE_FEED_GLOMMER"] = {
        execute = true,
        id = "MONE_FEED_GLOMMER",
        str = "喂食",
        fn = function(act)
            if act.doer
                    and act.invobject and act.invobject.prefab == "mone_glommer_poop_food"
                    and act.target and act.target.prefab == "glommer" then
                --if act.target.sg then
                --    act.target.sg:GoToState("bored")
                --end

                if act.target.components.periodicspawner then
                    act.target.components.periodicspawner:TrySpawn();
                end

                local item = act.invobject;
                if item.components.stackable then
                    item.components.stackable:Get():Remove();
                else
                    item:Remove();
                end
                return true;
            end
        end,
        state = "give",
        actiondata = {
            priority = 10;
        }
    },
}

-- testfn： 满足条件后加入动作队列。
local component_actions = {
    {
        actiontype = "SCENE",
        component = "mone_waterchest_structure", --? 耕地机有这个组件(workable)吗？肯定没有的啊。
        tests = {
            {
                execute = custom_actions["MONE_WATERCHEST_HAMMER"].execute,
                id = "MONE_WATERCHEST_HAMMER",
                testfn = function(inst, doer, actions, right)
                    return inst and inst:HasTag("mone_waterchest_structure") and right;
                end
            }
        }
    },
    {
        actiontype = "USEITEM",
        component = "inventoryitem",
        tests = {
            {
                execute = custom_actions["MONE_REPAIR_OBJECT"].execute,
                id = "MONE_REPAIR_OBJECT",
                testfn = function(inst, doer, target, actions, right)
                    -- 打个补丁吧，懒得修改了。
                    -- target.mone_repair_materials == nil 代表客机没有添加或者是压根不能修复！
                    if target and target:HasTag("mone_can_be_repaired_modify_nightstick")
                            and target.mone_repair_materials == nil then
                        target.mone_repair_materials = { transistor = 0.5 };
                    end

                    return inst and target and containValue(target.mone_repair_materials, inst.prefab) and target:HasTag("mone_can_be_repaired") and right;
                end
            }
        }
    },
    {
        actiontype = "USEITEM",
        component = "mone_pheromonestone",
        tests = {
            {
                execute = custom_actions["MONE_PHEROMONESTONE_INFINITE"].execute,
                id = "MONE_PHEROMONESTONE_INFINITE",
                testfn = function(inst, doer, target, actions, right)
                    local function IsValidTarget(targ)
                        if table.contains({
                            "autotrap_book", "xinhua_dictionary", "closed_book", "immortal_book", "unsolved_book",
                            "medal_naughtybell", "medal_spacetime_crystalball", "monster_book",
                        }, targ.prefab) then
                            return true;
                        end

                        if string.find(targ.prefab, "wx78module_") then
                            return true;
                        end

                        return targ:HasTag("_equippable")
                                or targ:HasTag("book")
                                or targ:HasTag("guitar")
                                or targ:HasTag("pheromonestone_target");
                    end

                    return inst and inst.prefab == "mone_pheromonestone" and
                            target and target:HasTag("mone_pheromonestone_infinite")
                            and IsValidTarget(target) and right;
                end
            }
        }
    },
    {
        actiontype = "USEITEM",
        component = "mone_pheromonestone2",
        tests = {
            {
                execute = custom_actions["MONE_PHEROMONESTONE_ETERNITY"].execute,
                id = "MONE_PHEROMONESTONE_ETERNITY",
                testfn = function(inst, doer, target, actions, right)
                    return inst and inst.prefab == "mone_pheromonestone2" and target and target:HasTag("mone_pheromonestone_eternity") and right;
                end
            }
        }
    },
    {
        actiontype = "USEITEM",
        component = "mone_poisonblam",
        tests = {
            {
                execute = custom_actions["MONE_POISONBLAM_ROTTEN"].execute,
                id = "MONE_POISONBLAM_ROTTEN",
                testfn = function(inst, doer, target, actions, right)
                    return target and target:HasTag("mone_poisonblam_perishable_target") and right;
                end
            }
        }
    },
    {
        actiontype = "SCENE",
        component = "mone_bathat_fly",
        tests = {
            {
                execute = custom_actions["MONE_BATHAT"].execute,
                id = "MONE_BATHAT",
                testfn = function(inst, doer, actions, right)
                    return inst and doer and inst == doer and inst:HasTag("mone_bathat_fly_isEquiped") and right;
                end
            }
        }
    },
    {
        actiontype = "USEITEM",
        component = "inventoryitem",
        tests = {
            {
                execute = custom_actions["MONE_FEED_GLOMMER"].execute,
                id = "MONE_FEED_GLOMMER",
                testfn = function(inst, doer, target, actions, right)
                    return doer:HasTag("player") and inst.prefab == "mone_glommer_poop_food" and target.prefab == "glommer";
                end
            }
        }
    }
}

local old_actions = {
    {
        execute = true, id = "PICK", -- 采集
        actiondata = {
            --fn = function(act)
            --    print("ZSH_TEST_PICK");
            --    return old_actions_fn["PICK"](act);
            --end
        },
        state = {
            testfn = function(doer, action)
                if doer:HasTag("mone_fast_picker") or doer:HasTag("mone_orangestaff_fast_picker") then
                    return true;
                end
            end,
            deststate = function(doer, action)
                return "attack" --原：doshortaction
            end
        }
    },
    {
        execute = true, id = "HARVEST", -- 收获
        actiondata = {
            --fn = function(act)
            --    if act.doer and act.doer:HasTag("mone_bathat_fly") then
            --        print("HARVEST--" .. tostring(act.doer:HasTag("mone_bathat_fly")));
            --        return false, "MONE_FAIL_01";
            --    else
            --        return old_actions_fn(act);
            --    end
            --end
        },
        state = {
            testfn = function(doer, action)
                if doer:HasTag("mone_fast_picker") or doer:HasTag("mone_orangestaff_fast_picker") then
                    return true
                end
            end,
            deststate = function(doer, action)
                return "attack"
            end
        }
    },
    {
        execute = true, id = "TAKEITEM", -- 拿东西
        actiondata = {
            --fn = function(act)
            --    if act.doer and act.doer:HasTag("mone_bathat_fly") then
            --        print("TAKEITEM--" .. tostring(act.doer:HasTag("mone_bathat_fly")));
            --        return false, "MONE_FAIL_01";
            --    else
            --        return old_actions_fn(act);
            --    end
            --end
        },
        state = {
            testfn = function(doer, action)
                if doer:HasTag("mone_fast_picker") or doer:HasTag("mone_orangestaff_fast_picker") then
                    return true
                end
            end,
            deststate = function(doer, action)
                return "attack"
            end
        }
    },
}

--do
--    -- TEST
--    local actions = {
--        "PICK", "HARVEST", "TAKEITEM",
--        "CHOP", "PICKUP", "MINE", "DIG", "HAMMER",
--        "SLEEPIN","MOUNT"
--    }
--    for _, v in ipairs(actions) do
--        ACTIONS[v].mone_id = v;
--    end
--end

--[[ FLY 限制飞行时的行为 ]]
if TUNING.MONE_TUNING.GET_MOD_CONFIG_DATA.bathat and false then
    local FLY_CANT_ACTIONS_ID = { "PICK", "HARVEST", "TAKEITEM" }

    table.insert(FLY_CANT_ACTIONS_ID, "PICKUP"); -- 捡起
    table.insert(old_actions, { execute = true, id = "PICKUP" });
    table.insert(FLY_CANT_ACTIONS_ID, "MOUNT"); -- 骑牛
    table.insert(old_actions, { execute = true, id = "MOUNT" });
    table.insert(FLY_CANT_ACTIONS_ID, "MIGRATE");
    table.insert(old_actions, { execute = true, id = "MIGRATE" });
    table.insert(FLY_CANT_ACTIONS_ID, "HAUNT");
    table.insert(old_actions, { execute = true, id = "HAUNT" });
    table.insert(FLY_CANT_ACTIONS_ID, "JUMPIN");
    table.insert(old_actions, { execute = true, id = "JUMPIN" });

    -- 保存老动作的 fn
    for _, act in ipairs(old_actions) do
        old_actions_fn[act.id] = ACTIONS[act.id].fn;
    end

    for _, id in ipairs(FLY_CANT_ACTIONS_ID) do
        if ACTIONS[id] then
            if STRINGS.CHARACTERS.GENERIC.ACTIONFAIL[id] == nil then
                STRINGS.CHARACTERS.GENERIC.ACTIONFAIL[id] = {};
            end
            STRINGS.CHARACTERS.GENERIC.ACTIONFAIL[id].MONE_FAIL = L and "飞行中，请降落！" or "In flight, please land!";
        end
    end

    local function seqContainsValue(list, val)
        for _, v in ipairs(list) do
            if v == val then
                return true;
            end
        end
    end
    -- 限制飞行动作
    for _, data in ipairs(old_actions) do
        if seqContainsValue(FLY_CANT_ACTIONS_ID, data.id) then
            local old_fn = data.actiondata and data.actiondata.fn;
            data.actiondata = {
                fn = function(act)
                    if act.doer and act.doer:HasTag("mone_bathat_fly") then
                        return false, "MONE_FAIL";
                    else
                        return (old_fn and old_fn(act)) or old_actions_fn[data.id](act);
                    end
                end
            }
        end
    end
end

API.addCustomActions(env, custom_actions, component_actions);
API.modifyOldActions(env, old_actions);


-- 设置修复动作(我的动作)的优先级高于存放动作
if ACTIONS["STORE"] and ACTIONS["MONE_REPAIR_OBJECT"] then
    ACTIONS["MONE_REPAIR_OBJECT"].priority = ACTIONS["STORE"].priority + 1;
end

-- 腐化动作优先级高于存放动作
if ACTIONS["STORE"] and ACTIONS["MONE_POISONBLAM_ROTTEN"] then
    ACTIONS["MONE_POISONBLAM_ROTTEN"].priority = ACTIONS["STORE"].priority + 1;
end

-- 进阶动作优先级高于存放动作
if ACTIONS["STORE"] and ACTIONS["MONE_PHEROMONESTONE_INFINITE"] then
    ACTIONS["MONE_PHEROMONESTONE_INFINITE"].priority = ACTIONS["STORE"].priority + 1;
end

-- 逆转动作优先级高于存放动作
if ACTIONS["STORE"] and ACTIONS["MONE_PHEROMONESTONE_ETERNITY"] then
    ACTIONS["MONE_PHEROMONESTONE_ETERNITY"].priority = ACTIONS["STORE"].priority + 1;
end


-- 修一个我也不知道为什么会报错的bug？
--[[
    [00:32:38]: MOD_COMPONENT_ACTIONS is

    [00:32:38]: [string "scripts/componentactions.lua"]:2512: attempt to index a nil value
    LUA ERROR stack traceback:
        scripts/componentactions.lua:2512 in (method) HasActionComponent (Lua) <2501-2523>
        scripts/actions.lua:813 in () ? (Lua) <812-821>
        =(tail call):-1 in ()  (tail) <-1--1>
        scripts/bufferedaction.lua:63 in (method) GetActionString (Lua) <50-64>
        scripts/widgets/hoverer.lua:63 in (method) OnUpdate (Lua) <30-146>
        scripts/frontend.lua:836 in (method) Update (Lua) <657-854>
        scripts/update.lua:92 in () ? (Lua) <33-135>

    2023-02-20-15:36 确定了一点，以下函数已经调用了
    local function ModComponentWarning(self, modname)
        print("ERROR: Mod component actions are out of sync for mod "..(modname or "unknown")..". This is likely a result of your mod's calls to AddComponentAction not happening on both the server and the client.")
        print("self.modactioncomponents is\n"..(dumptable(self.modactioncomponents) or ""))
        print("MOD_COMPONENT_ACTIONS is\n"..(dumptable(MOD_COMPONENT_ACTIONS) or ""))
    end

    所以我如果 return {} 是不是并没有什么大的影响？因为以下函数中已经判空了！
    function EntityScript:HasActionComponent(name)
        local id = ACTION_COMPONENT_IDS[name]
        if id ~= nil then
            for i, v in ipairs(self.actioncomponents) do
                if v == id then
                    return true
                end
            end
        end
        if self.modactioncomponents ~= nil then
            for modname, cmplist in pairs(self.modactioncomponents) do
                id = CheckModComponentIds(self, modname)[name]
                if id ~= nil then -- NOTE: 此处判空了！所以应该没问题吧？
                    for i, v in ipairs(cmplist) do
                        if v == id then
                            return true
                        end
                    end
                end
            end
        end
        return false
    end

]]

--[[ 兼容黑化动作行为学 ]]
do
    local ActionQueuer = ({ pcall(function()
        return require("components/actionqueuer");
    end) })[2];
    if isTab(ActionQueuer) then
        local QueuerActions = {
            ["MONE_FEED_GLOMMER"] = "allclick";
        }
        if AddActionQueuerAction and next(QueuerActions) then
            for k, v in pairs(QueuerActions) do
                AddActionQueuerAction(v, k, true)
            end
        end
    end
end

if true --[[ 保证默认开启 ]] then
    local function GetLocalFn(fn, fn_name)
        local level = 1;
        local MAX_LEVEL = 20;
        for i = 1, math.huge do
            local name, value = debug.getupvalue(fn, level);
            if name and name == fn_name then
                if value and type(value) == "function" then
                    return value, level;
                end
                break ;
            end
            level = level + 1;
            if level > MAX_LEVEL then
                break ;
            end
        end
    end

    -- 必须在调用 GetLocalFn 找到后，再调用该函数！
    local function SetLocalFn(fn, up, value)
        debug.setupvalue(fn, up, value);
    end

    -- 已知神话书说、太真等模组会触发。后面发现我的 海上背包 居然也会触发。
    if EntityScript then
        local old_HasActionComponent = EntityScript.HasActionComponent;
        local CheckModComponentIds, up = GetLocalFn(old_HasActionComponent, "CheckModComponentIds");
        --print("", "", tostring(CheckModComponentIds), tostring(up));
        if CheckModComponentIds and up then
            SetLocalFn(old_HasActionComponent, up, function(self, modname, ...)
                -- self 应该是绑定的预制物
                --do
                --    -- TEST
                --    print("SetLocalFn: " .. tostring(self) .. " " .. tostring(modname));
                --    print("CheckModComponentIds(self, modname): " .. tostring(CheckModComponentIds(self, modname)));
                --    print();
                --end

                local message = "self: " .. tostring(self) .. ", self.prefab: " .. tostring(self.prefab);

                --print("test: " .. message);

                -- 2023-04-22：这样解决也不是个事，未来试试彻底解决吧！
                ---- 鼠标快速移动上去触发？
                local result = CheckModComponentIds(self, modname, ...);
                if result == nil then
                    print("ChangNote: This is a ChangNote about an inexplicable bug.");
                    print("Message: " .. message);
                end
                return result or {};
            end)
        end
    end

    -- 处理一个类似的问题，反正只能不让客户端报错，具体为什么不知道怎么解决。已知：花样风滚草+能力勋章
    --if EntityScript then
    --    local old_RegisterComponentActions = EntityScript.RegisterComponentActions;
    --    function EntityScript:RegisterComponentActions(name, ...)
    --        if (self.modactioncomponents == nil) or (self.actionreplica and self.actionreplica.modactioncomponents == nil) then
    --            return ;
    --        end
    --        if old_RegisterComponentActions then
    --            old_RegisterComponentActions(self, name, ...);
    --        end
    --    end
    --end
end

--local function GetLocalFn(fn, fn_name)
--    local level = 1;
--    local MAX_LEVEL = 20;
--    for i = 1, math.huge do
--        local name, value = debug.getupvalue(fn, level);
--        if name and name == fn_name then
--            if value and type(value) == "function" then
--                return value, level;
--            end
--            break ;
--        end
--        level = level + 1;
--        if level > MAX_LEVEL then
--            break ;
--        end
--    end
--end
--
--local function SetLocalFn(fn, up, value)
--    debug.setupvalue(fn, up, value);
--end
--
--if EntityScript then
--    local old_HasActionComponent = EntityScript.HasActionComponent;
--    local CheckModComponentIds, up = GetLocalFn(old_HasActionComponent, "CheckModComponentIds");
--    if CheckModComponentIds and up then
--        SetLocalFn(old_HasActionComponent, up, function(self, modname)
--            local result = CheckModComponentIds(self, modname);
--            return result or {};
--        end)
--    end
--end
