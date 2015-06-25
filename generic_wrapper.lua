--[[
Name:					Generic Wrapper
Author:					Kendall Hester

Description:			Generic wrapper library for tables(5.1+) and userdata(5.1).

Usage:

local obj = wrap({1, 2, 3});

function obj:print()
	for _, v in ipairs(self) do 
		print(v)
	end
end

obj:print()

local obj2 = wrap({1, 2, 3}, {
	print = function(this, i)
		print(tonumber(this[i]));
	end
})

obj2:print();
--]]

--DEPEND
do
    unpack = unpack or table.unpack;
    
    setfenv = setfenv or function(f, env)
        return load(string.dump(f), nil, nil, env);
    end;
    
    getfenv = getfenv or function() return _ENV end;
end
    

local RESERVED_META = {
	["__index"] = true, 
	["__newindex"] = true, 
	["_O"] = true, 
	["_W"] = true
};

--[[
	table pack(...)

	Packs the arguments in a table.
--]]
local function pack(...)
	return {...};
end

--[[
	any pcall_s(function f, ...) 

	Runs pcall and errors if there is an error or return the values of the function.
--]]
local function pcall_s(f, ...)
	local R = pack(pcall(f, ...));
	
	if (R[1]) then
		table.remove(R, 1);
		return unpack(R);
	else
		error(R[2])
	end
end

local function copy(t0, t1)
    local T = t1 or {};
    for i, v in next, t0 do
        T[i] = v;
    end    
    return T;
end

local function merge(t0, t1)
	local T = t1 or {};
	for i, v in next, t0 do
		if (not T[i]) then
			T[i] = v;
		end
	end
	return T;
end

--[[
	table unwrap(table wrapped)
--]]
local function unwrap(wrapped)
	if (getmetatable(wrapped)) then
		if (rawget(getmetatable(wrapped), "_O")) then
			return unpack(rawget(getmetatable(wrapped), "_O"));
		end
	end
end

--[[
	table wrap(table object, table|function wrapper)
--]]
local function wrap(Object, Wrapper, LockWrapper)
	Wrapper = Wrapper or {};
	LockWrapper = LockWrapper or false;
	
	local Proxy = {};
	local Meta = {};
	
	Meta._O = setmetatable(pack(Object), {});
	
	if (LockWrapper) then
		Meta._W = setmetatable(pack(Wrapper), {__metatable = "locked"});
	else
		Meta._W = setmetatable(pack(Wrapper), {});
	end
	
	if (type(Object) == "table" and type(Wrapper) == "table") then
		Meta.__index = function(this, Key)
			if (Wrapper[Key]) then
				local T = type(Wrapper[Key]);
				
				if (T == "function") then
					return function(self, ...)
						if (unwrap(self)) then
                            return pcall_s(Wrapper[Key], copy(unwrap(self), Wrapper), ...);
						end	
						
						-- now, self is a parameter that was inputted
						return pcall_s(Wrapper[Key], copy(Object, Wrapper), self, ...);			
					end
				else
					return Wrapper[Key];
				end
			elseif (Object[Key]) then
				return Object[Key];
			end
		end
		
		Meta.__newindex = function(this, Key, Value)
			if (not LockWrapper) then
				Wrapper[Key] = Value;
			elseif (Object[Key]) then
				Object[Key] = Value;
			else
				error("Cannot edit wrapper member");
			end
		end
		
		if (Wrapper["__mt__"]) then
			local wrapper_meta_copy = {};
			
			for i, v in next, Wrapper.__meta__ do
				if (not RESERVED_META[i]) then
					Meta[i] = v;
				end
			end
		end
	elseif (type(Object) == "function") then
		if (type(Wrapper) == "function") then
			Meta.__call = function(this, ...)
				--return pcall_s(Wrapper, this, ...);
				return pcall_s(Wrapper, unwrap(this), ...);
			end
		elseif (type(Wrapper) == "table") then
			Meta.__call = function(this, ...)
				if (setfenv) then
					return pcall_s(setfenv(Object, Wrapper), ...);
				end
			end
		end
	end
		
	return setmetatable(Proxy, Meta);
end



return {
	wrap = wrap, 
	unwrap = unwrap,
	pack = pack,
};