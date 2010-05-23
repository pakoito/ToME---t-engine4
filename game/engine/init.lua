-- TE4 - T-Engine 4
-- Copyright (C) 2009, 2010 Nicolas Casalini
--
-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with this program.  If not, see <http://www.gnu.org/licenses/>.
--
-- Nicolas Casalini "DarkGod"
-- darkgod@te4.org

-- load some utility functions
dofile("/engine/utils.lua")
dofile("/engine/colors.lua")

-- load resolver functions for entities cloning
dofile("/engine/resolvers.lua")

require "config"
require "engine.Game"
require "engine.interface.GameMusic"
require "engine.KeyBind"
require "engine.Savefile"
require "engine.Tiles"
require "engine.PlayerProfile"
engine.Tiles.prefix = "/data/gfx/"

-- Engine Version
engine.version = {1,0,0}

-- Setup the user directory
engine.homepath = fs.getUserPath()..fs.getPathSeparator()..fs.getHomePath()..fs.getPathSeparator().."4.0"
fs.setWritePath(fs.getUserPath())
fs.mkdir(fs.getHomePath())
fs.mkdir(fs.getHomePath().."/4.0/")
fs.mkdir(fs.getHomePath().."/4.0/profiles/")
fs.mkdir(fs.getHomePath().."/4.0/settings/")
fs.setWritePath(fs.getHomePath())

-- Loads default config & user config
fs.mount(engine.homepath, "/")
config.loadString[[
window.size = "800x600"
sound.enabled = true
]]
for i, file in ipairs(fs.list("/settings/")) do
	if file:find(".cfg$") then
		config.load("/settings/"..file)
	end
end

-- Load default keys
engine.KeyBind:load("move,actions")

-- Load remaps
if fs.exists("/keybinds.cfg") then
	engine.KeyBind:loadRemap("/keybinds.cfg")
end

fs.umount(engine.homepath)

-- Setup a default key handler
local key = engine.KeyBind.new()
key:setCurrent()

-- Load the game module
game = false

engine.Game:setResolution(config.settings.window.size)
engine.interface.GameMusic:soundSystemStatus(config.settings.sound.enabled, true)

-- Load profile configs
profile = engine.PlayerProfile.new()

util.showMainMenu(true)
