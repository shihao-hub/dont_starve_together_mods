---
--- @author zsh in 2023/6/23 21:25
---


local force = nil;

print(force == nil);
print(force == nil and false);
print(force == nil and false or force);

print("---");
if force == nil then
    force = false;
end
print(force);