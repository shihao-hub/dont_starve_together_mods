---
--- @author zsh in 2023/1/20 14:27
---

local base = require("moreitems.main").shihao.base
local assertion = require("moreitems.main").shihao.module.assertion
local stl_table = require("moreitems.main").shihao.module.stl_table

local inherit_when_change_character = true

local interval = {}
---@return table|nil
local function get_persistent_data(filename)
    base.log.info("call get_persistent_data", "filename: " .. filename)
    local res
    TheSim:GetPersistentString(filename, function(load_success, data)
        if not load_success or data == nil then
            base.log.info("not load_success or data == nil")
            return
        end
        local success, saved_data = RunInSandbox(data)
        if not success then
            base.log.info("not success")
            return
        end
        res = saved_data
    end)
    return res
end

---@param filename string
---@param data table
local function set_persist_data(filename, data)
    -- DataDumper(filters, nil, false)
    --  fastmode 为 false，表示禁用快速模式，生成的 Lua 代码会更加详细和完整。
    --  astmode 为 true，表示启用快速模式，生成的 Lua 代码会更加简洁，但可能会丢失一些细节。
    local str = DataDumper(data, nil, true)
    TheSim:SetPersistentString(filename, str, false)
end


------------------------------------------------------------------------------------------------------------------------

local constants = require("more_items_constants")

local addnum = constants.LIFE_INJECTOR_VB__PER_ADD_NUM

local function oneatnum(self, eatnum)
    local inst = self.inst; -- player

    if inst.components.health and eatnum ~= 0 then
        inst.components.health:SetCurrentHealth(self.currenthealth);
        inst.components.health.maxhealth = self.maxhealth + eatnum * addnum;
        inst.components.health:ForceUpdateHUD(true) --force update HUD

        --print("self.currenthealth:" .. tostring(self.currenthealth));
        --print("self.maxhealth:" .. tostring(self.maxhealth));
        --print("inst.components.health.maxhealth:" .. tostring(inst.components.health.maxhealth));

        if inst.components.talker then
            inst.components.talker:Say("当前最大生命值为： " .. inst.components.health.maxhealth)
        end
    end
end

local function _is_player_included(username)
    return stl_table.contains_value(constants.LIFE_INJECTOR_VB__INCLUDED_PLAYERS, username)
end

local function _set_persist_data_on_init(component, persist_data)
    base.log.info("call _set_persist_data_on_init")

    local self = component

    local user = self.inst
    if not _is_player_included(user.prefab) then
        return
    end

    --base.log.info("1")

    persist_data = base.t_op(persist_data, persist_data, function() get_persistent_data(self:_get_persist_filename()) end)
    if not persist_data then
        return
    end

    --base.log.info("2")

    self.eatnum = persist_data.eatnum
    self.save_currenthealth = self.inst.components.health.currenthealth
    self.save_maxhealth = persist_data.save_maxhealth

    base.log.info("set save_maxhealth field success!")
end

local VB = Class(function(self, inst)
    self.inst = inst;

    self.save_currenthealth = nil;
    self.save_maxhealth = nil;

    self.eatnum = 0;


    -- 换人保存逻辑只和该延迟函数有关！
    -- init 阶段去查持久化的数据，但是需要限制人物，建议只考虑原版人物
    -- Bug: 需要添加延迟，因为 self.inst.userid 默认值是 ""，执行到此处时还未初始化
    -- NOTE: 此处添加了延迟，因此在构造函数中用到了属于 self 的函数将可以接受了。（构造函数中不推荐调用和 self 有关的函数，比如用到了 self）
    self.inst:DoTaskInTime(0, function()
        if not _is_player_included(self.inst.prefab) then
            return
        end

        assertion.assert_true(_is_player_included(self.inst.prefab))

        local old_save_maxhealth = self.save_maxhealth

        local persist_data = get_persistent_data(self:_get_persist_filename())

        local _is_changing_character = function()
            return inherit_when_change_character and self.save_maxhealth ~= persist_data.save_maxhealth
        end

        local is_changing_character = _is_changing_character()

        if not is_changing_character then
            base.log.info("not is_changing_character", old_save_maxhealth, self.save_maxhealth)
            return
        end

        _set_persist_data_on_init(self, persist_data)

        base.log.info("is_changing_character", old_save_maxhealth, self.save_maxhealth)
        self:HPIncreaseOnLoad()
    end)

    -- 注意 OnLoad 函数会在游戏重新加载时执行，具体查看 entityscript.lua:SetPersistData
end, nil, {
    --eatnum = oneatnum; -- 这里初始化组件的时候就执行了。有点麻烦。换个写法。
});

function VB:_get_persist_filename()
    base.log.info("call _get_persist_filename")
    return "lifeinjector_vb_" .. (self.inst.userid or "default")
end

function VB:HPIncrease()
    local inst = self.inst;
    self.eatnum = self.eatnum + 1;
    if inst.components.health then
        inst.components.health:SetCurrentHealth(inst.components.health.currenthealth);
        inst.components.health.maxhealth = inst.components.health.maxhealth + addnum;
        inst.components.health:ForceUpdateHUD(true) --force update HUD

        if inst.components.talker then
            inst.components.talker:Say("当前最大生命值为： " .. inst.components.health.maxhealth)
        end
    end
end

function VB:HPIncreaseOnLoad()
    local inst = self.inst;
    if inst.components.health and self.save_currenthealth and self.save_maxhealth then
        inst.components.health:SetCurrentHealth(self.save_currenthealth);
        inst.components.health.maxhealth = self.save_maxhealth;
        inst.components.health:ForceUpdateHUD(true) --force update HUD
    end
end

function VB:OnSave()
    base.log.info("call OnSave")

    local data = {
        eatnum = self.eatnum,
        save_currenthealth = self.save_currenthealth,
        save_maxhealth = self.save_maxhealth,
    }
    -- 持久化一下
    --[[
        测试发现，c_save 的时候确实持久化到文件中了，但是当重选完人物，立刻被序列化为初始值了！
        这是因为构造函数中 set_persist_data 是延迟后执行的。
        因此添加 if data.eatnum ~= 0 then 判断条件。
        这个判断条件保证了序列化数据的不会被破坏
    ]]
    if data.eatnum ~= 0 and _is_player_included(self.inst.prefab) then
        set_persist_data(self:_get_persist_filename(), data)
    end
    return data
end

function VB:OnLoad(data)
    base.log.info("call OnLoad")

    if data then
        if data.eatnum and data.save_currenthealth and data.save_maxhealth then
            self.eatnum = data.eatnum;
            self.save_currenthealth = data.save_currenthealth;
            self.save_maxhealth = data.save_maxhealth;
            -- 没吃过就不会失效。
            if data.eatnum ~= 0 then
                self:HPIncreaseOnLoad();
            end
        end
    end
end

return VB;
