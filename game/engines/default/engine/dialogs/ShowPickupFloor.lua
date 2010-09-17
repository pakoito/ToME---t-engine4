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

module(..., package.seeall, class.inherit(engine.Dialog))

function _M:init(title, x, y, filter, action)
	self.x, self.y = x, y
	self.filter = filter
	self.action = action
	engine.Dialog.init(self, title or "Pickup", game.w * 0.8, game.h * 0.8, nil, nil, nil, core.display.newFont("/data/font/VeraMono.ttf", 12))

	self:generateList()

	self.sel = 1
	self.scroll = 1
	self.max = math.floor((self.ih - 5) / self.font_h) - 1

	self:keyCommands({
		_ASTERISK = function() while self:use() do end end,
		__TEXTINPUT = function(c)
			if c:find("^[a-z]$") then
				self.sel = util.bound(1 + string.byte(c) - string.byte('a'), 1, #self.list)
				self:use()
			end
		end,
	},{
		MOVE_UP = function() self.sel = util.boundWrap(self.sel - 1, 1, #self.list) self.scroll = util.scroll(self.sel, self.scroll, self.max) self.changed = true end,
		MOVE_DOWN = function() self.sel = util.boundWrap(self.sel + 1, 1, #self.list) self.scroll = util.scroll(self.sel, self.scroll, self.max) self.changed = true end,
		ACCEPT = function() self:use() end,
		EXIT = function() game:unregisterDialog(self) end,
	})
	self:mouseZones{
		{ x=2, y=5, w=350, h=self.font_h*self.max, fct=function(button, x, y, xrel, yrel, tx, ty)
			self.changed = true
			self.sel = util.bound(self.scroll + math.floor(ty / self.font_h), 1, #self.list)
			if button == "left" then self:use()
			elseif button == "right" then
			end
		end },
	}
end

function _M:used()
	self:generateList()
	if #self.list == 0 then
		game:unregisterDialog(self)
		return false
	end
	return true
end

function _M:use()
	if self.list[self.sel] then
		self.action(self.list[self.sel].object, self.list[self.sel].item)
	end
	return self:used()
end

function _M:generateList()
	-- Makes up the list
	local list = {}
	local idx = 1
	local i = 1
	while true do
		local o = game.level.map:getObject(self.x, self.y, idx)
		if not o then break end
		if not self.filter or self.filter(o) then
			list[#list+1] = { name=string.char(string.byte('a') + i - 1)..") "..o:getDisplayString()..o:getName(), color=o:getDisplayColor(), object=o, item=idx }
			i = i + 1
		end
		idx = idx + 1
	end
	self.list = list
	self.sel = 1
	self.changed = true
end

function _M:drawDialog(s)
	-- Description part
	self:drawHBorder(s, self.iw / 2, 2, self.ih - 4)

	local talentshelp = ([[Keyboard: #00FF00#up key/down key#FFFFFF# to select an object; #00FF00#enter#FFFFFF# to use.
Mouse: #00FF00#Left click#FFFFFF# to pickup.
]]):splitLines(self.iw / 2 - 10, self.font)

	local lines = {}
	local h = 2
	for i = 1, #talentshelp do
		s:drawColorStringBlended(self.font, talentshelp[i], self.iw / 2 + 5, h)
		h = h + self.font:lineSkip()
	end

	h = h + self.font:lineSkip()
	if self.list[self.sel] then
		lines = self.list[self.sel].object:getDesc():splitLines(self.iw / 2 - 10, self.font)
	else
		lines = {}
	end
	self:drawWBorder(s, self.iw / 2 + self.iw / 6, h - 0.5 * self.font:lineSkip(), self.iw / 6)
	for i = 1, #lines do
		s:drawColorStringBlended(self.font, lines[i], self.iw / 2 + 5, 2 + h)
		h = h + self.font:lineSkip()
	end

	-- Talents
	self:drawSelectionList(s, 2, 5, self.font_h, self.list, self.sel, "name", self.scroll, self.max, nil, nil, nil, self.iw / 2 - 5)
	self.changed = false
end
