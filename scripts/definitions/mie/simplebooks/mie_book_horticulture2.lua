---
--- @author zsh in 2023/5/27 15:23
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

local fns = {};

local function Debuff(doer)
    local amount = 0.5;
    if doer:HasTag("player") then
        amount = 0; -- 取消掉此处的 debuff
        doer.components.hunger:DoDelta(-amount);
    end
end

local function Harvest(inst, data)
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

local function onreadfn(inst, doer)
    -- 阅读的时候就扣除
    if doer:HasTag("player") then
        doer.components.hunger:DoDelta(-50);
    end

    local DIST = MIE_HORTICULTURE_DIST;

    if inst.task then
        inst.task:Cancel();
        inst.task = nil;
    end

    inst.task = inst:DoPeriodicTask(0.33, function(inst, doer)
        local container = inst.components.container;
        if container == nil then
            return ;
        end

        local x, y, z = inst.Transform:GetWorldPosition();

        local ents = TheSim:FindEntities(x, y, z, DIST, MIE_HORTICULTURE_MUST_TAGS, MIE_HORTICULTURE_CANT_TAGS, MIE_HORTICULTURE_ONEOF_TAGS);

        local cnt = 0;
        local NUMBER = 2;
        for _, v in ipairs(ents) do
            if cnt >= NUMBER then
                break ;
            end
            if Harvest(v, { doer = doer }) == true then
                cnt = cnt + 1;
                Debuff(doer);
            end
        end
    end, nil, doer)
    doer.mie_book_horticulture_task = inst.task;
end

return {
    assets = { Asset("ANIM", "anim/books.zip"), },
    assets_fx = { Asset("ANIM", "anim/fx_books.zip"), },
    name = "mie_book_horticulture2",
    tags = { "mie_book_horticulture" },
    animstate = { bank = "books", build = "books", animation = "book_horticulture" },
    minimap = "book_horticulture.tex",
    common_postinit = function(inst)

    end,
    client_postinit = function(inst)

    end,
    master_postinit = function(inst)
        inst.components.inventoryitem.imagename = "book_horticulture";
        inst.components.inventoryitem.atlasname = "images/inventoryimages1.xml";
    end,
    onreadfn = onreadfn;
};