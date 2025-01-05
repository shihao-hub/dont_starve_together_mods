---
--- @author zsh in 2023/5/4 4:09
---

--[[
    告死天使之赐
    武器
    伤害55，战斗栏合成
    右键选定一片区域，《对该区域内的一个单位落下一道雷，对该目标造成武器攻击力×2×人物攻击系数的伤害》，此效果（书名号内的）再执行四次（累计五次），若此过程中因落雷击杀目标，则多重复一次此效果（书名号内），每击中一次敌人回复3点激励值；
    获得等同于激励值÷20的百分比吸血；
    每第五次普通攻击召唤闪电攻击敌人，造成相当于当前激励值的伤害并强制打断。

    风暴屹立者之心
    头盔
    减伤不固定，2000耐久，激励值大于0时回复耐久。
    san＞80%时获得20%攻击力加成，防御力为65%
    80%≥san＞60时获得10%攻击力加成，防御力为65%
    60%≥san≥40时获得30%攻击力加成，防御力为80%
    40%＞san时不再获得攻击力加成，防御力变为95%
    受到致命伤害时消耗掉该头盔并免疫两秒伤害，战斗栏合成。

    瓦尔基里的神圣羽衣
    护甲
    75%减伤，5%加速，5%攻击力提升，每有一种歌谣被演奏，便再获得5%加速，和5%攻击力提升。
    3000耐久，每有一种歌谣被演奏，便获得每秒回复2耐久。
    复活周围所有友方，并使他们获得50%加速，g键触发（可设置），CD:600s

    飞升开场白:消耗十点激励值，为范围内所有友军施加10秒移速加成60%。
    羽化进行曲:必须在一分钟内演奏过《飞升开场白》才能进行演奏消耗30点激励值，为范围内所有友军施加20秒buff:每秒回复5生命值。
    登神终乐章:必须在一分钟内演奏过《羽化进行曲》才能进行演奏，消耗70激励值，将范围内所有友军的生命值和san回复至满，并将周围所有敌对生物全部催眠。
    （都是类似惊心独白和粗鲁插曲的可重复演奏的歌谣）
    tips：搭配代罚者套装更棒哦！
]]


-- 环境设置
local ENV = TUNING.MONE_TUNING.MI_MODULES.WATHGRITHR_EXCLUSIVE_EQUIPMENTS.ENV;

-- 02
--local mt = getmetatable(ENV);
--if mt == nil or type(mt.__index) ~= "table" then
--    return ;
--end
--local mod_env = mt.__index;
--mt.__newindex = function(t, k, v)
--    assert(mod_env[k] == nil, "Error: env[\"" .. tostring(k) .. "\"] ~= nil");
--    rawset(t, k, v);
--end

-- 01
--local mt = getmetatable(ENV);
--if mt == nil or type(mt.__index) ~= "table" then
--    return ;
--end
--local mod_env = mt.__index;
--
--setmetatable(mt, { __index = mod_env });
--
--local prefix = "module_";
--
--mt.__index = function(t, k)
--    if type(k) == "string" then
--        return rawget(t, prefix .. k) or mt[k];
--    end
--    return rawget(t, k) or mt[k];
--end
--
--mt.__newindex = function(t, k, v)
--    if type(k) == "string" then
--        k = prefix .. k;
--    end
--    rawset(t, k, v);
--end

setfenv(1, ENV);

-- 模组的全局变量设置
MOD_ENV = {};

-- 模组的全局变量设置
MOD_ENV.MOD_ROOT = "scripts/mi_modules/wathgrithr_exclusive_equipments/";

MOD_ENV.IMAGES_ROOT = MOD_ENV.MOD_ROOT .. "images/";

MOD_ENV.COMPONENTS_ROOT = "mi_modules_agencies/wathgrithr_exclusive_equipments/";

MOD_ENV.MOD_COMPONENTS = {
    lswq_aoespell = MOD_ENV.COMPONENTS_ROOT .. "lswq_aoespell";
    lswq_rechargeable = MOD_ENV.COMPONENTS_ROOT .. "lswq_rechargeable";
}

