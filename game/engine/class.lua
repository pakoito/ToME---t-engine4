module("class", package.seeall)

local base = _G

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

function inherit(base)
	return function(c)
		setmetatable(c, {__index=base})
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
		if type(k) == "table" then nk = clonerecurs(k) end
		if type(e) == "table" then ne = clonerecurs(e) end
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

-- ---------------------------------------------------------------------
-- ---------------------------------------------------------------------
-- LOAD & SAVE
-- ---------------------------------------------------------------------
-- ---------------------------------------------------------------------
local function basicSerialize(o)
	if type(o) == "number" or type(o) == "boolean" then
		return tostring(o)
	elseif type(o) == "function" then
		return string.format("%q", string.dump(o))
	else   -- assume it is a string
		return string.format("%q", o)
	end
end

local function serialize_data(outf, name, value, saved, filter)
	saved = saved or {}       -- initial value
	outf(name, " = ")
	if type(value) == "number" or type(value) == "string" or type(value) == "boolean" or type(value) == "function" then
		outf(basicSerialize(value), "\n")
	elseif type(value) == "table" then
		if saved[value] then    -- value already saved?
			outf(saved[value], "\n")  -- use its previous name
		else
			saved[value] = name   -- save name for next time
			outf("{}\n")     -- create a new table
			for k,v in pairs(value) do      -- save its fields
				if not filter[k] then
					local fieldname = string.format("%s[%s]", name, basicSerialize(k))
					serialize_data(outf, fieldname, v, saved, filter)
				end
			end
		end
	else
		error("cannot save a " .. type(value) .. " ("..name..")")
	end
end

local function serialize(data, filter)
	local tbl = {}
	local outf = function(...) for i,str in ipairs(arg) do table.insert(tbl, str) end end
	serialize_data(outf, "data", data, nil, filter)
	table.insert(tbl, "return data\n")
	return tbl
end

local function deserialize(string)
	local f = loadstring(string)
	setfenv(f, {})
	return f()
end

function _M:save(filter)
	filter = filter or {}
	filter.new = true
	return table.concat(serialize(self, filter))
end

function load(str)
	local obj = deserialize(str)
	if obj then
		setmetatable(obj, {__index=require(obj.__CLASSNAME)})
		if obj.loaded then obj:loaded() end
	end
	return obj
end
