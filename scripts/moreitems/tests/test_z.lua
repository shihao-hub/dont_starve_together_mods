---
--- DateTime: 2025/1/6 20:42
---

local inspect = require("moreitems.lib.thirdparty.inspect.inspect")

local stl_string = require("moreitems.lib.shihao.module.stl_string")

--local function get_user(userid)
--    for _, ent in pairs(Ents) do
--        if ent:IsValid() and ent.userid == userid then
--            return ent
--        end
--    end
--end
--
--local userid = "KU_GNdCoZGM"
--
--local inst = get_user(userid)
--local component = inst.components.mone_lifeinjector_vb
--
--component.eatnum = 20000
--component:HPIncrease()


--local function get_user(userid) for _, ent in pairs(AllPlayers) do if ent:IsValid() and ent.userid == userid then return ent end end end; local userid = 'KU_GNdCoZGM'; local inst = get_user(userid); local component = inst.components.mone_lifeinjector_vb; component.eatnum = 20000; component.save_currenthealth = 20000; component.save_maxhealth = 20000; component:HPIncreaseOnLoad();

--local function get_user(userid) for _, ent in pairs(AllPlayers) do if ent:IsValid() and ent.userid == userid then return ent end end end; local userid = 'KU_GNdCoZGM'; local inst = get_user(userid); local component = inst.components.health; print(component.maxhealth);

local inspect = require("moreitems.lib.thirdparty.inspect.inspect")

local mini_utils = require("moreitems.lib.shihao.mini_utils")

print(arg, inspect(arg))
local function fn(...)
    print(arg, inspect(arg))
    --local args = mini_utils.get_arg(arg, ...) -- 未注释时，arg 就变成了 nil？
    print(1)
    print(inspect(arg))
end

fn(1, 2, 3, 4, 5, nil, nil, nil, 9)


print(inspect(stl_string.split(package.cpath, ";")))
