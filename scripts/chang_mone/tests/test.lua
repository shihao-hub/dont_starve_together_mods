---
--- @author zsh in 2023/1/12 3:33
---

--print(tostring(#1));
--print(string.find("1", "^[01]+$"));


--assert(false);


--for v in pairs({ a = 1 }) do
--    print(v);
--end
--
--for v in pairs({ 2 }) do
--    print(v);
--end


--local t = {
--    a="hello"
--}
--
--do
--    function t.a()
--        return "function-hello"
--    end
--end
--
--print(type(t.a));
--
--local n="100";
--print(tostring(tonumber(n)))

--print(tostring(ThePlayer.components.locomotor.runspeed));

--print(math.random(3, 3))

local function fn(...)
    print(select(2,...));
end

fn("1 ,","2, ","3, ");
