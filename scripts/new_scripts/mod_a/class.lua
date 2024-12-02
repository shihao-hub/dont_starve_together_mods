---
--- Created by zsh
--- DateTime: 2023/10/30 21:25
---

setfenv(1, _G)

---@class Object

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
        -- 字段发生修改的时候，就会调用相关函数。参数为：表本身、新值、旧值
        local old = p[1]
        p[1] = v
        p[2](t, v, old)
    end
end

local function _is_a(self, class)
    local mt = getmetatable(self)
    while mt do
        if mt == class then
            return true
        end
        mt = mt._base -- 往上找基类
    end
    return false
end

local function _is_class(self)
    return rawget(self, "is_instance") ~= nil
end

local function _type(self)
    return self._classname
end

local function _set_type(self, classname)
    self._classname = classname
    self.type = _type
end


--local function _on_read_only(t, v, old)
--    assert(v == old, "Cannot change read only property")
--end
--
--function morel_make_read_only(t, k)
--    local _ = rawget(t, "_")
--    assert(_ ~= nil, "Class does not support read only properties")
--    local p = _[k]
--    if p == nil then
--        _[k] = { t[k], _on_read_only }
--        rawset(t, k, nil)
--    else
--        p[2] = _on_read_only
--    end
--end


-- From Don't Starve together
-- base、ctor 只允许下列几种情况：
-- base table, ctor nil
-- base function, ctor nil
-- base nil, ctor function
-- props 的作用是：比如 props = { eat = oneat }，那么当 eat 被修改的时候，会调用 oneat 函数
---@overload fun(ctor:function)
---@overload fun(base:Object,ctor:function)
---@overload fun(base:Object,ctor:function,props:table)
function morel_Class(base, ctor, props)
    local c = {} -- prototype，原型，尚未初始化
    local c_inherited = {}
    if not ctor and type(base) == "function" then
        ctor = base
        base = nil
    elseif type(base) == "table" then
        -- 基类的浅拷贝，为什么是浅拷贝呢？避免复制表吗？
        -- Java 中是否如此呢？似乎是这样的。如果没有修改属性的引用，那么是操作的同一个对象。
        -- 那么总结，继承的时候是浅拷贝，而之后修改的时候
        --[[
            // Parent.java
            public class Parent {
                public StringBuilder stringBuilder = new StringBuilder();
                public Parent(){
                    stringBuilder.append("Parent");
                }
            }

            // Son.java
            public class Son extends Parent{
                public Son(){
                    stringBuilder.append("Son");
                }
                public Son(StringBuilder stringBuilder){
                    this.stringBuilder = stringBuilder;
                    this.stringBuilder.append("Son");
                }

                public static void main(String[] args) {
                    Son son = new Son();
                    System.out.println(son.stringBuilder); // -> ParentSon
                    Son son2 = new Son(new StringBuilder());
                    System.out.println(son2.stringBuilder); // -> Son
                }
            }
        ]]
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

    -- 这加个元表是为了可以通过 c(...) 的方式得到实例化对象
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

    -- 添加基类函数
    c.set_type = _set_type
    c.type = nil
    c.new = mt.__call -- function c:new(...) return self:_new(...) end，用于插件提示
    c._new = c.new

    c._ctor = ctor
    c.is_a = _is_a
    c.is_class = _is_class
    c.is_instance = function(obj) return type(obj) == "table" and _is_a(obj, c) end

    setmetatable(c, mt)

    return c
end

-- 注意，调用该函数得到的就已是实例化的对象了
function morel_Module()
    local prototype = morel_Class(function() end)
    return prototype()
end

-- 直接实例化一个单例对象
function morel_SingletonInstance(ctor)
    local prototype = morel_Class(ctor)
    return prototype:new()
end

---@overload fun() @无基类
function morel_super(prototype, instance, ...)
    if prototype == nil then
        return
    end
    prototype._ctor(instance, ...)
end

--function morel_preprocess(instance, classname)
--    instance:set_type(classname)
--end

