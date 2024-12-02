---
--- @author zsh in 2023/5/21 1:17
---

return function()

    -- 暂时先用这个方法实现吧！
    local function onhealthdelta(inst, data)
        if oneOfNull(4, inst, data, data.amount, data.afflicter) then
            return ;
        end

        -- 此处可以不用标签的...主要是标签有上限，搞得我写起来有点畏畏缩缩的...
        if not inst:HasTag("me_resplendentnoxhelm_owner") then
            return ;
        end

        local afflicter = data.afflicter;
        local amount = data.amount;

        -- 阿哲，永不妥协好像触发了我的相关bug，放电的时候攻击对方咋把自己杀了...
        if afflicter == inst then
            return ;
        end

        if amount < 0 and afflicter.components.combat and afflicter.components.health then
            local damage = -amount * 10;
            afflicter.components.health:DoDelta(-damage);
            afflicter:PushEvent("attacked", {
                attacker = inst,
                damage = damage,
                damageresolved = damage,
                weapon = nil,
                noimpactsound = afflicter.components.combat.noimpactsound
            })
            if afflicter.components.combat.onhitfn then
                afflicter.components.combat.onhitfn(afflicter, inst, damage);
            end
        end
    end

    env.AddPlayerPostInit(function(inst)
        if not TheWorld.ismastersim then
            return inst;
        end
        inst:ListenForEvent("healthdelta", onhealthdelta);
    end)
end