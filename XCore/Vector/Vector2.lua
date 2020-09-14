-- Vector2.lua
-- Provides access to an immutable Vector2 type.

local Vector2 = {}

local function NewVec2(x, y, isUnitVector)
	local x = x or 0
	local y = y or 0
	
	local magnitude = math.sqrt(math.pow(x, 2) + math.pow(y, 2))
	local isUnitVector = isUnitVector or magnitude == 1
	local vector
	if not isUnitVector then
		-- This is a standard vector. Make a new vector for the unit vector.
		vector = setmetatable({
			X = x,
			Y = y,
			Magnitude = magnitude,
			Unit = NewVec2(x / magnitude, y / magnitude, true)
		}, Vector2)
	else
		-- This is a unit vector. Set the Unit property to its parent vector.
		vector = setmetatable({
			X = x,
			Y = y,
			Magnitude = magnitude
		}, Vector2)
		vector.Unit = vector
	end
	
	local readOnly, mt = AsReadOnly(vector)
	return readOnly
end

local function ValidVector2Pair(left, right)
	if typeof(left) ~= "Vector2" or typeof(right) ~= "Vector2" then return false end
	return true
end

function Vector2.new(x, y)
	return NewVec2(x, y, false)
end

Vector2.__index = Vector2
Vector2.__type = "Vector2"
Vector2.__eq = function (left, right)
	if not ValidVector2Pair(left, right) then return false end
	return left.X == right.X and left.Y == right.Y
end
Vector2.__add = function (left, right)
	if not ValidVector2Pair(left, right) then error(ERR_ARITHMETIC_INVALID:format(typeof(left), "+", typeof(right))) end
	return NewVec2(left.X + right.X, left.Y + right.Y)
end
Vector2.__sub = function (left, right)
	if not ValidVector2Pair(left, right) then error(ERR_ARITHMETIC_INVALID:format(typeof(left), "-", typeof(right))) end
	return NewVec2(left.X - right.X, left.Y - right.Y)
end
Vector2.__mul = function (left, right)
	-- This has a number of proper cases.
	local lType = typeof(left)
	local rType = typeof(right)
	if lType == "Vector2" and rType == "Vector2" then
		return NewVec2(left.X * right.X, left.Y * right.Y)
	elseif lType == "number" and rType == "Vector2" then
		return NewVec2(left * right.X, left * right.Y)
	elseif lType == "Vector2" and rType == "number" then
		return NewVec2(left.X * right, left.Y * right)
	end
	error(ERR_ARITHMETIC_INVALID:format(lType, "*", rType))
end
Vector2.__div = function (left, right)
	-- This has a number of proper cases.
	local lType = typeof(left)
	local rType = typeof(right)
	if lType == "Vector2" and rType == "Vector2" then
		return NewVec2(left.X / right.X, left.Y / right.Y)
	elseif lType == "number" and rType == "Vector2" then
		return NewVec2(left / right.X, left / right.Y)
	elseif lType == "Vector2" and rType == "number" then
		return NewVec2(left.X / right, left.Y / right)
	end
	error(ERR_ARITHMETIC_INVALID:format(lType, "/", rType))
end
Vector2.__unm = function (vector)
	if typeof(vector) ~= "Vector2" then error(ERR_ARITHMETIC_INVALID:format("unary", "- (negative)", typeof(vector))) end
	return NewVec2(vector.X * -1, vector.Y * -1)
end
Vector2.__tostring = function (vector)
	if typeof(vector) ~= "Vector2" then error(ERR_INVALID_TYPE, "self", "__tostring", "Vector2", typeof(vector)) end
	return tostring(vector.X) .. ", " .. tostring(vector.Y)
end
return Vector2