local GameIntro = {}

local OnUpdateCon
local OnDrawCon
local SpaceSkipCon
local CurrentTime = 0
local FadeValue = 0
local OtherFadeValue = 0
local SPEEN = 0

local function Update(delta)
	CurrentTime = CurrentTime + delta
	SPEEN = SPEEN + delta * 8
	if CurrentTime >= 10 then
		GameIntro:Uninit()
	end
end

local function Draw()
	if CurrentTime < 5 then
		if CurrentTime < 1 then
			-- Fade in
			FadeValue = CurrentTime
		elseif CurrentTime > 4 then
			-- Fade out
			FadeValue = 5 - CurrentTime
		else
			FadeValue = 1
		end
		love.graphics.setColor(1, 1, 1, FadeValue)
		love.graphics.draw(TheDevTeamHue, 400, 300, SPEEN, 1.5, 1.5, 400, 300)
		love.graphics.setColor(1, 1, 1, 1)
		
		love.graphics.draw(TheDevTeamBG)
		love.graphics.draw(TheDevTeamText)
		
	elseif CurrentTime < 10 then
		if CurrentTime < 6 then
			-- Fade in
			FadeValue = CurrentTime - 5
		elseif CurrentTime > 9 then
			-- Fade out
			FadeValue = 10 - CurrentTime
		else
			FadeValue = 1
		end
		love.graphics.setColor(1, 1, 1, FadeValue)
		love.graphics.draw(UnexpectedJamLogo)
		TerminalVector:SetFont(36)
		love.graphics.print("For the...", 24, 48)
		
		if CurrentTime > 6 and CurrentTime < 8 then
			OtherFadeValue = math.sin((CurrentTime - 6) * math.pi / 2) -- wat
			TerminalVector:SetFont(14)
			love.graphics.setColor(0.2, 0.2, 0.2, OtherFadeValue)
			love.graphics.printf("Overused(?) Spanish Inquisition Joke Here", 0, 550, 800, "center")
		end
	end
	love.graphics.setColor(1, 1, 1, 0.5)
	TerminalVector:SetFont(12)
	love.graphics.print("Space to skip", 2, 600 - 14)
end

function GameIntro:Init()
	CurrentTime = 0
	FadeValue = 0
	OtherFadeValue = 0
	SPEEN = 0
	OnUpdateCon = LoveEventMarshaller.OnUpdate:Connect(Update)
	OnDrawCon = LoveEventMarshaller.OnDraw:Connect(Draw)
	SpaceSkipCon = LoveEventMarshaller.GUIKeyPressed:Connect(function (key)
		if key == "space" then
			self:Uninit()
		end
	end)
end

function GameIntro:Uninit()
	OnUpdateCon:Disconnect()
	OnDrawCon:Disconnect()
	SpaceSkipCon:Disconnect()
	MainMenu:Init()
end

return GameIntro