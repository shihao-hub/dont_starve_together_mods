---
--- @author zsh in 2023/2/5 14:09
---

local prefabname = "mie_relic_2";

local assets = {
    Asset("ANIM", "anim/relics.zip")
}

local fns = {};

function fns._onopenfn(inst, data)
    inst.SoundEmitter:PlaySound("dontstarve/wilson/chest_open");
end

local function genericFX(inst)
    local scale = 0.5;
    local fx = SpawnPrefab("collapse_big");
    local x, y, z = inst.Transform:GetWorldPosition();
    fx.Transform:SetNoFaced();
    fx.Transform:SetPosition(x, y, z);
    fx.Transform:SetScale(scale, scale, scale);
end

-- 这玩意只适用一个格子。。。。。。。
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

function fns._onclosefn(inst, data)
    inst.SoundEmitter:PlaySound("dontstarve/wilson/chest_close");

    -- 特殊效果
    if inst.components.container:IsEmpty() then
        return ;
    end
    local cnt = count(inst, data);

    if math.random() < 0.55 then
        local items_save_record = {};
        -- paris!!!!!! slots虽然是序列但是存在空洞
        for _, p in pairs(inst.components.container.slots) do
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
            end
            inst.components.container:DropEverything();
        end
    else
        if cnt ~= 0 then
            genericFX(inst, data);
            inst.components.talker:Say("󰀐看样子你的赌运不佳哦󰀐");
            inst.components.container:DestroyContents(); -- 移除所有预制物
        end
    end
end

-- NEW!
-- 重制一下，之前是一个格子，且可以 acceptstacks ~= false。现在是多个格子，且 acceptstacks == false。
-- 2023-03-25：设定不太好，再说吧！
local mie_relic_2_Remaking = false;
if mie_relic_2_Remaking then
    function fns._onclosefn(inst, doer)
        inst.SoundEmitter:PlaySound("dontstarve/wilson/chest_close");

        if inst.components.container:IsEmpty() then
            return ;
        end
        if doer == nil then
            return ;
        end

        local old_number_slots = inst.components.container:GetNumSlots();
        local items_save_record = {};
        local rubbish_items = {};

        -- paris!!!!!! slots虽然是序列但是存在空洞
        for k, p in pairs(inst.components.container.slots) do
            if p and p:IsValid() and p.persists then
                if math.random() < 0.6 then
                    table.insert(items_save_record, (p:GetSaveRecord())); -- GetSaveRecord 有两个返回值。。。
                else
                    table.insert(rubbish_items, inst.components.container:RemoveItemBySlot(k));
                end
            end
        end
        -- 删除预制物
        for _, v in ipairs(rubbish_items) do
            if v and v:IsValid() then
                v:Remove();
            end
        end

        if #items_save_record > 0 then
            genericFX(inst);
            local msg = "";
            if #items_save_record > old_number_slots * 0.8 then
                msg = "󰀁󰀁󰀁" .. tostring(doer.username) .. "的运气快爆棚了！󰀁󰀁󰀁";
            elseif #items_save_record > old_number_slots * 0.5 then
                msg = "󰀁󰀁" .. tostring(doer.username) .. "的运气挺不错的嘛󰀁󰀁";
            elseif #items_save_record > old_number_slots * 0.3 then
                msg = "󰀁" .. tostring(doer.username) .. "的运气还行吧󰀁";
            else
                msg = "" .. tostring(doer.username) .. "的运气不是太好";
            end

            TheNet:Announce(msg);

            for _, v in ipairs(items_save_record) do
                local x, y, z = inst.Transform:GetWorldPosition();
                SpawnSaveRecord(v).Transform:SetPosition(x + 0.5, y + 0.5, z);
            end
            inst.components.container:DropEverything();
        else
            genericFX(inst);
            TheNet:Announce("󰀐看样子" .. tostring(doer.username) .. "的赌运不佳哦󰀐");

            -- TEST
            print("GetNumSlots(): ", tostring(inst.components.container:GetNumSlots()));

            inst.components.container:DestroyContents(); -- 移除所有预制物
        end


    end
end

local function onhammered(inst)
    if inst.components.burnable ~= nil and inst.components.burnable:IsBurning() then
        inst.components.burnable:Extinguish()
    end
    if inst.components.lootdropper then
        inst.components.lootdropper:DropLoot();
    end

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
    inst.MiniMapEntity:SetIcon("relic_2.tex") -- More Items 本体导入过了

    inst:AddTag("structure")
    inst:AddTag("mie_relic_2")

    inst:SetPhysicsRadiusOverride(.1)
    MakeObstaclePhysics(inst, inst.physicsradiusoverride)

    inst.AnimState:SetBank("relic")
    inst.AnimState:SetBuild("relics")
    inst.AnimState:PlayAnimation("2")

    MakeSnowCoveredPristine(inst)

    inst:AddComponent("talker");

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        local old_OnEntityReplicated = inst.OnEntityReplicated
        inst.OnEntityReplicated = function(inst)
            if old_OnEntityReplicated then
                old_OnEntityReplicated(inst)
            end
            if inst and inst.replica and inst.replica.container then
                inst.replica.container:WidgetSetup("mie_relic_2");
            end
        end
        return inst
    end

    inst:AddComponent("inspectable");

    inst:AddComponent("container");
    inst.components.container:WidgetSetup("mie_relic_2");
    inst.components.container.onopenfn = fns._onopenfn;
    inst.components.container.onclosefn = fns._onclosefn;

    inst:AddComponent("lootdropper")
    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(3)
    inst.components.workable:SetOnFinishCallback(onhammered)

    MakeSnowCovered(inst)

    return inst;
end

return Prefab(prefabname, fn, assets),
MakePlacer(prefabname .. "_placer", "relic", "relics", "2");