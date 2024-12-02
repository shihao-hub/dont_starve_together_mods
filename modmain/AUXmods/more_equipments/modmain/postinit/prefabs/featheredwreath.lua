---
--- @author zsh in 2023/5/20 23:03
---


return function()
    -- 修改动作，佩戴者可以直接把兔子捡起来。呃，写错了，这是 fn...
    --local old_fn = ACTIONS.PICKUP.fn;
    --ACTIONS.PICKUP.fn = function(act, ...)
    --    local res;
    --
    --    local success;
    --    if isValid(act.doer) and act.doer:HasTag("player") and act.doer:HasTag("me_featheredwreath_creature_friend")
    --            and isValid(act.target)
    --            and table.contains({ "rabbit" }, act.target.prefab)
    --            and (act.target.components.inventoryitem and not act.target.components.inventoryitem.canbepickedup)
    --    then
    --        success = true;
    --        act.target.components.inventoryitem.canbepickedup = true;
    --    end
    --
    --    res = { old_fn(act, ...) };
    --
    --    if success and isValid(act.target) then
    --        act.target.components.inventoryitem.canbepickedup = false;
    --    end
    --
    --    return unpack(res, 1, table.maxn(res))
    --end

    env.AddGlobalClassPostConstruct("behaviours/runaway", "RunAway", function(self, ...)
        if isTab(self.hunternotags) then
            if not oneOfNull(3, self.inst, self.inst.prefab, self.inst.HasTag) then
                if self.inst:HasTag("smallcreature") or self.inst:HasTag("bird") or table.contains({
                    "perd",
                }, self.inst.prefab) then
                    table.insert(self.hunternotags, "me_featheredwreath_creature_friend");
                end
            end
        end
    end)
end