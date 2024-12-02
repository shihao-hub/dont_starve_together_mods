---
--- @author zsh in 2023/4/15 16:11
---

x, y, z = ThePlayer.Transform:GetWorldPosition();
cache = {};
for _, v in ipairs(TheSim:FindEntities(x, y, z, 20, nil, nil, { "FX", "fx" })) do
    if v and v:IsValid() and v.prefab then
        cache[v.prefab] = cache[v.prefab] or 0;
        cache[v.prefab] = cache[v.prefab] + 1;
    end
end
for k, v in pairs(cache) do
    print(tostring(k), tostring(v));
end

cache = {
    ["1"] = 2;
};
for k, v in pairs(cache) do

end