require "config"
require "engine.class"
require "engine.KeyCommand"

--- Handles key binds to "virtual" actions
module(..., package.seeall, class.inherit(engine.KeyCommand))

_M.binds_def = {}
_M.binds_remap = {}
_M.binds_loaded = {}

function _M:defineAction(t)
	assert(t.default, "no keybind default")
	assert(t.name, "no keybind name")
	t.desc = t.desc or t.name

	_M.binds_def[t.type] = t
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

function _M:init()
	engine.KeyCommand.init(self)
	self.virtuals = {}
	self.binds = {}

	-- Bind defaults
	for type, t in pairs(_M.binds_def) do
		for i, ks in ipairs(_M.binds_remap[type] or t.default) do
			self.binds[ks] = type
		end
	end
end

function _M:makeKeyString(sym, ctrl, shift, alt, meta, unicode)
	return ("sym:%s:%s:%s:%s:%s"):format(tostring(sym), tostring(ctrl), tostring(shift), tostring(alt), tostring(meta)), unicode and "uni:"..unicode
end

function _M:receiveKey(sym, ctrl, shift, alt, meta, unicode)
	local ks, us = self:makeKeyString(sym, ctrl, shift, alt, meta, unicode)
	print("[BIND]", sym, ctrl, shift, alt, meta, unicode and string.byte(unicode), " :=: ", ks, us, " ?=? ", self.binds[ks], us and self.binds[us])
	if self.binds[ks] and self.virtuals[self.binds[ks]] then
		self.virtuals[self.binds[ks]](sym, ctrl, shift, alt, meta, unicode)
		return
	elseif us and self.binds[us] and self.virtuals[self.binds[us]] then
		self.virtuals[self.binds[us]](sym, ctrl, shift, alt, meta, unicode)
		return
	end

	engine.KeyCommand.receiveKey(self, sym, ctrl, shift, alt, meta, unicode)
end

--- Adds a key/command combinaison
-- @param sym the key to handle
-- @param mods a table with the mod keys needed, i.e: {"ctrl", "alt"}
-- @param fct the function to call when the key is pressed
function _M:addBind(virtual, fct)
	self.virtuals[virtual] = fct
end

--- Adds a key/command combinaison
-- @param sym the key to handle
-- @param mods a table with the mod keys needed, i.e: {"ctrl", "alt"}
-- @param fct the function to call when the key is pressed
function _M:addBinds(t)
	for virtual, fct in pairs(t) do
		self:addBind(virtual, fct)
	end
end
