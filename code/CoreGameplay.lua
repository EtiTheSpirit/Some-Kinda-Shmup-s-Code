-- big ol gameplay controller

local CoreGameplay = {}

local function Update(delta)
	
end

local function Draw()
	love.graphics.setColor(1, 1, 1, 1)
	TerminalVector:SetFont(28)
	love.graphics.printf("Title Card :O", 0, 100, 800, "center")
end

function CoreGameplay:Init()
	
end

function CoreGameplay:Uninit()
	
end

return CoreGameplay