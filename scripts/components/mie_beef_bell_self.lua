---
--- @author zsh in 2023/2/9 14:33
---

local function onisCD(self, isCD, old)
    print("进入onisCD函数");
    print(string.format("%s %s %s"), tostring(self), tostring(isCD), tostring(old));
    if isCD then
        if self.inst:HasTag("beef_bell_isCD_NO") then
            self.inst:RemoveTag("beef_bell_isCD_NO");
        end
        self.inst:AddTag("beef_bell_isCD_YES");
    else
        if self.inst:HasTag("beef_bell_isCD_YES") then
            self.inst:RemoveTag("beef_bell_isCD_YES");
        end
        self.inst:AddTag("beef_bell_isCD_NO");
    end
end

local BeefBell = Class(function(self, inst)
    self.inst = inst;

    print("准备修改self.isCD");
    self.isCD = false;


end, nil, {
    isCD = onisCD;
})

return BeefBell;