-- Controls tilesets from a predefined image shape.
local TilesetMarshaller = {}
TilesetMarshaller.__index = TilesetMarshaller
TilesetMarshaller.__type = "Tileset"

local TilesetVariant = {}
TilesetVariant.__index = TilesetVariant
TilesetVariant.__type = "TileVariant"

local Tilesets = {}

local FLAG_SHEAR_FRONT_TILE = true
local FLAG_MULT_FRONT_POINT8 = true

-- Returns true if the given pixel is classified as part of the "top border".
local function IsTopBorder(x, y)
	if y <= 15 then
		local mid_low = y
		local mid_high = 31 - y
		return x >= mid_low and x <= mid_high
	end
	return false
end

-- Returns true if the given pixel is classified as part of the "bottom border".
local function IsBottomBorder(x, y)
	if y > 15 then
		y = y - 16
		local mid_low = 15 - y
		local mid_high = 15 + y + 1
		return x >= mid_low and x <= mid_high
	end
	return false
end

-- Returns true if the given pixel is classified as part of the "left border".
local function IsLeftBorder(x, y)
	if x <= 15 then
		local mid_low = x
		local mid_high = 31 - x
		return y >= mid_low and y <= mid_high
	end
	return false
end

-- Returns true if the given pixel is classified as part of the "right border".
local function IsRightBorder(x, y)
	if x > 15 then
		x = x - 16
		local mid_low = 15 - x
		local mid_high = 15 + x + 1
		return y >= mid_low and y <= mid_high
	end
	return false
end

-- Given an image and tile variant index (for multiple tiles stacked on the Y axis, see template image), this will generate all necessary images on the fly.
-- This generates an image data object containing three base indices:
-- Base: The main tile for a general top surface
-- Side: The tile for a side view.
-- Wedge: A diagonal wedge with its right angle in the lower left corner. It should be rotated around the center if being drawn
-- BORDERS:
-- 		Contains borders for all four sides, as well as four diagonal variants TopLeft, TopRight, BottomLeft, BottomRight (which contains two edges at once).
--		When drawing border images, if opposite borders are needed for whatever reason, just draw two images separately (e.g. draw Top then draw Bottom). They overlay the main image.

-- WARNING: This method is slow as it creates a lot of new image data!
local function PopulateArrayFromImage(imageData, variantIndex)
	local data = {
		Base = love.image.newImageData(32, 32);
		Side = love.image.newImageData(32, 32);
		Wedge = love.image.newImageData(32, 32);
		Borders = {
			Top = love.image.newImageData(32, 32);
			Left = love.image.newImageData(32, 32);
			Right = love.image.newImageData(32, 32);
			Bottom = love.image.newImageData(32, 32);
			TopLeft = love.image.newImageData(32, 32);
			TopRight = love.image.newImageData(32, 32);
			BottomLeft = love.image.newImageData(32, 32);
			BottomRight = love.image.newImageData(32, 32);
		}
	}
	for x = 0, 63 do
		for _y = 0, 63 do
			local y = _y + (variantIndex * 64)
			if _y <= 31 then
				if x <= 31 then
					-- top left (base)
					data.Base:setPixel(x, _y, imageData:getPixel(x, y))
				else
					-- top right (wedge)
					if (x - 32) <= _y then
						data.Wedge:setPixel(x - 32, _y, imageData:getPixel(x, y))
					else
						-- If it's out of the wedge bounds, give it black transparency.
						data.Wedge:setPixel(x - 32, _y, 0, 0, 0, 0)
					end
				end
			else
				if x <= 31 then
					-- bottom left (side)
					if not FLAG_SHEAR_FRONT_TILE or (FLAG_SHEAR_FRONT_TILE and _y < 52) then
						local r,g,b,a = imageData:getPixel(x, y)
						if FLAG_MULT_FRONT_POINT8 then
							r = r * 0.8
							g = g * 0.8
							b = b * 0.8
						end
						data.Side:setPixel(x, _y - 32, r,g,b,a)
					end
				else
					-- bottom right (border)
					-- We can take care of every border in one go with this.
					-- The area that affects top should be a triangle
					local _x = x - 32
					local _y = _y - 32
					if IsTopBorder(_x, _y) then
						data.Borders.Top:setPixel(_x, _y, imageData:getPixel(x, y))
						data.Borders.TopLeft:setPixel(_x, _y, imageData:getPixel(x, y))
						data.Borders.TopRight:setPixel(_x, _y, imageData:getPixel(x, y))
					elseif IsBottomBorder(_x, _y) then
						data.Borders.Bottom:setPixel(_x, _y, imageData:getPixel(x, y))
						data.Borders.BottomLeft:setPixel(_x, _y, imageData:getPixel(x, y))
						data.Borders.BottomRight:setPixel(_x, _y, imageData:getPixel(x, y))
					elseif IsLeftBorder(_x, _y) then
						data.Borders.Left:setPixel(_x, _y, imageData:getPixel(x, y))
						data.Borders.TopLeft:setPixel(_x, _y, imageData:getPixel(x, y))
						data.Borders.BottomLeft:setPixel(_x, _y, imageData:getPixel(x, y))
					elseif IsRightBorder(_x, _y) then
						data.Borders.Right:setPixel(_x, _y, imageData:getPixel(x, y))
						data.Borders.TopRight:setPixel(_x, _y, imageData:getPixel(x, y))
						data.Borders.BottomRight:setPixel(_x, _y, imageData:getPixel(x, y))
					end
				end
			end
		end
	end
	
	data.Base = love.graphics.newImage(data.Base)
	data.Side = love.graphics.newImage(data.Side)
	data.Wedge = love.graphics.newImage(data.Wedge)
	data.Base:setFilter("nearest", "nearest")
	data.Side:setFilter("nearest", "nearest")
	data.Wedge:setFilter("nearest", "nearest")
	
	for index, imgData in pairs(data.Borders) do
		data.Borders[index] = love.graphics.newImage(imgData)
		data.Borders[index]:setFilter("nearest", "nearest")
	end
	
	local data = AsReadOnly(setmetatable(data, TilesetVariant))
	return data
