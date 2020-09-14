-- Images
-- Logos
UnexpectedJamLogo = love.graphics.newImage("rsrc/logo/uj.png")
TheDevTeamBG = love.graphics.newImage("rsrc/logo/devteam/background.png")
TheDevTeamText = love.graphics.newImage("rsrc/logo/devteam/text.png")
TheDevTeamHue = love.graphics.newImage("rsrc/logo/devteam/huegarbage.png")

-- Buttons
ButtonFrame = love.graphics.newImage("rsrc/ui/button/buttonframe.png")
ButtonInnerFrame = love.graphics.newImage("rsrc/ui/button/buttonmiddle.png")
ButtonCenter = love.graphics.newImage("rsrc/ui/button/buttoncenter.png")

ButtonFrame:setFilter("nearest", "nearest")
ButtonInnerFrame:setFilter("nearest", "nearest")
ButtonCenter:setFilter("nearest", "nearest")

-- Sounds
UIMouseBeep = MultiSource.For("rsrc/sound/fx/ui/uiMouseBeep.ogg")
UIMouseBeepHigh = MultiSource.For("rsrc/sound/fx/ui/uiMouseBeepHigh.ogg")

--LongExplosion1Sounds = VariantSource.For("rsrc/sound/fx/explosion/Explosion1-", 5, ".ogg")
--LongExplosion2Sounds = VariantSource.For("rsrc/sound/fx/explosion/Explosion2-", 8, ".ogg")

-- Fonts
TerminalVector = FontLoader.For("rsrc/font/TerminalVector.ttf")
TerminalVector.FilterSettings.Minify = "nearest"
TerminalVector.FilterSettings.Magnify = "nearest"
PixelFont = love.graphics.newImageFont("rsrc/font/LOVE2D-Resource-Imagefont.png", " abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789.,!?-+/():;%&`'*#=[]\"")

-- Code dependent on assets.
MainMenu = require("scrsequence/mainmenu/MainMenu")
GameIntro = require("scrsequence/gameintro/GameIntro")