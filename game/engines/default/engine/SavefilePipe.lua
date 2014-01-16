-- TE4 - T-Engine 4
-- Copyright (C) 2009 - 2014 Nicolas Casalini
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
local Dialog = require "engine.ui.Dialog"

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
	self.pipe_types = {}
	self.on_done = {}
	self.max_before_wait = max_before_wait or 6
	self.co = nil
	self.current_nb = 0
	self.total_nb = 1
end

--- Cleanup old saves in steam cloud if needed
function _M:steamCleanup()
	if not core.steam then return end
	local oldns = core.steam.getFileNamespace()
	core.steam.setFileNamespace("")

	print("[SAVEFILE PIPE] Cleaning up steam cloud")
	local avail = core.steam.getCloudSize() / 1024 / 1024
	print("[SAVEFILE PIPE] Cloud has "..avail.."MB available")

	-- Still have room left
	local MAX_ALLOWED = 200
	if avail >= MAX_ALLOWED then core.steam.setFileNamespace(oldns) return end
	print("[SAVEFILE PIPE] Steam cloud missing space, cleaning up old saves")

	local saves = {}
	local list = core.steam.listFilesEndingWith("game.teag")
	for _, file in ipairs(list) do
		local _, _, modname, char = file:find("^([^/]+)/save/([^/]+)/game%.teag$")
		if modname then
			local ts = core.steam.timestampFile(file)
			saves[#saves+1] = {file=file, ts=ts, name=char, mod=modname}
		end
	end
	table.sort(saves, function(a, b) return a.ts < b.ts end)

	-- Forget until we have space
	while avail < MAX_ALLOWED and #saves > 0 do
		local save = table.remove(saves, 1)
		print("[SAVEFILE PIPE] Cloud Forgetting save", save.mod, save.name)
		for _, file in ipairs(core.steam.listFilesStartingWith(save.mod.."/save/"..save.name.."/")) do
			print("\t* "..file)
			core.steam.forgetFile(file)
		end
		avail = core.steam.getCloudSize() / 1024 / 1024
		print("\t => Cloud has "..avail.."MB available")
	end


	core.steam.setFileNamespace(oldns)
end

--- Disables/enables clean saves
-- @param v true or false
function _M:ignoreCloudSave(v)
	self.disable_cloud_saves = v
end

--- Push a savefile request
-- @param savename the name of the savefile to handle
-- @param type the Savefile method to use. I.e: "game", "level", "zone". This will cann the Savefile:saveGame, Savefile:saveLevel, Savefile:saveZone methods
-- @param object the object to save
-- @param class a class name, if different from the default one
-- @param on_end a function to call when this object is saved; this can be nil
function _M:push(savename, type, object, class, on_end)
	if game.onSavefilePush then game:onSavefilePush(savename, type, object, class) end

	-- Cant save twice the same thing before it finishes
	if self.pipe_types[type] and self.pipe_types[type][savename] then
		print("[SAVEFILE PIPE] Already saving data", type, savename, "waiting for finish before piping...")
		self:forceWait()
		print("[SAVEFILE PIPE] All pipe saving emptied, resuming next save")
	end

	local screenshot = nil
	if type == "game" then
		screenshot = game:takeScreenshot(true)
	end

	class = class or self.saveclass
	local Savefile = require(class)
	local id = Savefile["nameSave"..type:lower():capitalize()](Savefile, object)

	if #self.pipe == 0 then savefile_pipe.current_nb = 0 self:steamCleanup() end

	local clone, nb = object:cloneForSave()
	self.pipe_types[type] = self.pipe_types[type] or {}
	self.pipe_types[type][savename] = true

	self.pipe[#self.pipe+1] = {id=id, savename = savename, type=type, object=clone, nb_objects=nb, baseobject=object, class=class, saveversion=game:saveVersion("new"), screenshot=screenshot, on_end=on_end}
	local total_nb = 0
	for i, p in ipairs(self.pipe) do total_nb = total_nb + p.nb_objects end
	self.total_nb = total_nb
	if not self.co or coroutine.status(self.co) == "dead" then
		self.co = coroutine.create(function() return self:doThread() end)
		game:registerCoroutine("savefilepipe", self.co)
	end

	if game.onSavefilePushed then game:onSavefilePushed(savename, type, object, class) end


	-- Refuse to continue, make the user wait
	if #self.pipe >= self.max_before_wait or not config.settings.background_saves then
		self:forceWait()
	end

	return clone
end

--- Push a generic action to be done once saves complete
function _M:pushGeneric(name, fct)
	self.on_done[#self.on_done+1] = {name=name, fct=fct}
end

--- Actually do the saves
-- This should run in a coroutine.<br/>
-- Do not call this, this is automatic!
function _M:doThread()
	self.saving = true
	collectgarbage("collect")
--	collectgarbage("stop")
	if game:getPlayer() then game:getPlayer().changed = true end

	local waiton = {}
	self.waiton = waiton

	while #self.pipe > 0 do
		local p = self.pipe[1]
		local Savefile = require(p.class)
		local o = p.object

		print("[SAVEFILE PIPE] new save running in the pipe:", p.savename, p.type, "::", p.id, "::", p.baseobject, "=>", p.object, "("..p.nb_objects..")")

		local save = Savefile.new(p.savename, config.settings.background_saves)
		o.__saved_saveversion = p.saveversion
		save["save"..p.type:lower():capitalize()](save, o, true)
		if p.screenshot then save:saveScreenshot(p.screenshot) end
		p.save = save
		waiton[save.current_save_zip:gsub("%.tmp$", "")] = p
		save:close()

		table.remove(self.pipe, 1)
	end

	-- Unleash the fury of the offthread saving
	print("[SAVEFILE PIPE] unleashing save thread")
	core.serial.threadSave()

	-- Wait for feedback
	while next(waiton) do
		local pop = core.serial.popSaveReturn()
		if not pop then coroutine.yield()
		else
			local dontremove = false
			local p = waiton[pop]
			if p then
				local Savefile = require(p.class)

				print("[SAVEFILE PIPE] Checking save", p.savename, p.type, p.save.current_save_zip)
				local save = Savefile.new(p.savename, config.settings.background_saves)
				local okmain = save:checkValidity(p.type, p.object)
				save:close()

				if not okmain then
					print("[SAVEFILE PIPE] *RE*new save running in the pipe:", p.savename, p.type, "::", p.id, "::", p.baseobject, "=>", p.object, "("..p.nb_objects..")")

					local o = p.object
					local save = Savefile.new(p.savename, config.settings.background_saves)
					o.__saved_saveversion = p.saveversion
					save["save"..p.type:lower():capitalize()](save, o, true)
					if p.screenshot then save:saveScreenshot(p.screenshot) end
					p.save = save
					waiton[save.current_save_zip:gsub("%.tmp$", "")] = p
					save:close()
					core.serial.threadSave()
					print("[SAVEFILE PIPE] Resaving sent", p.savename, p.type, p.save.current_save_zip)
					dontremove = true
				end
			end

			if not dontremove then
				if p and p.on_end then
					p.on_end(p.save)
				end
				self.pipe_types[p.type][p.savename] = nil
				waiton[pop] = nil
			end
		end
	end
	self.waiton = nil

	if game.log then game.log("Saving done.") end
--	collectgarbage("restart")
	self.saving = false
	if game:getPlayer() then game:getPlayer().changed = true end

	-- Run the generic stuff
	while #self.on_done > 0 do
		local p = self.on_done[1]
		print("[SAVEFILE PIPE] on end", p.name)
		p.fct()
		table.remove(self.on_done, 1)
	end
end

--- Force to wait for the saves
function _M:forceWait()
	print("[SAVEFILE PIPE] force waiting")
	if #self.pipe == 0 and (not self.waiton or not next(self.waiton)) then return end

	local popup = Dialog:simpleWaiter("Saving...", "Please wait while saving...", nil, 1000, self.total_nb)
	core.display.forceRedraw()

	local cnt = 0
	while coroutine.status(self.co) ~= "dead" do
		cnt = cnt + 1
		if cnt == 1000 then core.display.forceRedraw() if game:getPlayer() then game:getPlayer().changed = true end cnt = 0 end
		coroutine.resume(self.co)
	end

	popup:done()
end

--- Allow to ignore saveversion token
function _M:ignoreSaveToken(v)
	self.ignore_save_token = v
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
	if _G.type(ret) == "table" and type ~= "game" and type ~= "world" and not self.ignore_save_token then
		if not game:saveVersion(ret.__saved_saveversion) then
			print("Loading savefile", savename, type, class," with id", ret.__saved_saveversion, "but current game does not know this token => ignoring")
			return nil
		end
	end

	return ret
end
