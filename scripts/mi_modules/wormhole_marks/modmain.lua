-- 环境设置
local ENV = TUNING.MONE_TUNING.MI_MODULES.WORMHOLE_MARKS.ENV;
setfenv(1, ENV);

MORE_ITEMS_MODULES_WORMHOLE_MARKS_ROOT = "scripts/mi_modules/wormhole_marks/";
MORE_ITEMS_MODULES_WORMHOLE_MARKS_COMPONENTS_ROOT = "mi_modules_agencies/wormhole_marks/";

-- 资源导入
local images = {
    "images/mark_1.xml", "images/mark_2.xml", "images/mark_3.xml", "images/mark_4.xml", "images/mark_5.xml",
    "images/mark_6.xml", "images/mark_7.xml", "images/mark_8.xml", "images/mark_9.xml", "images/mark_10.xml",
    "images/mark_11.xml", "images/mark_12.xml", "images/mark_13.xml", "images/mark_14.xml", "images/mark_15.xml",
    "images/mark_16.xml", "images/mark_17.xml", "images/mark_18.xml", "images/mark_19.xml", "images/mark_20.xml",
    "images/mark_21.xml", "images/mark_22.xml"
}

for _, v in ipairs(images) do
    local path = MORE_ITEMS_MODULES_WORMHOLE_MARKS_ROOT .. v;
    table.insert(env.Assets, Asset("ATLAS", path));
    env.AddMinimapAtlas(path);
end

local mod_components_root = MORE_ITEMS_MODULES_WORMHOLE_MARKS_COMPONENTS_ROOT;
local MOD_COMPONENTS = {
    wormhole_marks = mod_components_root .. "wormhole_marks";
    wormhole_counter = mod_components_root .. "wormhole_counter";
}

-- 主客机均添加
env.AddPrefabPostInit("wormhole", function(inst)
    if inst.components.wormhole_marks then
        return inst;
    end
    if inst.components[MOD_COMPONENTS.wormhole_marks] == nil then
        inst:AddComponent(MOD_COMPONENTS.wormhole_marks);
        inst.components.wormhole_marks = inst.components[MOD_COMPONENTS.wormhole_marks];
    end
    inst:ListenForEvent("starttravelsound", function(inst, data)
        if not inst.components.wormhole_marks:CheckMark() then
            inst.components.wormhole_marks:MarkEntrance()
        end

        local other = inst.components.teleporter.targetTeleporter
        if not other.components.wormhole_marks:CheckMark() then
            other.components.wormhole_marks:MarkExit()
        end
    end)
end)

-- 仅主机添加
env.AddPrefabPostInit("world", function(inst)
    if not TheWorld.ismastersim then
        return inst;
    end
    if not inst:HasTag("forest") then
        return inst;
    end
    if inst.components.wormhole_counter then
        return inst;
    end
    if inst.components[MOD_COMPONENTS.wormhole_counter] == nil then
        inst:AddComponent(MOD_COMPONENTS.wormhole_counter);
        inst.components.wormhole_counter = inst.components[MOD_COMPONENTS.wormhole_counter];
    end
end)