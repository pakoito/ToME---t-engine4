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
local function basicSerialize(o)
	if type(o) == "number" or type(o) == "boolean" then
		return tostring(o)
	elseif type(o) == "function" then
		return string.format("loadstring(%q)", string.dump(o))
	else   -- assume it is a string
		return string.format("%q", o)
	end
end

local function serialize_data(outf, name, value, saved, filter, allow, savefile, force)
	saved = saved or {}       -- initial value
	outf(name, " = ")
	if type(value) == "number" or type(value) == "string" or type(value) == "boolean" or type(value) == "function" then
		outf(basicSerialize(value), "\n")
	elseif type(value) == "table" then
		if not force and value.__CLASSNAME then
			savefile:addToProcess(value)
			outf("loadObject('", savefile:getFileName(value), "')\n")
		elseif saved[value] then    -- value already saved?
			outf(saved[value], "\n")  -- use its previous name
		else
			saved[value] = name   -- save name for next time
			outf("{}\n")     -- create a new table

			-- If we are the base table, decalre ourselves
			if name == "data" then
				outf('setLoaded("'..savefile:getFileName(value)..'", data)\n')
			end

			for k,v in pairs(value) do      -- save its fields
--				print(allow, k , filter[k], v, "will dump", (not allow and not filter[k]) or (allow and filter[k]))
				if (not allow and not filter[k]) or (allow and filter[k]) then
					local fieldname
					-- Special case to handle index by objects
					if type(k) == "table" and k.__CLASSNAME then
						savefile:addToProcess(k)
						fieldname = string.format("%s[loadObject('%s')]", name, savefile:getFileName(k))
					else
						fieldname = string.format("%s[%s]", name, basicSerialize(k))
					end
					serialize_data(outf, fieldname, v, saved, {new=true}, false, savefile, false)
				end
			end
		end
	else
		error("cannot save a " .. type(value) .. " ("..name..")")
	end
end

local function serialize(data, filter, allow, savefile)
	local tbl = {}
	local outf = function(...) for i,str in ipairs{...} do table.insert(tbl, str) end end
	serialize_data(outf, "data", data, nil, filter, allow, savefile, true)
	table.insert(tbl, "return data\n")
	return tbl
end

function _M:save(filter, allow, savefile)
	filter = filter or {}
	if not allow then
		filter.new = true
		filter._mo = true
	else
		filter.__CLASSNAME = true
	end
	local mt = getmetatable(self)
	setmetatable(self, {})
	local res = table.concat(serialize(self, filter, allow, engine.Savefile.current_save))
	setmetatable(self, mt)
	return res
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
