require "engine.class"

module(..., package.seeall, class.make)

_M.current_save = false

function _M:init(savefile)
	self.save_dir = "/save/"..savefile:gsub("[^a-zA-Z0-9_-.]", "_").."/"
	self.load_dir = "/tmp/loadsave/"

	self.tables = {}
	self.process = {}
	self.loaded = {}
	self.delayLoad = {}
	_M.current_save = self
end

function _M:close()
	self.tables = nil
	self.process = nil
	self.loaded = nil
	self.delayLoad = nil
	self.current_save_main = nil
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

function _M:saveGame(game)
	fs.mkdir(self.save_dir)

	local zip = fs.zipOpen(self.save_dir.."game.teag")
	self:saveObject(game, zip)
	zip:close()
end

function _M:saveLevel(level)
	fs.mkdir(self.save_dir)

	local zip = fs.zipOpen(self.save_dir..("level-%s-%d.teal"):format(level.data.short_name, level.level))
	self:saveObject(level, zip)
	zip:close()
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
	self.loaded[load] = o
	return o
end

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
