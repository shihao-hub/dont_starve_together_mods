---
--- @author zsh in 2023/2/19 0:26
---

local function MakeFood(data)
    local function fn()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddSoundEmitter()
        inst.entity:AddNetwork()

        MakeInventoryPhysics(inst)

        if data.tags then
            for _, v in ipairs(data.tags) do
                inst:AddTag(v);
            end
        end

        MakeInventoryFloatable(inst, "med", 0.1, 0.65);

        inst.AnimState:SetBank(data.animdata.bank)
        inst.AnimState:SetBuild(data.animdata.build)
        inst.AnimState:PlayAnimation(data.animdata.animation)

        inst.entity:SetPristine()

        if data.cs_fn then
            data.cs_fn(inst);
        end

        if not TheWorld.ismastersim then
            if data.client_fn then
                data.client_fn(inst);
            end
            return inst
        end

        inst:AddComponent("inspectable");
        inst:AddComponent("inventoryitem");
        inst:AddComponent("edible");
        inst:AddComponent("stackable");
        inst:AddComponent("bait");
        inst:AddComponent("tradable");

        if data.server_fn then
            data.server_fn(inst);
        end

        MakeHauntableLaunch(inst);

        return inst;
    end
    return Prefab(data.name, fn, data.assets);
end

local food_defs = require("definitions.mie.food_defs");

local prefabs = {};

for _, data in pairs(food_defs) do
    if data.CanMake then
        table.insert(prefabs, MakeFood(data));
    end
end

return unpack(prefabs);