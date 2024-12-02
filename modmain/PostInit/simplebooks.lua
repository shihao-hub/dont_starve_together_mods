---
--- @author zsh in 2023/2/13 16:01
---

local config_data = TUNING.MIE_TUNING.MOD_CONFIG_DATA;

local playerEvent = config_data.mie_book_silviculture or config_data.mie_book_horticulture;
if playerEvent then
    env.AddPlayerPostInit(function(inst)
        -- 2023-05-21：主客机都添加这个事件？把此处注释掉是否可以解决那个bug呢
        if not TheWorld.ismastersim then
            return inst;
        end
        local cnt = 0;
        inst:ListenForEvent("locomote", function(doer)
            --cnt = cnt + 1;
            --print(tostring(cnt) .. ": locomote");
            --print("doer.mie_book_silviculture_task: " .. tostring(doer.mie_book_silviculture_task));
            --print("doer.mie_book_silviculture_task2: " .. tostring(doer.mie_book_silviculture_task2));
            --print();
            if doer.mie_book_silviculture_task then
                doer.mie_book_silviculture_task:Cancel();
                doer.mie_book_silviculture_task = nil;
            end
            if doer.mie_book_silviculture_task2 then
                doer.mie_book_silviculture_task2:Cancel();
                doer.mie_book_silviculture_task2 = nil;
            end

            if doer.mie_book_horticulture_task then
                doer.mie_book_horticulture_task:Cancel();
                doer.mie_book_horticulture_task = nil;
            end
        end)
    end)
end

if config_data.mie_book_silviculture then
    env.AddPrefabPostInitAny(function(inst)
        if not TheWorld.ismastersim then
            return inst;
        end
        if inst:HasTag("_inventoryitem") then
            if inst.components.mie_book_silviculture_action == nil then
                inst:AddComponent("mie_book_silviculture_action");
            end
        end
    end)
end

if config_data.mie_book_horticulture then
    env.AddPrefabPostInitAny(function(inst)
        if not TheWorld.ismastersim then
            return inst;
        end
        if inst:HasTag("_inventoryitem") then
            if inst.components.mie_book_horticulture == nil then
                inst:AddComponent("mie_book_horticulture_action");
            end
        end
    end)
    -- 需要被指定排除的一些预制物添加统一标签
    for _, v in ipairs({

    }) do
        env.AddPrefabPostInit(v, function(inst)
            inst:AddTag("mie_book_horticulture_cannot_tag");
        end)
    end
end