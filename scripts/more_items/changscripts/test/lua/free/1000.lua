---
--- @author zsh in 2023/4/27 17:50
---

local GLOBAL = _G;

local ENV = setmetatable({}, {
    __index = function(t, k)
        if k ~= "print" then
            print("__index: " .. tostring(rawget(GLOBAL, k)));
        end
        return rawget(GLOBAL, k);
    end,
    __newindex = function(t, k, v)
        print("__newindex: " .. tostring(rawget(GLOBAL, k)));
        if rawget(GLOBAL, k) then
            print("--1");
            GLOBAL[k] = v;
            return ;
        end
        print("--2");
        rawset(t, k, v); -- be equivalent to DoNothing
    end
})

c_save = function()
    print("c_save1");
end
c_save();
print();

setfenv(1, ENV);

c_save = function()
    print("c_save2");
end
c_save();

print();
print(c_delete);
c_delete = function()

end