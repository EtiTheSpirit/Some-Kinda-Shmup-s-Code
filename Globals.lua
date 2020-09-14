-- Globals.lua
-- Injects some important variables and functions into the environment.

-- All draw calls will have their scale multiplied by this if they use images.
-- Of course, ^ must be manually implemented.
PIXEL_SCALE = 8

-- A null function that does nothing.
NULL_FUNC = function () end

-- An error that is thrown on pseudo-OOP objects when an instance method is called statically.
-- Format params: methodName, ctorName
ERR_STATIC_CALL = "Attempt to statically call method %s. Please call this on an instance of this type created via %s."

-- An error that is thrown when the type of an input variable is incorrect.
-- Format params: paramName, methodName, expectedType, realType
ERR_INVALID_TYPE = "Incorrect type for parameter '%s' in %s (expected %s, got %s)"

-- An error that is thrown when invalid arithmetic between metatables is performed.
-- Format params: leftType, op, rightType
ERR_ARITHMETIC_INVALID = "Attempt to perform invalid arithmetic operation [%s %s %s]"

-- A modification of setmetatable that returns a reference to the table passed in.
-- This is because I'm a picky screwball that is used to Roblox's API :P
local oldsetmeta = setmetatable
setmetatable = function (tbl, meta)
	oldsetmeta(tbl, meta)
	return tbl
end

RGBToFloat = function (r, g, b, a)
	return (r or 255) / 255, (g or 255) / 255, (b or 255) / 255, (a or 255) / 255
end

-- "Spawns" the input function as a new coroutine, passing in whatever parameters are provided after the function.
-- Unlike standard coroutine behavior, this will keep the stack trace in-tact.
-- You'll never guess which platform's API provides this function too. Of course, mine is different in that it doesn't run on an internal task scheduler, but still...
Spawn = function (func, ...)
	assert(type(func) == "function", ERR_INVALID_TYPE:format("func", "Spawn", "function", type(func)))

	local thread = coroutine.create(func)
	local ok, err = coroutine.resume(thread, ...)
	if not ok then
		error(tostring(err) + "\n" + debug.traceback(thread))
	end
end

-- Takes an input pseudo-OOP object and clears it out so that all information can be GC'd and so that it cannot be used anymore.
-- Any signals owned by this object will be disposed of as well, deleting all connections to those events.
DisposeObject = function (object, isTableSearch)
	assert(type(object) == "table" and (getmetatable(object) ~= nil or isTableSearch == true), "Cannot call DisposeObject on an object that isn't a table or a table that has no metatable.")
	for index in pairs(object) do
		local otype = typeof(object[index])
		--print("Disposing of " .. tostring(object) .. "[" .. tostring(index) .. "] which is a " .. otype)
		
		if otype == "Signal" then
			object[index]:Dispose()
		elseif otype == "Connection" then
			object[index]:Disconnect()
		elseif otype == "table" then
			--print("Searching this index for anything inside that needs to be disposed of...")
			DisposeObject(object[index], true)
		end
		object[index] = nil
	end
	setmetatable(object, nil)
end

-- Provided by https://www.lua.org/pil/13.4.5.html -- Modifies a table to be read-only.
-- This also returns the metatable for any applicable modifications.
local ERR_READONLY_FUNC = function () error("Attempt to modify a read-only table.", 2) end
AsReadOnly = function (tbl)
	local mt = {       -- create metatable
		__index = tbl,
		__newindex = ERR_READONLY_FUNC
	}
	local existingMeta = getmetatable(tbl)
	if existingMeta ~= nil and type(existingMeta) == "table" then
		-- Dupe metamethods.
		for index, method in pairs(existingMeta) do
			if index ~= "__index" and index ~= "__newindex" then
				mt[index] = method
			end
		end
	end
	return setmetatable({}, mt), mt
end

-- Similar to type, but takes in custom metatable garbage to determine custom types.
-- If a metatable has an index __type, which should be a string, then this function will return that value instead.
typeof = function (object)
	local t = type(object)
	if t ~= "table" then return t end
	local meta = getmetatable(object)
	if meta == nil then return "table" end
	local t = meta.__type
	if type(t) ~= "string" then return "table" end
	return t
end

-- table.insert but it returns the index that the object was added to.
-- Similarly to other table methods, it can be called either as table.insertRedIdx(table, value) OR table:insertRedIdx(value)
function table:insertRetIdx(value)
	local lastIndex = #self + 1
	self[lastIndex] = value
	return lastIndex
end