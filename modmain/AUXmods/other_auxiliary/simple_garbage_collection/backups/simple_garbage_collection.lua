---
--- @author zsh in 2023/5/5 19:08
---

--do
--    -- 2023-05-06：我是真的服了
--    -- 首先黑白名单的设置会导致圣诞彩灯居然删不掉？这是我的 UnionSeq 写的有问题吗？
--    -- 其次豪华灯饰似乎没有名字
--    -- 再者，为什么会导致腐烂物丢地上出问题？Get的时候不是生成了新的预制物了吗？莫名其妙。为什么指向同一个啊？
--    -- 最后，玩我呢？这么点代码为什么这么多事？莫名其妙啊我服了...
--    -- 我关掉了我的更多物品，然后发现把腐烂物丢地上还是会出现指向同一个引用的问题...?????
--    -- 服务器和本地模组都关了，还重置了世界，还这样？
--    return;
--end


local config_data = TUNING.MONE_TUNING.GET_MOD_CONFIG_DATA;

---黑名单：开启后，清理这些物品
local function AddBlackList(name)
    local value = false;
    if config_data.sgc_blacklist then
        value = nil; -- nil true ···
    end
    config_data["sgc_" .. name] = value;
end

---白名单：开启后，不清理这些物品
local function AddWhiteList(name)
    if config_data.sgc_whitelist then
        config_data["sgc_" .. name] = false;
    end
end

-- 不等于 false 就是 true，为什么这么麻烦呢？因为配置项有些东西我先注释掉了...
local function IsFakeTrue(var)
    return var ~= false;
end

local old_Import = Import;
local function Import(modulename, environment, ...)
    environment = setmetatable({
        config_data = config_data; -- 这个上值有问题啊？不对劲啊...
        AddBlackList = AddBlackList;
        AddWhiteList = AddWhiteList;
        IsFakeTrue = IsFakeTrue;
    }, { __index = env });
    modulename = "modmain/AUXmods/other_auxiliary/simple_garbage_collection/" .. modulename;
    return old_Import(modulename, environment, ...);
end

-- 备注：有些配置项被删掉了，所以目前判定是 ~= false，就也算是 true！...

local winter = IsFakeTrue(config_data.sgc_winter_switch) and Import("items/winter.lua") or {};
local halloween = IsFakeTrue(config_data.sgc_halloween_switch) and Import("items/halloween.lua") or {};

local others = {}

AddBlackList("spoiled_food"); -- 腐烂食物

AddWhiteList("twigs"); -- 树枝
AddWhiteList("silk"); -- 蜘蛛网
AddWhiteList("rottenegg"); -- 腐烂鸡蛋

for k, v in pairs({
    -- 黑名单
    spoiled_food = IsFakeTrue(config_data.sgc_spoiled_food), -- 腐烂食物

    -- 白名单
    twigs = IsFakeTrue(config_data.sgc_twigs), -- 树枝
    silk = IsFakeTrue(config_data.sgc_silk), -- 蜘蛛网
    rottenegg = IsFakeTrue(config_data.sgc_rottenegg), -- 腐烂鸡蛋

    -- 默认清理列表
    houndstooth = IsFakeTrue(config_data.sgc_houndstooth), -- 狗牙
    stinger = IsFakeTrue(config_data.sgc_stinger), -- 蜂刺
    guano = IsFakeTrue(config_data.sgc_guano), -- 鸟屎
    poop = IsFakeTrue(config_data.sgc_poop), -- 便便
    spidergland = IsFakeTrue(config_data.sgc_spidergland), -- 蜘蛛腺
}) do
    if v then
        table.insert(others, k);
    end
end

local CleanList = UnionSeq(others, winter, halloween);

local function genericFX(inst)
    local v = inst;

    -- 生成特效：这个判定应该是可以判定成只在地面上的吧？
    if v.Transform and v.components.inventoryitem
            and v.components.inventoryitem:GetGrandOwner() == nil then
        local x, y, z = v.Transform:GetWorldPosition();
        if null(x) or null(y) or null(z) then
            -- DoNothing
        else
            local fx = SpawnPrefab("sand_puff");
            -- 变色
            --if fx.AnimState then
            --    fx.AnimState:SetMultColour(.1, 1, .1, 1)
            --end
            local scale = 1.2;
            fx.Transform:SetScale(scale, scale, scale);
            fx.Transform:SetPosition(x, y, z);
        end
    end
end

local function GetPrefabName(inst)
    if not isValid(inst) then
        return "NotIsValidPrefabName";
    end
    local v = inst;
    return v.name or STRINGS.NAMES[string.upper(v.prefab)] or v:GetBasicDisplayName() or "MISSING NAME";
end

local function SetSpecialPrefabName(prefab_name)
    local name;
    if string.find(prefab_name, "^winter_ornament_light") then
        name = "圣诞灯";
    elseif string.find(prefab_name, "^winter_ornament_boss") then
        name = "华丽的装饰";
    end
    return name;
end

env.AddPrefabPostInit("world", function(inst)
    if not TheWorld.ismastersim then
        return inst;
    end

    inst:DoTaskInTime(1, function(inst)
        if --[[TheWorld.state.cycles > 30]] true --[[不需要这个功能]] then
            TheNet:Announce("更多物品：简易垃圾清理功能已开启。")
            local interval = TUNING.TOTAL_DAY_TIME * config_data.sgc_delay;
            local delay = 30;

            inst:DoPeriodicTask(interval, function(inst)
                TheNet:Announce("更多物品：服务器将于30秒后清理掉地面上的部分垃圾！");
                inst:DoTaskInTime(delay, function(inst)
                    local CleanedPrefabs = {};

                    -- 清理垃圾
                    for _, v in pairs(Ents) do
                        if isValid(v) and v.prefab then
                            if table.contains(CleanList, v.prefab) and v.IsInLimbo and not v:IsInLimbo() and v.components then
                                if CleanedPrefabs[v.prefab] == nil then
                                    CleanedPrefabs[v.prefab] = {};
                                    CleanedPrefabs[v.prefab].name = GetPrefabName(v);
                                end
                                if CleanedPrefabs[v.prefab].count == nil then
                                    CleanedPrefabs[v.prefab].count = 0;
                                end

                                local addnum = v.components.stackable and v.components.stackable:StackSize() or 1;
                                CleanedPrefabs[v.prefab].count = CleanedPrefabs[v.prefab].count + addnum;

                                genericFX(v);

                                v:Remove();
                            end
                        end
                    end

                    -- 生成输出信息
                    local msg = {};
                    local count = 0;
                    for prefab_name, data in pairs(CleanedPrefabs) do
                        local name = data.name;
                        if null(name) or isStr(name) and string.find(name, "MISSING NAME") then
                            name = SetSpecialPrefabName(prefab_name) or "获取不到名字的物品";
                        end
                        if isStr(name) then
                            if count % 5 == 0 then
                                table.insert(msg, name .. tostring(data.count) .. "个");
                            else
                                msg[#msg] = msg[#msg] .. " " .. name .. tostring(data.count) .. "个"
                            end
                            count = count + 1;
                        end
                    end

                    -- 输出信息
                    if #msg > 0 then
                        table.insert(msg, 1, "服务器清理了：");
                        for i = 1, #msg do
                            TheNet:Announce(msg[i]);
                        end
                    else
                        TheNet:Announce("当前世界的地面上不存在需要被清理的物品。");
                    end

                    -- 取消引用
                    CleanedPrefabs = nil;
                end)
            end)
        end
    end)
end)