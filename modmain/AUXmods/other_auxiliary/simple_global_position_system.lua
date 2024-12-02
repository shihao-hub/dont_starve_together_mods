---
--- @author zsh in 2023/5/13 2:27
---

-- 简易全球定位系统(GPS)：只在地图上面显示玩家图标和共享地图。


local function compass(inst)
    inst:AddTag("compassbearer");

    if not TheWorld.ismastersim then
        return inst;
    end

    if inst.components.maprevealable then
        inst.components.maprevealable:AddRevealSource(inst, "compassbearer");
    end
end

local function sentryward(inst)
    inst:AddTag("maprevealer");

    if not TheWorld.ismastersim then
        return inst;
    end

    inst:AddComponent("maprevealer");
end

env.AddPlayerPostInit(function(inst)
    compass(inst);
    sentryward(inst);
end)

-- 关于地图共享，灵魂状态不应该可以共享地图吧？


-- 处理一下指南针
local function compass_optimization()
    env.AddPrefabPostInit("compass",function(inst)
        if not TheWorld.ismastersim then
            return inst;
        end

        local equippable = inst.components.equippable;

        if equippable then
            local old_onunequipfn = equippable.onunequipfn;
            equippable.onunequipfn=function(inst, owner,...)
                old_onunequipfn(inst, owner,...);

                if owner.components.maprevealable ~= nil then
                    owner.components.maprevealable:AddRevealSource(inst, "compassbearer")
                end
                owner:AddTag("compassbearer")
            end
        end
    end)
end
compass_optimization();
