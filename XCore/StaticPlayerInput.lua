-- Provides methods to check input for this game's controls at any given time.
-- Events for key / mouse presses/releases are offered in LoveEventMarshaller

local Input = {}

function Input.Up()
	return love.keyboard.isScancodeDown("w") -- scancode supports azerty keyboards or whatever god-awful garbage someone might be using.
	-- We don't talk about the custom people.
end

function Input.Down()
	return love.keyboard.isScancodeDown("s")
end

function Input.Left()
	return love.keyboard.isScancodeDown("a")
end

function Input.Right()
	return love.keyboard.isScancodeDown("d")
end

function Input.Mouse1()
	return love.mouse.isDown(1)
end

function Input.Mouse2()
	return love.mouse.isDown(2)
end

function Input.MousePos()
	return Vector2.new(love.mouse.getX(), love.mouse.getY())
end

return Input