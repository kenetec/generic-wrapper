# generic-wrapper
A extremely lightweight wrapper library.

The library provides two main functions and one auxiliary function for usage.

##### Compatible with versions Lua:
  * Lua 5.1
  * Lua 5.2
  * Lua 5.3


API
---

The following is formatted in C++ - like syntax.

### Main functions

table wrap(table|function Object, table|function Wrapper, [bool Lock_Wrapper]) -> Table with the wrapper overlay.

any unwrap(table Wrapped) -> Object passed in wrap function.

### Auxiliary functions

table pack(...) -> Packs the arguments in a table(essentially the opposite of unpack).


Usage
---

The following displays a very basic example of how to use the library.

wrap() can accept two data types for each required argument, tables and functions.

##### Combinations:
  * wrap(table Object, table Wrapper)       -> Applys the Wrapper overlay to the Object.
  * wrap(function Object, table Wrapper)    -> Sets the function environment of the Object.
  * wrap(function Object, function Wrapper) -> Wrapper(Object, ...)

```lua
local wrapper = require "generic_wrapper"

local Obj1 = wrapper.wrap({1, 2, 3}, 
{
  print_content = function(this)          --"this" is passed by the library and behaves as the same as "self"
    for i, v in ipairs(this) do
      print(v);
    end
  end
  
  main = function(this)
    this:print_content();
  end
})

Obj1:main();

-->> 1
-->> 2
-->> 3
```

pack() is used to wrap any data type in a type which can be used in wrap(). "this" passed into methods will have to be unpacked manually to access raw members of the wrapped object, otherwise, do not unpack "this" to access wrapper methods.

```lua
-- LUA 5.1 ONLY
local proxy = newproxy(true);

getmetatable(proxy).__index = {
  doom = false
};

local obj2 = wrapper.wrap(wrapper.pack(proxy), {
    do_some = function(this)
            print "do"
    end,
    
    print_something = function(this)
        this:do_some();
        print(unpack(this).doom)
        --print(this, unpack(this))
    end
});
            
obj2:print_something();
```

unwrap() is simply used to retrieved the original item wrapped.

```lua
local t = wrapper.unwrap(obj1);

print(t["main"]);
```
