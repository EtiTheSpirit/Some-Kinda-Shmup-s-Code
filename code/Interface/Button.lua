local Button = {}
Button.__index = Button
Button.__type = "Button"

-- Some stock behavior
DRAW_FRAMED_BUTTON = function (self)
	local fWidth = ButtonFrame:getWidth()
	local fHeight = ButtonFrame:getHeight()
	local scaleX = self.Size.X / fWidth
	local scaleY = self.Size.Y / fHeight
	
	local add = self.UserData.AddOnHover or 0.05
	local border = self.UserData.BorderColor or {1, 1, 1, 1}
	local innerFrame = self.UserData.InnerColor or {1, 1, 1, 1}
	local center = self.UserData.CenterColor or {1, 1, 1, 1}
	local textColor = self.UserData.TextColor or {0, 0, 0, 1}
	
	local r,g,b,a = unpack(border)
	if self.IsMouseInside then
		r = r + add
		g = g + add
		b = b + add
	end
	love.graphics.setColor(r,g,b,a)
	love.graphics.draw(ButtonFrame, self.Position.X, self.Position.Y, 0, scaleX, scaleY)
	
	local r,g,b,a = unpack(innerFrame)
	if self.IsMouseInside then
		r = r + add
		g = g + add
		b = b + add
	end
	love.graphics.setColor(r,g,b,a)
	love.graphics.draw(ButtonInnerFrame, self.Position.X, self.Position.Y, 0, scaleX, scaleY)
	
	local r,g,b,a = unpack(center)
	if self.IsMouseInside then
		r = r + add
		g = g + add
		b = b + add
	end
	love.graphics.setColor(r,g,b,a)
	love.graphics.draw(ButtonCenter, self.Position.X, self.Position.Y, 0, scaleX, scaleY)
	
	local r,g,b,a = unpack(textColor)
	love.graphics.setColor(r,g,b,a)
	love.graphics.setFont(self.UserData.Font or TerminalVector:Get(14))
	-- + self.Size.X / 2
	-- + self.Size.Y / 2
	-- Don't add to X because center alignment does that already
	love.graphics.printf(self.UserData.Text or "", self.Position.X, self.Position.Y + self.Size.Y / 2 - (love.graphics.getFont():getHeight() / 2), self.Size.X, "center")
end

function Button.new()
	local button = {
		Position = Vector2.new(),
		Size = Vector2.new(),
		Active = true,
		DrawCallback = NULL_FUNC,
		
		IsMouseInside = false,
		MouseWentDownInside = false,
		MouseDown = Signal.new(),
		MouseUp = Signal.new(),
		MouseClick = Signal.new(),
		
		MouseEnter = Signal.new(),
		MouseLeave = Signal.new(),
		
		UserData = {},
		Internal = {}
	}
	
	button.Internal.MouseMoved = LoveEventMarshaller.GUIMouseMoved:Connect(function (position, delta)
		local isCurrentlyInside = false
		if	position.X >= button.Position.X and position.X <= button.Position.X + button.Size.X and
			position.Y >= button.Position.Y and position.Y <= button.Position.Y + button.Size.Y then
			-- Mouse is inside of the box.
			isCurrentlyInside = true
		end
		
		if button.IsMouseInside ~= isCurrentlyInside then
			-- State changed. This also means the GUI element caught the event, so we need to return true from this callback to tell the event marshaller that it should cancel.
			if isCurrentlyInside then
				button.MouseEnter:FireSynchronouslyNoCancel()
			else
				button.MouseLeave:FireSynchronouslyNoCancel()
			end
			button.IsMouseInside = isCurrentlyInside
			return true
		end
	end)
	
	button.Internal.MouseDown = LoveEventMarshaller.GUIMousePressed:Connect(function (mouseButton, position)
		-- Button doesn't matter. I just want any click.
		if	position.X >= button.Position.X and position.X <= button.Position.X + button.Size.X and
			position.Y >= button.Position.Y and position.Y <= button.Position.Y + button.Size.Y then
			-- Mouse is inside of the box.
			button.MouseDown:FireSynchronouslyNoCancel(button)
			button.MouseWentDownInside = true
			return true
		end
	end)
	
	button.Internal.MouseUp = LoveEventMarshaller.GUIMouseReleased:Connect(function (mouseButton, position)
		-- Button doesn't matter. I just want any click.
		if	position.X >= button.Position.X and position.X <= button.Position.X + button.Size.X and
			position.Y >= button.Position.Y and position.Y <= button.Position.Y + button.Size.Y then
			-- Mouse is inside of the box.
			button.MouseUp:FireSynchronouslyNoCancel(button)
			if button.MouseWentDownInside then
				-- This counts as a full click too
				button.MouseClick:FireSynchronouslyNoCancel(button)
			end
			button.MouseWentDownInside = false
			return true
		end
	end)
	
	button.Internal.Draw = LoveEventMarshaller.OnDraw:Connect(function ()
		button:DrawCallback() -- Using : is VERY IMPORTANT here because it passes in a reference to the button.
	end)
	
	return setmetatable(button, Button)
end

function Button:Destroy()
	assert(getmetatable(self) == Button, ERR_STATIC_CALL:format("Destroy", "Button.new()"))
	DisposeObject(self)
end

return Button