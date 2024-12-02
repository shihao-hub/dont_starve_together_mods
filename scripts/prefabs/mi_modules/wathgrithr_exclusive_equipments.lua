---
--- @author zsh in 2023/5/4 5:05
---

---@type ShiHao
local ShiHao = rawget(_G, "ShiHao");

if ShiHao == nil then
    print("Warning-Error: _G[\"ShiHao\"] == nil");
    return ;
end

local ROOT = "scripts/mi_modules/wathgrithr_exclusive_equipments/scripts/prefabs/";

local import_prefabs = {
    { ShiHao.Import(ROOT .. "armorlswq", _G) };
    { ShiHao.Import(ROOT .. "armorlswqbuff", _G) };
    { ShiHao.Import(ROOT .. "lswq_hat", _G) };
    { ShiHao.Import(ROOT .. "lswq_spear", _G) };
}

local Prefabs = {};

for _, prefabs in ipairs(import_prefabs) do
    for i = 1, table.maxn(prefabs) do
        table.insert(Prefabs, prefabs[i]);
    end
end

return unpack(Prefabs, 1, table.maxn(Prefabs));

