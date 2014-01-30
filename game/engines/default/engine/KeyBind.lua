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

require "config"
require "engine.class"
require "engine.KeyCommand"

--- Handles key binds to "virtual" actions
module(..., package.seeall, class.inherit(engine.KeyCommand))

_M.binds_def = {}
_M.binds_remap = {}
_M.binds_loaded = {}
_M.bind_order = 1

function _M:defineAction(t)
	assert(t.default, "no keybind default")
	assert(t.name, "no keybind name")
	t.desc = t.desc or t.name

	t.order = _M.bind_order
	_M.binds_def[t.type] = t
	_M.bind_order = _M.bind_order + 1
end

--- Loads a list of keybind definitions
-- Keybind definitions are in /data/keybinds/. Modules can define new ones.
-- @param a string representing the keybind, separated by commas. I.e: "move,hotkeys,actions,inventory"
function _M:load(str)
	local defs = str:split(",")
	for i, def in ipairs(defs) do
		if not _M.binds_loaded[def] then
			local f, err = loadfile("/data/keybinds/"..def..".lua")
			if not f and err then error(err) end
			setfenv(f, setmetatable({
				defineAction = function(t) self:defineAction(t) end
			}, {__index=_G}))
			f()

			print("[KEYBINDER] Loaded keybinds: "..def)
			_M.binds_loaded[def] = true
		end
	end
end

--- Loads a keybinds remap
function _M:loadRemap(file)
	local f, err = loadfile(file)
	if not f and err then error(err) end
	local d = {}
	setfenv(f, d)
	f()

	for virtual, keys in pairs(d) do
		print("Remapping", virtual, keys)
		_M.binds_remap[virtual] = keys
	end
end

--- Saves a keybinds remap
function _M:saveRemap(file)
	local restore = false
	if not file then
		restore = fs.getWritePath()
		fs.setWritePath(engine.homepath)
		file = "keybinds2.cfg"
	end

	local f = fs.open(file, "w")

	local k1, k2, k3

	for virtual, keys in pairs(_M.binds_remap) do
		k1 = "nil"
		k2 = "nil"
		k3 = "nil"
		if keys[1] then
			k1 = ("%q"):format(keys[1])
		end
		if keys[2] then
			k2 = ("%q"):format(keys[2])
		end
		if keys[3] then
			k3 = ("%q"):format(keys[3])
		end
		f:write(("%s = {%s,%s,%s}\n"):format(virtual, k1, k2, k3))
	end

	f:close()

	if restore then
		fs.setWritePath(restore)
	end
end

--- Returns the binding table for the given type
function _M:getBindTable(type)
	return _M.binds_remap[type.type] or type.default
end

function _M:init()
	engine.KeyCommand.init(self)
	self.virtuals = {}
	self.use_unicode = false

	self:bindKeys()
end

--- Binds all virtuals to keys, either defaults or remapped ones
function _M:bindKeys()
	self.binds = {}
	-- Bind defaults
	for type, t in pairs(_M.binds_def) do
		for i, ks in ipairs(_M.binds_remap[type] or t.default) do
			self.binds[ks] = self.binds[ks] or {}
			self.binds[ks][type] = true
		end
	end
end

