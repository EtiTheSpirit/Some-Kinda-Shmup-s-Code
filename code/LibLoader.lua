-- So that I avoid clutter in main.lua, this requires everything.

-- Inject globals.
require("code/Globals")
FileInfo = require("code/Util/FileInfo")

local EnumRegistry = require("code/XCore/Enumeration/Enum")
EnumRegistry.Register("MovementDirection", {"Up", "Down", "Left", "Right"})
EnumRegistry.Register("MouseButton", {["Left"] = 1, ["Right"] = 2})
EnumRegistry.Register("TileType", {"Base", "Side", "Wedge", "BorderLeft", "BorderRight", "BorderTop", "BorderBottom", "BorderTopLeft", "BorderTopRight", "BorderBottomLeft", "BorderBottomRight"})

MultiSource = require("code/Audio/MultiSource")
VariantSource = require("code/Audio/VariantSource") -- MUST be after MultiSource since this depends on it.
Vector2 = require("code/XCore/Vector/Vector2")
Signal = require("code/XCore/EventSystem/Signal") -- Signal requires EventConnection which is internal.
StaticPlayerInput = require("code/XCore/StaticPlayerInput")
LoveEventMarshaller = require("code/XCore/LoveEventMarshaller")

FontLoader = require("code/FontLoader")
Button = require("code/Interface/Button")

TilesetMarshaller = require("code/World/TilesetMarshaller")
DebugTileset = TilesetMarshaller.new("rsrc/tile/debug.png")

CoreGameplay = require("code/CoreGameplay")