---
--- @author zsh in 2023/1/18 10:40
---

local foods = {};

local config_data = TUNING.MONE_TUNING.GET_MOD_CONFIG_DATA;

foods["mone_beef_wellington"] = {
    CanMake = config_data.mone_beef_wellington,
    name = "mone_beef_wellington",
    assets = {
        Asset("ANIM", "anim/mone_beef_wellington.zip"),
        Asset("IMAGE", "images/foodimages/mone_beef_wellington.tex"),
        Asset("ATLAS", "images/foodimages/mone_beef_wellington.xml")
    },
    tags = { "mone_beef_wellington", "non_preparedfood" },
    animdata = { bank = "mone_beef_wellington", build = "mone_beef_wellington", animation = "idle" },
    cs_fn = function(inst)

    end,
    client_fn = function(inst)

    end,
    server_fn = function(inst)
        inst.components.inventoryitem.imagename = "mone_beef_wellington";
        inst.components.inventoryitem.atlasname = "images/foodimages/mone_beef_wellington.xml";

        inst.components.edible.hungervalue = 150;
        inst.components.edible.sanityvalue = 150;
        inst.components.edible.healthvalue = 150;
        inst.components.edible.foodtype = FOODTYPE.MEAT;
        inst.components.edible:SetOnEatenFn(function(inst, eater)
            if eater.components.debuffable and eater.components.debuffable:IsEnabled() and
                    not (eater.components.health and eater.components.health:IsDead()) and
                    not eater:HasTag("playerghost") and
                    eater.components.combat then
                eater.mone_buff_bw_attack = { totaltime = TUNING.SEG_TIME * 8 } -- TEMP
                eater.components.debuffable:AddDebuff("mone_buff_bw_attack", "mone_buff_bw_attack");
            end
        end)
        inst.components.stackable.maxsize = TUNING.STACK_SIZE_MEDITEM;
    end
}

foods["mone_chicken_soup"] = {
    CanMake = config_data.mone_chicken_soup,
    name = "mone_chicken_soup",
    assets = {
        Asset("ANIM", "anim/mone_chicken_soup.zip"),
        Asset("IMAGE", "images/foodimages/mone_chicken_soup.tex"),
        Asset("ATLAS", "images/foodimages/mone_chicken_soup.xml")
    },
    tags = { "mone_chicken_soup", "non_preparedfood" },
    animdata = { bank = "mone_chicken_soup", build = "mone_chicken_soup", animation = "idle" },
    cs_fn = function(inst)

    end,
    client_fn = function(inst)

    end,
    server_fn = function(inst)
        inst.components.inventoryitem.imagename = "mone_chicken_soup";
        inst.components.inventoryitem.atlasname = "images/foodimages/mone_chicken_soup.xml";

        inst.components.edible.hungervalue = 3;
        inst.components.edible.sanityvalue = 3;
        inst.components.edible.healthvalue = 3;
        inst.components.edible.foodtype = FOODTYPE.GOODIES;
        inst.components.edible:SetOnEatenFn(function(inst, eater)
            if math.random() < 0.1 then
                if eater.components.talker then
                    eater.components.talker:Say("啊，美味的馊鸡汤！")
                end
                if eater:HasTag("player") and eater.components.hunger and eater.components.sanity and eater.components.health then
                    eater.components.hunger:SetPercent(1);
                    eater.components.sanity:SetPercent(1);
                    eater.components.health:SetPercent(1);
                end
            else
                if eater.components.talker then
                    eater.components.talker:Say("只有一股馊味...")
                end
            end
        end)
        inst.components.stackable.maxsize = TUNING.STACK_SIZE_TINYITEM;
    end
}

