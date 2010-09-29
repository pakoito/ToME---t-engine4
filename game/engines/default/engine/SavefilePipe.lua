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
local Dialog = require "engine.Dialog"

--- Savefile code
-- Creates a savefile pipe, savefiles requests can be pushed into it, it will execute them
-- in order and, as much as possible, as a background process, thus not preventing the game from running.<br/>
-- There can only be one pipe! DO NOT TRY TO MAKE MORE
module(..., package.seeall, class.make)

_M.current = nil

--- Init a savefile pipe
-- @param class the name of the Savefile class to use. Defaults to engine.Savefile
-- @param max_before_wait Number of saves allowed in the pipe before the game pauses to do the saves (this is to prevent pushing too many saves and making it very very long)
function _M:init(class, max_before_wait)
	assert(not _M.current, "Tried to create more than one savefile pipe!")
	_M.current = self

	self.saveclass = class or "engine.Savefile"
	self.pipe = {}
	self.max_before_wait = max_before_wait or 3
	self.co = nil
end

--- Push a savefile request
-- @param savename the name of the savefile to handle
-- @param type the Savefile method to use. I.e: "game", "level", "zone". This will cann the Savefile:saveGame, Savefile:saveLevel, Savefile:saveZone methods
-- @param object the object to save
-- @param class a class name, if different from the default one
function _M:push(savename, type, object, class)
	class = class or self.saveclass
	local Savefile = require(class)
	local id = Savefile["nameSave"..type:lower():capitalize()](Savefile, object)

	self.pipe[#self.pipe+1] = {id=id, savename = savename, type=type, object=object:cloneFull(), baseobject=object, class=class, saveversion=game:saveVersion("new")}
	if not self.co or coroutine.status(self.co) == "dead" then
		self.co = coroutine.create(function() return self:doThread() end)
		game:registerCoroutine("savefilepipe", self.co)
	end

	-- Refuse to continue, make the user wait
	if #self.pipe >= self.max_before_wait then
		self:forceWait()
	end
end

--- Actually do the saves
-- This should run in a coroutine.<br/>
-- Do not call this, this is automatic!
function _M:doThread()
	self.saving = true
	collectgarbage("collect")
--	collectgarbage("stop")
	if game:getPlayer() then game:getPlayer().changed = true end
	while #self.pipe > 0 do
		local p = self.pipe[1]
		local Savefile = require(p.class)
		local o = p.object

		print("[SAVEFILE PIPE] new save running in the pipe:", p.savename, p.type, "::", p.id, "::", p.baseobject, "=>", p.object)

		local save = Savefile.new(p.savename, true)
		o.__saved_saveversion = p.saveversion
		save["save"..p.type:lower():capitalize()](save, o, true)
		save:close()

		table.remove(self.pipe, 1)
	end
	if game.log then game.log("Saving done.") end
--	collectgarbage("restart")
	self.saving = false
	if game:getPlayer() then game:getPlayer().changed = true end
end

--- Force to wait for the saves
function _M:forceWait()
	if #self.pipe == 0 then return end

	local popup = Dialog:simplePopup("Saving...", "Please wait while saving...", nil, true)
	popup.__showup = nil
	core.display.forceRedraw()

	while coroutine.status(self.co) ~= "dead" do
		coroutine.resume(self.co)
	end

	game:unregisterDialog(popup)
end

--- Load a savefile
-- @param savename the name of the savefile to handle
-- @param type the Savefile method to use. I.e: "game", "level", "zone". This will cann the Savefile:saveGame, Savefile:saveLevel, Savefile:saveZone methods
-- @param class a class name, if different from the default one
function _M:doLoad(savename, type, class, ...)
	class = class or self.saveclass
	local Savefile = require(class)
	local id = Savefile["nameLoad"..type:lower():capitalize()](Savefile, ...)

	-- Look for it in the pipe
	for i = 1, #self.pipe do
		local p = self.pipe[i]

		print("[SAVEFILE PIPE] looking for savefile to recover in the memory pipe", p.id, "?=?", id)
		if p.id == id then
			-- It is still in the save pipe: return it
			print("[SAVEFILE PIPE] recovering save from memory in pipe:", savename, type, "::", id)
			return p.baseobject
		end
	end

	local cur = Savefile:getCurrent()
	local save = Savefile.new(savename)
	local ret = save["load"..type:lower():capitalize()](save, ...)
	save:close()
	Savefile:setCurrent(cur)

	-- Check for validity
	if _G.type(ret) == "table" and type ~= "game" and type ~= "world" then
		if not game:saveVersion(ret.__saved_saveversion) then
			print("Loading savefile", savename, type, class," with id", ret.__saved_saveversion, "but current game does not know this token => ignoring")
			return nil
		end
	end

	return ret
end
