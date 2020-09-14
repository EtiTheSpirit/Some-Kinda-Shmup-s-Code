-- Controls the distribution of Love events via the event system.

local EventMarshaller = {
	-- ASYNC. Fires when Update is called. This is where movement and other individual update code should run.
	OnUpdate = Signal.new(),
	
	-- ASYNC. Fires after OnUpdate fires. This is where comparisons to the positions or other dynamic data of other objects should be compared (because it ensures everything got a chance to update first)
	AfterUpdate = Signal.new(),
	
	-- Fires when love says to draw things.
	-- NOTE: This method is synchronous! Do not yield or perform excessively expensive operations in event handlers as they will delay future calls.
	OnDraw = Signal.new(),
	
	-- Fires when a movement key (wasd) is pressed. Arguments: Enum movementDirection
	-- Any callback can return true to cancel other handlers from running.
	MovementPressed = Signal.new(),
	
	-- Fires when a movement key (wasd) is released. Arguments: Enum movementDirection
	-- Any callback can return true to cancel other handlers from running.
	MovementReleased = Signal.new(),
	
	-- These are identical to their non-GUI variants but they fire before those, and if one of these cancels, then the stock events won't fire.
	GUIKeyPressed = Signal.new(),
	GUIKeyReleased = Signal.new(),
	GUIMousePressed = Signal.new(),
	GUIMouseReleased = Signal.new(),
	GUIMouseMoved = Signal.new(),
	
	-- Fires when any key is pressed, including movement keys. Arguments: ScanCode key (ScanCode is the key on a stock American keyboard layout *no matter what*)
	-- Any callback can return true to cancel other handlers from running.
	KeyPressed = Signal.new(),
	
	-- Fires when any key is released, including movement keys. Arguments: ScanCode key (ScanCode is the key on a stock American keyboard layout *no matter what*)
	-- Any callback can return true to cancel other handlers from running.
	KeyReleased = Signal.new(),
	
	-- Fires when the mouse is clicked. Arguments: Enum mouseButton, Vector2 atPos
	-- Any callback can return true to cancel other handlers from running.
	MousePressed = Signal.new(),
	
	-- Fires when the mouse is released. Arguments: Enum mouseButton, Vector2 atPos
	-- Any callback can return true to cancel other handlers from running.
	MouseReleased = Signal.new(),
	
	-- Fires when the mouse is moved. Arguments: Vector2 newPos, Vector2 delta
	-- Any callback can return true to cancel other handlers from running.
	MouseMoved = Signal.new()
}

EventMarshallerUpdate = function (delta)
	-- Fire this one synchronously, and don't allow it to cancel.
	EventMarshaller.OnUpdate:FireSynchronouslyNoCancel(delta)
	EventMarshaller.AfterUpdate:Fire(delta)
end

EventMarshallerDraw = function ()
	-- EventMarshaller.OnDraw:FireSynchronouslyNoCancel()
	-- Need to manually fire this one due to unique behavior.
	local connections = EventMarshaller.OnDraw.Connections
	for index = 1, #connections do
		local connection = connections[index]
		if connection ~= nil and connection.Delegate ~= nil then
			-- Reset the color before every unique draw call.
			love.graphics.setColor(1, 1, 1, 1)
			connection.Delegate()
		end
	end
end

function love.keypressed(_, scancode)
	EventMarshaller.GUIKeyPressed:FireSynchronously(scancode)
	if EventMarshaller.GUIKeyPressed.Canceled then return end

	local targetMotionEvent = EventMarshaller.MovementPressed
	EventMarshaller.KeyPressed:FireSynchronously(scancode)
	if scancode == "w" then
		targetMotionEvent:FireSynchronously(Enum.MovementDirection.Up)
	elseif scancode == "a" then
		targetMotionEvent:FireSynchronously(Enum.MovementDirection.Left)
	elseif scancode == "s" then
		targetMotionEvent:FireSynchronously(Enum.MovementDirection.Down)
	elseif scancode == "d" then
		targetMotionEvent:FireSynchronously(Enum.MovementDirection.Right)
	end
end

function love.keyreleased(_, scancode)
	EventMarshaller.GUIKeyReleased:FireSynchronously(scancode)
	if EventMarshaller.GUIKeyReleased.Canceled then return end

	local targetMotionEvent = EventMarshaller.MovementReleased
	EventMarshaller.KeyReleased:FireSynchronously(scancode)
	if scancode == "w" then
		targetMotionEvent:FireSynchronously(Enum.MovementDirection.Up)
	elseif scancode == "a" then
		targetMotionEvent:FireSynchronously(Enum.MovementDirection.Left)
	elseif scancode == "s" then
		targetMotionEvent:FireSynchronously(Enum.MovementDirection.Down)
	elseif scancode == "d" then
		targetMotionEvent:FireSynchronously(Enum.MovementDirection.Right)
	end
end

function love.mousepressed(x, y, button)
	EventMarshaller.GUIMousePressed:FireSynchronously(button, Vector2.new(x, y))
	if EventMarshaller.GUIMousePressed.Canceled then return end

	EventMarshaller.MousePressed:FireSynchronously(button, Vector2.new(x, y))
end

function love.mousereleased(x, y, button)
	EventMarshaller.GUIMouseReleased:FireSynchronously(button, Vector2.new(x, y))
	if EventMarshaller.GUIMouseReleased.Canceled then return end
	
	EventMarshaller.MouseReleased:FireSynchronously(button, Vector2.new(x, y))
end

function love.mousemoved(x, y, dx, dy)
	EventMarshaller.GUIMouseMoved:FireSynchronously(Vector2.new(x, y), Vector2.new(dx, dy))
	if EventMarshaller.GUIMouseMoved.Canceled then return end

	EventMarshaller.MouseMoved:FireSynchronously(Vector2.new(x, y), Vector2.new(dx, dy))
end

local EvtRO, _ = AsReadOnly(EventMarshaller)
return EvtRO