---
--- Created by zsh
--- DateTime: 2023/11/23 3:51
---

require("new_scripts.mod_a.class")
local Switch = require("new_scripts.mod_a.module.switch_statement")

morel_type_nil = "nil"
morel_type_boolean = "boolean"
morel_type_number = "number"
morel_type_string = "string"
morel_type_table = "table"
morel_type_function = "function"
morel_type_thread = "thread"
morel_type_userdata = "userdata"

-- 但是 Lua 哪里需要 vector 呢？

---@class stl_vector
local vector = morel_Class(function(self, typename, size, init)
    self.typename = typename
    self:_check_typename()
    self.size = size or 19
    self.data = {}
    self:_init_data(init)
end)

function vector:new(typename, size, init)
    return vector(typename, size, init)
end

function vector:push_back()

end

function vector:tostring()
    local sb = require("new_scripts.mod_a.class.string_builder")()
    sb:append("[")
    for i = 1, self.size do
        sb:append(tostring(self.data[i])):append(i ~= self.size and "," or "")
    end
    sb:append("]")
    return sb:tostring()
end

function vector:_init_data(init)
    Switch.execute(self.typename, {
        [morel_type_nil] = function()
            for i = 1, self.size do
                self.data[i] = init or nil
            end
        end,
        [morel_type_boolean] = function()
            for i = 1, self.size do
                self.data[i] = init or false
            end
        end,
        [morel_type_number] = function()
            for i = 1, self.size do
                self.data[i] = init or 0.0
            end
        end,
        [morel_type_string] = function()
            for i = 1, self.size do
                self.data[i] = init or ""
            end
        end,
        --[morel_type_table] = function()
        --    for i = 1, self.size do
        --        self.data[i] = ""
        --    end
        --end,
        --[morel_type_function] = function()
        --    for i = 1, self.size do
        --        self.data[i] = ""
        --    end
        --end,
        --[morel_type_thread] = function()
        --    for i = 1, self.size do
        --        self.data[i] = ""
        --    end
        --end,
        --[morel_type_userdata] = function()
        --    for i = 1, self.size do
        --        self.data[i] = ""
        --    end
        --end,
    })
end

function vector:_check_typename()
    local typename = self.typename
    assert(type(typename) == "string", "typename mush be a string type.")
    local check = {
        [morel_type_nil] = true,
        [morel_type_boolean] = true,
        [morel_type_number] = true,
        [morel_type_string] = true,
        [morel_type_table] = true,
        [morel_type_function] = true,
        [morel_type_thread] = true,
        [morel_type_userdata] = true,
    }
    assert(check[typename], string.format("'%s' is an illegal param.", typename))
end

--local function main()
--    local array = vector(morel_type_string, nil, "123")
--    print(array:tostring())
--end
--main()

return vector