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

	self.__savefile_version_tokens = {}

	self.__threads = {}
end

function _M:loaded()
	self.w, self.h = core.display.size()
	self.dialogs = {}
	self.key = engine.Key.current
	self.mouse = engine.Mouse.new()
	self.mouse:setCurrent()

	self.__threads = self.__threads or {}
	self.__coroutines = self.__coroutines or {}
end

--- Defines the default fields to be saved by the savefile code
function _M:defaultSavedFields(t)
	local def = {
		w=true, h=true, zone=true, player=true, level=true, entities=true,
		energy_to_act=true, energy_per_tick=true, turn=true, paused=true, save_name=true,
		always_target=true, gfxmode=true, uniques=true, object_known_types=true,
		current_music=true, memory_levels=true, achievement_data=true, factions=true,
		__savefile_version_tokens = true,
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

--- Gets/increment the savefile version
-- @param token if "new" this will create a new allowed save token and return it. Otherwise this checks the token against the allowed ones and returns true if it is allowed
function _M:saveVersion(token)
	if token == "new" then
		token = util.uuid()
		self.__savefile_version_tokens[token] = true
		return token
	end
	return self.__savefile_version_tokens[token]
end

--- This is the "main game loop", do something here
function _M:tick()
	local stop = {}
	local id, co = next(self.__coroutines)
	while id do
		local ok, err = coroutine.resume(co)
		if not ok then
			print(debug.traceback(co))
			print("[COROUTINE] error", err)
		end
		if coroutine.status(co) == "dead" then
			stop[#stop+1] = id
		end
		id, co = next(self.__coroutines, id)
	end
	if #stop > 0 then
		for i = 1, #stop do
			self.__coroutines[stop[i]] = nil
			print("[COROUTINE] dead", stop[i])
		end
	end
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
	if d.key then d.key:setCurrent() end
	if d.mouse then d.mouse:setCurrent() end
	if d.on_register then d:on_register() end
end

--- Undisplay a dialog, removing its own keyhandler if needed
function _M:unregisterDialog(d)
	if not self.dialogs[d] then return end
	table.remove(self.dialogs, self.dialogs[d])
	self.dialogs[d] = nil
	d:unload()
	-- Update positions
	for i, id in ipairs(self.dialogs) do self.dialogs[id] = i end

	local last = self.dialogs[#self.dialogs] or self
	if last.key then last.key:setCurrent() end
	if last.mouse then last.mouse:setCurrent() end
	if last.on_recover_focus then last:on_recover_focus() end
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
	if f then
		f:write(data)
		f:close()
	else
		print("WARNING: could not save settings in ", file, "::", data)
	end
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
	self.w, self.h = core.display.size()
end

--- Requests the game to save
function _M:saveGame()
end

--- Add a coroutine to the pool
-- Coroutines registered will be run each game tick
function _M:registerCoroutine(id, co)
	print("[COROUTINE] registering", id, co)
	self.__coroutines[id] = co
end

--- Get the coroutine corresponding to the id
function _M:getCoroutine(id)
	return self.__coroutines[id]
end

--- Ask a registered coroutine to cancel
-- The coroutine must accept a "cancel" action
function _M:cancelCoroutine(id)
	local co = self.__coroutines[id]
	if not co then return end
	local ok, err = coroutine.resume(co, "cancel")
	if not ok then
		print(debug.traceback(co))
		print("[COROUTINE] error", err)
	end
	if coroutine.status(co) == "dead" then
		self.__coroutines[id] = nil
	else
		error("Told coroutine "..id.." to cancel, but it is not dead!")
	end
end

--- Save a thread into the thread pool
-- Threads will be auto join'ed when the module exits or when it can<br/>
-- ALL THREADS registered *MUST* return true when they exit
function _M:registerThread(th, linda)
	print("[THREAD] registering", th, linda, #self.__threads+1)
	self.__threads[#self.__threads+1] = {th=th, linda=linda}
	return #self.__threads
end

--- Try to join all registered threads
-- @param timeout the time in seconds to wait for each thread
function _M:joinThreads(timeout)
	for i = #self.__threads, 1, -1 do
		local th = self.__threads[i].th
		print("[THREAD] Thread join", i, th)
		local v, err = th:join(timeout)
		if err then print("[THREAD] error", th) error(err) end
		if v then
			print("[THREAD] Thread result", i, th, "=>", v)
			table.remove(self.__threads, i)
		end
	end
end
