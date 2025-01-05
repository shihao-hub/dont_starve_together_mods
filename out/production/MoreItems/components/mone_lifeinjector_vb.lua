---
--- @author zsh in 2023/1/20 14:27
---


---@return table|nil
local function get_persistent_data(filename)
    local res
    TheSim:GetPersistentString(filename, function(load_success, data)
        if not load_success or data == nil then
            return
        end
        local success, saved_data = RunInSandbox(data)
        if not success then
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

        print("self.currenthealth:" .. tostring(self.currenthealth));
        print("self.maxhealth:" .. tostring(self.maxhealth));
        print("inst.components.health.maxhealth:" .. tostring(inst.components.health.maxhealth));

        if inst.components.talker then
            inst.components.talker:Say("当前最大生命值为： " .. inst.components.health.maxhealth)
        end
    end
end

local function _set_persist_data_on_init(component)
    local self = component

    local user = self.inst
    if not constants.LIFE_INJECTOR_VB__INCLUDED_PLAYERS[user.prefab] then
        return
    end

    local persist_data = get_persistent_data(self:_get_persist_filename())
    if not persist_data then
        return
    end
    self.save_maxhealth = persist_data["save_maxhealth"]
end

local VB = Class(function(self, inst)
    self.inst = inst;

    self.save_currenthealth = nil;
    self.save_maxhealth = nil;

    self.eatnum = 0;

    -- init 阶段去查持久化的数据，但是需要限制人物，建议只考虑原版人物
    _set_persist_data_on_init(self)

    -- 注意 OnLoad 函数会在游戏重新加载时执行，具体查看 entityscript.lua:SetPersistData
end, nil, {
    --eatnum = oneatnum; -- 这里初始化组件的时候就执行了。有点麻烦。换个写法。
});

function VB:_get_persist_filename()
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
    local data = {
        eatnum = self.eatnum,
        save_currenthealth = self.save_currenthealth,
        save_maxhealth = self.save_maxhealth,
    }
    -- 持久化一下
    set_persist_data(self:_get_persist_filename(), data)
    return data
end

function VB:OnLoad(data)
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