---
--- DateTime: 2025/1/6 16:45
---


local module = {}

---期待 true
function module.assert_true(condition)
    assert(condition == true, "AssertionFailedError: Message ==> Expected condition to be true, but was false")
end

---期待 false
function module.assert_false(condition)
    assert(condition == false, "AssertionFailedError: Message ==> Expected condition to be false, but was true")
end

function module.assert_nil(value)
    assert(value == nil, "Message ==> Expected value to be null, but was: " .. tostring(value))
end

function module.assert_not_nil(value)
    assert(value ~= nil, "AssertionFailedError: Message ==> Expected value to not be null")
end

if select("#", ...) == 0 then
    xpcall(function()
        module.assert_true(false)
    end, print)

    xpcall(function()
        module.assert_false(true)
    end, print)

    xpcall(function()
        module.assert_nil(1)
    end, print)

    xpcall(function()
        module.assert_not_nil(nil)
    end, print)
end

return module
