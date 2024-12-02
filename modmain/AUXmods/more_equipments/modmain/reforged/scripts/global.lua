---
--- @author zsh in 2023/5/23 0:28
---

---@class ReForged_G
local ENV = {};

----------------
-- Table Util --
----------------
-- Takes a table and key names ordered by depth and returns the value at the index.
-- Returns nil if any of the given keys for the table return nil
-- Optional:
--    Keys can be given in order of access to check further into the table.
function ENV.CheckTable(tab, ...)
    local keys = {...}
    while tab and #keys > 0 do
        tab = tab[table.remove(keys, 1)]
    end
    return tab
end

-- Merges 2 tables together, first table given is the base table and the other table will be merged to it.
-- The 2nd table will still exist and be unaffected.
-- Any table values that have a string version of nil: "nil" will set that option to nil. This is only checked in table 2 since it is being merged into table 1.
-- Optional:
-- "override_values" = false (default): Duplicate indices will be ignored.
-- "override_values" = true: will cause the second table to override any duplicate indices.
function ENV.MergeTable(tbl_1, tbl_2, override_values)
    for i, j in pairs(tbl_2) do
        if override_values or not tbl_1[i] then
            tbl_1[i] = j ~= "nil" and j
        end
    end
end



return ENV;