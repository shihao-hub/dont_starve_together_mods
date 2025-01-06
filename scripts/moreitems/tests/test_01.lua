---
--- DateTime: 2025/1/6 20:42
---


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


local function get_user(userid) for _, ent in pairs(AllPlayers) do if ent:IsValid() and ent.userid == userid then return ent end end end; local userid = 'KU_GNdCoZGM'; local inst = get_user(userid); local component = inst.components.mone_lifeinjector_vb; component.eatnum = 20000; component.save_currenthealth = 20000; component.save_maxhealth = 20000; component:HPIncreaseOnLoad();

local function get_user(userid) for _, ent in pairs(AllPlayers) do if ent:IsValid() and ent.userid == userid then return ent end end end; local userid = 'KU_GNdCoZGM'; local inst = get_user(userid); local component = inst.components.health; print(component.maxhealth);
