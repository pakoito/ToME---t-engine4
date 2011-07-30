-- TE4 - T-Engine 4
-- Copyright (C) 2009, 2010, 2011 Nicolas Casalini
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
-- T-Engine4 savefiles are direct serialization of in game objects<br/>
-- Basically the engine is told to save your Game instance and then it will
-- recursively save all that it contains: level, map, entities, your own objects, ...<br/>
-- The savefile structure is a zip file that contains one file per object to be saved. Unzip one, it is quite obvious<br/>
-- A simple object (that does not do anything too fancy in its constructor) will save/load without anything
-- to code, it's magic!<br/>
-- For more complex objects, look at the methods save() and loaded() in objects that have them
module(..., package.seeall, class.make)

_M.current_save = false

--- Init a savefile
-- @param savefile the name of the savefile, usually the player's name. It will be sanitized so dont bother doing it
-- @param coroutine if true the saving will yield sometimes to let other code run
function _M:init(savefile, coroutine)
	self.short_name = savefile:gsub("[^a-zA-Z0-9_-.]", "_")
	self.save_dir = "/save/"..self.short_name.."/"
	self.quickbirth_file = "/save/"..self.short_name..".quickbirth"
	self.hotkeys_file = "/save/"..self.short_name..".hotkeys"
	self.load_dir = "/tmp/loadsave/"

	self.coroutine = coroutine
	self.tables = {}
	self.process = {}
	self.loaded = {}
	self.delayLoad = {}
	_M.current_save = self
end

function _M:getCurrent()
	return _M.current_save
end
function _M:setCurrent(save)
	_M.current_save = save
end

--- Finishes up a savefile
-- Always call it once done
function _M:close()
	self.tables = nil
	self.process = nil
	self.loaded = nil
	self.delayLoad = nil
	self.current_save_main = nil
end

--- Delete the savefile, if needed
function _M:delete()
	for i, f in ipairs(fs.list(self.save_dir)) do
		fs.delete(self.save_dir..f)
	end
	fs.delete(self.save_dir)
end

function _M:addToProcess(o)
	if not self.tables[o] then
		table.insert(self.process, o)
		self.tables[o] = true
	end
end

