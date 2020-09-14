local OldMainMenu = {}

local OnUpdateCon
local OnDrawCon
local Buttons = {
	Begin = nil,
	Options = nil,
	Exit = nil
}

local function Update(delta)
	
end

local function Draw()
	love.graphics.setColor(1, 1, 1, 1)
	TerminalVector:SetFont(28)
	love.graphics.printf("Title Card :O", 0, 100, 800, "center")
end

function OldMainMenu:Init()
	Buttons.Begin = Button.new()
	Buttons.Begin.DrawCallback = DRAW_FRAMED_BUTTON
	Buttons.Begin.UserData.AddOnHover = 0.1
	Buttons.Begin.UserData.BorderColor = {0, 0, 0, 1}
	Buttons.Begin.UserData.InnerColor = {RGBToFloat(0x54, 0x8E, 0x89)}
	Buttons.Begin.UserData.CenterColor = {RGBToFloat(0x0A, 0xA7, 0x4E)}
	Buttons.Begin.UserData.TextColor = {0, 0, 0, 1}
	Buttons.Begin.UserData.Font = FontLoader:Get(16)
	Buttons.Begin.UserData.Text = "Proto Button 1"
	Buttons.Begin.Position = Vector2.new(400 - (32 * PIXEL_SCALE / 2), 300)
	Buttons.Begin.Size = Vector2.new(32 * PIXEL_SCALE, 7 * PIXEL_SCALE)
	Buttons.Begin.MouseEnter:Connect(function ()
		UIMouseBeep:Play()
	end)
	Buttons.Begin.MouseClick:Connect(function ()
		UIMouseBeepHigh:Play()
		CoreGameplay:Init()
		MainMenu:Uninit()
	end)
	
	Buttons.Controls = Button.new()
	Buttons.Controls.DrawCallback = DRAW_FRAMED_BUTTON
	Buttons.Controls.UserData.AddOnHover = 0.1
	Buttons.Controls.UserData.BorderColor = {0, 0, 0, 1}
	Buttons.Controls.UserData.InnerColor = {RGBToFloat(0x54, 0x8E, 0x89)}
	Buttons.Controls.UserData.CenterColor = {RGBToFloat(0xBC, 0xB2, 0xCE)}
	Buttons.Controls.UserData.TextColor = {0, 0, 0, 1}
	Buttons.Controls.UserData.Font = FontLoader:Get(16)
	Buttons.Controls.UserData.Text = "Proto Button 2"
	Buttons.Controls.Position = Vector2.new(400 - (32 * PIXEL_SCALE / 2), 370)
	Buttons.Controls.Size = Vector2.new(32 * PIXEL_SCALE, 7 * PIXEL_SCALE)
	Buttons.Controls.MouseEnter:Connect(function ()
		UIMouseBeep:Play()
	end)
	Buttons.Controls.MouseClick:Connect(function ()
		UIMouseBeepHigh:Play()
	end)
	
	OnDrawCon = LoveEventMarshaller.OnDraw:Connect(Draw)
end

function OldMainMenu:Uninit()
	Buttons.Begin:Destroy()
	Buttons.Controls:Destroy()
	OnDrawCon:Disconnect()
end

return OldMainMenu