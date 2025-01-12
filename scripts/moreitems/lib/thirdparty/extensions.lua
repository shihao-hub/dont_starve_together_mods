--[[
## 引入本地扩展（Introduce Local Extension）
> 你需要为服务类提供一些额外函数，但你无法修改这个类。
> 
> 建立一个新类，使它包含这些额外函数，让这个扩展品成为源类的子类或包装类
]]

local function _Stream()
    local luafun = require("moreitems.lib.thirdparty.luafun.fun")
    local class = require("moreitems.lib.thirdparty.middleclass.middleclass").class

    ---@class Stream
    local Stream = class("Stream")

    local function _check_static_method(first_param)
        if type(first_param) ~= "table" then
            return
        end
        if first_param == Stream or first_param.class == Stream then
            error("Please use the method by `ClassName.methodName(...)`")
        end
    end

    function Stream.of(sequence)
        _check_static_method(sequence)
        return Stream(sequence)
    end

    function Stream:initialize(sequence)
        self._iter = luafun.iter(sequence)
        self._terminative = false
    end

    function Stream:_check_terminative()
        if self._terminative then
            error("This stream has been terminated.", 3)
        end
    end

    function Stream:_set_terminative()
        self._terminative = true
    end

    function Stream:filter(fn)
        self:_check_terminative()

        self._iter = self._iter:filter(fn)
        return self
    end

    function Stream:map(fn)
        self:_check_terminative()

        self._iter = self._iter:map(fn)
        return self
    end

    function Stream:take(n)
        self:_check_terminative()

        self._iter = self._iter:take(n)
        return self
    end

    function Stream:drop(n)
        self:_check_terminative()

        self._iter = self._iter:drop(n)
        return self
    end
    --------------------------------------------------------------------------------------------------------------------

    function Stream:foreach(fn)
        self:_check_terminative()

        self._iter:foreach(fn)
    end
    --------------------------------------------------------------------------------------------------------------------

    function Stream:totable()
        self:_check_terminative()

        local res = luafun.totable(self._iter)
        self:_set_terminative()
        return res
    end

    function Stream:sum()
        self:_check_terminative()

        local res = self._iter:sum()
        self:_set_terminative()
        return res
    end

    function Stream:count()
        self:_check_terminative()

        local res = 0
        -- Question: 在 count 中使用 foreach，如何并没循环依赖呢？说起来，我总是思考这个，是否犯了 You Ain't Gonna Need It 的错误
        self:foreach(function() return res + 1 end)
        self:_set_terminative()
        return res
    end

    return Stream
end

return {
    Stream = _Stream(),
}