function _M:findBoundKeys(virtual)
	local bs = {}
	for ks, virt in pairs(self.binds) do
		if virt[virtual] then bs[#bs+1] = ks end
	end
	return unpack(bs)
end

function _M:makeKeyString(sym, ctrl, shift, alt, meta, unicode, key)
	return ("sym:%s:%s:%s:%s:%s"):format(tostring(self.sym_to_name[sym] or sym), tostring(ctrl), tostring(shift), tostring(alt), tostring(meta)), key and ("sym:=%s:%s:%s:%s:%s"):format(key, tostring(ctrl), tostring(shift), tostring(alt), tostring(meta)), unicode and "uni:"..unicode
end

function _M:makeGestureString(gesture)
	return ("gest:%s"):format(tostring(gesture))
end

function _M:makeMouseString(button, ctrl, shift, alt, meta)
	return ("mouse:%s:%s:%s:%s:%s"):format(tostring(button), tostring(ctrl), tostring(shift), tostring(alt), tostring(meta))
end

function _M:formatKeyString(ks)
	if not ks then return "--" end

	if ks:find("^uni:") then
		return ks:sub(5)
	elseif ks:find("^sym:") then
		local i, j, sym, ctrl, shift, alt, meta = ks:find("^sym:([^:]+):([a-z]+):([a-z]+):([a-z]+):([a-z]+)$")
		if not i then return "--" end

		ctrl = ctrl == "true" and true or false
		shift = shift == "true" and true or false
		alt = alt == "true" and true or false
		meta = meta == "true" and true or false
		if sym:sub(1, 1) == "=" then
			sym = sym:sub(2)
		else
			if tonumber(sym) then sym = tonumber(sym)
			else sym = _M[sym]
			end
			sym = core.key.symName(sym)
		end
		sym = sym:gsub("Keypad ", "k")

		local st = ""
		if ctrl then st = "C"..st end
		if shift then st = "S"..st end
		if alt then st = "A"..st end
		if meta then st = "M"..st end
		if st ~= "" then sym = st..""..sym end

		return sym
	elseif ks:find("^mouse:") then
		local i, j, sym, ctrl, shift, alt, meta = ks:find("^mouse:([a-zA-Z0-9]+):([a-z]+):([a-z]+):([a-z]+):([a-z]+)$")
		if not i then return "--" end

		ctrl = ctrl == "true" and true or false
		shift = shift == "true" and true or false
		alt = alt == "true" and true or false
		meta = meta == "true" and true or false
		sym = sym:gsub("button", "b")

		local st = ""
		if ctrl then st = "C"..st end
		if shift then st = "S"..st end
		if alt then st = "A"..st end
		if meta then st = "M"..st end
		if st ~= "" then sym = st..""..sym end

		return sym
	elseif ks:find("^gest:") then
		local i, j, sym = ks:find("^gest:([a-zA-Z0-9]+)$")
		if not i then return "--" end
		return sym
	end
end

function _M:receiveKey(sym, ctrl, shift, alt, meta, unicode, isup, key, ismouse)
	if unicode and not self.use_unicode then return end

	self:handleStatus(sym, ctrl, shift, alt, meta, unicode, isup)

	if self.ignore[sym] then return end

	if self.any_key then self.any_key(sym, ctrl, shift, alt, meta, unicode, isup, key) end

	local ks, kks, us
	if not ismouse then ks, kks, us = self:makeKeyString(sym, ctrl, shift, alt, meta, unicode, key)
	else ks = self:makeMouseString(sym, ctrl, shift, alt, meta) end
--	print(self, "[BIND]", sym, ctrl, shift, alt, meta, unicode, " :=: ", ks, kks, us, " ?=? ", self.binds[ks], kks and self.binds[kks], us and self.binds[us])
	if self.binds[ks] then
		for virt, _ in pairs(self.binds[ks]) do if self.virtuals[virt] then
			if isup and not _M.binds_def[virt].updown then return end
			self.virtuals[virt](sym, ctrl, shift, alt, meta, unicode, isup, key)
			return true
		end end
	elseif kks and self.binds[kks] then
		for virt, _ in pairs(self.binds[kks]) do if self.virtuals[virt] then
			if isup and not _M.binds_def[virt].updown then return end
			self.virtuals[virt](sym, ctrl, shift, alt, meta, unicode, isup, key)
			return true
		end end
	elseif us and self.binds[us] then
		for virt, _ in pairs(self.binds[us]) do if self.virtuals[virt] then
--			if isup and not _M.binds_def[virt].updown then return end
			self.virtuals[virt](sym, ctrl, shift, alt, meta, unicode, isup, key)
			return true
		end end
	end

	return engine.KeyCommand.receiveKey(self, sym, ctrl, shift, alt, meta, unicode, isup, key)
end

--- Allow receiving unicode events
function _M:unicodeInput(v)
	self.use_unicode = v
end

--- Reset all binds
function _M:reset()
	self.virtuals = {}
	engine.KeyCommand.reset(self)
end

--- Force a key to trigger
function _M:triggerVirtual(virtual)
	if not self.virtuals[virtual] then return end
	self.virtuals[virtual]()
end

--- Adds a key/command combination
-- @param sym the key to handle
-- @param mods a table with the mod keys needed, i.e: {"ctrl", "alt"}
-- @param fct the function to call when the key is pressed
function _M:addBind(virtual, fct)
	self.virtuals[virtual] = fct
end

--- Adds a key/command combination
-- @param sym the key to handle
-- @param mods a table with the mod keys needed, i.e: {"ctrl", "alt"}
-- @param fct the function to call when the key is pressed
function _M:addBinds(t)
	local later = {}
	for virtual, fct in pairs(t) do
		if type(fct) == "function" then
--			print("bind", virtual, fct)
			self:addBind(virtual, fct)
		else
			later[virtual] = fct
		end
	end
	for virtual, fct in pairs(later) do
		self:addBind(virtual, self.virtuals[fct])
	end
end

--- Removes a key/command combination
function _M:removeBind(virtual)
	self.virtuals[virtual] = nil
end
