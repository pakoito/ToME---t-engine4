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

require "engine.class"
require "engine.Dialog"
local KeyBind = require "engine.KeyBind"

module(..., package.seeall, class.inherit(engine.Dialog))

function _M:init(key_source)
	engine.Dialog.init(self, "Key bindings", 600, game.h / 1.2)

	self:generateList(key_source)

	self.key_source = key_source

	self.selcol = 1
	self.sel = 1
	self.scroll = 1
	self.max = math.floor((self.ih - 5) / self.font_h) - 1

	self:keyCommands({
	},{
		MOVE_UP = function() self.sel = util.boundWrap(self.sel - 1, 1, #self.list) self.scroll = util.scroll(self.sel, self.scroll, self.max) self.changed = true end,
		MOVE_DOWN = function() self.sel = util.boundWrap(self.sel + 1, 1, #self.list) self.scroll = util.scroll(self.sel, self.scroll, self.max) self.changed = true end,
		MOVE_LEFT = function() self.selcol = util.boundWrap(self.selcol - 1, 1, 2) self.changed = true end,
		MOVE_RIGHT = function() self.selcol = util.boundWrap(self.selcol + 1, 1, 2) self.changed = true end,
		ACCEPT = function() self:use() end,
		EXIT = function()
			game:unregisterDialog(self)
			self.key_source:bindKeys()
			KeyBind:saveRemap()
		end,
	})
	self:mouseZones{
		{ x=0, y=0, w=game.w, h=game.h, mode={button=true}, norestrict=true, fct=function(button) if button ~= "none" then game:unregisterDialog(self) end end},
		{ x=2, y=5, w=600, h=self.font_h*self.max, fct=function(button, x, y, xrel, yrel, tx, ty)
			if tx < 430 then
				self.selcol = 1
			else
				self.selcol = 2
			end
			self.sel = util.bound(self.scroll + math.floor(ty / self.font_h), 1, #self.list)
			self.changed = true
			if button == "left" then self:use()
			elseif button == "right" then
			end
		end },
	}
end

function _M:use()
	local t = self.list[self.sel]

	--
	-- Make a dialog to ask for the key
	--
	local title = "Press a key (or escape) for: "..t.name
	local font = self.font
	local w, h = font:size(title)
	local d = engine.Dialog.new(title, w + 8, h + 25, nil, nil, nil, font)
	d:keyCommands{__DEFAULT=function(sym, ctrl, shift, alt, meta, unicode)
		-- Modifier keys are not treated
		if sym == KeyBind._LCTRL or sym == KeyBind._RCTRL or
		   sym == KeyBind._LSHIFT or sym == KeyBind._RSHIFT or
		   sym == KeyBind._LALT or sym == KeyBind._RALT or
		   sym == KeyBind._LMETA or sym == KeyBind._RMETA then
			return
		end

		if sym == KeyBind._BACKSPACE then
			t["bind"..self.selcol] = nil
			KeyBind.binds_remap[t.type] = KeyBind.binds_remap[t.type] or t.k.default
			KeyBind.binds_remap[t.type][self.selcol] = nil
		elseif sym ~= KeyBind._ESCAPE then
			local ks = KeyBind:makeKeyString(sym, ctrl, shift, alt, meta, unicode)
			print("Binding", t.name, "to", ks)
			t["bind"..self.selcol] = ks

			KeyBind.binds_remap[t.type] = KeyBind.binds_remap[t.type] or t.k.default
			KeyBind.binds_remap[t.type][self.selcol] = ks
		end
		game:unregisterDialog(d)
	end}

	d:mouseZones{ norestrict=true,
		{ x=0, y=0, w=game.w, h=game.h, fct=function(button, x, y, xrel, yrel, tx, ty)
			if xrel or yrel then return end
			if button == "left" then return end

			local ks = KeyBind:makeMouseString(
				button,
				core.key.modState("ctrl") and true or false,
				core.key.modState("shift") and true or false,
				core.key.modState("alt") and true or false,
				core.key.modState("meta") and true or false
			)
			print("Binding", t.name, "to", ks)
			t["bind"..self.selcol] = ks

			KeyBind.binds_remap[t.type] = KeyBind.binds_remap[t.type] or t.k.default
			KeyBind.binds_remap[t.type][self.selcol] = ks
			game:unregisterDialog(d)
		end },
	}

	d.drawDialog = function(self, s)
		s:drawColorStringBlendedCentered(self.font, self.selcol == 1 and "Bind key" or "Bind alternate key", 2, 2, self.iw - 2, self.ih - 2)
	end
	game:registerDialog(d)
end

function _M:generateList(key_source)
	local l = {}

	for virtual, t in pairs(KeyBind.binds_def) do
		if key_source.virtuals[virtual] then
			l[#l+1] = t
		end
	end
	table.sort(l, function(a,b)
		if a.group ~= b.group then
			return a.group < b.group
		else
			return a.order < b.order
		end
	end)

	-- Makes up the list
	local list = {}
	local i = 0
	for _, k in ipairs(l) do
		local binds = KeyBind:getBindTable(k)
		list[#list+1] = {
			k = k,
			name = k.name,
			type = k.type,
			bind1 = binds[1],
			bind2 = binds[2],
			b1 = function(v) return KeyBind:formatKeyString(v.bind1) end,
			b2 = function(v) return KeyBind:formatKeyString(v.bind2) end,
		}
		i = i + 1
	end
	self.list = list
end

function _M:drawDialog(s)
	local col = {155,155,0}
	local selcol = {255,255,0}

	self:drawSelectionList(s, 2,   5, self.font_h, self.list, self.sel, "name", self.scroll, self.max)
	self:drawSelectionList(s, 230, 5, self.font_h, self.list, self.sel, "b1", self.scroll, self.max, col, self.selcol == 1 and selcol or col)
	self:drawSelectionList(s, 430, 5, self.font_h, self.list, self.sel, "b2", self.scroll, self.max, col, self.selcol == 2 and selcol or col)
end
