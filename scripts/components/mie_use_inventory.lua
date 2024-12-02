---
--- @author zsh in 2023/3/1 12:25
---


local function oncanuse(self, canuse)
    if canuse then
        self.inst:AddTag("canuseininv_mie")
    else
        self.inst:RemoveTag("canuseininv_mie")
    end
end

local function oncanusescene(self, canusescene)
    if canusescene then
        self.inst:AddTag("canuseinscene_mie")
    else
        self.inst:RemoveTag("canuseinscene_mie")
    end
end

local Myth_Use_Inventory = Class(function(self, inst)
    self.inst = inst
    self.canuse = false
    self.canusescene = false
    self.onusefn = nil
end,
        nil,
        {
            canuse = oncanuse,
            canusescene = oncanusescene,
        }
)

function Myth_Use_Inventory:SetOnUseFn(fn)
    self.onusefn = fn
end

function Myth_Use_Inventory:OnUse(doer)
    if self.onusefn then
        return self.onusefn(self.inst, doer)
    end
    return true
end

return Myth_Use_Inventory