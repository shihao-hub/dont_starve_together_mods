---
--- @author zsh in 2023/5/22 17:45
---

-- 2023-05-26：此处不是太算被使用

local ItemType = Class(function(self, inst)
    self.inst = inst
    self.types = {}
    self.characters = {}
end)

function ItemType:IsType(_type)
    return self.types[_type] ~= nil or _type == self.inst.prefab
end

function ItemType:SetType(types)
    if type(types) == "table" then
        for k,v in pairs(types) do
            self.types[v] = true
        end
    else
        self.types[types] = true
    end
end

function ItemType:SetCharacterSpecific(characters)
    if type(characters) == "table" then
        for k,v in pairs(characters) do
            self.characters[v] = true
        end
    else
        self.characters[characters] = true
    end
end

function ItemType:IsAllowed(itr)
    if itr.restrictions[self.inst.prefab] or (GetTableSize(self.characters) > 0 and not self.characters[itr.inst.prefab]) then
        return false
    end
    for k,v in pairs(self.types) do
        if itr.restrictions[k] or k == "restricted" then
            return false
        end
    end
    return true
end

return ItemType
