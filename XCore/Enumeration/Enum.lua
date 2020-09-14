-- Enum.lua
-- Again, something inspired by Roblox. Provides a global `Enum` table which contains enums. Defining enums can be done with a method.

local _Enum = {}

-- Registers a new EnumItem, which is a table inside of Enum that contains values.
-- The input datatable should be a table in one of two forms:
-- Form #1: {["string"] = uniqueValue, ...} (to assign manual IDs)
-- Form #2: {"string", ...} (to assign automatic IDs)
-- This will then expose an enum accessible via Enum.name.entryInDataTable.
-- For example, calling _Enum.Register("Material", {"Grass", "Stone", "Wood"}) will allow me to reference Enum.Material.Grass (or Stone/Wood)
function _Enum.Register(name, dataTable)
	assert(type(name) == "string", ERR_INVALID_TYPE:format("name", "Enum.Register", "string", type(name)))

	local enumItem = {}
	local itemMeta = {__type = name}
	-- If the table has string indices, its length will be zero.
	if #dataTable == 0 then
		for key, value in pairs(dataTable) do
			if type(key) ~= "string" then error("Invalid key for EnumItem! Expected string, got " .. type(key)) end
			if type(value) ~= "number" then error("Invalid value for EnumItem [Enum." .. name .. "." .. key .. "]! Expected number, got " .. type(value)) end
			
			enumItem[key] = AsReadOnly(setmetatable({
				Name = key,
				Value = value
			}, itemMeta))
		end
	else
		for value = 1, #dataTable do
			local key = dataTable[value]
			if type(key) ~= "string" then error("Invalid key for EnumItem! Expected string, got " .. type(key)) end
			
			enumItem[key] = AsReadOnly(setmetatable({
				Name = key,
				Value = value
			}, itemMeta))
		end
	end
	
	local enumItem, itemMt = AsReadOnly(enumItem)
	itemMt.__type = "EnumItem"
	_Enum[name] = enumItem
	
	-- Update it here, don't return it. This allows realtime updates.
	Enum = AsReadOnly(_Enum)
end

return _Enum