local function modimport(modulename)
    modulename = MOD_ENV.MOD_ROOT .. modulename;

    --install our crazy loader!
    print("ModImport: " .. env.MODROOT .. modulename)
    if string.sub(modulename, #modulename - 3, #modulename) ~= ".lua" then
        modulename = modulename .. ".lua"
    end
    local result = kleiloadlua(env.MODROOT .. modulename)
    if result == nil then
        error("Error in wathgrithr_exclusive_equipments ModImport: " .. modulename .. " not found!")
    elseif type(result) == "string" then
        error("Error in wathgrithr_exclusive_equipments ModImport: " .. env.ModInfoname(env.modname) .. " importing " .. modulename .. "!\n" .. result)
    else
        setfenv(result, ENV)
        result()
    end
end

modimport("modmain/init/assets"); -- 空的
modimport("modmain/init/prefabfiles"); -- 空的

modimport("modmain/init/registers"); -- 注册图片

modimport("modmain/init/strings");

--local ACTIONS = env.ACTIONS;
--local State = env.State;
--local TimeEvent = env.TimeEvent;
--local FRAMES = env.FRAMES;
--local SpawnPrefab = env.SpawnPrefab;
--local TheSim = env.TheSim;
--local TheFrontEnd = env.TheFrontEnd;
--local TheInput = env.TheInput;
--local GetModConfigData = env.GetModConfigData;
--local SendModRPCToServer = env.SendModRPCToServer;
--local MOD_RPC = env.MOD_RPC;

local GetModConfigData = function(...)
    return GLOBAL["KET_P"];
end

env.AddStategraphPostInit("wilson", function(sg)
    local old_CASTAOE = sg.actionhandlers[ACTIONS.CASTAOE].deststate
    sg.actionhandlers[ACTIONS.CASTAOE].deststate = function(inst, action)
        local weapon = action.invobject
        if weapon then
            if weapon:HasTag("lswq_spear") then
                return "lswq_spear_elec_dash"
            end
        end
        return old_CASTAOE(inst, action)
    end
end)

env.AddStategraphPostInit("wilson_client", function(sg)
    local old_CASTAOE = sg.actionhandlers[ACTIONS.CASTAOE].deststate
    sg.actionhandlers[ACTIONS.CASTAOE].deststate = function(inst, action)
        local weapon = action.invobject
        if weapon then
            if weapon:HasTag("lswq_spear") then
                return "lswq_spear_elec_dash"
            end
        end
        return old_CASTAOE(inst, action)
    end
end)

local talkers = {
    "忏悔！",
    "你的神抛弃了你！",
    "在神的怒火下颤抖吧！",
    "我即是天罚，我即是清算！",
}

env.AddStategraphState("wilson", State {
    name = "lswq_spear_elec_dash",
    tags = { "aoe", "doing", "busy", "nointerrupt", "nomorph", "notalking" },
    onenter = function(inst)
        inst.components.locomotor:Stop()
        inst.AnimState:PlayAnimation("multithrust_yell")
    end,
    timeline = {
        TimeEvent(5 * FRAMES, function(inst)
            local fire = SpawnPrefab("lswq_spear_elec_preparefx")
            if fire then
                fire.entity:AddFollower()
                fire.Follower:FollowSymbol(inst.GUID, "swap_object", 0, -110, 0)
                inst.SoundEmitter:PlaySoundWithParams("dontstarve/rain/thunder_close", { intensity = 0.7 })
            end
        end),
        TimeEvent(15 * FRAMES, function(inst)
            inst.AnimState:PlayAnimation("atk_pre")
            inst.SoundEmitter:PlaySound("dontstarve/wilson/attack_weapon")
        end),

        TimeEvent(20 * FRAMES, function(inst)
            inst.components.talker:Say(talkers[math.random(#talkers)])
            inst:PerformBufferedAction()
        end),
        TimeEvent(22 * FRAMES, function(inst)
            inst.AnimState:PlayAnimation("atk", false)
            inst.sg:GoToState("idle", true)
        end),
    },
})

env.AddStategraphState("wilson_client", State {
    name = "lswq_spear_elec_dash",
    tags = { "aoe", "doing", "busy", "nointerrupt", "nomorph", "notalking" },
    onenter = function(inst)
        inst.components.locomotor:Stop()
        inst.AnimState:PlayAnimation("multithrust_yell")
        inst:PerformPreviewBufferedAction()
    end,
    timeline = {
        TimeEvent(15 * FRAMES, function(inst)
            inst.AnimState:PlayAnimation("atk_pre")
            inst.AnimState:PushAnimation("atk", false)
            inst.sg:GoToState("idle", true)
        end)
    },
    onexit = function(inst)
        inst:ClearBufferedAction()
    end
})

env.AddModRPCHandler("lswqrpc", "lswqrpc", function(inst)
    if inst:HasTag("playerghost") or (inst.components.health and inst.components.health:IsDead()) or inst.sg:HasStateTag("dead") then
        return
    end
    if inst.lswqrpccdin then
        return
    end
    if not (inst.components.playercontroller and inst.components.playercontroller:IsEnabled()) then
        return
    end
    local armor = inst.components.inventory and inst.components.inventory:GetEquippedItem(EQUIPSLOTS.BODY)

    if armor and armor.prefab == "armorlswq" then
        if not armor.components.timer:TimerExists("armorlswq_cd") then
            inst.sg:GoToState("book")
            armor.components.timer:StartTimer("armorlswq_cd", 600)
            local x, y, z = inst.Transform:GetWorldPosition()
            local ents = TheSim:FindEntities(x, 0, z, 32, { "player" })
            for k, v in pairs(ents) do
                if v:IsValid() then
                    v:DoTaskInTime(v:HasTag("playerghost") and 3 or 0, function(v)
                        if v.components.debuffable ~= nil and v.components.debuffable:IsEnabled() and
                                not (v.components.health ~= nil and v.components.health:IsDead()) and
                                not v:HasTag("playerghost")
                        then
                            v.components.debuffable:AddDebuff("armorlswqbuff", "armorlswqbuff")
                        end
                    end)
                    if v:HasTag("playerghost") then
                        v:PushEvent("respawnfromghost", { source = armor })
                    end
                end
            end
        else
            local lefttime = math.ceil(armor.components.timer:GetTimeLeft("armorlswq_cd")) or 0
            inst.components.talker:Say("我的神力尚需恢复 剩余时间:" .. lefttime .. "秒")
        end

    elseif inst.components.talker then
        inst.components.talker:Say("需要装备瓦尔基里的神圣羽衣")
    end
    inst.lswqrpccdin = true
    inst:DoTaskInTime(0.2, function(inst)
        inst.lswqrpccdin = false
    end)

    return true
end)

local function IsHUDScreen()
    local defaultscreen = false
    if TheFrontEnd:GetActiveScreen() and TheFrontEnd:GetActiveScreen().name and type(TheFrontEnd:GetActiveScreen().name) == "string" and TheFrontEnd:GetActiveScreen().name == "HUD" then
        defaultscreen = true
    end
    return defaultscreen
end

env.AddClassPostConstruct("widgets/controls", function(self)
    self.inst:ListenForEvent("onremove", function(inst, data)
        if self.lswqhandler ~= nil then
            self.lswqhandler:Remove()
        end
    end)
    if self.owner then
        self.lswqhandler = TheInput:AddKeyDownHandler(GetModConfigData("KEYKEYKEY"), function()
            if not IsHUDScreen() then
                return
            end
            SendModRPCToServer(MOD_RPC["lswqrpc"]["lswqrpc"])
        end)
    end
end)

env.AddComponentPostInit("inventory", function(self)
    local old_ApplyDamage = self.ApplyDamage
    self.ApplyDamage = function(self, damage, attacker, weapon, ...)
        if self.inst.armorlswqbuff or self.inst.lswqhatfx then
            return 0
        end
        return old_ApplyDamage(self, damage, attacker, weapon, ...)
    end
end)




