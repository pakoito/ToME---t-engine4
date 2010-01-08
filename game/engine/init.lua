-- load some utility functions
dofile("/engine/utils.lua")
dofile("/engine/colors.lua")

-- load resolver functions for entities cloning
dofile("/engine/resolvers.lua")

require "config"
require "engine.Game"
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

-- Loads default config & user config
fs.mount(engine.homepath, "/")
config.loadString[[
keyboard.locale = "en_US"
window.size = "1024x768"
]]
config.load("/settings.cfg")
fs.umount(engine.homepath)

-- Setup a default key handler
local key = engine.KeyCommand.new()
key:setCurrent()

-- Load the game module
game = false

engine.Game:setResolution(config.settings.window.size)

util.showMainMenu()
