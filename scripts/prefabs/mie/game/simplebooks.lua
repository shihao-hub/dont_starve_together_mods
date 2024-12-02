---
--- @author zsh in 2023/2/13 11:03
---

---
--- @author zsh in 2023/2/13 10:30
---

-- book 组件好像需要 reader 才能读
-- simplebook 的话诸如特效等等需要自己处理，先不处理。


--[[ NOTE: simplebooks 好像就是给烹饪书写的。。。 ]]

local function MakeSimpleBook(data)
    local function fn()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddSoundEmitter()
        inst.entity:AddNetwork()

        MakeInventoryPhysics(inst)

        local minimap = inst.entity:AddMiniMapEntity()
        minimap:SetIcon(data.minimap)

        inst.AnimState:SetBank(data.animstate.bank)
        inst.AnimState:SetBuild(data.animstate.build)
        inst.AnimState:PlayAnimation(data.animstate.animation)

        inst.Transform:SetScale(1.2, 1.2, 1.2)

        MakeInventoryFloatable(inst, "med", nil, 0.75)

        -- for simplebook component
        inst:AddTag("simplebook")
        inst:AddTag("bookcabinet_item")

        if data.deployhelper then
            --Dedicated server does not need deployhelper
            if not TheNet:IsDedicated() then
                inst:AddComponent("deployhelper")
                inst.components.deployhelper.onenablehelper = data.deployhelper.OnEnableHelper;
            end
        end

        if data.tags then
            for _, v in ipairs(data.tags) do
                inst:AddTag(v);
            end
        end

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            if data.container_client_fn then
                data.container_client_fn(inst);
            end
            return inst
        end

        if data.name == "mie_book_silviculture" then
            inst:AddComponent("mie_book_silviculture_action");
        end

        inst:AddComponent("inspectable")

        inst:AddComponent("inventoryitem")
        if data.inventoryitem_fn then
            data.inventoryitem_fn(inst);
        end

        inst:AddComponent("simplebook")
        inst.components.simplebook.onreadfn = data.onreadfn2 or function(inst, doer)
            -- DoNothing
        end

        if data.container_server_fn then
            data.container_server_fn(inst);
        end

        MakeHauntableLaunch(inst)

        return inst
    end

    return Prefab(data.name, fn, data.assets)
end

local simplebook_defs = {}


simplebook_defs.mie_book_silviculture = require("definitions.mie.simplebooks.mie_book_silviculture");
simplebook_defs.mie_book_horticulture = require("definitions.mie.simplebooks.mie_book_horticulture");

local prefabs = {};

local config_data = TUNING.MIE_TUNING.MOD_CONFIG_DATA;

if config_data.mie_book_silviculture then
    table.insert(prefabs, MakeSimpleBook(simplebook_defs.mie_book_silviculture));
end
if config_data.mie_book_horticulture then
    table.insert(prefabs, MakeSimpleBook(simplebook_defs.mie_book_horticulture));
end

return unpack(prefabs);
