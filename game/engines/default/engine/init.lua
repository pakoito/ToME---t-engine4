-- TE4 - T-Engine 4
-- Copyright (C) 2009, 2010, 2011, 2012, 2013 Nicolas Casalini
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
require "engine.version"
require "engine.interface.GameMusic"
require "engine.KeyBind"
require "engine.Savefile"
require "engine.SavefilePipe"
require "engine.Tiles"
require "engine.PlayerProfile"
engine.Tiles.prefix = "/data/gfx/"

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
audio.music_volume = 60
audio.effects_volume = 100
audio.enable = true
aa_text = true
fbo_active = true
shaders_active = true
shaders_kind_distort = true
shaders_kind_adv = true
shaders_kind_volumetric = false
particles_density = 100
background_saves = true
mouse_cursor = true
display_fps = 30
gamma_correction = 120
mouse_move = true
censor_boot = true
chat.filter = {}
chat.ignores = {}
addons = {}
upgrades { v1_0_5=true }
]]
for i, file in ipairs(fs.list("/settings/")) do
	if file:find(".cfg$") then
		config.load("/settings/"..file)
	end
end

if core.display.safeMode() then
	config.settings.aa_text = false
	config.settings.fbo_active = false
	config.settings.shaders_active = false
	config.settings.particles_density = 5
	config.settings.background_saves = false
	config.settings.mouse_cursor = false
	config.settings.display_fps = 10
	config.settings.window = {size='800x600 Windowed'}
end

-- Default resolution as big as possible
if not config.settings.window or not config.settings.window.size then
	local list = core.display.getModesList()
	table.sort(list, function(a, b) return a.w > b.w end)
	local r = list[1] or {w=800, h=600}
	print("[RESOLUTION] no configured resolution, defaulting to biggest possible: ", r.w, r.h)
	config.settings.window = config.settings.window or {}
	--local x, y = math.max(800, math.floor(r.w * 0.75)), math.max(600, math.floor(r.h*0.75))
	local x, y = r.w, r.h
	config.settings.window.size = x.."x"..y.." Fullscreen"
end

-- Move around
if config.settings.window.pos then
--	core.display.setWindowPos(config.settings.window.pos.x, config.settings.window.pos.y)
end

-- Audio
core.sound.enable(config.settings.audio.enable)

-- Load default keys
engine.KeyBind:load("move,hotkeys,inventory,actions,interface,debug")

-- Load remaps
if fs.exists("/keybinds2.cfg") then
	engine.KeyBind:loadRemap("/keybinds2.cfg")
end

fs.umount(engine.homepath)

-- Setup a default key handler
local key = engine.KeyBind.new()
key:setCurrent()

-- Load the game module
game = false

-- Setup resolution
engine.Game:setResolution(config.settings.window.size, true)
core.display.setTextBlended(config.settings.aa_text)
core.display.setGamma(config.settings.gamma_correction / 100)
if not config.settings.fbo_active then core.display.disableFBO() print("Disabling FBO") end
if not config.settings.shaders_active then core.shader.disable() print("Disabling Shaders") end

-- Load profile configs
core.profile.createThread()
profile = engine.PlayerProfile.new()
profile:start()

-- Create a savefile pipe
savefile_pipe = engine.SavefilePipe.new()

-- Setup FPS
core.game.setFPS(config.settings.display_fps)

util.showMainMenu(true)
