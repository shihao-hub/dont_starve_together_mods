local function fn()
    local function fn2()
        print(x)
    end
    local x = 2
    fn2()
end

fn()