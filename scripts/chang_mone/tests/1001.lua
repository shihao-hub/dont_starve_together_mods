---
--- @author zsh in 2023/4/4 11:59
---

-- 此处放到 modmain.lua 环境下执行

-- 这个只是个人习惯
GLOBAL.setmetatable(env, { __index = function(_, k)
    return GLOBAL.rawget(GLOBAL, k);
end });

-- 以下是示例代码
local containers = require("containers");
local params = containers.params;

-- 添加1
---------------------------------------------------------------------------------------------
params["此处请保证和你的预制物的代码名一致，不然需要处理点东西"] =
{
    widget =
    {
        slotpos = {},
        animbank = "ui_backpack_2x4",
        animbuild = "ui_backpack_2x4",
        --pos = Vector3(-5, -70, 0),
        pos = Vector3(-5, -80, 0),
    },
    issidewidget = true, -- 这些参数建议看看官方的，比如这个参数就背包有。有啥用我也懒得知道。
    type = "pack", -- 类型，官方有些默认类型有特殊作用的(比如 hand_inv 能自动贴边。)，而且同一类型的不能同时打开。
    openlimit = 1,
}

-- PS: 在哪里利用到了这个 params.xxx.widget 可以去看 widgets/containerwidget.lua

-- 此处是添加格子的，就是格子的坐标，有几个坐标官方就会自动添加几个格子
for y = 0, 3 do
    table.insert(params["这里就是上面那个"].widget.slotpos, Vector3(-162, -75 * y + 114, 0))
    table.insert(params["这里就是上面那个"].widget.slotpos, Vector3(-162 + 75, -75 * y + 114, 0))
end
---------------------------------------------------------------------------------------------



-- 这段代码放在末尾，因为官方申请格子数量的时候用到了这个字段，这段代码很重要。
for k, v in pairs(params) do
    containers.MAXITEMSLOTS = math.max(containers.MAXITEMSLOTS, v.widget.slotpos ~= nil and #v.widget.slotpos or 0)
end