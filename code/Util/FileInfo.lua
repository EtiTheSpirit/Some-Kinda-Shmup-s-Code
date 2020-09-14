-- FileInfo.lua
-- Offers utilities to get information about files and directories.

local FileInfo = {}

function FileInfo.For(path)
	local path = path:gsub("\\", "/") -- Replace backslashes with forward slashes.
	local fileInfo = {}
	
	-- Check if it ends in a slash.
	if path:sub(#path) == "/" then
		-- It does. Remove it
		path = path:sub(1, #path - 1)
	end
	
	fileInfo.FullName = path
	
	-- Now make a new data packet of stuff I care about
	local lastIndexOfSlash = path:find("/")
	if lastIndexOfSlash ~= nil then
		-- Get everything after that last slash.
		fileInfo.Name = path:sub(lastIndexOfSlash + 1)
		
		-- Now if it's not at the start, the Parent property (parent directory) needs to be set to everything before that.
		if lastIndexOfSlash > 1 then
			fileInfo.Parent = path:sub(1, lastIndexOfSlash - 1)
		else
			-- But if the slash is at the start, parent should be nothing
			fileInfo.Parent = ""
		end
	else
		-- No slashes?
		-- Maybe the path itself is a name.
		fileInfo.Name = path
		fileInfo.Parent = ""
	end
	
	local fileInfo, mt = AsReadOnly(fileInfo) -- Call global function to make this readonly (trying to set Name or Parent will error)
	mt.__type = "FileInfo"
	return fileInfo
end

return FileInfo