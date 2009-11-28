--[[ Allows for remote debugging, but it makes things *SLOW*
require"remdebug.engine"
remdebug.engine.start()
]]

-- load some utility functions
dofile("/engine/utils.lua")

require "engine.KeyCommand"
require "engine.Savefile"
require "engine.Tiles"
engine.Tiles.prefix = "/data/gfx/"

-- Setup a default key handler
local key = engine.KeyCommand.new()
key:setCurrent()

-- Load the game module
game = false

local Menu = require("special.mainmenu.class.Game")
game = Menu.new()
game:run()
