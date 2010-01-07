require "engine.class"

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
function _M:init(savefile)
	self.short_name = savefile:gsub("[^a-zA-Z0-9_-.]", "_")
	self.save_dir = "/save/"..self.short_name.."/"
	self.load_dir = "/tmp/loadsave/"

	self.tables = {}
	self.process = {}
	self.loaded = {}
	self.delayLoad = {}
	_M.current_save = self
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
	self.current_save_main = obj
	self:addToProcess(game)
	while #self.process > 0 do
		local tbl = table.remove(self.process)
		self.tables[tbl] = self:getFileName(tbl)
		zip:add(self:getFileName(tbl), tbl:save())
	end
	return self.tables[game]
end

--- Save the given game
function _M:saveGame(game)
	fs.mkdir(self.save_dir)

	local zip = fs.zipOpen(self.save_dir.."game.teag")
	self:saveObject(game, zip)
	zip:close()

	local desc = game:getSaveDescription()
	local f = fs.open(self.save_dir.."desc.lua", "w")
	f:write(("name = %q\n"):format(desc.name))
	f:write(("short_name = %q\n"):format(self.short_name))
	f:write(("description = %q\n"):format(desc.description))
	f:close()
end

--- Save a level
function _M:saveLevel(level)
	fs.mkdir(self.save_dir)

	local zip = fs.zipOpen(self.save_dir..("level-%s-%d.teal"):format(level.data.short_name, level.level))
	self:saveObject(level, zip)
	zip:close()
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

--- Loads a game
function _M:loadGame()
	local path = fs.getRealPath(self.save_dir.."game.teag")
	if not path or path == "" then return nil, "no savefile" end

	fs.mount(path, self.load_dir)

	local loadedGame = self:loadReal("main")

	-- Delay loaded must run
	for i, o in ipairs(self.delayLoad) do
--		print("loader executed for class", o, o.__CLASSNAME)
		o:loaded()
	end

	fs.umount(path)
	return loadedGame
end

--- Loads a level
function _M:loadLevel(zone, level)
	local path = fs.getRealPath(self.save_dir..("level-%s-%d.teal"):format(zone, level))
	if not path or path == "" then return false end

	fs.mount(path, self.load_dir)

	local loadedLevel = self:loadReal("main")

	-- Delay loaded must run
	for i, o in ipairs(self.delayLoad) do
--		print("loader executed for class", o, o.__CLASSNAME)
		o:loaded()
	end

	fs.umount(path)
	return loadedLevel
end

--- Checks for existence
function _M:check()
	return fs.exists(self.save_dir.."game.teag")
end
