---
--- @author zsh in 2023/2/14 13:45
---

local API = require("chang_mone.dsts.API");

local MIE_SILVICULTURE_DIST = 15;
local MIE_SILVICULTURE_MUST_TAGS = {}
local MIE_SILVICULTURE_CANT_TAGS = {
    "FX", "INLIMBO", "NOCLICK",
    "irreplaceable", "nonpotatable", "bundle", "nobundling",
    "mie_book_silviculture",
}
local MIE_SILVICULTURE_ONEOF_TAGS = { "_inventoryitem" }

--[[local containers = require "containers";
local params = containers.params;

params.mie_book_silviculture = {
    widget = {
        slotpos = {},
        animbank = "ui_chester_shadow_3x4",
        animbuild = "ui_chester_shadow_3x4",
        --pos = Vector3(0, 220, 0),
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
        table.insert(params.mie_book_silviculture.widget.slotpos, Vector3(75 * x - 75 * 2 + 75, 75 * y - 75 * 2 + 75, 0))
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

-- 重载游戏如果物品在人物身上则会执行此处
function fns.onpickupfn(inst, pickupguy, src_pos)
    -- 如果懒人书在猪猪袋中，拿起瞬间都是 nil ... 所以没意义。。。靠！
    --local owner = inst.components.inventoryitem and inst.components.inventoryitem.owner;
    ----print("owner: "..tostring(owner)) -- nil
    ----if owner and owner.prefab == "mone_piggybag" then
    --if owner == nil then
    --    if inst.components.container then
    --        if inst.components.container:IsOpen() then
    --            inst.components.container:Close();
    --        elseif pickupguy then
    --            inst.components.container:Open(pickupguy);
    --        end
    --        inst.components.container.canbeopened = false; -- 这个应该只是限制人物动作的吧？。
    --    end
    --    return ;
    --end

    if inst.components.container then
        inst.components.container:Close();
        inst.components.container.canbeopened = false;
    end
end

function fns.onopenfn(inst)
    inst.SoundEmitter:PlaySound("dontstarve/wilson/chest_open")
    inst:AddTag("mie_simplebooks_open");
end

function fns.onclosefn(inst)
    inst.SoundEmitter:PlaySound("dontstarve/wilson/chest_close")
    inst:RemoveTag("mie_simplebooks_open");
end

local function GetBuild(inst)
    local strnn = ""
    local str = inst.entity:GetDebugString()

    if not str then
        return nil
    end
    local bank, build, anim = str:match("bank: (.+) build: (.+) anim: .+:(.+) Frame")

    return build;
end

local mie_book_silviculture_fns = {};

-- 以下部分为：simutil.lua 内容修改
local PICKUP_MUST_ONEOF_TAGS = { "_inventoryitem", "pickable" }
local PICKUP_CANT_TAGS = {
    -- Items
    "INLIMBO", "NOCLICK", "irreplaceable", "knockbackdelayinteraction", "event_trigger",
    "minesprung", "mineactive", "catchable",
    "fire", "light", "spider", "cursed", "paired", "bundle",
    "heatrock", "deploykititem", "boatbuilder", "singingshell",
    "archive_lockbox", "simplebook",
    -- Pickables
    "flower", "gemsocket", "structure",
    -- Either
    "donotautopick",

    -- 我修改过的
    "trap"
}

local function FindPickupableItem_filter(v, ba, owner, radius, furthestfirst, positionoverride, ignorethese, onlytheseprefabs, allowpickables, ispickable, worker)
    if AllBuilderTaggedRecipes[v.prefab] then
        return false
    end
    -- NOTES(JBK): "donotautopick" for general class components here.
    if v.components.armor or v.components.weapon or v.components.tool or v.components.equippable or v.components.sewing or v.components.erasablepaper then
        return false
    end
    if v.components.burnable ~= nil and (v.components.burnable:IsBurning() or v.components.burnable:IsSmoldering()) then
        return false
    end
    if ispickable then
        if not allowpickables then
            return false
        end
    else
        if not (v.components.inventoryitem ~= nil and
                v.components.inventoryitem.canbepickedup and
                v.components.inventoryitem.cangoincontainer and
                not v.components.inventoryitem:IsHeld()) then
            return false
        end
    end
    if ignorethese ~= nil and ignorethese[v] ~= nil and ignorethese[v].worker ~= worker then
        return false
    end
    if onlytheseprefabs ~= nil and onlytheseprefabs[ispickable and v.components.pickable.product or v.prefab] == nil then
        return false
    end
    if v.components.container ~= nil then
        -- Containers are most likely sorted and placed by the player do not pick them up.
        return false
    end
    if v.components.bundlemaker ~= nil then
        -- Bundle creators are aesthetically placed do not pick them up.
        return false
    end
    if v.components.bait ~= nil and v.components.bait.trap ~= nil then
        -- Do not steal baits.
        return false
    end
    if v.components.trap ~= nil and not (v.components.trap:IsSprung() and v.components.trap:HasLoot()) then
        -- Only interact with traps that have something in it to take.
        return false
    end

    -- 我修改过的
    --if not ispickable and owner.components.inventory:CanAcceptCount(v, 1) <= 0 then -- TODO(JBK): This is not correct for traps nor pickables but they do not have real prefabs made yet to check against.
    --    return false
    --end

    if ba ~= nil and ba.target == v and (ba.action == ACTIONS.PICKUP or ba.action == ACTIONS.CHECKTRAP or ba.action == ACTIONS.PICK) then
        return false
    end
    return v, ispickable
end

-- 2023-03-01-23:27：为什么检索不到活木？

-- This function looks for an item on the ground that could be ACTIONS.PICKUP (or ACTIONS.CHECKTRAP if a trap) by the owner and subsequently put into the owner's inventory.
function mie_book_silviculture_fns.FindPickupableItem(owner, radius, furthestfirst, positionoverride, ignorethese, onlytheseprefabs, allowpickables, worker)
    if owner == nil or owner.components.inventory == nil then
        return nil
    end
    local ba = owner:GetBufferedAction()
    local x, y, z
    if positionoverride then
        x, y, z = positionoverride:Get()
    else
        x, y, z = owner.Transform:GetWorldPosition()
    end
    local ents = TheSim:FindEntities(x, y, z, radius, nil, PICKUP_CANT_TAGS, PICKUP_MUST_ONEOF_TAGS)
    local istart, iend, idiff = 1, #ents, 1
    if furthestfirst then
        istart, iend, idiff = iend, istart, -1
    end
    for i = istart, iend, idiff do
        local v = ents[i]
        local ispickable = v:HasTag("pickable")
        if FindPickupableItem_filter(v, ba, owner, radius, furthestfirst, positionoverride, ignorethese, onlytheseprefabs, allowpickables, ispickable, worker) then
            return v, ispickable
        end
    end
    return nil, nil
end

-- 以下部分为：actions.lua 原内容
function mie_book_silviculture_fns.DoToolWork(act, workaction)
    if act.target.components.workable ~= nil and
            act.target.components.workable:CanBeWorked() and
            act.target.components.workable:GetWorkAction() == workaction then
        act.target.components.workable:WorkedBy(
                act.doer,
                ((act.invobject ~= nil and
                        act.invobject.components.tool ~= nil and
                        act.invobject.components.tool:GetEffectiveness(workaction)
                ) or
                        (act.doer ~= nil and
                                act.doer.components.worker ~= nil and
                                act.doer.components.worker:GetEffectiveness(workaction)
                        ) or
                        1
                ) *
                        (act.doer.components.workmultiplier ~= nil and
                                act.doer.components.workmultiplier:GetMultiplier(workaction) or
                                1
                        )
        )
        return true
    end
    return false
end

function mie_book_silviculture_fns.debuff(inst, doer)
    if doer:HasTag("player") then
        doer.components.hunger:DoDelta(-0.5); -- 0.5 挺多的，改成 0.3 试试？
        --doer.components.hunger:DoDelta(-33);
        --doer.components.sanity:DoDelta(-33);
    end
end

function mie_book_silviculture_fns.isTreeRoot(inst)
    if inst:HasTag("stump") then
        return true;
    end
end

-- Main Function
local function onreadfn2(inst, doer)
    local range = MIE_SILVICULTURE_DIST;
    local give_success = true; -- 保证能完全塞满
    --print("inst.task: " .. tostring(inst.task));
    if inst.task then
        inst.task:Cancel();
        inst.task = nil;
    end

    if inst.task2 then
        inst.task2:Cancel();
        inst.task2 = nil;
    end

    --if doer and doer:IsValid() and doer.mie_book_silviculture_task then
    --    doer.mie_book_silviculture_task:Cancel();
    --    doer.mie_book_silviculture_task = nil;
    --end
    --
    --if doer and doer:IsValid() and doer.mie_book_silviculture_task2 then
    --    doer.mie_book_silviculture_task2:Cancel();
    --    doer.mie_book_silviculture_task2 = nil;
    --end

    inst.task = inst:DoPeriodicTask(TUNING.ORANGEAMULET_ICD, function(inst, doer)
        --print("刷刷刷！");
        local container = inst.components.container;
        if container and give_success then
            -- 一次捡多个
            for i = 1, 3 do
                local item = mie_book_silviculture_fns.FindPickupableItem(doer, range, false);

                if item then
                    SpawnPrefab("sand_puff").Transform:SetPosition(item.Transform:GetWorldPosition());

                    give_success = container:GiveItem(item, nil, nil);

                    mie_book_silviculture_fns.debuff(inst, doer);
                end
            end
        end
    end, nil, doer)

    inst.task2 = inst:DoPeriodicTask(2 / 2, function(inst, doer)
        if not (doer and doer:IsValid()) then
            return ;
        end

        -- 2023-06-12：这个bug依旧存在，而且上下地洞的时候触发了崩溃
        -- 我服了，看样子得换种写法...
        local x, y, z = doer.Transform:GetWorldPosition();

        if not (x and y and z) then
            return ;
        end

        -- 按道理来说：MIE_SILVICULTURE_CANT_TAGS 应该是不需要的吧？
        local _ents = TheSim:FindEntities(x, y, z, MIE_SILVICULTURE_DIST, { "stump" }, MIE_SILVICULTURE_CANT_TAGS);
        --[[        do
                    -- TEST
                    print("_ents: ");
                    local cnt = 0;
                    for _, v in ipairs(_ents) do
                        cnt = cnt + 1;
                        print("", tostring(cnt) .. ": " .. tostring(v))
                    end
                end]]

        -- 其实这里是不需要的，stump 标签就够了！
        local ents = {};
        if #_ents > 0 then
            for _, v in ipairs(_ents) do
                if mie_book_silviculture_fns.isTreeRoot(v) then
                    table.insert(ents, v);
                end
            end
        end

        --[[        do
                    -- TEST
                    print("ents: ");
                    local cnt = 0;
                    for _, v in ipairs(ents) do
                        cnt = cnt + 1;
                        print("", tostring(cnt) .. ": " .. tostring(v))
                    end
                end]]

        if #ents > 0 then
            local cnt = 0;
            for _, v in ipairs(ents) do
                cnt = cnt + 1;
                if cnt > 10 then
                    break ; -- 加个限制吧，不然一次全执行了。。。太卡了！
                end
                local act = { target = v, invobject = nil, doer = doer }
                mie_book_silviculture_fns.DoToolWork(act, ACTIONS.DIG);
                mie_book_silviculture_fns.debuff(inst, doer);
            end
        end
    end, nil, doer);

    doer.mie_book_silviculture_task = inst.task;
    doer.mie_book_silviculture_task2 = inst.task2;

    --inst:ListenForEvent("animover", function(inst)
    --    print("animover!!!");
    --    if inst.task then
    --        inst.task:Cancel();
    --        inst.task = nil;
    --    end
    --end);

    -- 我靠！！！这监听要移除啊！太危险了，靠靠靠！！！
    --[[        local cnt = 0;
            doer:ListenForEvent("locomote", function(doer)
                cnt = cnt + 1;
                print(tostring(cnt) .. ": locomote");
                print("doer.mie_book_silviculture_task: " .. tostring(doer.mie_book_silviculture_task));
                print("doer.mie_book_silviculture_task2: " .. tostring(doer.mie_book_silviculture_task2));
                print();
                if doer.mie_book_silviculture_task then
                    doer.mie_book_silviculture_task:Cancel();
                    doer.mie_book_silviculture_task = nil;
                end
                if doer.mie_book_silviculture_task2 then
                    doer.mie_book_silviculture_task2:Cancel();
                    doer.mie_book_silviculture_task2 = nil;
                end
            end)]]
end

local data = {
    assets = { Asset("ANIM", "anim/books.zip"), },
    assets_fx = { Asset("ANIM", "anim/fx_books.zip"), },
    name = "mie_book_silviculture",
    tags = { "mie_book_silviculture" },
    animstate = { bank = "books", build = "books", animation = "book_silviculture" }, -- 换个贴图吧？simplebook组件应该就是给烹饪书写的。。。但是换成烹饪指南的话。难搞哦。
    minimap = "book_silviculture.tex",
    ---没啥用的，需要我兼容一下显示范围的mod可能才有用。有机会去写一下吧！
    --[[deployhelper = {
        OnEnableHelper = function(inst, enabled)
            if enabled then
                if inst.helper == nil then
                    inst.helper = CreateEntity()

                    -- Non-networked entity
                    inst.helper.entity:SetCanSleep(false)
                    inst.helper.persists = false

                    inst.helper.entity:AddTransform()
                    inst.helper.entity:AddAnimState()

                    inst.helper:AddTag("CLASSIFIED")
                    inst.helper:AddTag("NOCLICK")
                    inst.helper:AddTag("placer")

                    inst.helper.Transform:SetScale(PLACER_SCALE, PLACER_SCALE, PLACER_SCALE)

                    inst.helper.AnimState:SetBank("firefighter_placement")
                    inst.helper.AnimState:SetBuild("firefighter_placement")
                    inst.helper.AnimState:PlayAnimation("idle")
                    inst.helper.AnimState:SetLightOverride(1)
                    inst.helper.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
                    inst.helper.AnimState:SetLayer(LAYER_BACKGROUND)
                    inst.helper.AnimState:SetSortOrder(1)
                    inst.helper.AnimState:SetAddColour(237 / 255, 162 / 255, 0 / 255, 0)

                    inst.helper.entity:SetParent(inst.entity)
                end
            elseif inst.helper ~= nil then
                inst.helper:Remove()
                inst.helper = nil
            end
        end
    },]]
    inventoryitem_fn = function(inst)
        inst.components.inventoryitem.imagename = "book_silviculture";
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
                inst.replica.container:WidgetSetup("mie_book_silviculture");
            end
        end
    end,
    container_server_fn = function(inst)
        inst:AddComponent("container");
        inst.components.container:WidgetSetup("mie_book_silviculture");
        inst.components.container.onopenfn = fns.onopenfn;
        inst.components.container.onclosefn = fns.onclosefn;
    end,
    ---@deprecated
    --[[    onreadfn = function(inst, doer)
            local x, y, z = doer.Transform:GetWorldPosition()
            local range = MIE_SILVICULTURE_DIST;

            local _ents = TheSim:FindEntities(x, y, z, range, MIE_SILVICULTURE_MUST_TAGS, MIE_SILVICULTURE_CANT_TAGS, MIE_SILVICULTURE_ONEOF_TAGS);
            local ents_inventoryitem = {};
            local ents_rest = {};
            for _, v in ipairs(_ents) do
                if v:HasTag("_inventoryitem") then
                    table.insert(ents_inventoryitem, v);
                else
                    table.insert(ents_rest, v);
                end
            end
            -- 捡起预制物
            for _, v in ipairs(ents_inventoryitem) do
                local success = inst.components.container:GiveItem(v);
                if success then
                    -- 随机生成特效，尽量生成少点（目前是这样，之后换个特效！）
                    if math.random() < 0.3 then
                        local sand_puff, scale = SpawnPrefab("sand_puff"), 1.5;
                        sand_puff.Transform:SetScale(scale, scale, scale);
                        sand_puff.Transform:SetPosition(v.Transform:GetWorldPosition());
                    end
                else
                    break ;
                end
            end
            -- 处理一下树根
            for _, v in ipairs(ents_rest) do
                if mie_book_silviculture_fns.isTreeRoot(v) then

                end
            end
            -- 再找一次 _inventoryitem 预制物，然后塞到容器里。

            mie_book_silviculture_fns.debuff(inst, doer);
        end,]]
    onreadfn2 = onreadfn2;
};

return data;