end

function TilesetMarshaller.new(tilesetFileInfo)
	if type(tilesetFileInfo) == "string" then
		tilesetFileInfo = FileInfo.For(tilesetFileInfo)
	end
	
	local iData = love.image.newImageData(tilesetFileInfo.FullName)
	local vCount = math.floor(iData:getHeight() / 64)
	local tileset = {
		Name = tilesetFileInfo.Name,
		Variants = {}
	}
	
	-- Grab the images.
	for variant = 1, vCount do
		tileset.Variants[variant] = PopulateArrayFromImage(iData, variant - 1) -- Variant here is zero-indexed so it needs to have -1
	end
	
	local variants = AsReadOnly(tileset.Variants)
	tileset.Variants = variants -- Set it to the readonly array.
	
	local tileset = setmetatable(tileset, TilesetMarshaller)
	local tileset = AsReadOnly(tileset)
	Tilesets[tileset.Name] = tileset
	
	return tileset
end


-- function TilesetVariant:GetBase()
	-- assert(getmetatable(self) == TilesetVariant, ERR_STATIC_CALL:format("GetBase", "TilesetMarshaller.new() :: Variants")
	-- return self.Base
-- end

-- function TilesetVariant:GetSide()
	-- assert(getmetatable(self) == TilesetVariant, ERR_STATIC_CALL:format("GetSide", "TilesetMarshaller.new() :: Variants")
	-- return self.Side
-- end

-- function TilesetVariant:GetBorder(tileType)
	-- assert(getmetatable(self) == TilesetVariant, ERR_STATIC_CALL:format("GetBorder", "TilesetMarshaller.new() :: Variants")
	-- if type(borderType) == "string" then
		-- borderType = Enum.TileType[tileType]
	-- end
	-- assert(typeof(tileType) == "TileType", ERR_INVALID_TYPE:format("tileType", "GetBorder", "TileType", typeof(tileType)))
	-- local name = borderType.Name
	-- assert(name ~= "Base" and name ~= "Side" and name ~= "Wedge", "Cannot use Base, Side, or Wedge -- It is not a border tile!")
	-- return self.Borders[name]
-- end

function TilesetVariant:Get(tileType)
	assert(typeof(self) == "TileVariant", ERR_STATIC_CALL:format("GetBorder", "TilesetMarshaller.new() :: Variants"))
	if type(tileType) == "string" then
		tileType = Enum.TileType[tileType]
		if tileType == nil then
			error("Unknown TileType \"" .. tileType + "\"!")
		end
	end
	assert(typeof(tileType) == "TileType", ERR_INVALID_TYPE:format("tileType", "Get", "TileType", typeof(tileType)))
	local name = tileType.Name
	if name ~= "Base" and name ~= "Side" and name ~= "Wedge" then
		return self.Borders[name], true
	else
		return self[name], false --base/side/wedge are indices of the root table.
	end
end

-- function TilesetVariant:DrawBase(x, y, rot, scale)
	-- assert(getmetatable(self) == TilesetVariant, ERR_STATIC_CALL:format("DrawBase", "TilesetMarshaller.new() :: Variants")
	-- self:Draw(self.Base, x, y, rot, scale)
-- end

-- function TilsetVariant:DrawSide(x, y, rot, scale)
	-- assert(getmetatable(self) == TilesetVariant, ERR_STATIC_CALL:format("DrawSide", "TilesetMarshaller.new() :: Variants")
	-- self:Draw(self.Side, x, y, rot, scale)
-- end

-- function TilesetVariant:DrawBorder(borderName, x, y, rot, scale)
	-- assert(getmetatable(self) == TilesetVariant, ERR_STATIC_CALL:format("DrawBorder", "TilesetMarshaller.new() :: Variants")
	-- assert(type(borderName) == "string", ERR_INVALID_TYPE:format("borderName", "DrawBorder", "string", type(borderName))
	-- self:Draw(self:GetBorder(
-- end

function TilesetVariant:Draw(tileType, x, y, rot, scale, noBaseIfDrawingBorder)
	assert(typeof(self) == "TileVariant", ERR_STATIC_CALL:format("GetBorder", "TilesetMarshaller.new() :: Variants"))
	assert(typeof(tileType) == "TileType", ERR_INVALID_TYPE:format("tileType", "Draw", "TileType", typeof(tileType)))
	
	local rot = rot or 0 -- Default to 0 if it's not specified.
	local scale = scale or 1 -- Default to 1 in the same case.
	local noBaseIfDrawingBorder = (noBaseIfDrawingBorder == true)
	
	assert(type(x) == "number", ERR_INVALID_TYPE:format("x", "Draw", "number", type(x)))
	assert(type(y) == "number", ERR_INVALID_TYPE:format("y", "Draw", "number", type(y)))
	assert(type(rot) == "number", ERR_INVALID_TYPE:format("rot", "Draw", "number", type(rot)))
	assert(type(scale) == "number", ERR_INVALID_TYPE:format("scale", "Draw", "number", type(scale)))
	assert(rot <= 3 and rot >= 0, "Parameter rot is out of range! Expected a value ranging from 0 to 3.")
	
	local tileImage, isBorder = self:Get(tileType)
	if isBorder and not noBaseIfDrawingBorder then
		-- If we want to draw a border image, then draw the base image first under it so the border doesn't look out of place.
		-- * unless noBaseIfDrawingBorder = true, in which case we specifically do not want to draw the base.
		love.graphics.draw(baseTileImage, x + 16 * scale, y + 16 * scale, rot * math.pi/2, scale, scale, 16, 16)
	end
	-- draw the given image.
	love.graphics.draw(tileImage, x + 16 * scale, y + 16 * scale, rot * math.pi/2, scale, scale, 16, 16)
end

--[[
function TilesetMarshaller:CreateTileset(imagePath, tilesetName)
	local tileset = {}
	local iData = love.image.newImageData(imagePath)
	local iDatArray = {}
	local totalOffset = IData:getHeight() / 64
	
	for ofst = 0, totalOffset - 1 do
		iDatArray[ofst+1] = PopulateArrayFromImage(iData, ofst)
	end
	
	function Tileset:GetBaseImage(idx)
		local idx = idx or 1
		return IDatArray[idx].Base
	end
	
	function Tileset:GetSideImage(idx)
		local idx = idx or 1
		return IDatArray[idx].Side
	end
	
	function Tileset:GetWedgeImage(idx)
		local idx = idx or 1
		return IDatArray[idx].Wedge
	end
	
	function Tileset:GetBorderImage(idx, border)
		local idx = idx or 1
		local border = border:gsub("top", "Top")
		local border = border:gsub("left", "Left")
		local border = border:gsub("right", "Right")
		local border = border:gsub("bottom", "Bottom")
		return IDatArray[idx].Borders[border]
	end
	
	function Tileset:DrawTile(tileType, tileGroup, x, y, rotation, scale)
		local tileImage = nil
		local isBorder = false
		local baseTileImage = self:GetBaseImage(tileGroup)
		if tileType == "base" then
			tileImage = baseTileImage
		elseif tileType == "side" then
			tileImage = self:GetSideImage(tileGroup)
		elseif tileType == "wedge" then
			tileImage = self:GetWedgeImage(tileGroup)
		elseif tileType == "top" or tileType == "bottom" or tileType == "left" or tileType == "right" or tileType == "topleft" or tileType == "topright" or tileType == "bottomleft" or tileType == "bottomright" then
			isBorder = true
			tileImage = self:GetBorderImage(tileGroup, tileType)
		end
		assert(tileImage ~= nil, "Invalid tileType! Expected Top, Front, or Wedge")
		local x = x or 0
		local y = y or 0
		local rotation = rotation or 0
		local scale = scale or 1
		if isBorder then
			love.graphics.draw(baseTileImage, x, y, rotation, scale)
		end
		love.graphics.draw(tileImage, x, y, rotation, scale)
	end
	
	function Tileset:GetNumTiles()
		return #IDatArray
	end
	
	Tilesets[tilesetName] = Tileset
	
	return Tileset
end
--]]

-- This will return a tileset with the given name, or nil if no such tileset exists.
function TilesetMarshaller.GetTilesetByName(name)
	return Tilesets[name]
end
--[[
function TilesetMarshaller.MakeDrawableTileData(colorDef, pixel)
	if colorDef == nil and pixel ~= "000000" then
		error("Unable to find color definition for pixel [" .. tostring(pixel) .. "]!")
	elseif colorDef == nil and pixel == "000000" then
		return {}
	elseif colorDef ~= nil and pixel == "000000" then
		error("Do not overwrite pixel color 000000 in colordefs.json! Black is used for an empty space.")
	end
	
	local TileData = {}
	TileData.TileSet = TilesetMarshaller:GetTilesetByName(colorDef[1])
	TileData.RandomizedValue = math.random(1, TileData.TileSet:GetNumTiles())
	TileData.TileName = colorDef[1]
	TileData.TileType = colorDef[2]
	TileData.Flags = {}
	for i = 3, #colorDef do
		local flag = colorDef[i]
		if flag then
			if #flag >= 7 and flag:sub(1, 7) == "usetile" then
				TileData.Flags.AllowedTiles = TileData.Flags.AllowedTiles or {}
				table.insert(AllowedTiles, tonumber(flag:sub(8)))
			else
				TileData.Flags[flag] = flag
			end
		end
	end
	
	function TileData:Draw(x, y, randomTile)
		if self.TileSet == nil then 
			print(self.TileName)
			return
		end
		local randomTile = nil
		if self.Flags.AllowedTiles and not self.Flags["norng"] then
			randomTile = self.Flags.AllowedTiles[math.random(1, #self.Flags.AllowedTiles)]
		elseif not self.Flags["norng"] then
			randomTile = self.RandomizedValue
		else
			randomTile = 1
		end
		
		local rotation = 0
		if self.Flags["rot90"] then
			rotation = math.pi / 2
		elseif self.Flags["rot180"] then
			rotation = math.pi
		elseif self.Flags["rot270"] then
			rotation = 3 * (math.pi / 2)
		end
		
		local x, y = x * 32, y * 32
		self.TileSet:DrawTile(self.TileType, randomTile, x, y, rotation, 1)
		
		if self.Flags["drawfrontunder"] then
			self.TileSet:DrawTile("front", randomTile, x, y + 32, rotation, 1)
		end
	end
	
	return TileData
end
--]]

return TilesetMarshaller