foods["mone_lifeinjector_vb"] = {
    CanMake = config_data.mone_lifeinjector_vb,
    name = "mone_lifeinjector_vb",
    assets = {
        Asset("ANIM", "anim/mone_lifeinjector_vb.zip"),
        Asset("IMAGE", "images/foodimages/mone_lifeinjector_vb.tex"),
        Asset("ATLAS", "images/foodimages/mone_lifeinjector_vb.xml")
    },
    tags = { "mone_lifeinjector_vb", "non_preparedfood" },
    animdata = { bank = "mone_lifeinjector_vb", build = "mone_lifeinjector_vb", animation = "idle" },
    cs_fn = function(inst)

    end,
    client_fn = function(inst)

    end,
    server_fn = function(inst)
        inst.components.inventoryitem.imagename = "mone_lifeinjector_vb";
        inst.components.inventoryitem.atlasname = "images/foodimages/mone_lifeinjector_vb.xml";

        inst.components.edible.hungervalue = 0;
        inst.components.edible.healthvalue = 0;
        inst.components.edible.sanityvalue = 0;
        inst.components.edible.foodtype = FOODTYPE.GOODIES;
        inst.components.edible:SetOnEatenFn(function(inst, eater)
            if eater and eater.components.mone_lifeinjector_vb then
                if eater.mone_vb_non_ban then
                    eater.components.mone_lifeinjector_vb:HPIncrease();
                elseif eater.components.talker then
                    eater.components.talker:Say("我吃了没有任何效果...");
                end
            end
        end)
        inst.components.stackable.maxsize = TUNING.STACK_SIZE_TINYITEM;

        -- 添加新鲜度组件
        --inst:AddComponent("perishable");
        --inst.components.perishable:SetPerishTime(TUNING.PERISH_SUPERSLOW / 8);
        --inst.components.perishable:StartPerishing();
        --inst.components.perishable.onperishreplacement = "lifeinjector";

    end
}

foods["mone_honey_ham_stick"] = {
    CanMake = config_data.mone_honey_ham_stick,
    name = "mone_honey_ham_stick",
    assets = {
        Asset("ANIM", "anim/bs_food_58.zip"),
        Asset("IMAGE", "images/foodimages/bs_food_58.tex"),
        Asset("ATLAS", "images/foodimages/bs_food_58.xml")
    },
    tags = { "mone_honey_ham_stick", "non_preparedfood" },
    animdata = { bank = "bs_food_58", build = "bs_food_58", animation = "idle" },
    cs_fn = function(inst)

    end,
    client_fn = function(inst)

    end,
    server_fn = function(inst)
        inst.components.inventoryitem.imagename = "bs_food_58";
        inst.components.inventoryitem.atlasname = "images/foodimages/bs_food_58.xml";

        inst.components.edible.hungervalue = 50;
        inst.components.edible.sanityvalue = 50;
        inst.components.edible.healthvalue = -15;
        inst.components.edible.foodtype = FOODTYPE.MEAT;
        inst.components.edible:SetOnEatenFn(function(inst, eater)
            if eater.components.debuffable and eater.components.debuffable:IsEnabled() and
                    not (eater.components.health and eater.components.health:IsDead()) and
                    not eater:HasTag("playerghost") then
                eater.mone_buff_hhs_work = { totaltime = TUNING.SEG_TIME * 8 * 2 / 2 } -- TEMP
                eater.components.debuffable:AddDebuff("mone_buff_hhs_work", "mone_buff_hhs_work");
            end
        end)

        inst.components.stackable.maxsize = TUNING.STACK_SIZE_MEDITEM;

        --inst:AddComponent("perishable");
        --inst.components.perishable:SetPerishTime(TUNING.PERISH_SUPERSLOW / 8 * 3 * 2);
        --inst.components.perishable:StartPerishing();
        --inst.components.perishable.onperishreplacement = "spoiled_food";
    end
}

