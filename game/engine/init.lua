--[[ Allows for remote debugging, but it makes things *SLOW*
require"remdebug.engine"
remdebug.engine.start()
]]

-- load some utility functions
dofile("/engine/utils.lua")

require "engine.KeyCommand"
require "engine.Tiles"

-- Setup a default key handler
local key = engine.KeyCommand.new()
key:setCurrent()

-- Exit the game, this is brutal for now
key:addCommand(key._x, {"ctrl"}, function() os.exit() end)
-- Fullscreen toggle
key:addCommand(key._RETURN, {"alt"}, function() core.display.fullscreen() end)

-- Load the game module
game = false
local mod_def = loadfile("/mod/init.lua")
if mod_def then
	local mod = {}
	setfenv(mod_def, mod)
	mod_def()

	if not mod.name or not mod.short_name or not mod.version or not mod.starter then os.exit() end

	engine.Tiles.prefix = "/data/gfx/"
	game = dofile("/"..mod.starter:gsub("%.", "/")..".lua")
	game:run()
else
	os.exit()
end
