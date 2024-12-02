---
--- @author zsh in 2023/2/22 12:09
---

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    inst:AddTag("NOCLICK")
    inst:AddTag("FX")

    if not TheWorld.ismastersim then
        inst:DoTaskInTime(0.1,function(inst)
            print("ThePlayer: "..tostring(ThePlayer));
            if ThePlayer and ThePlayer.components.talker then
                ThePlayer.components.talker:Say("即将跳转至创意工坊`更多物品扩展包`模组的订阅页面");
            end
            inst:DoTaskInTime(2,function(inst)
                VisitURL("https://steamcommunity.com/sharedfiles/filedetails/?id=2928706576");
            end);
        end)

        return inst
    end

    inst.persists = false;

    --inst:DoTaskInTime(0.1,function(inst)
    --    print("ThePlayer: "..tostring(ThePlayer));
    --    -- 开启洞穴后 ThePlayer 不存在？因为这是主机代码？
    --    if ThePlayer and ThePlayer.components.talker then
    --        ThePlayer.components.talker:Say("即将跳转至创意工坊`更多物品扩展包`模组的订阅页面");
    --    end
    --    inst:DoTaskInTime(2,function(inst)
    --        VisitURL("https://steamcommunity.com/sharedfiles/filedetails/?id=2928706576");
    --    end);
    --end)

    inst:DoTaskInTime(5, function(inst)
        print(tostring(inst.prefab) .. ":Remove()!");
        inst:Remove();
    end);

    return inst
end

return Prefab("mone_empty_prefab", fn)