---
--- Created by zsh
--- DateTime: 2023/9/24 15:14
---

setfenv(1, _G)
require("lib.shlib.env")

local function __index(t, k)
    local p = rawget(t, "_")[k]
    if p ~= nil then
        return p[1]
    end
    return getmetatable(t)[k]
end

local function __newindex(t, k, v)
    local p = rawget(t, "_")[k]
    if p == nil then
        -- 不被代理的话，就正常赋值
        rawset(t, k, v)
    else
        -- 字段发生修改的时候，就会调用相关函数
        local old = p[1]
        p[1] = v
        p[2](t, v, old)
    end
end

local function is_a(self, class)
    local mt = getmetatable(self)
    while mt do
        if mt == class then
            return true
        end
        mt = mt._base -- 往上找基类
    end
    return false
end

local function is_class(self)
    return rawget(self, "is_instance") ~= nil
end


-- 存放所有类的原型
ShiHaoEnv.ClassPrototype = {
    _ = {
        PrintAllPrototypeName = function(self)
            local buffer = {}
            for i, v in pairs(self) do
                if v.is_class and v:is_class() then
                    table.insert(buffer, string.format("%q", i))
                end
            end
            print(table.concat(buffer, ", "))
        end
    }
}

setmetatable(ShiHaoEnv.ClassPrototype, {
    __call = function(t, arg1, ...)
        local n = select("#", ...)

        -- 该函数有两种调用方式：一种是调用 _ 中的无参函数，一种是类原型的定义操作
        -- FIXME: 但是第一种调用显然很危险
        if n <= 0 then
            local func_name = arg1
            local props = rawget(t, "_")

            --local function error_handler()
            --    local val = props[func_name]
            --
            --
            --    return val
            --end

            return props[func_name](t, ...)
        else
            -- 调用模板
            --[[
                ShiHaoEnv.ClassPrototype("Dog", nil, function(self)
                    self.name = "Dog"
                    self.age = 10

                    -- 用来打印，实际上函数定义不是写在构造函数里的
                    function self:tostring()
                        return string.format("{ name:%s, age:%d }",self.name,self.age)
                    end
                end, nil)
                local Dog = ShiHaoEnv.ClassPrototype.Dog()
                print(Dog:tostring())
            ]]

            local args = { ... }
            local index_name, base, ctor, props = arg1, args[1], args[2], args[3]
            local c = ShiHaoEnv.Class(base, ctor, props)
            t[index_name] = c
            return c
        end
    end,
})

-- From Don't Starve together
-- base、ctor 只允许下列几种情况：
-- base table, ctor nil
-- base function, ctor nil
-- base nil, ctor function
function ShiHaoEnv.Class(base, ctor, props)
    local c = {} -- prototype，原型，尚未初始化
    local c_inherited = {}
    if not ctor and type(base) == "function" then
        ctor = base
        base = nil
    elseif type(base) == "table" then
        -- 基类的浅拷贝
        for i, v in pairs(base) do
            c[i] = v
            c_inherited[i] = v
        end
        c._base = base
    end

    if props ~= nil then
        c.__index = __index
        c.__newindex = __newindex
    else
        c.__index = c
    end

    local mt = {}
    mt.__call = function(t, ...)
        local obj = {}
        if props ~= nil then
            obj._ = {}
            for k, v in pairs(props) do
                obj._[k] = { nil, v }
            end
        end
        setmetatable(obj, c)
        if c._ctor then
            c._ctor(obj, ...)
        end
        return obj
    end

    c._ctor = ctor
    c.is_a = is_a
    c.is_class = is_class
    c.is_instance = function(obj) return type(obj) == "table" end

    setmetatable(c, mt)

    return c
end