function love.load()
	require("code/LibLoader")
	require("code/AssetLoader")
	GameIntro:Init()
end

function love.update(delta)
	EventMarshallerUpdate(delta)
end

function love.draw()
	EventMarshallerDraw()
end

