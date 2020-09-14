local MultiSource = {}
MultiSource.__index = MultiSource

function MultiSource.For(audioPath)
	local src = {
		BaseSource = love.audio.newSource(audioPath, "static"),
		InUse = {},
		Free = {}
	}
	
	for i = 1, 5 do
		table.insert(src.Free, src.BaseSource:clone())
	end
	
	LoveEventMarshaller.OnUpdate:Connect(function (dt)
		src:Update(dt)
	end)
	
	return setmetatable(src, MultiSource)
end


function MultiSource:Play()
	assert(getmetatable(self) == MultiSource, ERR_STATIC_CALL:format("Play", "MultiSource.For(audioPath)"))
	local audio = self.Free[1]
	if audio == nil then
		audio = self.SoundTemplate:clone() -- yuck
	else
		table.remove(self.Free, 1)
	end
	audio:play()
	table.insert(self.InUse, audio)
end

function MultiSource:Update(delta)
	assert(getmetatable(self) == MultiSource, ERR_STATIC_CALL:format("Update", "MultiSource.For(audioPath)"))
	local inUseList = self.InUse
	for index = 1, #inUseList do
		local source = inUseList[index]
		if source ~= nil and not source:isPlaying() then
			-- This source is dead, move it back to the free list.
			table.remove(self.InUse, index)
			table.insert(self.Free, 1, source)
		end
	end
end

return MultiSource