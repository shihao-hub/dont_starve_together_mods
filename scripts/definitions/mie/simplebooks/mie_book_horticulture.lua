---
--- @author zsh in 2023/2/19 13:14
---

local API = require("chang_mone.dsts.API");

local MIE_HORTICULTURE_DIST = 15;
local MIE_HORTICULTURE_MUST_TAGS = {

}
local MIE_HORTICULTURE_CANT_TAGS = {
    "INLIMBO", "NOCLICK", "knockbackdelayinteraction", "catchable", "fire", "minesprung", "mineactive",
    "trap", "bird", "smallcreature", "smalloceancreature",
    "mie_book_horticulture_cannot_tag"
}
local MIE_HORTICULTURE_ONEOF_TAGS = {
    "_inventoryitem", "plant", "witherable", "kelp",
    "structure", "lureplant", "mush-room", "waterplant",
    "oceanvine", "lichen"
}

--[[local containers = require "containers";
local params = containers.params;

params.mie_book_horticulture = {
    widget = {
        slotpos = {},
        animbank = "ui_chester_shadow_3x4",
        animbuild = "ui_chester_shadow_3x4",
        pos = Vector3(220, 220, 0),
        side_align_tip = 160,
        buttoninfo = {
            text = "一键整理",
            position = Vector3(-125 + 90 + 30 + 1 + 2, -270 + 80 + 10 + 1 + 2, 0),
            fn = function(inst, doer)
                if inst.components.container ~= nil then
                    API.arrangeContainer(inst);
                elseif inst.replica.container ~= nil and not inst.replica.container:IsBusy() then
                    SendRPCToServer(RPC.DoWidgetButtonAction, nil, inst, nil)
                end
            end,
            validfn = function(inst)
                return inst.replica.container ~= nil and not inst.replica.container:IsEmpty()
            end
        }
    },
    type = "chest_simplebooks",
    itemtestfn = function(container, item, slot)
        if container.inst.prefab == item.prefab then
            return false;
        end
        return not (item:HasTag("irreplaceable") or item:HasTag("_container") or item:HasTag("bundle") or item:HasTag("nobundling"));
    end
}

for y = 2.5, -0.5, -1 do
    for x = 0, 2 do
        table.insert(params.mie_book_horticulture.widget.slotpos, Vector3(75 * x - 75 * 2 + 75, 75 * y - 75 * 2 + 75, 0))
    end
end

for _, v in pairs(params) do
    containers.MAXITEMSLOTS = math.max(containers.MAXITEMSLOTS, v.widget.slotpos ~= nil and #v.widget.slotpos or 0)
end]]

local fns = {};

function fns.ondropped(inst)
    if inst.components.container then
        inst.components.container:Close();
        inst.components.container.canbeopened = true;
    end
end

function fns.onpickupfn(inst, pickupguy, src_pos)
    if inst.components.container then
        inst.components.container:Close();
        inst.components.container.canbeopened = false;
    end
end

function fns.onopenfn(inst)
    inst.SoundEmitter:PlaySound("dontstarve/wilson/chest_open");
    inst:AddTag("mie_simplebooks_open");
end

function fns.onclosefn(inst)
    inst.SoundEmitter:PlaySound("dontstarve/wilson/chest_close")
    inst:RemoveTag("mie_simplebooks_open");
end

local mie_book_horticulture_fns = {};

function mie_book_horticulture_fns.debuff(doer)
    local amount = 0.5;
    if doer:HasTag("player") then
        amount = 0; -- 取消掉此处的 debuff
        doer.components.hunger:DoDelta(-amount);
    end
end

local function can(item, doer)
    local inventoryitem = item and item.components.inventoryitem;
    if inventoryitem and inventoryitem.canbepickedup and inventoryitem.cangoincontainer and
            not inventoryitem:IsHeld() and doer.components.inventory:CanAcceptCount(item, 1) > 0 then
        return true;
    end
end

-- 忽略！！！
function mie_book_horticulture_fns.pickup(data)
    local ents, doer = data.ents, data.doer;

    for _, v in ipairs(ents) do
        if can(v, doer) then
            if doer.components.minigame_participator then
                local minigame = doer.components.minigame_participator:GetMinigame();
                if minigame then
                    minigame:PushEvent("pickupcheat", { cheater = doer, item = v });
                end
            end
            SpawnPrefab("sand_puff").Transform:SetPosition(v.Transform:GetWorldPosition());

            if v.components.stackable then
                v = v.components.stackable:Get()
            end

            if v.components.trap and v.components.trap:IsSprung() then
                v.components.trap:Harvest(doer);
                return ;
            end

            doer.components.inventory:GiveItem(v, nil, v:GetPosition());
            return true;
        end
    end
end

function mie_book_horticulture_fns.harvest(inst, data)
    local doer = data and data.doer;
    local x, y, z = inst.Transform:GetWorldPosition();
    if not (x and y and z and doer) then
        return false;
    end

    -- 农作物，好像是旧农场
    if inst.components.crop and inst.components.crop.matured == true then
        inst.components.crop:Harvest(doer);
        SpawnPrefab("sand_puff").Transform:SetPosition(x, y, z);
        return true;
    end

    -- 蘑菇农场、蜂箱等
    if inst.components.harvestable and inst.components.harvestable:CanBeHarvested() then
        if inst.prefab == "mushroom_farm" and inst.components.harvestable.produce and inst.components.harvestable.produce < 4 then
            -- DoNothing
            return ;
        else
            inst.components.harvestable:Harvest(doer);
            SpawnPrefab("sand_puff").Transform:SetPosition(x, y, z);
        end
        return true;
    end

    -- 锅
    if inst.components.stewer and inst.components.stewer:IsDone() then
        inst.components.stewer:Harvest(doer);
        SpawnPrefab("sand_puff").Transform:SetPosition(x, y, z);
        return true;
    end

    -- 农作物，没有花、胡萝卜、蕨菜等
    if inst.components.pickable and inst.components.pickable:CanBePicked() then
        inst.components.pickable:Pick(doer);
        SpawnPrefab("sand_puff").Transform:SetPosition(x, y, z);
        return true;
    end

    -- 晒肉架
    if inst.components.dryer and inst.components.dryer:IsDone() then
        inst.components.dryer:Harvest(doer);
        SpawnPrefab("sand_puff").Transform:SetPosition(x, y, z);
        return true;
    end

    -- 眼球草
    if inst.components.shelf and inst.components.shelf.itemonshelf then
        inst.components.shelf:TakeItem(doer);
        SpawnPrefab("sand_puff").Transform:SetPosition(x, y, z);
        return true;
    end

    -- 如果被采摘的巨大作物 PS：应该写在前面！
    --if inst.components.perishable and inst.components.workable and inst.components.equippable and inst.components.lootdropper then
    --    -- DoNothing
    --    return true;
    --end
    return ;
end

-- Main Function
local function onreadfn2(inst, doer)
    -- 阅读的时候就扣除
    if doer:HasTag("player") then
        doer.components.hunger:DoDelta(-50);
        --doer.components.sanity:DoDelta(-50);
    end

    local range = MIE_HORTICULTURE_DIST;
    local give_success = true;
    if inst.task then
        inst.task:Cancel();
        inst.task = nil;
    end

    --if doer and doer:IsValid() and doer.mie_book_horticulture_task then
    --    doer.mie_book_horticulture_task:Cancel();
    --    doer.mie_book_horticulture_task = nil;
    --end

    -- 写的非常不好。可以进一步优化的！
    inst.task = inst:DoPeriodicTask(TUNING.ORANGEAMULET_ICD, function(inst, doer)
        --count = count + 1;
        --print("   " .. tostring(count));
        local container = inst.components.container;
        if container and give_success then
            local x, y, z = inst.Transform:GetWorldPosition();
            local ents = TheSim:FindEntities(x, y, z, range, MIE_HORTICULTURE_MUST_TAGS, MIE_HORTICULTURE_CANT_TAGS, MIE_HORTICULTURE_ONEOF_TAGS);

            -- 忽略！！！
            --give_success = mie_book_horticulture_fns.pickup({ ents = ents, doer = doer });

            -- TEST
            --for _, v in ipairs(ents) do
            --    print(" ", tostring(v));
            --end

            local cnt = 0;
            local NUMBER = 2;
            for _, v in ipairs(ents) do
                if cnt >= NUMBER then
                    break ;
                end
                if mie_book_horticulture_fns.harvest(v, { doer = doer }) == true then
                    cnt = cnt + 1;
                    mie_book_horticulture_fns.debuff(doer);
                end
            end
        end
    end, nil, doer)
    doer.mie_book_horticulture_task = inst.task;
end

local data = {
    assets = { Asset("ANIM", "anim/books.zip"), },
    assets_fx = { Asset("ANIM", "anim/fx_books.zip"), },
    name = "mie_book_horticulture",
    tags = { "mie_book_horticulture" },
    animstate = { bank = "books", build = "books", animation = "book_horticulture" },
    minimap = "book_horticulture.tex",
    inventoryitem_fn = function(inst)
        inst.components.inventoryitem.imagename = "book_horticulture";
        inst.components.inventoryitem.atlasname = "images/inventoryimages1.xml";
        inst.components.inventoryitem:SetOnDroppedFn(fns.ondropped);
        inst.components.inventoryitem:SetOnPickupFn(fns.onpickupfn);
    end,
    container_client_fn = function(inst)
        local old_OnEntityReplicated = inst.OnEntityReplicated
        inst.OnEntityReplicated = function(inst)
            if old_OnEntityReplicated then
                old_OnEntityReplicated(inst)
            end
            if inst.replica and inst.replica.container then
                inst.replica.container:WidgetSetup("mie_book_horticulture");
            end
        end
    end,
    container_server_fn = function(inst)
        inst:AddComponent("container");
        inst.components.container:WidgetSetup("mie_book_horticulture");
        inst.components.container.onopenfn = fns.onopenfn;
        inst.components.container.onclosefn = fns.onclosefn;
    end,
    onreadfn2 = onreadfn2;
};

-- 不添加容器了！Harvest、Pick、TakeItem 这种函数都是放到口袋里的。我可能需要 hook，麻烦。
--params.mie_book_horticulture = nil;
--data.container_client_fn = nil;
--data.container_server_fn = nil;
-- 添加了也不碍事！

return data;