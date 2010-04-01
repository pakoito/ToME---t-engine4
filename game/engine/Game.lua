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

require "engine.class"
require "engine.Mouse"
require "engine.DebugConsole"

--- Represent a game
-- A module should subclass it and initialize anything it needs to play inside
module(..., package.seeall, class.make)

--- Constructor
-- Sets up the default keyhandler.
-- Also requests the display size and stores it in "w" and "h" properties
function _M:init(keyhandler)
	self.key = keyhandler
	self.level = nil
	self.log = function() end
	self.logSeen = function() end
	self.w, self.h = core.display.size()
	self.dialogs = {}
	self.save_name = "player"
	self.player_name = "player"

	self.mouse = engine.Mouse.new()
	self.mouse:setCurrent()

	self.uniques = {}
end

function _M:loaded()
	self.w, self.h = core.display.size()
	self.dialogs = {}
	self.key = engine.Key.current
	self.mouse = engine.Mouse.new()
	self.mouse:setCurrent()
end

--- Defines the default fields to be saved by the savefile code
function _M:defaultSavedFields(t)
	local def = {
		w=true, h=true, zone=true, player=true, level=true, entities=true,
		energy_to_act=true, energy_per_tick=true, turn=true, paused=true, save_name=true,
		always_target=true, gfxmode=true, uniques=true, object_known_types=true,
		current_music=true, memory_levels=true,
	}
	table.merge(def, t)
	return def
end

--- Sets the player name
function _M:setPlayerName(name)
	self.save_name = name
	self.player_name = name
end

--- Starts the game
-- Modules should reimplement it to do whatever their game needs
function _M:run()
end

--- Sets the current level
-- @param level an engine.Level (or subclass) object
function _M:setLevel(level)
	self.level = level
end

--- Tells the game engine to play this game
function _M:setCurrent()
	core.game.set_current_game(self)
	_M.current = self
end

--- Displays the screen
-- Called by the engine core to redraw the screen every frame
function _M:display()
	for i, d in ipairs(self.dialogs) do
		d:display()
		d:toScreen(d.display_x, d.display_y)
	end

	if self.flyers then
		self.flyers:display()
	end
end

--- Returns the player
-- Reimplement it in your module, this can just return nil if you dont want/need
-- the engine adjusting stuff to the player or if you have many players or whatever
function _M:getPlayer()
	return nil
end

--- This is the "main game loop", do something here
function _M:tick()
end

--- Called when a zone leaves a level
-- Going from "old_lev" to "lev", leaving level "level"
function _M:leaveLevel(level, lev, old_lev)
end

--- Called by the engine when the user tries to close the window
function _M:onQuit()
end

--- Sets up a text flyers
function _M:setFlyingText(fl)
	self.flyers = fl
end

--- Registers a dialog to display
function _M:registerDialog(d)
	table.insert(self.dialogs, d)
	self.dialogs[d] = #self.dialogs
end

--- Undisplay a dialog, removing its own keyhandler if needed
function _M:unregisterDialog(d)
	if not self.dialogs[d] then return end
	table.remove(self.dialogs, self.dialogs[d])
	self.dialogs[d] = nil
	d:unload()
end

--- The C core gives us command line arguments
function _M:commandLineArgs(args)
	for i, a in ipairs(args) do
		print("Command line: ", a)
	end
end

--- Called by savefile code to describe the current game
function _M:getSaveDescription()
	return {
		name = "player",
		description = [[Busy adventuring!]],
	}
end

--- Save a settings file
function _M:saveSettings(file, data)
	local restore = fs.getWritePath()
	fs.setWritePath(engine.homepath)
	local f = fs.open("/settings/"..file..".cfg", "w")
	f:write(data)
	f:close()
	if restore then fs.setWritePath(restore) end
end

available_resolutions =
{
	["800x600"] = {800, 600, false},
	["1024x768"] = {1024, 768, false},
	["1200x1024"] = {1200, 1024, false},
	["1600x1200"] = {1600, 1200, false},
	["800x600 Fullscreen"] = {800, 600, true},
	["1024x768 Fullscreen"] = {1024, 768, true},
	["1200x1024 Fullscreen"] = {1200, 1024, true},
	["1600x1200 Fullscreen"] = {1600, 1200, true},
}
--- Change screen resolution
function _M:setResolution(res)
	if not available_resolutions[res] then return false, "unknown resolution" end

	local old_w, old_h = self.w, self.h
	core.display.setWindowSize(available_resolutions[res][1], available_resolutions[res][2], available_resolutions[res][3])
	self.w, self.h = core.display.size()

	if self.w ~= old_w or self.h ~= old_h then
		self:onResolutionChange()

		self:saveSettings("resolution", ("window.size = %q\n"):format(res))
	end
end

--- Called when screen resolution changes
function _M:onResolutionChange()
end

--- Requests the game to save
function _M:saveGame()
end
