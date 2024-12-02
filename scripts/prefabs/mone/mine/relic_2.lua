---
--- @author zsh in 2023/1/29 12:54
---

local prefabname = "mone_relic_2";

local assets = {
    Asset("ANIM", "anim/relics.zip")
}

local fns = {};

function fns._onopenfn(inst, data)
    inst.SoundEmitter:PlaySound("dontstarve/wilson/chest_open");
end

local function count(inst, data)
    local cnt = 0;
    for _, v in ipairs(inst.components.container.slots) do
        if v.components.stackable then
            cnt = cnt + v.components.stackable.stacksize;
        else
            cnt = cnt + 1;
        end
    end
    return cnt;
end

local function genericFX(inst, data)
    local scale = 0.5;
    local fx = SpawnPrefab("collapse_big");
    local x, y, z = inst.Transform:GetWorldPosition();
    fx.Transform:SetNoFaced();
    fx.Transform:SetPosition(x, y, z);
    fx.Transform:SetScale(scale, scale, scale);
end

local function isBanList(item, inst, data)
    --local doer = data and data.doer;
    --if doer then
    --    if item.prefab == "ash" then
    --        doer.components.talker:Say("不好意思，我不能耍小聪明。");
    --        return false;
    --    end
    --end
    if item.prefab == "ash" then
        inst.components.talker:Say("不好意思，我不能耍小聪明。");
        return false;
    end
    return true;
end

-- Pay attention:
-- 1、目前我的容器容量只是1，所有我有些部分有可能只是按照容量为1写的
-- 2、需要考虑全面一下，避免有耐久的物品被人钻漏洞！
function fns._onclosefn(inst, data)
    inst.SoundEmitter:PlaySound("dontstarve/wilson/chest_close");

    -- 特殊效果
    if inst.components.container:IsEmpty() then
        return ;
    end
    local cnt = count(inst, data);

    if math.random() < 0.51 then
        local items_save_record = {};
        for _, p in pairs(inst.components.container.slots) do
            -- paris!!!!!!slots虽然是序列但是存在空洞
            --do
            --    -- 验证一下 fueled or finiteuses or armor or perishable 组件的百分比
            --    if p.mone_relic_2_percent then
            --        --print("p.mone_relic_2_percent: " .. tostring(p.mone_relic_2_percent));
            --        if p.mone_relic_2_percent <= 0.8 then
            --            inst.components.talker:Say("存在耐久度低于80%的物品，请勿钻小空子哦！我可是很聪明的！");
            --            inst.components.container:DropEverything();
            --            return ;
            --        end
            --    end
            --end

            if p:IsValid() and p.persists then
                table.insert(items_save_record, (p:GetSaveRecord())); -- GetSaveRecord 有两个返回值。。。
            end
        end
        if #items_save_record > 0 then
            genericFX(inst, data);
            inst.components.talker:Say("󰀁你的运气挺不错的嘛󰀁");
            for _, v in ipairs(items_save_record) do
                local x, y, z = inst.Transform:GetWorldPosition();
                SpawnSaveRecord(v).Transform:SetPosition(x + 0.5, y + 0.5, z);
                --inst.components.container:GiveItem(SpawnSaveRecord(v));
            end
            inst.components.container:DropEverything();
        end
    else
        if cnt ~= 0 then
            genericFX(inst, data);
            inst.components.talker:Say("󰀐看样子你的赌运不佳哦󰀐");
            -- 移除所有预制物
            inst.components.container:DestroyContents();
        end
    end

    -- 截断
    do
        return ;
    end

    -- 生效后加个定时器（以后改成界面直接显示一个倒计时器！）
    inst.components.container.canbeopened = false;
    inst:DoTaskInTime(1, function(inst)
        inst.components.talker:Say("请等待 5 秒之后再尝试哦~ ");
    end)

    -- 不想研究了，就这样吧。能跑就行。。。
    --[[do
        inst:DoTaskInTime(2, function(inst)
            inst.components.talker:Say("还有 9 秒！");
        end);
        inst:DoTaskInTime(3, function(inst)
            inst.components.talker:Say("还有 8 秒！");
        end);
        inst:DoTaskInTime(4, function(inst)
            inst.components.talker:Say("还有 7 秒！");
        end);
        inst:DoTaskInTime(5, function(inst)
            inst.components.talker:Say("还有 6 秒！");
        end);
        inst:DoTaskInTime(6, function(inst)
            inst.components.talker:Say("还有 5 秒！");
        end);
        inst:DoTaskInTime(7, function(inst)
            inst.components.talker:Say("还有 4 秒！");
        end);
        inst:DoTaskInTime(8, function(inst)
            inst.components.talker:Say("还有 3 秒！");
        end);
        inst:DoTaskInTime(9, function(inst)
            inst.components.talker:Say("还有 2 秒！");
        end);
        inst:DoTaskInTime(10, function(inst)
            inst.components.talker:Say("还有 1 秒！");
        end);
    end]]
    do
        inst:DoTaskInTime(2, function(inst)
            inst.components.talker:Say("还有 4 秒！");
        end);
        inst:DoTaskInTime(3, function(inst)
            inst.components.talker:Say("还有 3 秒！");
        end);
        inst:DoTaskInTime(4, function(inst)
            inst.components.talker:Say("还有 2 秒！");
        end);
        inst:DoTaskInTime(5, function(inst)
            inst.components.talker:Say("还有 1 秒！");
        end);
    end

    inst:DoTaskInTime(6, function(inst)
        inst.components.container.canbeopened = true;
        inst.components.talker:Say("你可以继续尝试了~ 搏一搏，单车变摩托！");
    end);
end

local function onhammered(inst)
    if inst.components.burnable ~= nil and inst.components.burnable:IsBurning() then
        inst.components.burnable:Extinguish()
    end
    inst.components.lootdropper:DropLoot()

    -- wc，没有设置掉落所有物品！！！
    if inst.components.container then
        inst.components.container:DropEverything();
    end

    local fx = SpawnPrefab("collapse_big")
    fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
    fx:SetMaterial("wood")
    inst:Remove()
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst.entity:AddMiniMapEntity()
    inst.MiniMapEntity:SetIcon("relic_2.tex")

    inst:AddTag("structure")
    -- 猪人火炬是什么样的？

    inst:SetPhysicsRadiusOverride(.1)
    MakeObstaclePhysics(inst, inst.physicsradiusoverride)

    inst.AnimState:SetBank("relic")
    inst.AnimState:SetBuild("relics")
    inst.AnimState:PlayAnimation("2")

    MakeSnowCoveredPristine(inst)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        local old_OnEntityReplicated = inst.OnEntityReplicated
        inst.OnEntityReplicated = function(inst)
            if old_OnEntityReplicated then
                old_OnEntityReplicated(inst)
            end
            if inst and inst.replica and inst.replica.container then
                inst.replica.container:WidgetSetup("mone_relic_2");
            end
        end
        return inst
    end

    -- 2023-02-16-22:46：客机看不到说话的内容。。。。。。？
    inst:AddComponent("talker");

    --inst:AddComponent("inspectable")

    inst:AddComponent("container");
    inst.components.container:WidgetSetup("mone_relic_2");
    inst.components.container.onopenfn = fns._onopenfn;
    inst.components.container.onclosefn = fns._onclosefn;

    inst:AddComponent("lootdropper")
    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(4)
    inst.components.workable:SetOnFinishCallback(onhammered)

    MakeSnowCovered(inst)
    MakeHauntableWork(inst)

    return inst;
end

return Prefab(prefabname, fn, assets),
MakePlacer(prefabname .. "_placer", "relic", "relics", "2");