local VariantSource = {}
VariantSource.__index = VariantSource

function VariantSource.For(baseName, count, extension)
	local varSrc = {
		Variants = {}
	}

	for i = 1, count do
		table.insert(varSrc.Variants, MultiSource.For(baseName .. string.format("%02d", i) .. extension))
	end
	
	return setmetatable(varSrc, VariantSource)
end

function VariantSource:PlayRandom()
	assert(getmetatable(self) == VariantSource, ERR_STATIC_CALL:format("PlayRandom", "VariantSource.For(baseName, count, extension)"))
	local randIndex = math.random(1, #self.Variants)
	self.Variants[randIndex]:Play()
end

function VariantSource:Play(index)
	assert(getmetatable(self) == VariantSource, ERR_STATIC_CALL:format("Play", "VariantSource.For(baseName, count, extension)"))
	if index < 1 or index > #self.Variants then
		error("Attempt to play invalid VariantSource! Index out of range.")
	end
	self.Variants[index]:Play()
end

return VariantSource