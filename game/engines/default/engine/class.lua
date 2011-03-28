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

module("class", package.seeall)

local base = _G

local function search(k, plist)
	for i=1, #plist do
		local v = plist[i][k]     -- try `i'-th superclass
		if v then return v end
	end
end


function make(c)
	setmetatable(c, {__index=_M})
	c.new = function(...)
		local obj = {}
		obj.__CLASSNAME = c._NAME
		setmetatable(obj, {__index=c})
		if obj.init then obj:init(...) end
		return obj
	end
	return c
end

function inherit(base, ...)
	local ifs = {...}
	return function(c)
		if #ifs == 0 then
			setmetatable(c, {__index=base})
		else
			for i, _if in ipairs(ifs) do
				for k, e in pairs(_if) do
					if k ~= "init" and k ~= "_NAME" and k ~= "_M" and k ~= "_PACKAGE" and k ~= "new" then
						c[k] = e
--						print(("caching interface value %s (%s) from %s to %s"):format(k, tostring(e), _if._NAME, c._NAME))
					end
				end
			end
			setmetatable(c, {__index=base})
		end
		c.new = function(...)
			local obj = {}
			obj.__CLASSNAME = c._NAME
			setmetatable(obj, {__index=c})
			if obj.init then obj:init(...) end
			return obj
		end
		c.castAs = function(o)
			o.__CLASSNAME = c._NAME
			setmetatable(o, {__index=c})
		end
		return c
	end
end

function _M:getClassName()
	return self.__CLASSNAME
end

function _M:getClass()
	return getmetatble(self).__index
end

local function clonerecurs(d)
	local n = {}
	for k, e in pairs(d) do
		local nk, ne = k, e
		if type(k) == "table" and not k.__CLASSNAME then nk = clonerecurs(k) end
		if type(e) == "table" and not e.__CLASSNAME then ne = clonerecurs(e) end
		n[nk] = ne
	end
	return n
end
--[[
local function cloneadd(dest, src)
	for k, e in pairs(src) do
		local nk, ne = k, e
		if type(k) == "table" then nk = cloneadd(k) end
		if type(e) == "table" then ne = cloneadd(e) end
		dest[nk] = ne
	end
end
]]
function _M:clone(t)
	local n = clonerecurs(self)
	if t then
--		error("cloning mutation not yet implemented")
--		cloneadd(n, t)
		for k, e in pairs(t) do n[k] = e end
	end
	setmetatable(n, getmetatable(self))
	if n.cloned then n:cloned(self) end
	return n
end

local function clonerecursfull(clonetable, d)
	local nb = 0
	local add
	local n = {}
	clonetable[d] = n

	local k, e = next(d)
	while k do
		local nk, ne = k, e
		if clonetable[k] then nk = clonetable[k]
		elseif type(k) == "table" then nk, add = clonerecursfull(clonetable, k) nb = nb + add
		end

		if clonetable[e] then ne = clonetable[e]
		elseif type(e) == "table" and (type(k) ~= "string" or k ~= "__threads") then ne, add = clonerecursfull(clonetable, e) nb = nb + add
		end
		n[nk] = ne

		k, e = next(d, k)
	end
	setmetatable(n, getmetatable(d))
	if n.cloned and n.__CLASSNAME then n:cloned(d) end
	if n.__CLASSNAME then nb = nb + 1 end
	return n, nb
end

--- Clones the object, all subobjects without cloning twice a subobject
-- @return the clone and the number of cloned objects
function _M:cloneFull()
--	local old = core.game.getTime()
--	core.serial.cloneFull(self)
--	print("CLONE C", core.game.getTime() - old)

--	old = core.game.getTime()
--	local clonetable = {}
--	clonerecursfull(clonetable, self)
--	print("CLONE LUA", core.game.getTime() - old)

	local clonetable = {}
	return clonerecursfull(clonetable, self)
--	return core.serial.cloneFull(self)
end

--- Replaces the object with an other, by copying (not deeply)
function _M:replaceWith(t)
	-- Delete fields
	for k, e in pairs(self) do
		self[k] = nil
	end
	for k, e in pairs(t) do
		self[k] = e
	end
	setmetatable(self, getmetatable(t))
end

-- ---------------------------------------------------------------------
-- ---------------------------------------------------------------------
-- LOAD & SAVE
-- ---------------------------------------------------------------------
-- ---------------------------------------------------------------------

function _M:save(filter, allow)
	filter = filter or {}
	if self._no_save_fields then table.merge(filter, self._no_save_fields) end
	if not allow then
		filter.new = true
		filter._no_save_fields = true
		filter._mo = true
		filter._mo_final = true
	else
		filter.__CLASSNAME = true
	end
	local mt = getmetatable(self)
	setmetatable(self, {})
	local savefile = engine.Savefile.current_save
	local s = core.serial.new(
		-- Zip to write to
		savefile.current_save_zip,
		-- Namer
		function(t) return savefile:getFileName(t) end,
		-- Processor
		function(t) savefile:addToProcess(t) end,
		-- Allowed table
		allow and filter or nil,
		-- Disallowed table
		not allow and filter or nil,
		-- 2nd disallowed table
		self._no_save_fields
	)
	s:toZip(self)

	setmetatable(self, mt)
end

_M.LOAD_SELF = {}

local function deserialize(string, src)
	local f, err = loadstring(string)
	if err then print("error deserializing", string, err) end
	setfenv(f, {
		setLoaded = function(name, t)
--			print("[setLoaded]", name, t)
			engine.Savefile.current_save.loaded[name] = t
		end,
		loadstring = loadstring,
		loadObject = function(n)
			if n == src then
				return _M.LOAD_SELF
			else
				return engine.Savefile.current_save:loadReal(n)
			end
		end,
	})
	return f()
end

function load(str, delayloading)
	local obj = deserialize(str, delayloading)
	if obj then
--		print("setting obj class", obj.__CLASSNAME)
		setmetatable(obj, {__index=require(obj.__CLASSNAME)})
		if obj.loaded then
--			print("loader found for class", obj, obj.__CLASSNAME)
			if delayloading and not obj.loadNoDelay then
				engine.Savefile.current_save:addDelayLoad(obj)
			else
				obj:loaded()
			end
		end
	end
	return obj
end

--- "Reloads" a cloneFull result object
-- This will make sure each object and subobject method :loaded() is called
function _M:cloneReloaded()
	local delay_load = {}
	local seen = {}

	local function reload(obj)
--		print("setting obj class", obj.__CLASSNAME)
		setmetatable(obj, {__index=require(obj.__CLASSNAME)})
		if obj.loaded then
--			print("loader found for class", obj, obj.__CLASSNAME)
			if not obj.loadNoDelay then
				delay_load[#delay_load+1] = obj
			else
				obj:loaded()
			end
		end
	end

	local function recurs(t)
		if seen[t] then return end
		seen[t] = true
		for k, e in pairs(t) do
			if type(k) == "table" then
				recurs(k)
				if k.__CLASSNAME then reload(k) end
			end
			if type(e) == "table" then
				recurs(e)
				if e.__CLASSNAME then reload(e) end
			end
		end
	end

	-- Start reloading
	recurs(self)
	reload(self)

	-- Computed delayed loads
	for i = 1, #delay_load do delay_load[i]:loaded() end
end
