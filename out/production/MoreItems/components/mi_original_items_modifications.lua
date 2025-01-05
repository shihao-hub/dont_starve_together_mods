---
--- @author zsh in 2023/4/25 20:44
---

local Prototype = Class(function(self, inst)
    self.inst = inst;
    self.inst.mi_ori_item_modify_tag = nil;
end)

function Prototype:OnSave()
    return {
        mi_ori_item_modify_tag = self.inst.mi_ori_item_modify_tag;
    }
end

function Prototype:OnLoad(data)
    if data then
        if data.mi_ori_item_modify_tag ~= nil then
            self.inst.mi_ori_item_modify_tag = data.mi_ori_item_modify_tag;
        end
    end
end

return Prototype;