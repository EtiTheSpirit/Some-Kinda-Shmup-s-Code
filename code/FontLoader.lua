-- FontLoader.lua
-- Offers a tool to load fonts of a given size dynamically.
-- It contains two methods, Get and SetFont, which can either be called on an instance (created via FontLoader.For) or statically (directly on FontLoader).
-- Calling it on an instance will create a new font associated with the given instance for the given size (or return a cached font)
-- Calling it statically will do the same, but for the stock Love2D font instead.

local FontLoader = {} -- Global.
FontLoader.__index = FontLoader
local GlobalCache = {}
local GlobalFilterSettings = {
	Minify = "linear",
	Magnify = "linear",
	Anisotropy = nil
}

function FontLoader.For(fontPath)
	local font = {
		Path = fontPath,
		FilterSettings = {
			Minify = "linear",
			Magnify = "linear",
			Anisotropy = 1
		},
		Cache = {}
	}
	return setmetatable(font, FontLoader)
end

-- Returns an object for the given font at the given size.
-- If called statically, this returns the Love2D default font at the given size.
function FontLoader:Get(size)
	assert(type(size) == "number", ERR_INVALID_TYPE:format("size", "Get", "number", type(size)))
	local isStaticCall = getmetatable(self) ~= FontLoader
	if isStaticCall then
		if GlobalCache[size] == nil then
			local oldFont = love.graphics.getFont()
			GlobalCache[size] = love.graphics.setNewFont(size)
			GlobalCache[size]:setFilter(GlobalFilterSettings.Minify, GlobalFilterSettings.Magnify, GlobalFilterSettings.Anisotropy)
			love.graphics.setFont(oldFont)
		end
		return GlobalCache[size]
	else
		if self.Cache[size] == nil then
			self.Cache[size] = love.graphics.newFont(self.Path, size)
			self.Cache[size]:setFilter(self.FilterSettings.Minify, self.FilterSettings.Magnify, self.FilterSettings.Anisotropy)
		end
		return self.Cache[size]
	end
end

-- Identical to Get, except it will call love.graphics.setFont as well to change the current active font instead of returning the font object.
function FontLoader:SetFont(size)
	assert(type(size) == "number", ERR_INVALID_TYPE:format("size", "Get", "number", type(size)))
	local isStaticCall = getmetatable(self) ~= FontLoader
	if isStaticCall then
		if GlobalCache[size] == nil then
			GlobalCache[size] = love.graphics.setNewFont(size)
			GlobalCache[size]:setFilter(GlobalFilterSettings.Minify, GlobalFilterSettings.Magnify, GlobalFilterSettings.Anisotropy)
		end
		love.graphics.setFont(GlobalCache[size])
	else
		if self.Cache[size] == nil then
			self.Cache[size] = love.graphics.setNewFont(self.Path, size)
			self.Cache[size]:setFilter(self.FilterSettings.Minify, self.FilterSettings.Magnify, self.FilterSettings.Anisotropy)
		end
		love.graphics.setFont(self.Cache[size])
	end
end

function FontLoader:SetFilter(minify, magnify, anisotropy)
	assert(minify == "linear" or minify == "nearest", ERR_INVALID_TYPE:format("minify", "SetFilter", "string (linear or nearest)", type(minify) .. "(" .. tostring(minify) .. ")"))
	assert(magnify == "linear" or magnify == "nearest", ERR_INVALID_TYPE:format("magnify", "SetFilter", "string (linear or nearest)", type(magnify) .. "(" .. tostring(magnify) .. ")"))
	assert(type(anisotropy) == "number" or anisotropy == nil, ERR_INVALID_TYPE:format("anisotropy", "SetFilter", "number", type(anisotropy)))
	local isStaticCall = getmetatable(self) ~= FontLoader
	if isStaticCall then
		for size, font in pairs(GlobalCache) do
			font:setFilter(minify, magnify, anisotropy)
		end
		GlobalFilterSettings.Minify = minify
		GlobalFilterSettings.Magnify = magnify
		GlobalFilterSettings.Anisotropy = anisotropy
	else
		for size, font in pairs(self.Cache) do
			font:setFilter(minify, magnify, anisotropy)
		end
		self.FilterSettings.Minify = minify
		self.FilterSettings.Magnify = magnify
		self.FilterSettings.Anisotropy = anisotropy
	end
end

return FontLoader