foods["mone_stomach_warming_hamburger"] = {
    CanMake = config_data.mone_stomach_warming_hamburger,
    name = "mone_stomach_warming_hamburger",
    assets = {
        Asset("ANIM", "anim/bs_food_33.zip"),
        Asset("IMAGE", "images/foodimages/bs_food_33.tex"),
        Asset("ATLAS", "images/foodimages/bs_food_33.xml")
    },
    tags = { "mone_stomach_warming_hamburger", "non_preparedfood" },
    animdata = { bank = "bs_food_33", build = "bs_food_33", animation = "idle" },
    cs_fn = function(inst)

    end,
    client_fn = function(inst)

    end,
    server_fn = function(inst)
        inst.components.inventoryitem.imagename = "bs_food_33";
        inst.components.inventoryitem.atlasname = "images/foodimages/bs_food_33.xml";

        inst.components.edible.hungervalue = 0;
        inst.components.edible.sanityvalue = 0;
        inst.components.edible.healthvalue = 0;
        inst.components.edible.foodtype = FOODTYPE.GOODIES;
        inst.components.edible:SetOnEatenFn(function(inst, eater)
            if eater and eater.components.mone_stomach_warming_hamburger then
                if eater.mone_swh_non_ban then
                    eater.components.mone_stomach_warming_hamburger:VitIncrease();
                elseif eater.components.talker then
                    eater.components.talker:Say("我吃了没有任何效果...");
                end
            end
        end)
        inst.components.stackable.maxsize = TUNING.STACK_SIZE_TINYITEM;
    end
}

foods["mone_guacamole"] = {
    CanMake = config_data.mone_guacamole,
    name = "mone_guacamole",
    assets = {
        Asset("ANIM", "anim/cook_pot_food.zip"),
        Asset("INV_IMAGE", "guacamole"),
    },
    tags = { "mone_guacamole", "non_preparedfood" },
    animdata = { bank = "cook_pot_food", build = "cook_pot_food", animation = "idle" },
    cs_fn = function(inst)
        inst.AnimState:OverrideSymbol("swap_food", "cook_pot_food", "guacamole")
    end,
    client_fn = function(inst)

    end,
    server_fn = function(inst)
        inst.components.inventoryitem.imagename = "guacamole";
        inst.components.inventoryitem.atlasname = "images/inventoryimages.xml";

        inst.components.edible.hungervalue = 37.5;
        inst.components.edible.sanityvalue = 0;
        inst.components.edible.healthvalue = 20;
        inst.components.edible.foodtype = FOODTYPE.MEAT;
        inst.components.edible:SetOnEatenFn(function(inst, eater)
            -- 靠！熊大吃了崩溃了
            if not eater:HasTag("player") then
                return ;
            end

            if eater.components.timer == nil then
                eater:AddComponent("timer");
            end
            local TIME = 240; -- 未来拓展：防沙尘暴？
            if eater.components.talker then
                eater.components.talker:Say("我获得了：" .. tostring(TIME) .. " 秒的夜视能力！");
            end
            if not eater.components.timer:TimerExists("mone_guacamole_timer") then
                eater.components.timer:StartTimer("mone_guacamole_timer", TIME);
                eater.mone_guacamole_nightvision:set(true);
            else
                -- 不可叠加！
                eater.components.timer:StopTimer("mone_guacamole_timer");
                eater.components.timer:StartTimer("mone_guacamole_timer", TIME);
                eater.mone_guacamole_nightvision:set(false);
                eater.mone_guacamole_nightvision:set(true);
                --print("--3");
                -- 2023-02-17-21:39：能力勋章的复眼勋章导致此处set但是监听并没有执行？？
                -- 因为值要变化才行！
            end
        end)

        inst.components.stackable.maxsize = TUNING.STACK_SIZE_LARGEITEM;

        --inst:AddComponent("perishable");
        --inst.components.perishable:SetPerishTime(TUNING.PERISH_FAST); -- 6 天
        --inst.components.perishable:StartPerishing();
        --inst.components.perishable.onperishreplacement = "spoiled_food";
    end
}

return foods;

