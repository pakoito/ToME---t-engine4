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

-- Setup the user directory
engine.homepath = fs.getUserPath()..fs.getPathSeparator()..fs.getHomePath()..fs.getPathSeparator().."4.0"
fs.setWritePath(fs.getUserPath())
fs.mkdir(fs.getHomePath())
fs.mkdir(fs.getHomePath().."/4.0/")
fs.setWritePath(fs.getHomePath())

-- Setup a default key handler
local key = engine.KeyCommand.new()
key:setCurrent()

-- Load the game module
game = false

local Menu = require("special.mainmenu.class.Game")
game = Menu.new()
game:run()
