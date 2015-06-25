local wrapper = require "generic_wrapper"

local obj = wrapper.wrap({1, 2, 3}, {
    print = function(this)
        for i, v in ipairs(this) do
            print(v)
        end
    end
})

obj:print();

local obj2 = wrapper.wrap(function(a, b)
        dosomething();
    end,
    {
        print = print;
        dosomething = function() print "something" end;
    }
)

obj2(5, 3);

local obj3 = wrapper.wrap(function(a)
    print(a);
end, function(f, ...)
    print(f, ...)
end)
    