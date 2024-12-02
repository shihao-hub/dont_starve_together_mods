---
--- @author zsh in 2023/4/22 12:11
---

local config_data = TUNING.MONE_TUNING.GET_MOD_CONFIG_DATA;
local MAXSIZE_CHANGE = config_data.maxsize_change;

if not MAXSIZE_CHANGE or type(MAXSIZE_CHANGE) ~= "number" then
    return ;
end

-- 修改小恶魔最大可携带的灵魂的数量
local WORTOX_MAX_SOULS = config_data.wortox_max_souls_change;
if WORTOX_MAX_SOULS and type(WORTOX_MAX_SOULS) == "number" then
    TUNING.WORTOX_MAX_SOULS = WORTOX_MAX_SOULS > MAXSIZE_CHANGE and MAXSIZE_CHANGE or WORTOX_MAX_SOULS;
end

-- 修改堆叠上限
TUNING.STACK_SIZE_MEDITEM = MAXSIZE_CHANGE;
TUNING.STACK_SIZE_SMALLITEM = MAXSIZE_CHANGE;
TUNING.STACK_SIZE_LARGEITEM = MAXSIZE_CHANGE;
TUNING.STACK_SIZE_TINYITEM = MAXSIZE_CHANGE;

local STACK_SIZES = {
    TUNING.STACK_SIZE_MEDITEM,
    TUNING.STACK_SIZE_SMALLITEM,
    TUNING.STACK_SIZE_LARGEITEM,
    TUNING.STACK_SIZE_TINYITEM,
}
local STACK_SIZE_CODES = table.invert(STACK_SIZES); -- MAXSIZE_CHANGE 4


-- 兼容一下其他模组，假如某些模组使用的是数字，而非变量...但是我的模组加载太慢了呀...好像没啥用...
env.AddPrefabPostInitAny(function(inst)
    if not TheWorld.ismastersim then
        return inst;
    end
    if inst.components.stackable then
        if not table.contains(STACK_SIZES, inst.components.stackable.maxsize) then
            inst.components.stackable.maxsize = MAXSIZE_CHANGE;
        end
    end
end)

-- 刷新一下数据
package.loaded["components/stackable_replica"] = nil;
local stackable_replica = require("components/stackable_replica");

local function ClearPreviewStackSize(inst)
    inst.replica.stackable.previewstacksize = nil;
end

local function OnStackSizeDirty(inst)
    local self = inst.replica.stackable
    if not self then
        return --stackable removed?
    end

    self:ClearPreviewStackSize()
    inst:PushEvent("inventoryitem_stacksizedirty")
end

-- 这个旧的构造函数用不了，因为底层报错了。关于 network variable 注册的问题。所以我只能用覆写法了... 报错信息：Registering duplicate lua network variable 2698481014 in entity [100093]
-- 2024-10-30：就是因为使用了覆盖法，所以此处会发生崩溃
local _ctor = stackable_replica._ctor;
stackable_replica._ctor = function(self, inst, ...)
    self.inst = inst
    self._stacksize = GLOBAL.net_shortint(inst.GUID, "stackable._stacksize", "stacksizedirty")
    self._stacksizeupper = GLOBAL.net_shortint(inst.GUID, "stackable._stacksizeupper", "stacksizedirty")
    self._ignoremaxsize = GLOBAL.net_bool(inst.GUID, "stackable._ignoremaxsize")
    self._maxsize = GLOBAL.net_shortint(inst.GUID, "stackable._maxsize")
    if not GLOBAL.TheWorld.ismastersim then
        inst:ListenForEvent("stacksizedirty", OnStackSizeDirty)
    end
end






