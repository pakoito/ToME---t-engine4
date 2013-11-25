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

module("class", package.seeall)

local base = _G
local run_inherited = {}

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

local skip_key = {init=true, _NAME=true, _M=true, _PACKAGE=true, new=true, _BASES=true, castAs=true}
function inherit(...)
	local bases = {...}
	return function(c)
		c._BASES = bases
		-- Recursive inheritance caching
		-- Inheritance proceeds from the first to last argument, so if the first and last base classes share a key the value will match the last base class
		if #bases > 1 then
			local completed_bases = {}
--			local inheritance_mapper = {}
			local cache_inheritance
			cache_inheritance = function(c, base)
				-- Only cache a base class once
				if not completed_bases[base] then
					-- Recurse first so we replace those values
					if base._BASES and type(base._BASES) == "table" then
						for i, _base in ipairs(base._BASES) do
							cache_inheritance(c, _base)
						end
					end
					-- Cache all the immediate variables
--					local ncopied = 0
					for k, e in pairs(base) do
						if not skip_key[k] and (base[k] ~= nil) then
--							if c[k] ~= nil then
--								print(("INHERIT: *WARNING* replacing interface value %s (%s) from %s with (%s) from %s"):format(k, tostring(c[k]), inheritance_mapper[k], tostring(base[k]), base._NAME))
--							else
--								print(("INHERIT: caching interface value %s (%s) from %s to %s"):format(k, tostring(e), base._NAME, c._NAME))
--							end
							c[k] = base[k]
--							inheritance_mapper[k] = base._NAME
--							ncopied = ncopied + 1
						end
					end
--					print(("INHERIT: cached %d values from %s to %s"):format(ncopied, base._NAME, c._NAME))
					completed_bases[base] = true
					completed_bases[#completed_bases+1] = base
				end
			end
			local i = 1
			while i <= #bases do
--				print(("INHERIT: base class #%d, %s"):format(i, bases[i]._NAME))
				cache_inheritance(c, bases[i])
				i = i + 1
			end
--			print(("INHERIT: recursed through %d base classes for %s"):format(#completed_bases, c._NAME))
		end
		setmetatable(c, {__index=bases[1]})
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
		if c.inherited then
			run_inherited[#run_inherited+1] = function()
				local i = 1
				while i <= #bases do
					c:inherited(bases[i], i)
					i = i + 1
				end
			end
		end
		return c
	end
end

function _M:importInterface(base)
	for k, e in pairs(base) do
		if not skip_key[k] and (base[k] ~= nil) then
			self[k] = base[k]
		end
	end
end

function _M:getClassName()
	return self.__CLASSNAME
end

function _M:getClass()
	return getmetatable(self).__index
end

function _M:runInherited()
	for _, f in ipairs(run_inherited) do
		f()
	end
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

local function clonerecursfull(clonetable, d, noclonecall)
	local nb = 0
	local add
	local n = {}
	clonetable[d] = n

	local k, e = next(d)
	while k do
		local nk, ne = k, e
		if clonetable[k] then nk = clonetable[k]
		elseif type(k) == "table" then nk, add = clonerecursfull(clonetable, k, noclonecall) nb = nb + add
		end

		if clonetable[e] then ne = clonetable[e]
		elseif type(e) == "table" and (type(k) ~= "string" or k ~= "__threads") then ne, add = clonerecursfull(clonetable, e, noclonecall) nb = nb + add
		end
		n[nk] = ne

		k, e = next(d, k)
	end
	setmetatable(n, getmetatable(d))
	if not noclonecall and n.cloned and n.__CLASSNAME then n:cloned(d) end
	if n.__CLASSNAME then nb = nb + 1 end
	return n, nb
end

--- Clones the object, all subobjects without cloning twice a subobject
-- @return the clone and the number of cloned objects
function _M:cloneFull(t)
	local clonetable = {}
	local n = clonerecursfull(clonetable, self)
	if t then
		for k, e in pairs(t) do n[k] = e end
	end
	return n
--	return core.serial.cloneFull(self)
end

--- Clones the object, all subobjects without cloning twice a subobject
-- Does not invoke clone methods as this is not for reloading, just for saving
-- @return the clone and the number of cloned objects
function _M:cloneForSave()
	local clonetable = {}
	return clonerecursfull(clonetable, self, true)
--	return core.serial.cloneFull(self)
end

--- Replaces the object with an other, by copying (not deeply)
function _M:replaceWith(t)
	if self.replacedWith then self:replacedWith(false, t) end

	-- Delete fields
	while next(self) do
		self[next(self)] = nil
	end
	for k, e in pairs(t) do
		self[k] = e
	end
	setmetatable(self, getmetatable(t))

	if self.replacedWith then self:replacedWith(true) end
end

-- ---------------------------------------------------------------------
-- ---------------------------------------------------------------------
-- Hooks & Events system
-- ---------------------------------------------------------------------
-- ---------------------------------------------------------------------

local _hooks = {hooks={}, list={}}
local _current_hook_dir = nil

function _M:setCurrentHookDir(dir)
	_current_hook_dir = dir
end

function _M:bindHook(hook, fct)
	if type(fct) == "string" and _current_hook_dir then
		local f, err = loadfile(_current_hook_dir..fct..".lua")
		if not f then error(err) end
		local ok, hook = pcall(f)
		if not ok then error(hook) end
		fct = hook
	end

	_hooks.list[hook] = _hooks.list[hook] or {}
	table.insert(_hooks.list[hook], fct)

	local sfct = [[return function(l, self, data) local ok=false]]

	for i, fct in ipairs(_hooks.list[hook]) do
		sfct = sfct..([[ if l[%d](self, data) then ok=true end]]):format(i)
	end

	sfct = sfct..[[ return ok end]]
	local f, err = loadstring(sfct)
	if not f then error(err) end
	_hooks.hooks[hook] = f()
end

function _M:triggerHook(hook)
	local h = hook[1]
	if not _hooks.hooks[h] then return end
	return _hooks.hooks[h](_hooks.list[h], self, hook)
end

-- ---------------------------------------------------------------------
-- ---------------------------------------------------------------------
-- LOAD & SAVE
-- ---------------------------------------------------------------------
-- ---------------------------------------------------------------------

__zipname_zf_store = {}
function _M:save(filter, allow)
	filter = filter or {}
	if self._no_save_fields then table.merge(filter, self._no_save_fields) end
	if not allow then
		filter.new = true
		filter._no_save_fields = true
		filter._mo = true
		filter._last_mo = true
		filter._mo_final = true
		filter._hooks = true
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
--			print("loader found for class", obj, obj.__CLASSNAME, obj.loadNoDelay, obj.loaded, require(obj.__CLASSNAME).loaded)
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

return _M