function _M:addDelayLoad(o)
--	print("add delayed", _M, "::", self, #self.delayLoad, o)
	table.insert(self.delayLoad, 1, o)
end

function _M:getFileName(o)
	if o == self.current_save_main then
		return "main"
	else
		return o.__CLASSNAME.."-"..tostring(o):sub(8)
	end
end

function _M:saveObject(obj, zip)
	self.current_save_zip = zip
	self.current_save_main = obj
	self:addToProcess(obj)
	while #self.process > 0 do
		local tbl = table.remove(self.process)
		self.tables[tbl] = self:getFileName(tbl)
--		zip:add(self:getFileName(tbl), tbl:save(nil, nil, self))
		tbl:save()
		savefile_pipe.current_nb = savefile_pipe.current_nb + 1

		if self.coroutine then coroutine.yield() end
	end
	return self.tables[obj]
end

--- Get a savename for a world
function _M:nameSaveWorld(world)
	return "world.teaw"
end
--- Get a savename for a world
function _M:nameLoadWorld()
	return "world.teaw"
end

--- Save the given world
function _M:saveWorld(world, no_dialog)
	collectgarbage("collect")

	fs.mkdir(self.save_dir)

	local popup
	if not no_dialog then
		popup = Dialog:simplePopup("Saving world", "Please wait while saving the world...", nil, true)
		popup.__showup = nil
	end
	core.display.forceRedraw()

	local zip = fs.zipOpen(self.save_dir..self:nameSaveWorld(world)..".tmp")
	self:saveObject(world, zip)
	zip:close()
	fs.delete(self.save_dir..self:nameSaveWorld(world))
	fs.rename(self.save_dir..self:nameSaveWorld(world)..".tmp", self.save_dir..self:nameSaveWorld(world))

	if not no_dialog then game:unregisterDialog(popup) end
end

--- Save the given birth descriptors, used for quick start
function _M:saveQuickBirth(descriptor)
	collectgarbage("collect")

	local f = fs.open(self.quickbirth_file, "w")
	for k, e in pairs(descriptor) do
		f:write(("%s = %q\n"):format(tostring(k), tostring(e)))
	end
	f:close()
end

--- Load the given birth descriptors, used for quick start
function _M:loadQuickBirth()
	collectgarbage("collect")

	local f = loadfile(self.quickbirth_file)
	print("[QUICK BIRTH]", f)
	if f then
		-- Call the file body inside its own private environment
		local def = {}
		setfenv(f, def)
		if pcall(f) then
			return def
		end
	end
	return nil
end

function _M:loadQuickHotkeys()
	local f = loadfile(self.hotkeys_file)
	print("[HOTKEYS]", f)
	if f then
		--Call the file body inside its own private environment
		local def = {}
		setfenv(f, def)
		if pcall(f) then
			return def
		end
	end
	return nil
end

--- Saves the screenshot of a game
function _M:saveScreenshot(screenshot)
	if not screenshot then return end
	fs.mkdir(self.save_dir)

	local f = fs.open(self.save_dir.."cur.png", "w")
	f:write(screenshot)
	f:close()
end

--- Get a savename for a game
function _M:nameSaveGame(game)
	return "game.teag"
end
--- Get a savename for a game
function _M:nameLoadGame()
	return "game.teag"
end

--- Save the given game
function _M:saveGame(game, no_dialog)
	collectgarbage("collect")

	fs.mkdir(self.save_dir)

	local popup
	if not no_dialog then
		popup = Dialog:simplePopup("Saving game", "Please wait while saving the game...", nil, true)
		popup.__showup = nil
	end
	core.display.forceRedraw()

	local zip = fs.zipOpen(self.save_dir..self:nameSaveGame(game)..".tmp")
	self:saveObject(game, zip)
	zip:close()
	fs.delete(self.save_dir..self:nameSaveGame(game))
	fs.rename(self.save_dir..self:nameSaveGame(game)..".tmp", self.save_dir..self:nameSaveGame(game))

	local desc = game:getSaveDescription()
	local f = fs.open(self.save_dir.."desc.lua", "w")
	f:write(("module = %q\n"):format(game.__mod_info.short_name))
	f:write(("module_version = {%d,%d,%d}\n"):format(game.__mod_info.version[1], game.__mod_info.version[2], game.__mod_info.version[3]))
	f:write(("name = %q\n"):format(desc.name))
	f:write(("short_name = %q\n"):format(self.short_name))
	f:write(("timestamp = %d\n"):format(os.time()))
	f:write(("description = %q\n"):format(desc.description))
	f:close()

	if not no_dialog then game:unregisterDialog(popup) end

	-- A bit hacky, save hotkeys, this will do until I can make it better for multiplayer stuff
	local f = fs.open(self.hotkeys_file, "w")
	if game:getPlayer().hotkey then
		f:write("quickhotkeys = {}\n")
		for i, known_t_id in pairs(game:getPlayer().hotkey) do
			if known_t_id[1] == "talent" then
				f:write(("quickhotkeys[%q] = %i\n"):format(tostring(known_t_id[2]) , i))
			end
		end
	end
	f:close()
end

--- Get a savename for a zone
function _M:nameSaveZone(zone)
	return ("zone-%s.teaz"):format(zone.short_name)
end
--- Get a savename for a zone
function _M:nameLoadZone(zone)
	return ("zone-%s.teaz"):format(zone)
end

--- Save a zone
function _M:saveZone(zone, no_dialog)
	fs.mkdir(self.save_dir)

	local popup
	if not no_dialog then
		popup = Dialog:simplePopup("Saving zone", "Please wait while saving the zone...", nil, true)
		popup.__showup = nil
	end
	core.display.forceRedraw()

	local zip = fs.zipOpen(self.save_dir..self:nameSaveZone(zone)..".tmp")
	self:saveObject(zone, zip)
	zip:close()
	fs.delete(self.save_dir..self:nameSaveZone(zone))
	fs.rename(self.save_dir..self:nameSaveZone(zone)..".tmp", self.save_dir..self:nameSaveZone(zone))

	if not no_dialog then game:unregisterDialog(popup) end
end

--- Get a savename for a level
function _M:nameSaveLevel(level)
	return ("level-%s-%d.teal"):format(level.data.short_name, level.level)
end
--- Get a savename for a level
function _M:nameLoadLevel(zone, level)
	return ("level-%s-%d.teal"):format(zone, level)
end

--- Save a level
function _M:saveLevel(level, no_dialog)
	fs.mkdir(self.save_dir)

	local popup
	if not no_dialog then
		popup = Dialog:simplePopup("Saving level", "Please wait while saving the level...", nil, true)
		popup.__showup = nil
	end
	core.display.forceRedraw()

	local zip = fs.zipOpen(self.save_dir..self:nameSaveLevel(level)..".tmp")
	self:saveObject(level, zip)
	zip:close()
	fs.delete(self.save_dir..self:nameSaveLevel(level))
	fs.rename(self.save_dir..self:nameSaveLevel(level)..".tmp", self.save_dir..self:nameSaveLevel(level))

	if not no_dialog then game:unregisterDialog(popup) end
end

--- Get a savename for an entity
function _M:nameSaveEntity(e)
	return ("entity-%s.teae"):format(e.name:gsub("[^a-zA-Z0-9_-.]", "_"):lower())
end
--- Get a savename for an entity
function _M:nameLoadEntity(name)
	return ("entity-%s.teae"):format(name:gsub("[^a-zA-Z0-9_-.]", "_"):lower())
end

--- Save an entity
function _M:saveEntity(e, no_dialog)
	fs.mkdir(self.save_dir)

	local popup
	if not no_dialog then
		popup = Dialog:simplePopup("Saving entity", "Please wait while saving the entity...", nil, true)
		popup.__showup = nil
	end
	core.display.forceRedraw()

	local zip = fs.zipOpen(self.save_dir..self:nameSaveEntity(e)..".tmp")
	self:saveObject(e, zip)
	zip:close()
	fs.delete(self.save_dir..self:nameSaveEntity(e))
	fs.rename(self.save_dir..self:nameSaveEntity(e)..".tmp", self.save_dir..self:nameSaveEntity(e))

	if not no_dialog then game:unregisterDialog(popup) end
end

local function resolveSelf(o, base, allow_object)
	if o.__CLASSNAME and not allow_object then return end

	local change = {}
	for k, e in pairs(o) do
		if type(e) == "table" then
			if e == class.LOAD_SELF then change[#change+1] = k
			else resolveSelf(e, base, false)
			end
		end
	end
	for i, k in ipairs(change) do o[k] = base end
end

function _M:loadReal(load)
	if self.loaded[load] then return self.loaded[load] end
	local f = fs.open(self.load_dir..load, "r")
--	print("loading", load)
	local lines = {}
	while true do
		local l = f:read()
		if not l then break end
		lines[#lines+1] = l
	end
	f:close()
	local o = class.load(table.concat(lines), load)

	-- Resolve self referencing tables now
	resolveSelf(o, o, true)

	self.loaded[load] = o
	return o
end

--- Loads a world
function _M:loadWorld()
	local path = fs.getRealPath(self.save_dir..self:nameLoadWorld())
	if not path or path == "" then return nil, "no savefile" end

	fs.mount(path, self.load_dir)

	local popup = Dialog:simplePopup("Loading world", "Please wait while loading the world...")
	popup.__showup = nil
	core.display.forceRedraw()

	local loadedWorld = self:loadReal("main")

	-- Delay loaded must run
	for i, o in ipairs(self.delayLoad) do
--		print("loader executed for class", o, o.__CLASSNAME)
		o:loaded()
	end

	fs.umount(path)

	game:unregisterDialog(popup)

	return loadedWorld
end

--- Loads a game
function _M:loadGame()
	local path = fs.getRealPath(self.save_dir..self:nameLoadGame())
	if not path or path == "" then return nil, "no savefile" end

	fs.mount(path, self.load_dir)

	local popup = Dialog:simplePopup("Loading game", "Please wait while loading the game...")
	popup.__showup = nil
	core.display.forceRedraw()

	local loadedGame = self:loadReal("main")

	-- Delay loaded must run
	local delay_fct = function()
		for i, o in ipairs(self.delayLoad) do
--			print("loader executed for class", o, o.__CLASSNAME)
			o:loaded()
		end
	end

	fs.umount(path)

	game:unregisterDialog(popup)

	return loadedGame, delay_fct
end

--- Loads a zone
function _M:loadZone(zone)
	local path = fs.getRealPath(self.save_dir..self:nameLoadZone(zone))
	if not path or path == "" then return false end

	fs.mount(path, self.load_dir)

	local popup = Dialog:simplePopup("Loading zone", "Please wait while loading the zone...")
	popup.__showup = nil
	core.display.forceRedraw()

	local loadedZone = self:loadReal("main")

	-- Delay loaded must run
	for i, o in ipairs(self.delayLoad) do
--		print("loader executed for class", o, o.__CLASSNAME)
		o:loaded()
	end

	game:unregisterDialog(popup)

	fs.umount(path)
	return loadedZone
end

--- Loads a level
function _M:loadLevel(zone, level)
	local path = fs.getRealPath(self.save_dir..self:nameLoadLevel(zone, level))
	if not path or path == "" then return false end

	fs.mount(path, self.load_dir)

	local popup = Dialog:simplePopup("Loading level", "Please wait while loading the level...")
	popup.__showup = nil
	core.display.forceRedraw()

	local loadedLevel = self:loadReal("main")

	-- Delay loaded must run
	for i, o in ipairs(self.delayLoad) do
--		print("loader executed for class", o, o.__CLASSNAME)
		o:loaded()
	end

	game:unregisterDialog(popup)

	fs.umount(path)
	return loadedLevel
end

--- Loads an entity
function _M:loadEntity(name)
	local path = fs.getRealPath(self.save_dir..self:nameLoadEntity(name))
	if not path or path == "" then return false end

	fs.mount(path, self.load_dir)

	local popup = Dialog:simplePopup("Loading entity", "Please wait while loading the entity...")
	popup.__showup = nil
	core.display.forceRedraw()

	local loadedEntity = self:loadReal("main")

	-- Delay loaded must run
	for i, o in ipairs(self.delayLoad) do
--		print("loader executed for class", o, o.__CLASSNAME)
		o:loaded()
	end

	game:unregisterDialog(popup)

	fs.umount(path)
	return loadedEntity
end

--- Checks for existence
function _M:check()
	return fs.exists(self.save_dir..self:nameLoadGame())
end
